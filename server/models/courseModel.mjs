import Parser	   	 from 'json2csv';
import csv from 'csv-parser';
import  * as util from '../util/index.js';
import * as fs from 'fs';

export default class courseModel{    
    static columns = [ 'canvasid', 'coursename', 'coursedescription', 'startdate', 'enddate'];
    canvasid;
    coursename;
    coursedescription;
    startdate;
    enddate;

    constructor( canvasId, courseName, courseDescription, startDate, endDate){
        this.canvasid          = canvasId;
        this.coursename        = courseName;
        this.coursedescription = courseDescription;
        this.startdate         = startDate ? startDate : '1/1/1970';
        this.enddate           = endDate ? endDate : '12/31/9999';
    }

    static async convertJSONtoArray(jsonObj) {
        let parsedDataArray = [];

        if( Array.isArray( jsonObj ) ) {
          for(const element of jsonObj){
            const course = new courseModel(
              element[ "id" ],
              element[ "name" ],
              element[ "course_code" ],
              element[ "start_at" ],
              element[ "end_at" ]
            );
            parsedDataArray.push( course );
          }
        }
        else{
          const course = new courseModel(
            jsonObj[ "id" ],
            jsonObj[ "name" ],
            jsonObj[ "course_code" ],
            jsonObj[ "start_at" ],
            jsonObj[ "end_at" ]
          );
          parsedDataArray.push( course );		
        }

        return parsedDataArray;     
    }

    static async getAllCoursesFromCanvas(pgPool, currentCourseArr, writeCSV) {
      try {
        // Perform the HTTP request to get the data
        const requestDef = util.getCanvasRequestDefinition('courses', null);
        const data = await util.makeHttpsRequest(requestDef); 
        const parsedData = JSON.parse(data);
        const parsedDataArray = this.convertJSONtoArray(parsedData, currentCourseArr);

        if(writeCSV === true){
          console.log('Retrieved Course Data, attempting to parse and save as csv');
          const fileName = './extracts/courses/courseData_' + new Date().toISOString().replace(/[: ]/g, '_') + '.csv';
          const parsedDataCSV = Parser.parse(parsedDataArray); 
          fs.writeFileSync(fileName, parsedDataCSV);        
          await this.upsertCsvData(fileName, pgPool);
          console.log('Course data upsert completed!');
          return parsedDataArray;
        }       
        else{
          const res = util.upsertJsonToDb(parsedDataArray, 'course', courseModel.columns, 'canvasid', pgPool, currentCourseArr);
          console.log('Course data upsert completed!');
          return parsedDataArray;
        }
        
      } catch (error) {
        console.error('Error during course data processing:', error);
      }
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
              const res = await client.query(query, values);
            }    
          } catch (err) {
            console.error('Error during upsert:', err);
          } finally {
            // Close the pool connection when done
            await client.release();
          }
        });
    }

  }