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
        
        const studentPromises = await models.studentModel.getStudentsFromCanvas(courseArray);
        const assGroupPromises = await models.assignmentGroupModel.getAssignmentGroupsFromCanvas(courseArray);

        // Wait for all assignment group promises to settle
        const assGrpResults = await Promise.allSettled(assGroupPromises);

        const resArray = [];
        for (const res of assGrpResults) {
            if (Array.isArray(res['value'])) {
                for (const resInstance of res['value']) {
                    resArray.push(resInstance);
                }
            }
        }

        // Convert JSON to array
        const assGrpArray = await models.assignmentGroupModel.convertJSONtoArray(resArray);

        // Wait for the assignment groups to be processed
        await models.assignmentGroupModel.processAssignmentGroups(assGrpArray, pgPool);
        
        console.log('Assignment groups processed successfully!');
		

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

