export default class courseStudentModel{    
  static columns = new Set(['courseid', 'studentid', 'uniqueid']);
  static conflictColumn = 'uniqueid';
  courseid;
  studentid;
  uniqueid;

  constructor( courseId, studentId ){
      this.courseid          = courseId;
      this.studentid        = studentId;
      this.uniqueid        = courseId + '_' + studentId;
  }
  static convertJSONtoArray(jsonObj) {
      let parsedDataArray = [];
      if( Array.isArray( jsonObj ) ) {
        for(const element of jsonObj){
          parsedDataArray.push( new courseStudentModel(
            element[ "course_id" ].toString(),
            element['user']['id'].toString()
          ));
        }	
      }
      else{
        parsedDataArray.push( new courseStudentModel(
          jsonObj[ "course_id" ].toString(),
          jsonObj['user']['id'].toString()
        ));
      }
      return parsedDataArray;     
  }
}