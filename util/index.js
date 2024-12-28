import fs from 'fs';
import https	     from 'https';
import Parser from 'json2csv';

export function getCanvasRequestDefinition(targetObj,params){
    const canvasToken= JSON.parse(fs.readFileSync('config.json','utf8')).canvas.authToken;
    let objPathMap;
    if(params){
        objPathMap = new Map([
            ["students", "/api/v1/courses/" + params.get('courseId') + "/enrollments?per_page=1000"],
            ["courses", '/api/v1/courses?per_page=1000'],
            ["assignmentgroups", '/api/v1/courses/' + params.get('courseId') + '/assignment_groups?per_page=1000'],
            ['assignments','/api/v1/courses/' + params.get('courseId') + '/assignments?per_page=1000'],
            ['submissions','/api/v1/courses/' + params.get('courseId') + '/students/submissions?student_ids[]=all&include[]=user&workflow_state=graded&per_page=35000']
        ]);
    }
    else{
        objPathMap = new Map([
            ["courses", '/api/v1/courses?per_page=1000']
        ]);
    }
    return {
        protocol: 'https:',
        hostname: 'canvas.instructure.com',
        port: 443,
        path: objPathMap.get(targetObj),
        method: 'GET',
        headers: {
            'Authorization': 'Bearer ' + canvasToken
        },
        agent: new https.Agent({
            keepAlive: true,
            maxSockets: 15,
            keepAliveMsecs: 60000,
            maxFreeSockets: 5
        })
    };
}

export function writeFilePromise(fileName, data, encodingType) {
	return new Promise((resolve, reject) => {
		fs.writeFile(file, data, encodingType, (err) => {
			if (err) {
				reject(err);
			} else {
				resolve(fileName);
			}
		});
	});
}

export function makeHttpsRequest(requestDefinition) {
	return new Promise((resolve, reject) => {
		https.get(requestDefinition, (response) => {
			let data = '';
			response.on('data', (chunk) => {
			data += chunk;
			});
			response.on('end', () => {
			resolve(data);
			});
		}).on('error', (err) => {
			reject(err);
		});
	});
}

export function getAllFromTable(tableName) {
    return new Promise(async (resolve, reject) => {
        try {
            const client = await pgPool.connect();
            const result = await client.query(`SELECT * FROM ${tableName}`);
            client.release();
            resolve(result);
        } catch (error) {
            console.error(error);
            reject(error);
        }
    });
}

export async function upsertJsonToDb(jsonContent, tableName, tableColumns, conflictColumn, pool) {
    let status = true;
    const results = [];
    try {
        // Start a transaction
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
        
            // Iterate through records and insert them into the PostgreSQL table
            for (const record of jsonContent) {
                const row = new Array(tableColumns.length);
                let queryStr = '';
                let conflictString = '';
                const conflictColumnArr = [];
                try {
                    let valStr = '';
                    let valIndex = 1;                    
                    for(const col of tableColumns){
                        valStr += '$'+valIndex + ', ';
                        valIndex++;
                        row.push(record[col]);
                        if(col != conflictColumn){
                            conflictColumnArr.push(col +' = EXCLUDED.' + col)
                        }
                    }
                    valStr = valStr.trim().endsWith(',') ? valStr.trim().substring(0, valStr.trim().length - 1) : valStr.trim();
                    queryStr =  'INSERT INTO '+ tableName +' ('+ Array.from(tableColumns).join(', ') + ') VALUES ('+ valStr +')';
                    conflictString = 'ON CONFLICT (' + conflictColumn + ') DO UPDATE SET ' +  conflictColumnArr.join(', ') + ';';
                    queryStr = queryStr + ' ' + conflictString;
                    await client.query( queryStr, row.filter( e => e != undefined ));
                    results.push({ record, success: true, error: null });
                } 
                catch (insertError) {
                    console.error('Insert error for ' + tableName + ' record:', record, insertError.message);
                    console.error('Query:', queryStr);
                    console.error('Data:',  row.filter( e => e != undefined ));
                    results.push({ record, success: false, error: insertError.message });
                    status = false;
                }
            }
        
            await client.query('COMMIT');
            console.log('All ' + tableName + ' records processed.');
        } 
        catch (transactionError) {
            await client.query('ROLLBACK');
            console.error('Transaction error:', transactionError.message);
            status = false;
        } 
        finally {
            client.release();
            // Log results
           // console.log('Results:', results);            
        }    
        
    } catch (err) {
        console.error('Error connecting to database:', err.message);
    } finally {
        return { 'status' : status, 'results' : results };
    }
}

export async function getRecentLoadStatus(pool){
    const query = `SELECT DISTINCT ON (targetobject) processid, targetobject, processstarttime
                    FROM processqueue
                    WHERE processstatus LIKE 'Complete%' 
                    AND processname = 'Load Data' 
                    AND processstarttime >= NOW() - INTERVAL '24 hours'
                    ORDER BY targetobject, processstarttime DESC;`
    const client = await pool.connect();
    const result = await client.query( query );
    client.release();
    if(Array.isArray(result.rows)){
        const ret = result.rows.map( e =>{ return e.targetobject });
        return ret;
    }
    else{
        return result.rows.targetobject;
    }
}

export async function saveCsv(parsedData, obj){
    const assCSV = Parser.parse(parsedData);
    const assFileName = './extracts/'+ obj +'/' +obj+ 'Data_' + new Date().toISOString().replace(/[: ]/g, '_') + '.csv';
    fs.writeFileSync(assFileName, assCSV);    
}