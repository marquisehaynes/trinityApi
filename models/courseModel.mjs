import * as fs         from 'fs';
import * as CopyStream from 'pg-copy-streams';
import csv from 'csv-parser';

export default class courseModel{    

    canvasid;
    coursename;
    coursedescription;
    startdate;
    enddate;

    constructor( canvasId, courseName, courseDescription, startDate, endDate ){
        this.canvasid          = canvasId;
        this.coursename        = courseName;
        this.coursedescription = courseDescription;
        this.startdate         = startDate;
        this.enddate           = endDate;
    }
  
    toObj(){
        return retObj = {
            'canvasid'          : this.canvasid,
            'coursename'        : this.coursename,
            'coursedescription' : this.coursedescription,
            'startdate'         : this.startdate,
            'enddate'           : this.enddate
        };
    }
    
    stringify(){
        let orderedKeys = [ 'canvasid', 'coursename', 'coursedescription', 'startdate', 'enddate' ];

        return JSON.stringify({
            'canvasid'          : this.canvasid,
            'coursename'        : this.coursename,
            'coursedescription' : this.coursedescription,
            'startdate'         : this.startdate,
            'enddate'           : this.enddate
        }, orderedKeys );

    }

    static convertJSONtoArray(jsonObj) {
        let parsedDataArray = [];

        if( Array.isArray( jsonObj ) ) {
            jsonObj.forEach( element => {
                parsedDataArray.push( new courseModel(
                    element[ "id" ],
                    element[ "name" ],
                    element[ "course_code" ],
                    element[ "start_at" ],
                    element[ "end_at" ]
                ));
            });		
        }
        else{
          parsedDataArray.push( new courseModel(
            jsonObj[ "id" ],
            jsonObj[ "name" ],
            jsonObj[ "course_code" ],
            jsonObj[ "start_at" ],
            jsonObj[ "end_at" ]
          ));		
        }

        return parsedDataArray;     
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
              const { canvasid, coursename, coursedescription, startdate, enddate } = row;
              
              const query = `
                INSERT INTO course (canvasid, coursename, coursedescription, startdate, enddate)
                VALUES ($1, $2, $3, $4, $5)
                ON CONFLICT (canvasid)
                DO UPDATE SET 
                  coursename = EXCLUDED.coursename, 
                  coursedescription = EXCLUDED.coursedescription,
                  startdate = EXCLUDED.startdate,
                  enddate = EXCLUDED.enddate
                  ;
              `;
    
              const values = [canvasid, coursename, coursedescription, startdate, enddate];
              
              // Run the upsert query for each row
              await client.query(query, values);
            }    
            console.log('Course CSV data upserted successfully!');
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
        text: 'select * from course;'
      });
      return result;
    }
}