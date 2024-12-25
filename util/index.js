import fs from 'fs';
import https	     from 'https';

export function getCanvasRequestDefinition(targetObj,params){
    const canvasToken= JSON.parse(fs.readFileSync('config.json','utf8')).canvas.authToken;
    let objPathMap;
    if(params){
        objPathMap = new Map([
            ["students", "/api/v1/courses/" + params.get('courseId') + "/enrollments?per_page=1000"],
            ["courses", '/api/v1/courses?per_page=1000'],
            ["assignmentgroups", '/api/v1/courses/' + params.get('courseId') + '/assignment_groups?per_page=1000'],
            ['assignments','/api/v1/courses/' + params.get('courseId') + '/assignments?per_page=1000'],
            ['submissions','/api/v1/courses/' + params.get('courseId') + '/students/submissions?student_ids[]=all&workflow_state=graded&per_page=35000']
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

export async function upsertJsonToDb(jsonContent, tableName, tableColumns) {
    try {
        // Read the CSV file synchronously
        const fileContent = fs.readFileSync('path/to/your.csv', 'utf-8');
    
        // Parse the CSV data
        const records = parse(fileContent, {
        columns: true, // Use the first row as column headers
        skip_empty_lines: true,
        });
    
        // Store results
        const results = [];
    
        // Start a transaction
        const client = await pool.connect();
        try {
        await client.query('BEGIN');
    
        // Iterate through records and insert them into the PostgreSQL table
        for (const record of records) {
            try {
            await client.query(
                'INSERT INTO your_table (column1, column2, column3) VALUES ($1, $2, $3)',
                [record.column1, record.column2, record.column3]
            );
            results.push({ record, success: true, error: null });
            } catch (insertError) {
            console.error('Insert error for record:', record, insertError.message);
            results.push({ record, success: false, error: insertError.message });
            }
        }
    
        await client.query('COMMIT');
        console.log('All records processed.');
        } catch (transactionError) {
        await client.query('ROLLBACK');
        console.error('Transaction error:', transactionError.message);
        } finally {
        client.release();
        }
    
        // Log results
        console.log('Results:', results);
    } catch (err) {
        console.error('Error reading or processing the CSV file:', err.message);
    } finally {
        await pool.end();
    }
}