'use strict';
// Offline deterministic batch runner. AI simulation is not human playtesting.
const fs=require('node:fs');
const {execute}=require('./adapter.cjs');
const count=Number(process.argv[2]||1000);
const profile=process.argv[3]||'rookie';
const output=process.argv[4]||'work/playtest.json';
if(!Number.isInteger(count)||count<1||count>10000) throw Error('count 1..10000 required');
if(!['rookie','professional','pressure','tensei'].includes(profile)) throw Error('Unknown profile: '+profile);
const usePerSeat=profile==='pressure'||profile==='tensei';
const records=[];
for(let seed=0;seed<count;seed++){
  const start=performance.now();
  try {
    const state={seed,replies:[],ai_profile:usePerSeat?'professional':'rookie'};
    if(usePerSeat) state.ai_profiles=[profile,profile,profile];
    const result=execute({op:'auto',state});
    const conserved=result.scores.reduce((a,b)=>a+b)===100000;
    records.push({seed,done:result.done,conserved,ms:Math.round(performance.now()-start),scores:result.scores,decisions:result.state.replies.length});
  } catch(e){records.push({seed,error:e.message,ms:Math.round(performance.now()-start)});}
  if((seed+1)%100===0) console.log(`${seed+1}/${count}`);
}
const failures=records.filter(r=>r.error||!r.done||!r.conserved);
const report={profile,count,failures:failures.length,max_ms:Math.max(...records.map(r=>r.ms)),mean_ms:Math.round(records.reduce((s,r)=>s+r.ms,0)/count),positive_player_results:records.filter(r=>r.scores?.[0]>25000).length,records};
fs.writeFileSync(output,JSON.stringify(report,null,2));
console.log(JSON.stringify({...report,records:undefined}));
process.exitCode=failures.length?1:0;
