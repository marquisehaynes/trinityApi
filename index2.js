import * as models from './models/index.js';    
import https	     from 'https';
import express	   from 'express';
import fs		   		 from 'fs';
import pg		   		 from 'pg';
import Parser	   	 from 'json2csv';

const CopyStream = import( 'pg-copy-streams' );
const app				 = new express();
const dbConfig	 = JSON.parse( fs.readFileSync( 'config.json','utf8' ) ).database;
const pgPool = new pg.Pool({
	user										: dbConfig.username,
	password								: dbConfig.password,
	host										: dbConfig.host,
	port										: dbConfig.port,
	database								: dbConfig.dbName,
	max											: 25,
	idleTimeoutMillis				: 20000,
	connectionTimeoutMillis : 20000,
});

app.listen( 3000, () => {
    console.log( "Server running on port 3000" );
   });

app.get( '/syncall', ( req, res ) => {
    models.courseModel.getAllCoursesFromCanvas(pgPool);
});

