import * as models from './models/index.js';
import  * as util from './util/index.js'; 
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
        const assGrpArray = [];
		const assArray = [];
		const courseStudentArray = [];
		for(const course of courseArray){
			const courseId = course['canvasid'];
			const assGrpRequestDef = util.getCanvasRequestDefinition('assignmentgroups', new Map([ ['courseId', courseId] ]));
			const assRequestDef = await util.getCanvasRequestDefinition('assignments', new Map([ ['courseId', courseId] ]));
			const studentRequestDef = await util.getCanvasRequestDefinition('students', new Map([ ['courseId', courseId] ]));
			const assGrpData = await util.makeHttpsRequest(assGrpRequestDef); 			
			const assData = await util.makeHttpsRequest(assRequestDef); 
			const studentRequestData = await util.makeHttpsRequest(studentRequestDef); 
			const parsedAssignments = JSON.parse(assData);
			const parsedAssignmentGroups = JSON.parse(assGrpData);
			const parsedCourseStudents = JSON.parse(studentRequestData);
			
			for(const ag of parsedAssignmentGroups){
				ag.courseId = courseId;
				assGrpArray.push(ag);
			}
			
			for(const a of parsedAssignments){
				a.courseid = courseId;
				assArray.push(a);
			}
			
			for(const std of parsedCourseStudents){
				if (std['role'] == 'StudentEnrollment' && std['user']['name'] != 'Test Student') {
					courseStudentArray.push(std);
				}
			}
			
		}
		console.log('retrieved assignment groups!');	
		console.log('retrieved assignments!');
		console.log('retrieved students!');
		const finalAssGrpArray = await models.assignmentGroupModel.convertJSONtoArray(assGrpArray);
		console.log('converted assignment groups!');
		const finalAssArray = await models.assignmentModel.convertJSONtoArray(assArray);
		console.log('converted assignments!');
		const finalStudentArray = await models.studentModel.convertJSONtoArray(courseStudentArray);
		console.log('converted students!');
		const finalCourseStudentArray = await models.courseStudentModel.convertJSONtoArray(courseStudentArray);
		console.log('converted courseStudents!');
		
		const retMap = {
			'course' : courseArray,
			'assignmentGroup' : finalAssGrpArray,
			'assignment' : finalAssArray,
			'student' : finalStudentArray,
			'courseStudent' : finalCourseStudentArray
		};

		/*
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
		*/
        // Send the response
        res.send(courseStudentArray);

    } catch (error) {
        console.error('Error during the sync operation:', error);
        res.status(500).send('Internal Server Error');
    }	
});

