export default class submissionModel{    
  static columns = new Set(['canvasid', 'attemptnumber', 'assignmentid', 'studentid', 'coursestudentid', 'score']);
  static conflictColumn = 'canvasid';
  canvasid;
  attemptnumber;
  assignmentid;
  studentid;
  coursestudentid;
  score;

  constructor( canvasId, courseStudentId, studentId, assId, attemptNumber, Score ){
    this.canvasid = canvasId;
    this.coursestudentid = courseStudentId;
    this.studentid = studentId;
    this.assignmentid = assId;
    this.attemptnumber = attemptNumber ? attemptNumber : 0;
    this.score = Score;
  }
  
  static convertJSONtoArray(jsonObj) {
    let parsedDataArray = [];

    if( Array.isArray( jsonObj ) ) {
      jsonObj.forEach( element => {
        parsedDataArray.push( new submissionModel(
          element[ "id" ].toString(),
          element[ "coursestudentid" ].toString(),
          element[ "user_id" ].toString(),
          element[ "assignment_id" ].toString(),
          element[ "attempt" ],
          element["score"] ? element["score"] : 0
        ));
      });		
    }
    else{
      parsedDataArray.push( new submissionModel(
        jsonObj[ "id" ].toString(),
        jsonObj[ "coursestudentid" ].toString(),
        jsonObj[ "user_id" ].toString(),
        jsonObj[ "assignment_id" ].toString(),
        jsonObj[ "attempt" ],
        jsonObj["score"] ? jsonObj["score"] : 0
      ));		
    }
    return parsedDataArray;     
  }
}