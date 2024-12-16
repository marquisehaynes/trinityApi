import * as fs         from 'fs';
import csv from 'csv-parser';
import  * as util from '../util/index.js';  
import Parser from 'json2csv';

export default class assignmentModel{    

    groupid;
    name;
    pointspossible;
    canvasid;

    constructor( canvasId, groupId, assName, pointsPossible){
        this.canvasid = canvasId;
        this.groupid = groupId;
        this.name = assName;
        this.pointspossible = pointsPossible;
    }
  
    static convertJSONtoArray(jsonObj) {
        let parsedDataArray = [];

        if( Array.isArray( jsonObj ) ) {
            jsonObj.forEach( element => {
                parsedDataArray.push( new assignmentModel(
                    element[ "id" ].toString(),
                    element[ "assignment_group_id" ],
                    element[ "name" ],
                    element[ "points_possible" ]
                ));
            });		
        }
        else{
            parsedDataArray.push( new assignmentModel(
                element[ "id" ].toString(),
                element[ "assignment_group_id" ],
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
                const { canvasid, groupid, name, pointspossible } = row;
                
                const query = `
                  INSERT INTO assignment (canvasid, groupid, name, pointspossible)
                  VALUES ($1, $2, $3, $4)
                  ON CONFLICT (canvasid)
                  DO UPDATE SET 
                    groupid = EXCLUDED.groupid, 
                    name = EXCLUDED.name,
                    pointspossible = EXCLUDED.pointspossible
                    ;
                `;
      
                const values = [canvasid, groupid, name, pointspossible];
                
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

}