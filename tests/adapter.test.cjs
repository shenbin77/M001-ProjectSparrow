'use strict';
const test=require('node:test');
const assert=require('node:assert/strict');
const {execute}=require('../backend/adapter.cjs');
test('seeded opening and replay are deterministic',()=>{
  const a=execute({op:'new',seed:42}),b=execute({op:'new',seed:42});
  assert.deepEqual(a,b);
  const next=execute({op:'action',state:a.state,choice:a.choices[0].reply});
  assert.equal(next.state.replies.length,1);
  assert.deepEqual(next,execute({op:'action',state:b.state,choice:b.choices[0].reply}));
});
test('rejects malformed state and illegal actions',()=>{
  assert.throws(()=>execute({op:'unknown'}));
  assert.throws(()=>execute({op:'new',seed:-1}));
  assert.throws(()=>execute({op:'action',state:{seed:1,replies:[]},choice:{hule:true}}),/Illegal/);
  assert.throws(()=>execute({op:'auto',state:{seed:1,replies:[{dapai:'bad'}]}}),/Illegal/);
});
test('50 deterministic automatic single-hand games terminate with conserved points',()=>{
  let wins=0;
  for(let seed=0;seed<50;seed++){
    const final=execute({op:'auto',state:{seed,replies:[]}});
    assert.equal(final.done,true,'seed '+seed);
    assert.equal(final.scores.reduce((a,b)=>a+b),100000,'seed '+seed);
    assert.equal(final.choices.length,0);
    assert.ok(final.result.log.length>=1);
    if(final.result.log.some(hand=>hand.some(event=>event.hule))) wins++;
    assert.deepEqual(final,execute({op:'auto',state:final.state}));
  }
  assert.ok(wins>0,'AI must complete actual scored wins, not only exhaustive draws');
});
test('interactive replay supports chi, pon and both kan paths without deadlock',()=>{
  const seen=new Set();
  for(let seed=0;seed<30;seed++){
    let game=execute({op:'new',seed});
    for(let n=0;!game.done && n<150;n++){
      const choice=game.choices.find(c=>c.reply.hule)
        || game.choices.find(c=>c.reply.fulou||c.reply.gang)
        || game.choices.find(c=>c.reply.dapai?.endsWith('*'))
        || game.choices[0];
      assert.ok(choice,'every paused state exposes an action');
      seen.add(choice.label.split(' ')[0]);
      game=execute({op:'action',state:game.state,choice:choice.reply});
    }
    assert.equal(game.done,true,'interactive seed '+seed);
  }
  for(const kind of ['Chi','Pon','Kan','Open']) assert.ok(seen.has(kind),kind+' exercised');
});
