export default class studentModel{   
  static columns = new Set(['canvasid', 'fullname', 'sortablename']);
  static conflictColumn = 'canvasid';
  canvasid;
  fullname;
  sortablename;

  constructor( canvasId, fullName, sortableName ){
      this.canvasid          = canvasId;
      this.fullname          = fullName;
      this.sortablename      = sortableName;
  }

  static convertJSONtoArray(jsonObj) {
    const data = [];

    if( Array.isArray( jsonObj ) ) {
      for(const element of jsonObj){
        const std = new studentModel(
          element["user"]["id"].toString(),
          element["user"]["name"],
          element["user"]["sortable_name"]
        );

        if(!data.includes(JSON.stringify(std))){
          data.push(JSON.stringify(std));
        }
      }	
    }
    else{
      const std = new studentModel(
        jsonObj["user"]["id"].toString(),
        jsonObj["user"]["name"],
        jsonObj["user"]["sortable_name"]
      );
      if(!data.includes(JSON.stringify(std))){
        data.push(JSON.stringify(std));
      }
    }

    return data.map(e => JSON.parse(e));   
  }
}