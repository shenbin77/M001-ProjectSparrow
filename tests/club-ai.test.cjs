'use strict';
const test=require('node:test');
const assert=require('node:assert/strict');
const {execute}=require('../backend/adapter.cjs');
test('pressure style is deterministic with same seed',()=>{
  const state={seed:42,replies:[],ai_profile:'professional',ai_profiles:['pressure','pressure','pressure']};
  const a=execute({op:'auto',state});
  const b=execute({op:'auto',state});
  assert.deepEqual(a,b);
  assert.equal(a.done,true);
  assert.equal(a.scores.reduce((x,y)=>x+y),100000);
});
test('tensei style is deterministic with same seed',()=>{
  const state={seed:42,replies:[],ai_profile:'professional',ai_profiles:['tensei','tensei','tensei']};
  const a=execute({op:'auto',state});
  const b=execute({op:'auto',state});
  assert.deepEqual(a,b);
  assert.equal(a.done,true);
  assert.equal(a.scores.reduce((x,y)=>x+y),100000);
});
test('pressure differs from professional on same seed',()=>{
  const p=execute({op:'auto',state:{seed:42,replies:[],ai_profile:'professional',ai_profiles:['pressure','pressure','pressure']}});
  const q=execute({op:'auto',state:{seed:42,replies:[],ai_profile:'professional',ai_profiles:['professional','professional','professional']}});
  assert.ok(JSON.stringify(p.result.log)!==JSON.stringify(q.result.log)
    ||JSON.stringify(p.state.replies)!==JSON.stringify(q.state.replies),
    'pressure and professional should diverge');
});
test('per-seat styles are deterministic and returned in state',()=>{
  const state={seed:7,replies:[],ai_profile:'rookie',ai_profiles:['rookie','tensei','pressure']};
  const a=execute({op:'auto',state});
  const b=execute({op:'auto',state});
  assert.deepEqual(a,b);
  assert.equal(a.done,true);
  assert.equal(a.scores.reduce((x,y)=>x+y),100000);
  assert.deepEqual(a.state.ai_profiles,['rookie','tensei','pressure']);
});
test('rejects invalid style names and malformed ai_profiles',()=>{
  assert.throws(()=>execute({op:'new',seed:1,ai_profiles:['nope','tensei','pressure']}),/Invalid AI/);
  assert.throws(()=>execute({op:'new',seed:1,ai_profiles:['rookie','tensei']}),/Invalid AI/);
  assert.throws(()=>execute({op:'new',seed:1,ai_profile:'nope'}),/Invalid AI/);
});
test('legacy professional protocol without ai_profiles is unchanged',()=>{
  const state={seed:42,replies:[],ai_profile:'professional'};
  const a=execute({op:'auto',state});
  const b=execute({op:'auto',state});
  assert.deepEqual(a,b);
  assert.equal(a.done,true);
  assert.equal(a.scores.reduce((x,y)=>x+y),100000);
  assert.equal(a.state.ai_profile,'professional');
  assert.notDeepEqual(a.state.replies,execute({op:'auto',state:{...state,ai_profile:'rookie'}}).state.replies);
});
test('start_match request shape (rookie base + per-club styles) is legal for all four clubs',()=>{
  const CLUB_STYLES=['rookie','tensei','pressure','professional'];
  for (const style of CLUB_STYLES) {
    const r=execute({op:'new',seed:7,ai_profile:'rookie',ai_profiles:[style,style,style]});
    assert.equal(r.ok,true,'club style '+style+' rejected');
    assert.deepEqual(r.state.ai_profiles,[style,style,style]);
  }
  assert.throws(()=>execute({op:'new',seed:7,ai_profile:'tensei',ai_profiles:['tensei','tensei','tensei']}),/Invalid AI profile/);
});
