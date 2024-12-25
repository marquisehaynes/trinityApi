import * as fs         from 'fs';
import * as CopyStream from 'pg-copy-streams';
import csv from 'csv-parser';
import studentModel from './studentModel.mjs';

export default class courseStudentModel{    

    courseid;
    studentid;
    uniqueid;

    constructor( courseId, studentId ){
        this.courseid          = courseId;
        this.studentid        = studentId;
        this.uniqueid        = courseId + '_' + studentId;
    }

    static async upsertCsvData( csvFilePath, pgPool ) {
      const client = await pgPool.connect();
      // Start reading the CSV file
      const csvData = [];
      console.log('Attempting to read from '+ csvFilePath);
      await fs.createReadStream(csvFilePath)
        .pipe(csv())
        .on('data', (row) => {
          csvData.push(row);
        })
        .on('end', async () => {
          try {
            // Process rows in batches to prevent exceeding query length limits
            for (const row of csvData) {
              const { courseid, studentid, uniqueid } = row;
              
              const query = `
                INSERT INTO coursestudent (courseid, studentid, uniqueid)
                VALUES ($1, $2, $3)
                ON CONFLICT (uniqueid)
                DO NOTHING;
              `;
    
              const values = [ courseid, studentid, uniqueid ];
              
              // Run the upsert query for each row
              await client.query(query, values);
            }    
            console.log('CourseStudent CSV data upserted successfully!');
          } catch (err) {
            console.error('Error during upsert:', err);
          } finally {
            // Close the pool connection when done
            await client.release();
            return;
          }
        });
    }

    static convertJSONtoArray(jsonObj) {
      let parsedDataArray = [];
      if( Array.isArray( jsonObj ) ) {
        for(const element of jsonObj){
          parsedDataArray.push( new courseStudentModel(
            element[ "course_id" ].toString(),
            element['user']['id'].toString()
          ));
        }	
      }
      else{
        parsedDataArray.push( new courseStudentModel(
          jsonObj[ "course_id" ].toString(),
          jsonObj['user']['id'].toString()
        ));
      }
      return parsedDataArray;     
  }

    
}