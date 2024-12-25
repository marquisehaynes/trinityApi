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
        const assGrpArray = [];
		const assArray = [];
		const courseStudentArray = [];
		const subArray = [];
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
			for(const sub of parsedSubmissions){
				sub["courseid"] = courseId;
				sub["coursestudentid"] = courseId + '_' + sub["user_id"];
				subArray.push(sub);
			}
			
		}
		const finalAssGrpArray = await models.assignmentGroupModel.convertJSONtoArray(assGrpArray);
		const finalAssArray = await models.assignmentModel.convertJSONtoArray(assArray);
		const finalStudentArray = await models.studentModel.convertJSONtoArray(courseStudentArray);
		const finalCourseStudentArray = await models.courseStudentModel.convertJSONtoArray(courseStudentArray);
		const finalSubmissionsArray = await models.submissionModel.convertJSONtoArray(subArray);
		const retMap = {
			'course' : courseArray,
			'assignmentGroup' : finalAssGrpArray,
			'assignment' : finalAssArray,
			'student' : await models.studentModel.processStudents(finalStudentArray, pgPool),
			'courseStudent' : finalCourseStudentArray,
			'submission' : finalSubmissionsArray
		};

        // Send the response
        res.send(retMap);

    } catch (error) {
        console.error('Error during the sync operation:', error);
        res.status(500).send('Internal Server Error');
    }	
});

