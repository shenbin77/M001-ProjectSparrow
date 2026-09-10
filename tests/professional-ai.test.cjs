'use strict';
const test=require('node:test');
const assert=require('node:assert/strict');
const {execute}=require('../backend/adapter.cjs');
test('professional open-source AI is deterministic and preserved across replay',()=>{
  const state={seed:42,replies:[],ai_profile:'professional'};
  const a=execute({op:'auto',state});
  const b=execute({op:'auto',state});
  assert.deepEqual(a,b);
  assert.equal(a.done,true);
  assert.equal(a.scores.reduce((x,y)=>x+y),100000);
  assert.equal(a.state.ai_profile,'professional');
  assert.notDeepEqual(a.state.replies,execute({op:'auto',state:{...state,ai_profile:'rookie'}}).state.replies);
});
test('reject unsupported AI profiles rather than silently changing difficulty',()=>{
  assert.throws(()=>execute({op:'new',seed:1,ai_profile:'not-an-ai'}),/Invalid AI/);
});
