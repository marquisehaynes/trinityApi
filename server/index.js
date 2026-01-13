import * as models from './models/index.js';
import  * as util from './util/index.js'; 
import  * as canvasUtil from './canvasUtil/index.js'; 
import express	   from 'express';
import fs		   		 from 'fs';
import pg		   		 from 'pg';
import { Issuer } from 'openid-client';

const keycloakIssuer = await Issuer.discover('http://keycloak/realms/trinity');

const appClient = new keycloakIssuer.Client({
  client_id: 'backend-client',
  client_secret: 'secret', // confidential client
  redirect_uris: ['http://trinityedu.ddns.net:3000/api/auth/callback'],
  response_types: ['code']
});

const app = new express();
app.use(express.json());
const PORT = 3000;
const dbConfig	 = JSON.parse( fs.readFileSync( 'config.json','utf8' ) ).database;
const pgPool = new pg.Pool({
	user : dbConfig.username,
	password : dbConfig.password,
	host : dbConfig.host,
	port : dbConfig.port,
	database : dbConfig.dbName,
	max	: 25,
	idleTimeoutMillis : 20000,
	connectionTimeoutMillis : 20000,
});

app.listen( PORT, () => {
    console.log( "Server running on port 3000" );
   });

function requireAuth(req, res, next) {
  if (!req.session.user) {
    return res.sendStatus(401);
  }
  next();
}

app.get( '/api/query', requireAuth, async ( req, res ) => {
	const payload = req.body;
	const query = `SELECT * FROM ${payload.objectType}` +  (payload.recordId ? ` WHERE id = '${payload.recordId}'` : '');
	const client = await pgPool.connect();
	try{
		const queryRes = await client.query(query);
		res.send( queryRes.rows.length > 0 ? {
			"rowCount" : queryRes.rowCount,
			"rows": queryRes.rows
		} : [] );   
	}
	catch(err){
		res.status(400).send( err ); 
	}
	finally{
		client.release();
	}
});

app.get('/api/sync', async (req, res) => {
	//const client = await pgPool.connect();

	
    res.status(200).send( await canvasUtil.syncCanvasData((await pgPool.connect())) );
});

app.get('/api/auth/me', (req, res) => {
  if (!req.session.user) {
    return res.sendStatus(401);
  }
  res.json(req.session.user);
});

app.get('/api/auth/login', (req, res) => {
  const url = appClient.authorizationUrl({
    scope: 'openid profile email',
    state: crypto.randomUUID()
  });
  res.redirect(url);
});

app.get('/api/auth/callback', async (req, res) => {
  const params = client.callbackParams(req);
  const tokenSet = await client.callback(
    'https://trinityedu.net:3000/api/auth/callback',
    params
  );

  req.session.user = {
    sub: tokenSet.claims().sub,
    email: tokenSet.claims().email,
    roles: tokenSet.claims().realm_access?.roles
  };

  req.session.tokens = tokenSet; // store securely
  res.redirect('/');
});