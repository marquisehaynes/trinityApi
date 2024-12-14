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

app.get( '/syncall', async ( req, res ) => {
    const courseArray = await models.courseModel.getAllCoursesFromCanvas(pgPool);
	console.log('Course data processed and upserted successfully!');
	const studentPromises = await models.studentModel.getStudentsFromCanvas(courseArray);
	const assGroupPromises = await models.assignmentGroupModel.getAssignmentGroupsFromCanvas(courseArray);
	Promise.allSettled(assGroupPromises)
	.then( async function(results) {
		const resArray = [];
		for(const res of results){
			if(Array.isArray(res['value'])){
				for(const resInstance of res['value'] ){
					resArray.push(resInstance);
				}	
			}					
		}
		const assGrpArray = await models.assignmentGroupModel.convertJSONtoArray(resArray);
		return await models.assignmentGroupModel.processAssignmentGroups(assGrpArray, pgPool);
 	})
	.then( results => {
		res.send(results);
	})
	/*
	Promise.allSettled(studentPromises)
	.then( async function(results) {
		const resArray = [];
		for(const res of results){
			for(const resInstance of res['value'] ){
				resArray.push(resInstance);
			}			
		}
		const studentData = await models.studentModel.processStudents(resArray, pgPool);
		console.log('done processing students');
		return studentData;
	})
	.then(processedRes =>{	
		res.send(processedRes);	
	});
	*/
	
	
});

