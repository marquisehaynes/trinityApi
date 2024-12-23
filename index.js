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
		const assGrpData =  await models.assignmentGroupModel.processAssignmentGroups(assGrpArray, pgPool);        
        console.log('Assignment groups processed successfully!');

		const assPromises = await models.assignmentModel.getAssignmentFromCanvas(courseArray);
		const assResults = await Promise.allSettled(assPromises);
		const assResArray = assResults.flatMap(res => Array.isArray(res['value']) ? res['value'] : []);
		const assArray = await models.assignmentModel.convertJSONtoArray(assResArray);
		const assData = await models.assignmentModel.processAssignments(assArray, pgPool);
		console.log('Assignments processed successfully!');
		
		const studentPromises = await models.studentModel.getStudentsFromCanvas(courseArray);
		const studentResults = await Promise.allSettled(studentPromises);
		const studentResArray = studentResults.flatMap(res => Array.isArray(res['value']) ? res['value'] : []);
		const studentData = await models.studentModel.processStudents(studentResArray, pgPool);
		console.log('Students and CourseStudents processed successfully!');

		const submissionPromises = await models.submissionModel.getSubmissionsFromCanvas(assData);
		const submissionResults = await Promise.allSettled(submissionPromises);
		//const submissionResArray = submissionResults.flatMap(res => Array.isArray(res['value']) ? res['value'] : []);

        // Send the response
        res.send(submissionResults);

    } catch (error) {
        console.error('Error during the sync operation:', error);
        res.status(500).send('Internal Server Error');
    }	
});

