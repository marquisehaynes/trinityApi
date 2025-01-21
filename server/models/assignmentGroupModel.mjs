export default class assignmentGroupModel{    
  static columns = new Set(['canvasid', 'courseid', 'name', 'weight']);
  static conflictColumn = 'canvasid';
  canvasid;
  courseid;
  name;
  weight;    

  constructor( canvasId, courseId, groupName, Weight){
      this.canvasid          = canvasId;
      this.courseid        = courseId;
      this.name = groupName;
      this.weight         = Weight;
  }

  static convertJSONtoArray(jsonObj) {
      let parsedDataArray = [];

      if( Array.isArray( jsonObj ) ) {
          jsonObj.forEach( element => {
              parsedDataArray.push( new assignmentGroupModel(
                  element[ "id" ].toString(),
                  element["courseid"],
                  element[ "name" ],
                  element[ "group_weight" ]
              ));
          });		
      }
      else{
        const courseRecordId = courseData.find((e) => e.canvasid == jsonObj.course_id).id;
          parsedDataArray.push( new assignmentGroupModel(
            jsonObj[ "id" ].toString(),
            jsonObj["courseid"],
            jsonObj[ "name" ],
            jsonObj[ "group_weight" ]
          ));		
      }

      return parsedDataArray;     
  }   
}