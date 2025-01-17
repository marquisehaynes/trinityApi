
export default class processQueueProcessModel{    
  static columns = new Set(['id', 'processname', 'processstatus', 'processstarttime', 'processendtime', 'targetobject', 'failuremessage', 'totalbatches', 'failedbatches']);
  static conflictColumn = 'id';
  
  id;
  processname;
  processstatus;
  processstarttime;
  processendtime;
  targetobject;
  failuremessage;
  totalbatches;
  failedbatches;

  constructor( processName, targetObj, totalBatches){
    this.processname = processName;
    this.targetobject = targetObj;
    this.totalbatches = totalBatches;
    this.failedbatches = 0;
    this.processstatus = 'Running';
    this.processstarttime = new Date().toISOString();
  }

  async post(client){
    let row = new Array(processQueueProcessModel.columns.length); 
    let queryStr;
    try {
      if(!this.failuremessage && this.id ){ this.failuremessage = ''; }
        await client.query('BEGIN');        
        for(const col of processQueueProcessModel.columns){
            row.push(this[col]);
        }
        row = row.filter( e => e != undefined );
        
        if( this.id ){
          
          queryStr =  `INSERT INTO processqueue ( id, processname, processstatus, processstarttime, processendtime, targetobject, failuremessage, totalbatches, failedbatches ) 
                     VALUES ( $1, $2, $3, $4, $5, $6, $7 , $8, $9)
                     ON CONFLICT (id) 
                     DO UPDATE SET 
                     processstatus = EXCLUDED.processstatus,
                     processendtime = EXCLUDED.processendtime,
                     failuremessage = EXCLUDED.failuremessage,
                     failedbatches = EXCLUDED.failedbatches
                     `;
        }
        else{
          queryStr =  `INSERT INTO processqueue ( processname, processstatus, processstarttime, targetobject, totalbatches, failedbatches, id ) 
                     VALUES ( $1, $2, $3, $4, $5, $6, DEFAULT )
                     RETURNING id
                     `;
        }
        
        const result = await client.query( queryStr, row );
        if(result.rows.length > 0){
          this.id = result.rows[0].id;
        }  
        
        await client.query('COMMIT');
        console.log('ProcessQueue item upserted. Id: '+this.id + ' Name: ' + this.processname + ' Object: '+ this.targetobject + ' Status: '+ this.processstatus);
    } 
    catch (transactionError) {
        await client.query('ROLLBACK');
        console.error('PQ Transaction error:', transactionError.message);
        console.error('Data: ', row);
        console.error('Query: ', queryStr);
    }
  }
}