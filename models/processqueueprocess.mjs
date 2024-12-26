import * as fs         from 'fs';
import * as CopyStream from 'pg-copy-streams';
import csv from 'csv-parser';
import  * as util from '../util/index.js';  
import Parser from 'json2csv';

export default class processQueueProcessModel{    
  static columns = new Set(['processid', 'processname', 'processstatus', 'processstarttime', 'processendtime', 'targetobject', 'failuremessage', 'totalbatches', 'failedbatches']);
  static conflictColumn = 'canvasid';
  
  processid;
  processname;
  processstatus;
  processstarttime;
  processendtime;
  targetobject;
  failuremessage;
  totalbatches;
  failedbatches;

  constructor(processId, processName, processStatus, processStartTime, processEndTime, targetObj, totalBatches){
    this.processid = processId;
    this.processname = processName;
    this.processstatus = processStatus;
    this.processstarttime = processStartTime;
    this.processendtime = processEndTime;
    this.targetobject = targetObj;
    this.totalbatches = totalBatches;
    this.failedbatches = 0;
  }

  async postToDb(pgPool){
    util.upsertJsonToDb(this, processqueue, processQueueProcessModel.columns, processQueueProcessModel.conflictColumn, pgPool);
  }
}