export default class courseStudentModel{    
  static columns = new Set(['canvascourseid', 'canvasstudentid','courseid','studentid', 'uniqueid']);
  static conflictColumn = 'uniqueid';
  canvascourseid;
  canvasstudentid;
  courseid;
  studentid;
  uniqueid;

  constructor( canvasCourseId, courseRecordId, canvasStudentId, studentRecordId ){
      this.canvascourseid          = canvasCourseId;
      this.courseid = courseRecordId;
      this.canvasstudentid        = canvasStudentId;
      this.studentid = studentRecordId;
      this.uniqueid        = courseRecordId + '_' + studentRecordId;
  }
  static convertJSONtoArray(jsonObj, courseData, studentData) {
      let parsedDataArray = [];
      if( Array.isArray( jsonObj ) ) {
        for(const element of jsonObj){
          if (element['role'] == 'StudentEnrollment' && element['user']['name'] != 'Test Student'){
            const courseRecordId = courseData.find((e) => e.canvasid == element.course_id).id;
            const studentRecordId = studentData.find((e) => e.canvasid == element.user_id).id;
            parsedDataArray.push( new courseStudentModel(
              element.course_id,
              courseRecordId,
              element['user']['id'].toString(),
              studentRecordId
            ));
          }
        }	
      }
      else{
        if (jsonObj['role'] == 'StudentEnrollment' && jsonObj['user']['name'] != 'Test Student'){
          const courseRecordId = courseData.find((e) => e.canvasid == jsonObj.course_id).id;
          const studentRecordId = studentData.find((e) => e.canvasid == jsonObj.user_id).id;
          parsedDataArray.push( new courseStudentModel(
            jsonObj.course_id,
            courseRecordId,
            element['user']['id'].toString(),
            studentRecordId
          ));
        }
      }
      return parsedDataArray;     
  }
}