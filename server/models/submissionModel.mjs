export default class submissionModel{    
  static columns = new Set(['canvasid', 'attemptnumber', 'assignmentid', 'studentid', 'coursestudentid', 'score']);
  static conflictColumn = 'canvasid';
  
  canvasid;
  coursestudentid;
  assignmentid;
  studentid;
  score;
  attemptnumber;

  constructor( canvasId, courseStudentId, studentId, assId, attemptNumber, Score ){
    this.canvasid = canvasId;
    this.coursestudentid = courseStudentId;
    this.studentid = studentId;
    this.assignmentid = assId;
    this.attemptnumber = attemptNumber ? attemptNumber : 0;
    this.score = Score;
  }
  
  static convertJSONtoArray(jsonObj, courseStudentData, assignmentData) {
    let parsedDataArray = [];

    if( Array.isArray( jsonObj ) ) {
      jsonObj.forEach( element => {
        try {
          const assignmentRecord = assignmentData.find((e) => e.canvasid == element.assignment_id);
          const courseStudentRecord = courseStudentData.find((e) => e.canvasstudentid == element.user_id && e.courseid == assignmentRecord.courseid );
          const studentId = courseStudentRecord.studentid;
          parsedDataArray.push( new submissionModel(
            element[ "id" ].toString(),
            courseStudentRecord.id,
            studentId,
            assignmentRecord.id,
            element[ "attempt" ],
            element["score"] ? element["score"] : 0
          ));
        } catch (error) { }        
      });		
    }
    else{
      try {
        const assignmentRecord = assignmentData.find((e) => e.canvasid == jsonObj.assignment_id);
        const courseStudentRecord = courseStudentData.find((e) => e.canvasstudentid == jsonObj.user_id && e.courseid == assignmentRecord.courseid );
        const studentId = courseStudentRecord.studentid;
        parsedDataArray.push( new submissionModel(
          jsonObj[ "id" ].toString(), 
          courseStudentRecord.id,
          studentId,
          assignmentRecord.id,
          jsonObj[ "attempt" ],
          jsonObj["score"] ? jsonObj["score"] : 0
        ));		
      } catch (error) { }
    }
    return parsedDataArray;     
  }
}