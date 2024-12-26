import * as models from './models/index.js';
import  * as util from './util/index.js'; 
import express	   from 'express';
import fs		   		 from 'fs';
import pg		   		 from 'pg';

const app				 = new express();
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

app.listen( 3000, () => {
    console.log( "Server running on port 3000" );
   });

app.get( '/syncall', async ( req, res ) => {
    try {
		const assGrpArray = [];
		const assArray = [];
		const courseStudentArray = [];
		const subArray = [];
		let finalAssGrpArray;
		let finalAssArray;
		let finalStudentArray;
		let finalCourseStudentArray;
		let finalSubmissionsArray;
		let courseRetStatus =false;
		let studentLoadResult;
		const pq = new models.processQueueProcessModel(null, 'Retrieve Canvas Data', 'Running', Date.now(), null, 'All',1);
		pq.postToDb(pgPool);
		try {
			const courseArray = await models.courseModel.getAllCoursesFromCanvas(pgPool);
			for(const course of courseArray){
				const courseId = course['canvasid'];
				const assGrpRequestDef = util.getCanvasRequestDefinition('assignmentgroups', new Map([ ['courseId', courseId] ]));
				const assRequestDef = await util.getCanvasRequestDefinition('assignments', new Map([ ['courseId', courseId] ]));
				const studentRequestDef = await util.getCanvasRequestDefinition('students', new Map([ ['courseId', courseId] ]));
				const submissionRequestDef = await util.getCanvasRequestDefinition('submissions', new Map([ ['courseId', courseId] ]));
				const assGrpData = await util.makeHttpsRequest(assGrpRequestDef); 			
				const assData = await util.makeHttpsRequest(assRequestDef); 
				const stdData = await util.makeHttpsRequest(studentRequestDef); 
				const submissionData = await util.makeHttpsRequest(submissionRequestDef); 
				const parsedAssignments = JSON.parse(assData);
				const parsedAssignmentGroups = JSON.parse(assGrpData);
				const parsedCourseStudents = JSON.parse(stdData);
				const parsedSubmissions = JSON.parse(submissionData);
				
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
				for(const sub of parsedSubmissions.filter( s => s["user"]["name"] != 'Test Student')){
					sub["courseid"] = courseId;
					sub["coursestudentid"] = courseId + '_' + sub["user_id"];
					subArray.push(sub);
				}
			}
			finalAssGrpArray = await models.assignmentGroupModel.convertJSONtoArray(assGrpArray);
			finalAssArray = await models.assignmentModel.convertJSONtoArray(assArray);
			const assIdLst = finalAssArray.map(e => e.canvasid);
			finalStudentArray = await models.studentModel.convertJSONtoArray(courseStudentArray);
			finalCourseStudentArray = await models.courseStudentModel.convertJSONtoArray(courseStudentArray);
			const csIdLst = finalCourseStudentArray.map(e => e.uniqueid);
			finalSubmissionsArray = await models.submissionModel.convertJSONtoArray(subArray).filter(e => { return assIdLst.includes(e.assignmentid) && csIdLst.includes(e.coursestudentid); });
			console.log('Data Retrieval Complete!');
			pq.processendtime = Date.now();
			pq.processstatus = 'Complete';
			courseRetStatus = true;
		} 
		catch (error) {
			pq.processendtime = Date.now();
			pq.processstatus = 'Failed';
			pq.failedbatches = 1;
			pq.failuremessage = error;
		}
		finally{
			if(courseRetStatus){
				pq.postToDb(pgPool);
				pq = new models.processQueueProcessModel(null, 'Load Data', 'Running', Date.now(), null, 'Student', finalStudentArray.length);
				pq.postToDb(pgPool);
				try {
					studentLoadResult = await util.upsertJsonToDb(finalStudentArray, 'student', models.studentModel.columns, models.studentModel.conflictColumn, pgPool);
					console.log('Student Load Complete!');
					pq.processendtime = Date.now();
					pq.processstatus = 'Complete';
				} 
				catch (error) {
					pq.processendtime = Date.now();
					pq.processstatus = 'Failed';
					pq.failuremessage = error;
					pq.failedbatches = finalStudentArray.length;
					console.log('Student Load Failed!');
				}
				finally{
					pq.failedbatches = studentLoadResult.results.map(e => e.success == false);
					pq.postToDb(pgPool);
					pq = new models.processQueueProcessModel(null, 'Load Data', 'Running', Date.now(), null, 'CourseStudent', finalStudentArray.length);
					pq.postToDb(pgPool);
				}
			}
		}
        

		
		
		
		const courseStudentLoadResult = await util.upsertJsonToDb(finalCourseStudentArray, 'coursestudent', models.courseStudentModel.columns, models.courseStudentModel.conflictColumn, pgPool);
		console.log('CourseStudent Load Complete!');
		const assGrpLoadResult = await util.upsertJsonToDb(finalAssGrpArray, 'assignmentgroup', models.assignmentGroupModel.columns, models.assignmentGroupModel.conflictColumn, pgPool);
		console.log('Assignment Group Load Complete!');
		const assLoadResult = await util.upsertJsonToDb(finalAssArray, 'assignment', models.assignmentModel.columns, models.assignmentModel.conflictColumn, pgPool);
		console.log('Assignment Load Complete!');
		const submissionLoadResult = await util.upsertJsonToDb(finalSubmissionsArray, 'assignmentsubmission', models.submissionModel.columns, models.submissionModel.conflictColumn, pgPool);
		console.log('Submission Load Complete!');
		const retMap = {
			'course' : true,
			'assignmentGroup' : assGrpLoadResult,
			'assignment' : assLoadResult,
			'student' : studentLoadResult,
			'courseStudent' : courseStudentLoadResult,
			'submission' : submissionLoadResult
		};
        // Send the response
        res.send(retMap);

    } catch (error) {
        console.error('Error during the sync operation:', error);
        res.status(500).send('Internal Server Error');
    }	
});

