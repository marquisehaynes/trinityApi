import * as models from './models/index.js';
import  * as util from './util/index.js'; 
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
const objPfx = await util.getObjectPrefixes(pgPool);

app.listen( PORT, async () => {
	let checkBool = true;
	let failReason;
	if(Object.getPrototypeOf(objPfx) === Map.prototype){
			checkBool = objPfx.size > 0;
			failReason = objPfx.size > 0 ? null : 'No Prefixes returned';
	}
	else{
		checkBool = false;
		failReason = `Prefix call didn't return a Map`;
	}
	console.log('Loaded Object Keys: '+  checkBool + (!checkBool ? (' ' + failReason) : ''));
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


app.get( '/testQuery', async ( req, res ) => {
    const client = await pgPool.connect();
	const ret = (await client.query(`SELECT gen_id from gen_id('processqueue')`)).rows[0].gen_id;
    await client.release();
    res.send(ret);    
});

app.get( '/testPost', async ( req, res ) => {
	const client = await pgPool.connect();
	const nextIdQry = await client.query(`SELECT gen_id from gen_id('processqueue');`);
	const nextId = nextIdQry.rows[0].gen_id;
	const start = new Date().toISOString();
	console.log(nextId);
	
	const queryStr =  `INSERT INTO processqueue ( id, processname, processstatus, processstarttime, targetobject, totalbatches, failedbatches) 
				VALUES ( '${nextId}', 'testProcess','Running', '${start}', 'All', 1, 0 )
				RETURNING id
				`;
	const result = await client.query(queryStr);
	await client.release();

	res.status(200).send(result.rows[0].id);
});

app.get( '/syncall', async ( req, res ) => {
	const pq1 = new models.processQueueProcessModel('DataSync', 'All',1);
	await pq1.post(pgPool);
    try {
		const loadStatuses = await util.getRecentLoadStatus(pgPool);
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
		let courseStudentLoadResult;
		let assGrpLoadResult;
		let assLoadResult;
		let submissionLoadResult;
		let pq = new models.processQueueProcessModel('Retrieve Canvas Data', 'All',1);
		await pq.post(pgPool);
		
		try {
			const courseArray = await models.courseModel.getAllCoursesFromCanvas(pgPool,false);
			for(const course of courseArray){
				const courseId = course['canvasid'];
				const assGrpRequestDef = util.getCanvasRequestDefinition('assignmentgroups', new Map([ ['courseId', courseId] ]));
				const assRequestDef = await util.getCanvasRequestDefinition('assignments', new Map([ ['courseId', courseId] ]));
				const studentRequestDef = await util.getCanvasRequestDefinition('students', new Map([ ['courseId', courseId] ]));
				const submissionRequestDef = await util.getCanvasRequestDefinition('submissions', new Map([ ['courseId', courseId] ]));
				const assGrpData = loadStatuses.includes('assignmentgroup') ? '[]' : await util.makeHttpsRequest(assGrpRequestDef); 			
				const assData = loadStatuses.includes('assignment') ? '[]' : await util.makeHttpsRequest(assRequestDef); 
				const stdData = loadStatuses.includes('student') ? '[]' : await util.makeHttpsRequest(studentRequestDef); 
				const submissionData = loadStatuses.includes('submission') ? '[]' : await util.makeHttpsRequest(submissionRequestDef); 
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
			let assIdLst;
			let csIdLst;
			if(!loadStatuses.includes('assignmentgroup')){
				finalAssGrpArray = await models.assignmentGroupModel.convertJSONtoArray(assGrpArray);
				finalAssArray = await models.assignmentModel.convertJSONtoArray(assArray);
				assIdLst = finalAssArray.map(e => e.canvasid);
			}
			if(!loadStatuses.includes('student')){
				finalStudentArray = await models.studentModel.convertJSONtoArray(courseStudentArray);
			}
			if(!loadStatuses.includes('coursestudent')){
				finalCourseStudentArray = await models.courseStudentModel.convertJSONtoArray(courseStudentArray);
				csIdLst = finalCourseStudentArray.map(e => e.uniqueid);
			}
			if(!loadStatuses.includes('assignmentsubmission')){
				const client = await pgPool.connect();				
				assIdLst = assIdLst ? assIdLst : (await client.query('SELECT canvasid from assignment')).rows.map(e => { return e.canvasid; } );
				csIdLst = csIdLst ? csIdLst : (await client.query('SELECT uniqueid from coursestudent')).rows.map(e => { return e.uniqueid; } );
				await client.release();
				finalSubmissionsArray = await models.submissionModel.convertJSONtoArray(subArray).filter(e => { return assIdLst.includes(e.assignmentid) && csIdLst.includes(e.coursestudentid); });
			
			}
			console.log('Data Retrieval Complete!');
			courseRetStatus = true;
			pq.processendtime = new Date().toISOString();
			pq.processstatus = 'Completed';
		} 
		catch (error) {
			console.log('Data retrieval error: ', error);
			pq.processendtime = new Date().toISOString();
			pq.processstatus = 'Failed';
			pq.failedbatches = 1;
			pq.failuremessage = JSON.stringify(error);

			pq1.failuremessage = JSON.stringify(error);
			pq1.processendtime = new Date().toISOString();
			pq1.processstatus = 'Failed';
			pq1.post(pgPool);
		}
		finally{
			await pq.post(pgPool);
			if(courseRetStatus){				
				pq = new models.processQueueProcessModel( 'Load Data', 'Student', Array.isArray(finalStudentArray) ? finalStudentArray.length : 0 );
				await pq.post(pgPool);
				try {
					if(loadStatuses.includes('student')){
						console.log('Student Load Skipped!');
						pq.processendtime = new Date().toISOString();
						pq.processstatus = 'Skipped';
						studentLoadResult = 'Skipped';
					}
					else{
						studentLoadResult = await util.upsertJsonToDb(finalStudentArray, 'student', models.studentModel.columns, models.studentModel.conflictColumn, pgPool, objPfx);
						console.log('Student Load Complete!');
						pq.processendtime = new Date().toISOString();
						pq.processstatus = 'Completed';
					}					
				} 
				catch (error) {
					pq.processendtime = new Date().toISOString();
					pq.processstatus = 'Failed';
					pq.failuremessage = JSON.stringify(error);
					pq.failedbatches = finalStudentArray.length;
					console.log('Student Load Failed!');
				}
				finally{
					pq.failedbatches = studentLoadResult != 'Skipped' ? studentLoadResult.results.map(e => e.success == false).length : 0;
					await pq.post(pgPool);
					pq = new models.processQueueProcessModel( 'Load Data', 'CourseStudent', Array.isArray(finalCourseStudentArray) ? finalCourseStudentArray.length : 0);
					await pq.post(pgPool);
					try {
						if(loadStatuses.includes('coursestudent')){
							console.log('CourseStudent Load Skipped!');
							pq.processendtime = new Date().toISOString();
							pq.processstatus = 'Skipped';
							courseStudentLoadResult = 'Skipped';
						}
						else{
							courseStudentLoadResult = await util.upsertJsonToDb(finalCourseStudentArray, 'coursestudent', models.courseStudentModel.columns, models.courseStudentModel.conflictColumn, pgPool, objPfx);
							console.log('CourseStudent Load Complete!');
							pq.processendtime = new Date().toISOString();
							pq.processstatus = 'Completed';
						}						
					} 
					catch (error) {
						pq.processendtime = new Date().toISOString();
						pq.processstatus = 'Failed';
						pq.failuremessage = JSON.stringify(error);
						pq.failedbatches = finalCourseStudentArray.length;
						console.log('CourseStudent Load Failed!');
					} 
					finally{
						pq.failedbatches = courseStudentLoadResult != 'Skipped' ? courseStudentLoadResult.results.map(e => e.success == false).length : 0;
						await pq.post(pgPool);
						pq = new models.processQueueProcessModel( 'Load Data', 'AssignmentGroup', Array.isArray(finalAssGrpArray) ? finalAssGrpArray.length : 0 );
						await pq.post(pgPool);
						try {
							if(loadStatuses.includes('assignmentgroup')){
								console.log('AssignmentGroup Load Skipped!');
								pq.processendtime = new Date().toISOString();
								pq.processstatus = 'Skipped';
								assGrpLoadResult = 'Skipped';
							}
							else{
								assGrpLoadResult = await util.upsertJsonToDb(finalAssGrpArray, 'assignmentgroup', models.assignmentGroupModel.columns, models.assignmentGroupModel.conflictColumn, pgPool, objPfx);
								console.log('AssignmentGroup Load Complete!');
								pq.processendtime = new Date().toISOString();
								pq.processstatus = 'Completed';
							}							
						} catch (error) {
							pq.processendtime = new Date().toISOString();
							pq.processstatus = 'Failed';
							pq.failuremessage = JSON.stringify(error);
							pq.failedbatches = finalAssGrpArray.length;
							console.log('AssignmentGroup Load Failed!');
						}
						finally{
							pq.failedbatches = assGrpLoadResult != 'Skipped' ? assGrpLoadResult.results.map(e => e.success == false).length : 0;
							await pq.post(pgPool);
							pq = new models.processQueueProcessModel( 'Load Data', 'Assignment', Array.isArray(finalAssArray) ? finalAssArray.length : 0 );
							await pq.post(pgPool);
							try {
								if(loadStatuses.includes('assignment')){
									console.log('Assignment Load Skipped!');
									pq.processendtime = new Date().toISOString();
									pq.processstatus = 'Skipped';
									assLoadResult = 'Skipped';
								}
								else{
									assLoadResult = await util.upsertJsonToDb(finalAssArray, 'assignment', models.assignmentModel.columns, models.assignmentModel.conflictColumn, pgPool,objPfx);
									console.log('Assignment Load Complete!');
									pq.processendtime = new Date().toISOString();
									pq.processstatus = 'Completed';
								}								
							} 
							catch (error) {
								pq.processendtime = new Date().toISOString();
								pq.processstatus = 'Failed';
								pq.failuremessage = JSON.stringify(error);
								pq.failedbatches = finalAssArray.length;
								console.log('Assignment Load Failed!');
							}
							finally{
								pq.failedbatches = assLoadResult != 'Skipped' ? assLoadResult.results.map(e => e.success == false).length : 0;
								await pq.post(pgPool);
								pq = new models.processQueueProcessModel( 'Load Data', 'AssignmentSubmission', Array.isArray(finalSubmissionsArray) ? finalSubmissionsArray.length : 0 );
								await pq.post(pgPool);
								try {
									if(loadStatuses.includes('assignmentsubmission')){
										console.log('Submission Load Skipped!');
										pq.processendtime = new Date().toISOString();
										pq.processstatus = 'Skipped';
										submissionLoadResult = 'Skipped';
									}
									else{
										submissionLoadResult = await util.upsertJsonToDb(finalSubmissionsArray, 'assignmentsubmission', models.submissionModel.columns, models.submissionModel.conflictColumn, pgPool,objPfx);
										console.log('Submission Load Complete!');
										pq.processendtime = new Date().toISOString();
										pq.processstatus = 'Completed';
									}									
								} 
								catch (error) {
									pq.processendtime = new Date().toISOString();
									pq.processstatus = 'Failed';
									pq.failuremessage = JSON.stringify(error);
									pq.failedbatches = finalSubmissionsArray.length;
									console.log('Submission Load Failed!');
								}
								finally{
									pq.failedbatches = submissionLoadResult != 'Skipped' ? submissionLoadResult.results.map(e => e.success == false).length : 0;
									await pq.post(pgPool);
									const retMap = {
										'course' : true,
										'assignmentGroup' : Array.isArray(assGrpLoadResult.results) ? assGrpLoadResult.status : assGrpLoadResult,
										'assignment' : Array.isArray(assLoadResult.results) ? assLoadResult.status : assGrpLoadResult,
										'student' : Array.isArray(studentLoadResult.results) ? studentLoadResult.status : studentLoadResult,
										'courseStudent' : Array.isArray(courseStudentLoadResult.results) ? courseStudentLoadResult.status : courseStudentLoadResult,
										'submission' : Array.isArray(submissionLoadResult.results) ? submissionLoadResult.status : submissionLoadResult
									};
									let resBool = true;
									for(const key of Object.keys(retMap)){
										const tmp = retMap[key] === true || retMap[key] === 'Skipped';
										resBool = resBool && tmp;
									}
									pq1.processendtime = new Date().toISOString();
									pq1.processstatus = 'Completed';
									pq1.post(pgPool);
									// Send the response
									res.status(200).send(resBool);
								}								
							}							
						}
					}					
				}
			}
		}
    } 
	catch (error) {
        console.error('Error during the sync operation:', error);
        res.status(500).send('Internal Server Error');
		pq1.failuremessage = JSON.stringify(error);
		pq1.processendtime = new Date().toISOString();
		pq1.processstatus = 'Failed';
		pq1.post(pgPool);
    }
});

