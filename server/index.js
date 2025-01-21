import * as models from './models/index.js';
import  * as util from './util/index.js'; 
import  * as canvasUtil from './canvasUtil/index.js'; 
import express	   from 'express';
import fs		   		 from 'fs';
import pg		   		 from 'pg';

const app				 = new express();
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

app.get( '/query', async ( req, res ) => {
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

app.get('/sync', async (req, res) => {
	//const client = await pgPool.connect();

	
    res.status(200).send( await canvasUtil.syncCanvasData((await pgPool.connect())) );
});

