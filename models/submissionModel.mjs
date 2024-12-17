import * as fs         from 'fs';
import csv from 'csv-parser';
import  * as util from '../util/index.js';  
import Parser from 'json2csv';

export default class submissionModel{    

    canvasid;
    attemptnumber;
    assignmentid;
    studentid;
    coursestudentid;
    score;


    constructor( canvasId, courseStudentId, studentId, assId, attemptNumber, Score ){
      this.canvasid = canvasId;
      this.coursestudentid = courseStudentId;
      this.studentid = studentId;
      this.assignmentid = assId;
      this.attemptnumber = attemptNumber;
      this.score = Score;
    }
  
    static convertJSONtoArray(jsonObj) {
        let parsedDataArray = [];

        if( Array.isArray( jsonObj ) ) {
            jsonObj.forEach( element => {
                parsedDataArray.push( new submissionModel(
                    element[ "id" ].toString(),
                    element[ "courseid" ].toString(),
                    element[ "assignment_group_id" ].toString(),
                    element[ "name" ],
                    element[ "points_possible" ]
                ));
            });		
        }
        else{
            parsedDataArray.push( new submissionModel(
              element[ "id" ].toString(),
              element[ "courseid" ].toString(),
              element[ "assignment_group_id" ].toString(),
              element[ "name" ],
              element[ "points_possible" ]
            ));		
        }

        return parsedDataArray;     
    }

    static async upsertCsvData( csvFilePath, pgPool ) {
      const client = await pgPool.connect();
      // Start reading the CSV file
      const csvData = [];
      console.log('Attempting to read from '+ csvFilePath);
      fs.createReadStream(csvFilePath)
      .pipe(csv())
      .on('data', (row) => {
        csvData.push(row);
      })
      .on('end', async () => {
        try {
          // Process rows in batches to prevent exceeding query length limits
          for (const row of csvData) {
            const { canvasid, assignmentgroupid, name, pointspossible, courseid } = row;
            
            const query = `
              INSERT INTO assignment (canvasid, assignmentgroupid, name, pointspossible, courseid)
              VALUES ($1, $2, $3, $4, $5)
              ON CONFLICT (canvasid)
              DO UPDATE SET 
                assignmentgroupid = EXCLUDED.assignmentgroupid, 
                name = EXCLUDED.name,
                pointspossible = EXCLUDED.pointspossible,
                courseid = EXCLUDED.courseid
                ;
            `;
  
            const values = [canvasid, assignmentgroupid, name, pointspossible, courseid];
            
            // Run the upsert query for each row
            await client.query(query, values);
          }    
          console.log('Assignment CSV data upserted successfully!');
        } catch (err) {
          console.error('Error during upsert:', err);
        } finally {
          // Close the pool connection when done
          await client.release();
        }
      });
    }

    static async getSubmissionsFromCanvas(assignmentArray) {
      try {
        // Perform the HTTP request to get the data        
        return assignmentArray.map((element) => {
          return new Promise(async (resolve, reject) => {
            try {
              const courseId = element['courseid'];
              const assignmentId = element['canvasid'];
              const requestDef = await util.getCanvasRequestDefinition('submissions', new Map([ ['courseId', courseId], ['assignmentId', assignmentId] ]));
              const data = await util.makeHttpsRequest(requestDef); 
              const parsedSubmissions = JSON.parse(data);
              console.log(parsedData);
              for(const a of parsedSubmissions){
                a.courseid = courseId;
              }
              resolve(parsedSubmissions);
            } catch (error) {
              resolve(error);
            }           
          });
        });
      } catch (error) {
        console.error('Error during assignment processing:', error);
      }
    }

    static async processAssignments(parsedData, pgPool){
      const assCSV = Parser.parse(parsedData);
      const assFileName = './extracts/assignments/assignmentData_' + new Date().toISOString().replace(/[: ]/g, '_') + '.csv';
      fs.writeFileSync(assFileName, assCSV);          
      await this.upsertCsvData(assFileName, pgPool);
      return parsedData;
    }

}