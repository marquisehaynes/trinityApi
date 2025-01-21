import * as models from '../models/index.js';
import  * as util from '../util/index.js';

export async function syncCanvasData(client) {
   
    //#region VariableInit
    const objArr = [ 'course', 'student', 'coursestudent', 'assignmentgroup', 'assignment', 'assignmentsubmission' ];
    const currentData = await util.getCurrentDbData(client, objArr);	
    const canvasData = {};
    const loadStatuses = await util.getRecentLoadStatus(client);
    const loadStatusMap = {
        course : loadStatuses.includes('course'),
        student : loadStatuses.includes('student'),
        assignmentGroup : loadStatuses.includes('assignmentgroup'),
        assignment : loadStatuses.includes('assignment'),
        submission : loadStatuses.includes('submission')
    };
    const unconvertedDataMaster = {
        student : [],
        assignmentGroup : [],
        assignment : [],
        submission : []
    };
    const convertedDataMaster = {
        student : [],
        courseStudent : [],
        assignmentGroup : [],
        assignment : [],
        submission : []
    };
    const pq = new models.processQueueProcessModel('DataSync', 'All',1);
    //#endregion
   
    await pq.post(client);
    let pq1 = new models.processQueueProcessModel('Retrieve Canvas Data', 'Course',1);
    await pq1.post(client);
    try{	
        //#region Request Course data
        if(loadStatusMap.course) { 
            convertedDataMaster.course = currentData['course']; 
            canvasData.course = 'skipped';
            console.log('Course Sync Skipped!');
        } 
        else {
            const canvasCourses = await util.makeHttpsRequest( util.getCanvasRequestDefinition('courses', null) ); 
            const parsedCanvasCourses = await models.courseModel.convertJSONtoArray(JSON.parse(canvasCourses));
            const upsertedCourses = await util.upsertJsonToDb(parsedCanvasCourses, 'course', models.courseModel.columns, 'canvasid', client);
            if(upsertedCourses.status){ 
                convertedDataMaster.course = upsertedCourses; 
                canvasData.course = true;
            }
            else{ 
                canvasData.course = false; 
                convertedDataMaster.course = upsertedCourses; 
                /*throw error*/ 
            }						
        }
        //#endregion Request Course data
    } 
    catch (error) {
        console.error('Error during course sync:', error);
           res.status(500).send('Error during course sync:', error);
        pq.failuremessage = JSON.stringify(error);
        pq.processendtime = new Date().toISOString();
        pq.processstatus = 'Failed';
    }
    finally{
        //end Retrieve Canvas Data
   
        //#region Request non-course Canvas Data
        try {
            pq1 = new models.processQueueProcessModel('Retrieve Canvas Data', 'All',1);
            await pq1.post(client);
            for(const course of convertedDataMaster.course.results.map(e => { return e.record; })){
                const courseId = course.id;
                const courseCanvasId = course.canvasid;
                const unconvertedData = {};
                const assGrpRequestDef = await util.getCanvasRequestDefinition('assignmentgroups', courseCanvasId);
                const assRequestDef = await util.getCanvasRequestDefinition('assignments', courseCanvasId);
                const studentRequestDef = await util.getCanvasRequestDefinition('students', courseCanvasId);
                const submissionRequestDef = await util.getCanvasRequestDefinition('submissions', courseCanvasId);
                
                unconvertedData.assigments = loadStatusMap.assignment ? currentData['assignment'] : JSON.parse(( await util.makeHttpsRequest(assRequestDef) ));
                unconvertedData.assignmentgroups = loadStatusMap.assignmentGroup  ? currentData['assignmentgroup'] : JSON.parse(( await util.makeHttpsRequest(assGrpRequestDef) ));
                unconvertedData.students =  loadStatusMap.student ? currentData['student'] : JSON.parse(( await util.makeHttpsRequest(studentRequestDef) ));
                unconvertedData.submissions = loadStatusMap.submission ? currentData['submission'] : JSON.parse(( await util.makeHttpsRequest(submissionRequestDef) ));
                //course.unconvertedData = unconvertedData;
   
                unconvertedDataMaster.assignment.push(...unconvertedData.assigments);
                unconvertedDataMaster.assignmentGroup.push(...unconvertedData.assignmentgroups.map(e => { e.courseid = courseId; e.courseCanvasId = courseCanvasId; return e; }));
                unconvertedDataMaster.student.push(...unconvertedData.students);
                unconvertedDataMaster.submission.push(...unconvertedData.submissions);
                //console.log('Unconverted data retrieved for course: '+courseId);
            }
        } 
        //#endregion Request non-course Canvas Data
        catch (error) {
            console.error('Error during data sync:', error);
            res.status(500).send('Error during data sync:', error);
            pq.failuremessage = JSON.stringify(error);
            pq.processendtime = new Date().toISOString();
            pq.processstatus = 'Failed';
        }
        finally{
            //#region Data Conversion & Load
            try{
                console.log('Starting Data Conversion and Load');
    
                //convertedDataMaster = full converted canvas dataset, except course
                //canvasData = status values, except Course (full converted and inserted dataset)
                convertedDataMaster.student = (await util.upsertJsonToDb( 
                    models.studentModel.convertJSONtoArray(unconvertedDataMaster.student), 
                    'student', models.studentModel.columns, 
                    'canvasid', client ));
                canvasData.student = convertedDataMaster.student.status;
    
                convertedDataMaster.courseStudent = (await util.upsertJsonToDb( 
                    models.courseStudentModel.convertJSONtoArray(unconvertedDataMaster.student, convertedDataMaster.course.results.map(e => { return e.record; }), convertedDataMaster.student.results.map(e => { return e.record; }) ), 
                    'coursestudent', models.courseStudentModel.columns, 
                    'uniqueid', client ));
                canvasData.courseStudent = convertedDataMaster.courseStudent.status;
    
                convertedDataMaster.assignmentGroup = (await util.upsertJsonToDb( 
                    models.assignmentGroupModel.convertJSONtoArray(unconvertedDataMaster.assignmentGroup, convertedDataMaster.course.results.map(e => { return e.record; }) ), 
                    'assignmentgroup', models.assignmentGroupModel.columns, 
                    'canvasid', client ));
                canvasData.assignmentGroup = convertedDataMaster.assignmentGroup.status;
    
                convertedDataMaster.assignment = (await util.upsertJsonToDb( 
                    models.assignmentModel.convertJSONtoArray(unconvertedDataMaster.assignment, convertedDataMaster.course.results.map(e => { return e.record; }), convertedDataMaster.assignmentGroup.results.map(e => { return e.record; }) ), 
                    'assignment', models.assignmentModel.columns, 
                    'canvasid', client ));
                canvasData.assignment = convertedDataMaster.assignment.status;
    
                convertedDataMaster.submission = (await util.upsertJsonToDb( 
                    models.submissionModel.convertJSONtoArray(unconvertedDataMaster.submission, convertedDataMaster.courseStudent.results.map(e => { return e.record; }), convertedDataMaster.assignment.results.map(e => { return e.record; }) ), 
                    'assignmentsubmission', models.submissionModel.columns, 
                    'canvasid', client ));
                canvasData.submission = convertedDataMaster.submission.status;
    
                console.log('Data Conversion and Load Complete');
                
            }
            //#endregion Data Conversion & Load
            catch (error) {				
            }
            finally{
           // res.status(200).send(canvasData);
            client.release();	
            return {canvasData, unconvertedDataMaster, convertedDataMaster};
            }
        }
    }
}
