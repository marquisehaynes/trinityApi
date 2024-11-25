const models = import('./models/index.js');
const { parse } = require('json2csv');
const CopyStream = require('pg-copy-streams');
const { Client, Pool } = require('pg');
const express = require('express');
const https = require('node:https');
const app = express();
const fs = require('fs');
const dbConfig = JSON.parse(fs.readFileSync('config.json','utf8')).database;
const pgConn = new Client({
	user: dbConfig.username,
	password: dbConfig.password,
	host: dbConfig.host,
	port: dbConfig.port,
	database: dbConfig.dbName,
});
const pgPool = new Pool({
	user: dbConfig.username,
	password: dbConfig.password,
	host: dbConfig.host,
	port: dbConfig.port,
	database: dbConfig.dbName,
	max: 25,
	idleTimeoutMillis: 5000,
	connectionTimeoutMillis: 2000
});

function makeHttpsRequest(requestDefinition, callback) {
	https.get(requestDefinition, (response) => {
	  let data = '';
  
	  // A chunk of data has been received.
	  response.on('data', (chunk) => {
		data += chunk;
	  });
  
	  // The response has ended.
	  response.on('end', () => {
		callback(null, data);
	  });
	}).on('error', (err) => {
	  callback(err, null);
	});
}


  
async function getAllFromTable(tableName, callback) {
	try {
		const client = await pgPool.connect(); 
		const result = await client.query(`SELECT * FROM ${tableName}`);
		client.release();
		callback(null, result);
	} catch (error) {
		callback(error, null);
	}
}

app.listen(3000, () => {
 console.log("Server running on port 3000");
});

app.get("/msg", (req, res, next) => {
 res.json({"message": "onRes"});
});

app.get("/", (req, res, next) => {
 res.json({"message": JSON.stringify(dbConfig)});
});

app.get("/confirmdbconnection", (req, res, next) => {
	pgConn.connect()
	.then(() => {
		res.json({"message": 'database connected'});
	})
	.catch((err) => {
	res.json({"message": 'Error connecting to PostgreSQL database::: '+err});
	});
});

app.get('/synccourses', (req, res) => {
	let canvasConfig = JSON.parse(fs.readFileSync('config.json','utf8')).canvas;
	let canvasRequestDef = {
		protocol:'https:',
		hostname: 'canvas.instructure.com',
		port: 443,
		path: '/api/v1/courses?per_page=1000',
		method: 'GET',
		headers: {
		  'Authorization': 'Bearer '+canvasConfig.authToken
		}
	};
	makeHttpsRequest(canvasRequestDef, (error, data) => {
		if (error) {
			return res.status(500).json({ message: 'Error fetching data', error });
		}
	  	let parsedData = JSON.parse(data);
		let parsedDataCSV;
		
		let parsedDataArray = models.courseModel.convertJSONtoArray(parsedData);
	
	  	parsedDataCSV = parse(parsedDataArray);
		console.log(parsedDataCSV);	  
		res.status(200).json(parsedDataCSV); // Return the data as JSON to the client
		
		//save to csv
		const fileName = './extracts/courses/courseData_' + new Date().toISOString() +'.csv';
		
		fs.writeFile(fileName, parsedDataCSV, 'utf8', function (err) {
			if (err) {
				console.log('Some error occured - file either not saved or corrupted file saved.');
			} 
			else{
				const csvFilePath = fileName; //path.join(__dirname, 'data.csv');
				const tableName = 'course';

				models.courseModel.copyCsvToPostgres(csvFilePath, tableName, pgPool)
				.then(() => {
					console.log('It\'s saved!');
					console.log('CSV import completed');
				
				})
				.catch((err) => console.error('Error importing CSV:', err));
				
			}
		  });
	});

	
});
