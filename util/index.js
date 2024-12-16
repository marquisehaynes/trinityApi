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
            ['submissions','']
        ]);
    }
    else{
        objPathMap = new Map([
            ["courses", '/api/v1/courses?per_page=1000']
            ['submissions','']
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
        }
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
