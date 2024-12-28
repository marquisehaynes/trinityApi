import Parser	   	 from 'json2csv';
import  * as util from '../util/index.js';

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

    static async getAllCoursesFromCanvas(pgPool) {
      try {
        // Perform the HTTP request to get the data
        const requestDef = util.getCanvasRequestDefinition('courses', null);
        const fileName = './extracts/courses/courseData_' + new Date().toISOString().replace(/[: ]/g, '_') + '.csv';
        const data = await util.makeHttpsRequest(requestDef); 
        const parsedData = JSON.parse(data);
        const parsedDataArray = this.convertJSONtoArray(parsedData);
        console.log('Retrieved Course Data, attempting to parse and save as csv');
        const parsedDataCSV = Parser.parse(parsedDataArray); 
        fs.writeFileSync(fileName, parsedDataCSV);        
        await this.upsertCsvData(fileName, pgPool);
        console.log('Course data upsert completed!');
        return parsedDataArray;
      } catch (error) {
        console.error('Error during course data processing:', error);
      }
    }
  }