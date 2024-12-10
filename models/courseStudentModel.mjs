import * as fs         from 'fs';
import * as CopyStream from 'pg-copy-streams';
import csv from 'csv-parser';

export default class courseStudentModel{    

    courseid;
    studentid;
    uniqueid;

    constructor( courseId, studentId ){
        this.courseid          = courseId;
        this.studentid        = studentId;
        this.uniqueid        = courseId + '_' + studentId;
    }
  
    toObj(){
        return retObj = {
            'courseid'          : this.courseid,
            'studentid'        : this.studentid,
            'uniqueid'          :this.uniqueid
        };
    }
    
    stringify(){
        let orderedKeys = [ 'courseid', 'studentid', 'uniqueid' ];

        return JSON.stringify({
            'courseid'          : this.courseid,
            'studentid'        : this.studentid,
            'uniqueid'          :this.uniqueid
        }, orderedKeys );

    }

    static async upsertCsvData( csvFilePath, pgPool ) {
      const client = await pgPool.connect();
      // Start reading the CSV file
      const csvData = [];
    
      fs.createReadStream(csvFilePath)
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
            console.log('CSV data upserted successfully!');
          } catch (err) {
            console.error('Error during upsert:', err);
          } finally {
            // Close the pool connection when done
            await client.release();
          }
        });
    }

    static async getAll(pgPool){
      const client = await pgPool.connect();
      const result = await client.query({
        rowMode: 'array',
        text: 'select * from coursestudent;'
      });
      return result;
    }
}