'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const {characters} = require('../data/characters.json');
test('eight original player records have valid ids, club links and four skill choices',()=>{
  assert.equal(characters.length,8);
  const ids=new Set(characters.map(c=>c.id));
  assert.equal(ids.size,8);
  for(const c of characters){
    assert.ok(c.age>=18 && c.age<90);
    assert.ok(['sparrow','dragon','crane','tide'].includes(c.club));
    assert.ok(c.mentor_id==='' || ids.has(c.mentor_id));
    for(const k of ['attack','defense','reading','mental','potential']) assert.ok(Number.isInteger(c[k]) && c[k]>=1 && c[k]<=100,k);
    assert.equal(c.skills.length,4);
    for(const k of ['name','style','desire','flaw']) assert.ok(typeof c[k]==='string' && c[k].length>0,k);
  }
});
