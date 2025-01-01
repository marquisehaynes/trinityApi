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

  static convertJSONtoArray(jsonObj) {
      let parsedDataArray = [];

      if( Array.isArray( jsonObj ) ) {
          jsonObj.forEach( element => {
              parsedDataArray.push( new assignmentModel(
                  element[ "id" ].toString(),
                  element[ "courseid" ].toString(),
                  element[ "assignment_group_id" ].toString(),
                  element[ "name" ],
                  element[ "points_possible" ]
              ));
          });		
      }
      else{
          parsedDataArray.push( new assignmentModel(
            jsonObj[ "id" ].toString(),
            jsonObj[ "courseid" ].toString(),
            jsonObj[ "assignment_group_id" ].toString(),
            jsonObj[ "name" ],
            jsonObj[ "points_possible" ]
          ));		
      }

      return parsedDataArray;     
  }
}