export default class assignmentModel{    
  static columns = new Set(['canvasid', 'groupid', 'courseid', 'name', 'pointspossible']);
  static conflictColumn = 'canvasid';
  canvasid;
  groupid;
  name;
  pointspossible;
  courseid;

  constructor( canvasId,courseId, groupId, assName, pointsPossible ){
    this.canvasid = canvasId;
    this.courseid = courseId;
    this.groupid = groupId;
    this.name = assName;
    this.pointspossible = pointsPossible ? pointsPossible : 0;
  }

  static convertJSONtoArray(jsonObj, courseData, groupData) {
      let parsedDataArray = [];

      if( Array.isArray( jsonObj ) ) {
          jsonObj.forEach( element => {
              const courseRecordId = courseData.find((e) => e.canvasid == element.course_id).id;
              const groupRecordId = groupData.find((e) => e.canvasid == element.assignment_group_id).id;
              parsedDataArray.push( new assignmentModel(
                  element[ "id" ].toString(),
                  courseRecordId,
                  groupRecordId,
                  element[ "name" ],
                  element[ "points_possible" ]
              ));
          });		
      }
      else{
          const courseRecordId = courseData.find((e) => e.canvasid == jsonObj.course_id).id;
          const groupRecordId = groupData.find((e) => e.canvasid == jsonObj.assignment_group_id).id;
          parsedDataArray.push( new assignmentModel(
            jsonObj[ "id" ].toString(),
            courseRecordId,
            groupRecordId,
            jsonObj[ "name" ],
            jsonObj[ "points_possible" ]
          ));		
      }

      return parsedDataArray;     
  }
}