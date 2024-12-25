import * as fs         from 'fs';
import * as CopyStream from 'pg-copy-streams';
import csv from 'csv-parser';
import  * as util from '../util/index.js';  
import Parser from 'json2csv';

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
  

    static convertJSONtoArray(jsonObj) {
        let parsedDataArray = [];

        if( Array.isArray( jsonObj ) ) {
            jsonObj.forEach( element => {
                parsedDataArray.push( new assignmentGroupModel(
                    element[ "id" ].toString(),
                    element[ "courseId" ],
                    element[ "name" ],
                    element[ "group_weight" ]
                ));
            });		
        }
        else{
            parsedDataArray.push( new assignmentGroupModel(
              jsonObj[ "id" ].toString(),
              jsonObj[ "courseId" ],
              jsonObj[ "name" ],
              jsonObj[ "group_weight" ]
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

    static async getAssignmentGroupsFromCanvas(courseArray) {
      try {
        // Perform the HTTP request to get the data        
        return courseArray.map((element) => {
          return new Promise(async (resolve, reject) => {
            try {
              const courseId = element['canvasid'];
              const requestDef = await util.getCanvasRequestDefinition('assignmentgroups', new Map([ ['courseId', courseId] ]));
              const data = await util.makeHttpsRequest(requestDef); 
              const parsedAssignmentGroups = JSON.parse(data);
              for(const ag of parsedAssignmentGroups){
                ag.courseId = courseId;
              }
              resolve(parsedAssignmentGroups);
            } catch (error) {
              resolve(error);
            }           
          });
        });
      } catch (error) {
        console.error('Error during assignment group processing:', error);
      }
    }

    static async processAssignmentGroups(parsedData, pgPool){
      const assGrpCSV = Parser.parse(parsedData);
      const assGrpFileName = './extracts/assignmentgroups/assignmentGroupData_' + new Date().toISOString().replace(/[: ]/g, '_') + '.csv';
      fs.writeFileSync(assGrpFileName, assGrpCSV);          
      await this.upsertCsvData(assGrpFileName, pgPool);
      return parsedData;
    }
   
}