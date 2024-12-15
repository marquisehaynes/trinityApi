import * as models from './models/index.js';
import express	   from 'express';
import fs		   		 from 'fs';
import pg		   		 from 'pg';

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
    try {
        const courseArray = await models.courseModel.getAllCoursesFromCanvas(pgPool);
        console.log('Course data processed and upserted successfully!');
               
        const assGroupPromises = await models.assignmentGroupModel.getAssignmentGroupsFromCanvas(courseArray);
		const assGrpResults = await Promise.allSettled(assGroupPromises);
		const assGrpResArray = assGrpResults.flatMap(res => Array.isArray(res['value']) ? res['value'] : []);
		const assGrpArray = await models.assignmentGroupModel.convertJSONtoArray(assGrpResArray);
		await models.assignmentGroupModel.processAssignmentGroups(assGrpArray, pgPool);        
        console.log('Assignment groups processed successfully!');
		
		const studentPromises = await models.studentModel.getStudentsFromCanvas(courseArray);
		const studentResults = await Promise.allSettled(studentPromises);
		const studentResArray = studentResults.flatMap(res => Array.isArray(res['value']) ? res['value'] : []);
		const studentData = await models.studentModel.processStudents(studentResArray, pgPool);
		console.log('Students and CourseStudents processed successfully!');
		
        // Send the response
        res.send(assGrpArray);

    } catch (error) {
        console.error('Error during the sync operation:', error);
        res.status(500).send('Internal Server Error');
    }
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

