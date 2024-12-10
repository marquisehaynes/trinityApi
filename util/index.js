import fs from 'fs';
export function getCanvasRequestDefinition(targetObj,params){
    const canvasToken= JSON.parse(fs.readFileSync('config.json','utf8')).canvas.authToken;
    const objPathMap = new Map([
        ["course", "/api/v1/courses/" + params.get('courseId') + "/enrollments?per_page=1000"]
    ]);
    return canvasRequestDef = {
        protocol: 'https:',
        hostname: 'canvas.instructure.com',
        port: 443,
        path: '/api/v1/courses/' + courseId + '/enrollments?per_page=1000',
        method: 'GET',
        headers: {
            'Authorization': 'Bearer ' + canvasToken
        }
    };
}
