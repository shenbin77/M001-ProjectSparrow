'use strict';
const {execute}=require('./adapter.cjs');
function respond(line) {
  try { if(line.length>200000) throw Error('Request too large'); process.stdout.write(JSON.stringify(execute(JSON.parse(line)))+'\n'); }
  catch(error) { process.stdout.write(JSON.stringify({ok:false,error:error.message})+'\n'); }
}
if(process.argv[2]==='--request-file') {
  const fs=require('node:fs');
  let response;
  try {
    if(fs.statSync(process.argv[3]).size>200000) throw Error('Request too large');
    response=execute(JSON.parse(fs.readFileSync(process.argv[3],'utf8')));
  } catch(error) { response={ok:false,error:error.message}; }
  fs.writeFileSync(process.argv[4],JSON.stringify(response));
}
else if(process.argv[2]) respond(process.argv[2]);
else require('node:readline').createInterface({input:process.stdin,crlfDelay:Infinity}).on('line',respond);
