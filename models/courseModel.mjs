import * as fs from 'fs';
import * as CopyStream from 'pg-copy-streams';
export class courseModel{    

    canvasid;
    coursename;
    coursedescription;
    startdate;
    enddate;
    constructor(canvasId, courseName, courseDescription, startDate, endDate){
        this.canvasid = canvasId;
        this.coursename = courseName;
        this.coursedescription = courseDescription;
        this.startdate = startDate;
        this.enddate = endDate;
    }

    toObj(){
        return retObj = {
            'canvasid' : this.canvasid,
            'coursename' : this.coursename,
            'coursedescription' : this.coursedescription,
            'startdate' : this.startdate,
            'enddate' : this.enddate
        };
    }
    
    stringify(){
        let orderedKeys = ['canvasId', 'courseName', 'courseDescription', 'startDate', 'endDate'];
        return JSON.stringify({
            'canvasid' : this.canvasid,
            'coursename' : this.coursename,
            'coursedescription' : this.coursedescription,
            'startdate' : this.startdate,
            'enddate' : this.enddate
        }, orderedKeys);
    }

    static convertJSONtoArray(jsonObj) {
        let parsedDataArray = [];
        if(Array.isArray(jsonObj)){
            jsonObj.forEach(element => {
                parsedDataArray.push(new courseModel(
                    element["id"],
                    element["name"],
                    element["course_code"],
                    element["start_at"],
                    element["end_at"]
                ));
            });		
        }
        else{
        parsedDataArray.push(new courseModel(
            jsonObj["id"],
            jsonObj["name"],
            jsonObj["course_code"],
            jsonObj["start_at"],
            jsonObj["end_at"]
        ));		
        }
        return parsedDataArray;     
    }

    static async copyCsvToPostgres(csvFilePath, tableName, pgPool) {
        const client = await pgPool.connect();
      
        try {
          // Open the CSV file as a readable stream
          let fileStream = fs.createReadStream(csvFilePath);
      
          // Create the copy stream to perform the bulk copy operation
          let copyStream = client.query(
            CopyStream.from(
                `COPY ${tableName} 
                FROM STDIN WITH CSV HEADER DELIMITER ','`
            )
          );
      
          // Pipe the CSV file stream into the copy stream
          fileStream.pipe(copyStream);
      
          // Handle the completion of the stream copy process
          copyStream.on('finish', () => {
            console.log(`Successfully copied CSV into table ${tableName}`);
          });
      
          // Handle any errors that occur during the copy operation
          copyStream.on('error', (err) => {
            console.error('Error copying CSV:', err);
          });
      
          // Wait until the copy operation completes
          await new Promise((resolve, reject) => {
            copyStream.on('finish', resolve);
            copyStream.on('error', reject);
          });
        } catch (err) {
          console.error('Error in copy operation:', err);
        } finally {
          // Release the client back to the pool
          client.release();
        }
      }
}
