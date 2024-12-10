import * as fs         from 'fs';
import * as CopyStream from 'pg-copy-streams';
import csv from 'csv-parser';

export default class studentModel{    

    canvasid;
    fullname;
    sortablename;


    constructor( canvasId, fullName, sortableName ){
        this.canvasid          = canvasId;
        this.fullname          = fullName;
        this.sortablename      = sortableName;
    }
  
    toObj(){
        return retObj = {
            'canvasid'          : this.canvasid,
            'fullname'          : this.fullname,
            'sortablename'      : this.sortablename
        };
    }
    
    stringify(){
        let orderedKeys = [ 'canvasid', 'fullname', 'sortablename' ];
        return JSON.stringify(this.toObj(), orderedKeys );
    }

    static convertJSONtoArray(jsonObj) {
        let parsedDataArray = [];

        if( Array.isArray( jsonObj ) ) {
            jsonObj.forEach( element => {
                parsedDataArray.push( new studentModel(
                    element[ "id" ],
                    element[ "name" ],
                    element[ "course_code" ],
                    element[ "start_at" ],
                    element[ "end_at" ]
                ));
            });		
        }
        else{
          parsedDataArray.push( new studentModel(
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
              const { canvasid,fullname, sortablename } = row;
              
              const query = `
                INSERT INTO student (canvasid, fullname, sortablename)
                VALUES ($1, $2, $3)
                ON CONFLICT (canvasid)
                DO UPDATE SET 
                  fullname = EXCLUDED.fullname,
                  sortablename = EXCLUDED.sortablename
                  ;
              `;
    
              const values = [canvasid, fullname, sortablename];
              
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
}