import * as fs         from 'fs';
import * as CopyStream from 'pg-copy-streams';
import csv from 'csv-parser';
import * as models from './index.js'; 
import  * as util from '../util/index.js';  
import Parser from 'json2csv';

export default class studentModel{    

    canvasid;
    fullname;
    sortablename;


    constructor( canvasId, fullName, sortableName ){
        this.canvasid          = canvasId;
        this.fullname          = fullName;
        this.sortablename      = sortableName;
    }
  
    static convertJSONtoArray(jsonObj) {
        const data = [];

        if( Array.isArray( jsonObj ) ) {
          for(const element of jsonObj){
            const std = new studentModel(
              element["user"]["id"],
              element["user"]["name"],
              element["user"]["sortable_name"]
            );

            if(!data.includes(JSON.stringify(std))){
              data.push(JSON.stringify(std));
            }
          }	
        }
        else{
          const std = new studentModel(
            jsonObj["user"]["id"],
            jsonObj["user"]["name"],
            jsonObj["user"]["sortable_name"]
          );
          if(!data.includes(JSON.stringify(std))){
            data.push(JSON.stringify(std));
          }
        }

        return data.map(e => JSON.parse(e));   
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
            console.log('Student CSV data upserted successfully!');
          } catch (err) {
            console.error('Error during upsert:', err);
          } finally {
            // Close the pool connection when done
            await client.release();
            return;
          }
        });
    }

    static async processStudents(parsedData, pgPool){
      let studentArr = [];
      const courseStudentArray = [];
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
      studentArr = Array.from(new Set(studentArr.map(o => JSON.stringify(o)))).map(str => JSON.parse(str));
      const studentCSV = Parser.parse(studentArr); 
      const studentFileName = './extracts/students/studentData_' + new Date().toISOString().replace(/[: ]/g, '_') + '.csv';
      const courseStudentCSV = Parser.parse(courseStudentArray);
      const courseStudentFileName = './extracts/coursestudents/courseStudentData_' + new Date().toISOString().replace(/[: ]/g, '_') + '.csv';
      fs.writeFileSync(studentFileName, studentCSV);        
      fs.writeFileSync(courseStudentFileName, courseStudentCSV);  
      await this.upsertCsvData(studentFileName, pgPool);
      await models.courseStudentModel.upsertCsvData(courseStudentFileName, pgPool);
      return {
        'studentArr' : studentArr,
        'courseStudentArray' : courseStudentArray,
      }
    }

    static async getStudentsFromCanvas(courseArray) {
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