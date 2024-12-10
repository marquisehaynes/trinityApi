import * as models from './models/index.js';
import https	     from 'https';
import express	   from 'express';
import fs		   		 from 'fs';
import pg		   		 from 'pg';
import Parser	   	 from 'json2csv';

const CopyStream = import( 'pg-copy-streams' );
const app				 = new express();
const dbConfig	 = JSON.parse( fs.readFileSync( 'config.json','utf8' ) ).database;
const pgPool = new pg.Pool({
	user										: dbConfig.username,
	password								: dbConfig.password,
	host										: dbConfig.host,
	port										: dbConfig.port,
	database								: dbConfig.dbName,
	max											: 25,
	idleTimeoutMillis				: 20000,
	connectionTimeoutMillis : 20000,
});

function writeFilePromise(fileName, data, encodingType) {
	return new Promise((resolve, reject) => {
		fs.writeFile(file, data, encodingType, (err) => {
			if (err) {
				reject(err);
			} else {
				resolve();
			}
		});
	});
}

function makeHttpsRequest(requestDefinition) {
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


/* function makeHttpsRequest( requestDefinition, callback ) {
	https.get( requestDefinition, ( response ) => {
		
	  let data = '';
  
	  // A chunk of data has been received.
	  response.on( 'data', ( chunk ) => {
			data += chunk;
	  });
  
	  // The response has ended.
	  response.on( 'end', () => {
			callback( null, data );
	  });

	}).on( 'error', ( err ) => {
	  callback( err, null) ;
	});

}
*/

async function handleCourses( ) {
	let canvasConfig		 = JSON.parse(fs.readFileSync('config.json','utf8')).canvas;
	let canvasRequestDef = {
		protocol :'https:',
		hostname : 'canvas.instructure.com',
		port		 : 443,
		path		 : '/api/v1/courses?per_page=1000',
		method	 : 'GET',
		headers	 : {
		  'Authorization' : 'Bearer ' + canvasConfig.authToken
		}
	};
	makeHttpsRequest( canvasRequestDef, ( error, data ) => {
		if ( error ) {
			return res.status( 500 ).json( { message : 'Error fetching data', error } );
		}
		const courseParsedData = JSON.parse( data );		
		const courseDataArray = models.courseModel.convertJSONtoArray( courseParsedData );	
	  	const courseDataCSV = Parser.parse( courseDataArray );
		//res.status( 200 ).json( courseDataCSV ); // Return the data as JSON to the client
		
		//save courses to csv
		const fileName = './extracts/courses/courseData_' + new Date().toISOString().replace(':', '_') + '.csv';
		writeFilePromise(fileName, courseDataCSV, 'utf8')
		.catch((err) =>{

		})
		.then(() =>{
			//Upsert Course CSV
			models.courseModel.upsertCsvData( csvFilePath, pgPool );
		})
		.then(()=>{
			//Student & CourseStudent Promise Prep
			return Promise.allSettled( courseDataArray.map((element) => {
				const courseId = element['canvasid'];       		
				canvasRequestDef = {
					protocol: 'https:',
					hostname: 'canvas.instructure.com',
					port: 443,
					path: '/api/v1/courses/' + courseId + '/enrollments?per_page=1000',
					method: 'GET',
					headers: {
						'Authorization': 'Bearer ' + canvasConfig.authToken
					}
				};
	
				return new Promise((resolve, reject) => {
					makeHttpsRequest(canvasRequestDef, (error, data) => {
						if (error) {
							return reject({ message: 'Error fetching course data for course: ' + courseId, error });
						}
	
						// For each element in roster array, add to maps
						const parsedCourseStudents = JSON.parse(data);
						if (parsedCourseStudents.length > 0) {
							for (let j = 0; j < parsedCourseStudents.length; j++) {
								const std = parsedCourseStudents[j];
								if (std['role'] == 'StudentEnrollment' && std['user']['name'] != 'Test Student') {
									const student = new models.studentModel(
										parseInt(std['user']['id']),
										std['user']['name'],
										std['user']['sortable_name']
									);
									//studentArray.push(student);
									studentMap.set(std['user']['id'], student);
									courseStudentArray.push(new models.courseStudentModel( parseInt(courseId), std['user']['id'] ));
								}
							}
						}
						resolve(); // Resolve the promise when the request is completed
					});
				});
			}));
		})
		.then((promiseArr) =>{
			Promise.allSettled(promiseArr)
		})
		fs.writeFile( fileName, courseDataCSV, 'utf8', function ( err ) {
			if ( err ) {
				console.log( 'Some error occured - course file either not saved or corrupted file saved.' );
			} 
			else{
				const csvFilePath = fileName; 
				models.courseModel.upsertCsvData( csvFilePath, pgPool )
				.then( () => {
					//Handle Students and CourseStudents
					const studentMap = new Map();
					const courseStudentArray = [];
					outerStudentPromises = courseDataArray.map((element) => {
						const courseId = element['canvasid'];       		
						canvasRequestDef = {
							protocol: 'https:',
							hostname: 'canvas.instructure.com',
							port: 443,
							path: '/api/v1/courses/' + courseId + '/enrollments?per_page=1000',
							method: 'GET',
							headers: {
								'Authorization': 'Bearer ' + canvasConfig.authToken
							}
						};
			
						return new Promise((resolve, reject) => {
							makeHttpsRequest(canvasRequestDef, (error, data) => {
								if (error) {
									return reject({ message: 'Error fetching course data for course: ' + courseId, error });
								}
			
								// For each element in roster array, add to maps
								const parsedCourseStudents = JSON.parse(data);
								if (parsedCourseStudents.length > 0) {
									for (let j = 0; j < parsedCourseStudents.length; j++) {
										const std = parsedCourseStudents[j];
										if (std['role'] == 'StudentEnrollment' && std['user']['name'] != 'Test Student') {
											const student = new models.studentModel(
												parseInt(std['user']['id']),
												std['user']['name'],
												std['user']['sortable_name']
											);
											//studentArray.push(student);
											studentMap.set(std['user']['id'], student);
											courseStudentArray.push(new models.courseStudentModel( parseInt(courseId), std['user']['id'] ));
										}
									}
								}
								resolve(); // Resolve the promise when the request is completed
							});
						});
					});
				});
				
			}
		});
	});


}
  
app.get( '/syncall', ( req, res ) => {
	handleCourses()
	.catch(err => {

	})
	.then(
		handleStudents();
	)
});

async function getAllFromTable( tableName, callback ) {

	try {
		const client = await pgPool.connect(); 
		const result = await client.query( `SELECT * FROM ${ tableName }` );

		client.release();
		callback( null, result );
	}
	
	catch( error ) {
		console.error(error);
		callback( error, null );
	}

}

app.listen( 3000, () => {
 console.log( "Server running on port 3000" );
});


app.get( '/syncassgroups', ( req, res ) => {
	let canvasConfig		 = JSON.parse(fs.readFileSync('config.json','utf8')).canvas;
	
	let canvasRequestDef = {
		protocol: 'https:',
		hostname: 'canvas.instructure.com',
		port: 443,
		path: '/api/v1/courses/' + '10627765' + '/assignment_groups?per_page=1000',
		method: 'GET',
		headers: {
			'Authorization': 'Bearer ' + canvasConfig.authToken
		}
	};
	makeHttpsRequest(canvasRequestDef, (error, data) => {
		if (error) {
			return reject({ message: 'Error fetching course data for assignment groups: ' + courseId, error });
		}
		const assGroups = JSON.parse(data);
		let parsedAssGroupArray = models.assignmentGroupModel.convertJSONtoArray( assGroups, 10627765 );
	
	  	let parsedAssGroupCSV = Parser.parse( parsedAssGroupArray );
		

		const fileName = './extracts/assignmentgroups/assignmentGroupData_' + new Date().toISOString().replace(':', '_') + '.csv';
		
		fs.writeFile( fileName, parsedAssGroupCSV, 'utf8', function ( err ) {

			if ( err ) {
				console.log( 'Some error occured - file either not saved or corrupted file saved.' );
			} 
			else{
				const csvFilePath = fileName; 
				models.assignmentGroupModel.upsertCsvData( csvFilePath, pgPool )
				.then( () => {
					res.status( 200 ).json( parsedAssGroupCSV );
				})
				.catch( ( err ) => console.error( 'Error importing CSV: ', err ) );
				
			}
		});

	});
});

app.get( '/synccourses', ( req, res ) => {
	let canvasConfig		 = JSON.parse(fs.readFileSync('config.json','utf8')).canvas;
	let canvasRequestDef = {
		protocol :'https:',
		hostname : 'canvas.instructure.com',
		port		 : 443,
		path		 : '/api/v1/courses?per_page=1000',
		method	 : 'GET',
		headers	 : {
		  'Authorization' : 'Bearer ' + canvasConfig.authToken
		}
	};
	

	makeHttpsRequest( canvasRequestDef, ( error, data ) => {
		if ( error ) {
			return res.status( 500 ).json( { message : 'Error fetching data', error } );
		}
		let parsedData = JSON.parse( data );
		let parsedDataCSV;
		
		//let parsedDataArray = model.courseModel.someBullShit();
		let parsedDataArray = models.courseModel.convertJSONtoArray( parsedData );
	
	  	parsedDataCSV = Parser.parse( parsedDataArray );
		
		res.status( 200 ).json( parsedDataCSV ); // Return the data as JSON to the client
		
		//save to csv
		const fileName = './extracts/courses/courseData_' + new Date().toISOString().replace(':', '_') + '.csv';
		
		fs.writeFile( fileName, parsedDataCSV, 'utf8', function ( err ) {

			if ( err ) {
				console.log( 'Some error occured - file either not saved or corrupted file saved.' );
			} 
			else{
				const csvFilePath = fileName; 
				models.courseModel.upsertCsvData( csvFilePath, pgPool )
				.then( () => {
					//Process AssignmentGroups
					const assGrpPromises = parsedDataArray.map((element) => {
						const courseId = element['canvasid'];       
			
						let canvasRequestDef = {
							protocol: 'https:',
							hostname: 'canvas.instructure.com',
							port: 443,
							path: '/api/v1/courses/' + courseId + '/assignment_groups?per_page=1000',
							method: 'GET',
							headers: {
								'Authorization': 'Bearer ' + canvasConfig.authToken
							}
						};
			
						return new Promise((resolve, reject) => {
							makeHttpsRequest(canvasRequestDef, (error, data) => {
								if (error) {
									return reject({ message: 'Error fetching course data for course: ' + courseId, error });
								}
								const assignments = JSON.parse(data);
								assignments.map((element)=>{

								})
							
								resolve(); // Resolve the promise when the request is completed
							});
						});
					});

					// Wait for all promises to resolve using Promise.all
					Promise.allSettled(assGrpPromises)
					.then(() => {
						const studentArr = Array.from(studentMap.values());
						console.log(studentMap.size); // Log after all requests are completed
						
						const parsedDataCSV = Parser.parse( studentArr );
						//save to csv
						const fileName = './extracts/students/studentData_' + new Date().toISOString().replace(':', '_') + '.csv';
						try {
							fs.writeFile( fileName, parsedDataCSV, 'utf8', function ( err ) {
		
								if ( err ) {
									console.log( 'Some error occured - student file either not saved or corrupted file saved.' );
								} 
								else{
									const csvFilePath = fileName; 
									models.studentModel.upsertCsvData( csvFilePath, pgPool )
									.then( () => {  
										const parsedCourseStudentCSV = Parser.parse( courseStudentArray );
										//save to csv
										const csfileName = './extracts/coursestudents/courseStudentData_' + new Date().toISOString().replace(':', '_') + '.csv';
										try {
											fs.writeFile( csfileName, parsedCourseStudentCSV, 'utf8', function ( err ) {
												if ( err ) {
													console.log( 'Some error occured - student file either not saved or corrupted file saved.' );
												} 
												models.courseStudentModel.upsertCsvData(csfileName, pgPool)
												.then(()=>{
													console.log('CourseStudents updated successfully');
													getAllFromTable('coursestudent', (error, data) => {
														if (error) {
															return res.status(500).json({ message: 'Error querying coursestudents after update', error });
														}
														const retArr = data.rows;
														res.status(200).json(retArr); // Send the response after all requests
									
													});
												})
												.catch((err)=>{
													console.error('Error importing courseStudent csv: ', error);
												})
											});
										}
										catch (fileSaveError) {
											console.log(fileSaveError);
										}
										
									})
									.catch( ( err ) => console.error( 'Error importing student CSV: ', err ) );
									
									
								}
							})
						} catch (fileSaveError) {
							console.log(fileSaveError);
						}
					})
					.catch((error) => {
						res.status(500).json(error); // Handle any errors from the promises
					})
					.finally(()=>{
						
						
					})

				})
				.catch( ( err ) => console.error( 'Error importing CSV: ', err ) );
				
			}
		});
	});

	
});

app.get('/syncstudents', (req, res) => {
    const canvasConfig = JSON.parse(fs.readFileSync('config.json', 'utf8')).canvas;
    const studentMap = new Map();
	const courseStudentArray = [];
    // Query all courses
    getAllFromTable('course', (error, data) => {
        if (error) {
            return res.status(500).json({ message: 'Error querying courses', error });
        }
        const courseArray = data.rows;

        // Create an array of promises for each course
        const coursePromises = courseArray.map((element) => {
            const courseId = element['canvasid'];       

            let canvasRequestDef = {
                protocol: 'https:',
                hostname: 'canvas.instructure.com',
                port: 443,
                path: '/api/v1/courses/' + courseId + '/enrollments?per_page=1000',
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + canvasConfig.authToken
                }
            };

            return new Promise((resolve, reject) => {
                makeHttpsRequest(canvasRequestDef, (error, data) => {
                    if (error) {
                        return reject({ message: 'Error fetching course data for course: ' + courseId, error });
                    }

                    // For each element in roster array, add to maps
                    const parsedCourseStudents = JSON.parse(data);
                    if (parsedCourseStudents.length > 0) {
                        for (let j = 0; j < parsedCourseStudents.length; j++) {
                            const std = parsedCourseStudents[j];
                            if (std['role'] == 'StudentEnrollment' && std['user']['name'] != 'Test Student') {
                                const student = new models.studentModel(
                                    parseInt(std['user']['id']),
                                    std['user']['name'],
                                    std['user']['sortable_name']
                                );
                                //studentArray.push(student);
                                studentMap.set(std['user']['id'], student);
								courseStudentArray.push(new models.courseStudentModel( parseInt(courseId), std['user']['id'] ));
                            }
                        }
                    }
                    resolve(); // Resolve the promise when the request is completed
                });
            });
        });

        // Wait for all promises to resolve using Promise.all
        Promise.allSettled(coursePromises)
            .then(() => {
				const studentArr = Array.from(studentMap.values());
                console.log(studentMap.size); // Log after all requests are completed
                
				const parsedDataCSV = Parser.parse( studentArr );
				//save to csv
				const fileName = './extracts/students/studentData_' + new Date().toISOString().replace(':', '_') + '.csv';
				try {
					fs.writeFile( fileName, parsedDataCSV, 'utf8', function ( err ) {

						if ( err ) {
							console.log( 'Some error occured - student file either not saved or corrupted file saved.' );
						} 
						else{
							const csvFilePath = fileName; 
							models.studentModel.upsertCsvData( csvFilePath, pgPool )
							.then( () => {  
								const parsedCourseStudentCSV = Parser.parse( courseStudentArray );
								//save to csv
								const csfileName = './extracts/coursestudents/courseStudentData_' + new Date().toISOString().replace(':', '_') + '.csv';
								try {
									fs.writeFile( csfileName, parsedCourseStudentCSV, 'utf8', function ( err ) {
										if ( err ) {
											console.log( 'Some error occured - student file either not saved or corrupted file saved.' );
										} 
										models.courseStudentModel.upsertCsvData(csfileName, pgPool)
										.then(()=>{
											console.log('CourseStudents updated successfully');
											getAllFromTable('coursestudent', (error, data) => {
												if (error) {
													return res.status(500).json({ message: 'Error querying coursestudents after update', error });
												}
												const retArr = data.rows;
												res.status(200).json(retArr); // Send the response after all requests
							
											});
										})
										.catch((err)=>{
											console.error('Error importing courseStudent csv: ', error);
										})
									});
								}
								catch (fileSaveError) {
									console.log(fileSaveError);
								}
								
							})
							.catch( ( err ) => console.error( 'Error importing student CSV: ', err ) );
							
							
						}
					})
				} catch (fileSaveError) {
					console.log(fileSaveError);
				}
            })
            .catch((error) => {
                res.status(500).json(error); // Handle any errors from the promises
            })
			.finally(()=>{
			})
    });
});
