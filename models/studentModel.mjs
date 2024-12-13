import * as fs         from 'fs';
import * as CopyStream from 'pg-copy-streams';
import csv from 'csv-parser';
import * as models from './index.js'; 
import  * as util from '../util/index.js';  

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

    static processStudents(parsedData){
      const studentArr = [];
      const courseStudentArray = [];
      console.log(parsedData);
      if (parsedData.length > 0) {
        for (let j = 0; j < parsedData.length; j++) {
            const std = parsedData[j];
            const courseId = std['course_id'];
            if (std['role'] == 'StudentEnrollment' && std['user']['name'] != 'Test Student') {
                const student = new studentModel(
                    parseInt(std['user']['id']),
                    std['user']['name'],
                    std['user']['sortable_name']
                );
                studentArr.push(student);
                courseStudentArray.push(new models.courseStudentModel( parseInt(courseId), std['user']['id'] ));
            }
        }        
      }

      return {
        'studentArr' : studentArr,
        'studentArrCount' :  studentArr.length,
        'courseStudentArray' : courseStudentArray,
        'courseStudentArrayCount' :  courseStudentArray.length,
      }
    }

    static async getStudentsFromCanvas(courseArray, pgPool) {
      
      let parsedDataArray;
      let parsedDataCSV;
      const fileName = './extracts/students/studentData_' + new Date().toISOString().replace(/[: ]/g, '_') + '.csv';
      
      try {
        // Perform the HTTP request to get the data        
        return courseArray.map((element) => {
          return new Promise(async (resolve, reject) => {
            try {
              const courseId = element['canvasid'];
              const requestDef = await util.getCanvasRequestDefinition('students', new Map([ ['courseId', courseId] ]));
              const data = await util.makeHttpsRequest(requestDef); 
              const parsedCourseStudents = JSON.parse(data);
              //processStudents(parsedCourseStudents);
              resolve(parsedCourseStudents);
            } catch (error) {
              resolve(error);
            }           
          });
        });
      } catch (error) {
        console.error('Error during student data processing:', error);
      }
    }
}