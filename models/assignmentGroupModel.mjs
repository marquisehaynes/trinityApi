import * as fs         from 'fs';
import * as CopyStream from 'pg-copy-streams';
import csv from 'csv-parser';

export default class assignmentGroupModel{    

    canvasid;
    courseid;
    groupname;
    weight;
    

    constructor( canvasId, courseId, groupName, Weight){
        this.canvasid          = canvasId;
        this.courseid        = courseId;
        this.groupname = groupName;
        this.weight         = Weight;
    }
  

    static convertJSONtoArray(jsonObj, course) {
        let parsedDataArray = [];

        if( Array.isArray( jsonObj ) ) {
            jsonObj.forEach( element => {
                parsedDataArray.push( new assignmentGroupModel(
                    element[ "id" ].toString(),
                    course.toString(),
                    element[ "name" ],
                    element[ "group_weight" ]
                ));
            });		
        }
        else{
            parsedDataArray.push( new assignmentGroupModel(
                element[ "id" ].toString(),
                course.toString(),
                element[ "name" ],
                element[ "group_weight" ]
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
              const { canvasid, courseid, groupname, weight } = row;
              
              const query = `
                INSERT INTO assignmentgroup (canvasid, courseid, name, weight)
                VALUES ($1, $2, $3, $4)
                ON CONFLICT (canvasid)
                DO UPDATE SET 
                  courseid = EXCLUDED.courseid, 
                  name = EXCLUDED.name,
                  weight = EXCLUDED.weight
                  ;
              `;
    
              const values = [canvasid, courseid, groupname, weight];
              
              // Run the upsert query for each row
              await client.query(query, values);
            }    
            console.log('Assignment Group CSV data upserted successfully!');
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
        text: 'select * from assignmentgroup;'
      });
      return result;
    }
}