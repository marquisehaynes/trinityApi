import * as fs         from 'fs';
import csv from 'csv-parser';
import  * as util from '../util/index.js';  
import Parser from 'json2csv';

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
                  element[ "courseId" ],
                  element[ "name" ],
                  element[ "group_weight" ]
              ));
          });		
      }
      else{
          parsedDataArray.push( new assignmentGroupModel(
            jsonObj[ "id" ].toString(),
            jsonObj[ "courseId" ],
            jsonObj[ "name" ],
            jsonObj[ "group_weight" ]
          ));		
      }

      return parsedDataArray;     
  }   
}