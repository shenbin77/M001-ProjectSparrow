'use strict';
const M = require('../vendor/majiang-core/lib');

function choicesFor(game, seat) {
  const out = [], add = (label, reply) => out.push({label, reply});
  const own = game.model.lunban === seat, status = game._status;
  if (own && ['zimo','gangzimo','fulou'].includes(status)) {
    // A called open kan proceeds directly to its replacement draw.
    if (status === 'fulou' && game._gang) return out;
    const discards = game.get_dapai() || [];
    if (status !== 'fulou') {
      if (game.allow_hule()) add('Tsumo', {hule:true});
      for (const m of game.get_gang_mianzi() || []) add('Kan '+m, {gang:m});
      if (game.allow_pingju()) add('Nine terminals draw', {pingju:true});
    }
    for (const p of discards) {
      add('Discard '+p, {dapai:p});
      if (status !== 'fulou' && game.allow_lizhi(p)) add('Riichi '+p, {dapai:p+'*'});
    }
  } else if (!own && ['dapai','gang'].includes(status)) {
    if (status === 'gang' && /^[mpsz]\d{4}$/.test(game._gang)) return out;
    if (game.allow_hule(seat)) add('Ron', {hule:true});
    if (status === 'dapai') {
      for (const m of game.get_gang_mianzi(seat) || []) add('Open kan '+m,{fulou:m});
      for (const m of game.get_peng_mianzi(seat) || []) add('Pon '+m,{fulou:m});
      for (const m of game.get_chi_mianzi(seat) || []) add('Chi '+m,{fulou:m});
    }
    if (out.length) add('Pass',{});
  }
  return out;
}

// Only the acting player's hand enters this policy: no wall/opponent inspection.
function selectAI(hand, choices) {
  const win = choices.find(c=>c.reply.hule);
  if (win) return win.reply;
  const discards = choices.filter(c=>c.reply.dapai);
  if (!discards.length) return {};
  let best = null, bestScore = Infinity;
  for (const c of discards) {
    const copy = hand.clone().dapai(c.reply.dapai);
    const score = M.Util.xiangting(copy)*100 - M.Util.tingpai(copy).length - (c.reply.dapai.endsWith('*') ? 0.1 : 0);
    if (score < bestScore) { bestScore=score; best=c.reply; }
  }
  return best;
}

function execute(request) {
  if (!request || !['new','action','auto'].includes(request.op)) throw Error('Invalid operation');
  const state = request.op === 'new' ? {seed:request.seed ?? Date.now()%4294967296,replies:[]} : request.state;
  if (!state || !Number.isInteger(state.seed) || state.seed<0 || state.seed>4294967295 || !Array.isArray(state.replies) || state.replies.length>1000) throw Error('Invalid replay state');
  const replies = JSON.parse(JSON.stringify(state.replies));
  let rng=state.seed, index=0, pending=null, result=null, done=false, actionUsed=false;
  const oldRandom=Math.random;
  Math.random=()=>{rng=(rng+0x6D2B79F5)|0; let t=Math.imul(rng^(rng>>>15),1|rng); t^=t+Math.imul(t^(t>>>7),61|t); return ((t^(t>>>14))>>>0)/4294967296;};
  try {
    const players=Array.from({length:4},()=>({action(_msg,cb){if(cb) cb({});}}));
    const game=new M.Game(players,paipu=>{done=true; result={scores:paipu.defen,rank:paipu.rank,points:paipu.point,log:paipu.log};},M.rule({'場数':0,'連荘方式':0,'延長戦方式':0}),'Project Sparrow single-hand contest');
    game._sync=true;
    game.kaiju(0);
    for (let steps=0;steps<2000;steps++) {
      const seat=game.model.player_id.indexOf(0);
      for (let s=0;s<4;s++) {
        const choices=choicesFor(game,s);
        if (!choices.length) continue;
        const id=game.model.player_id[s];
        if (id!==0) {game._reply[id]=selectAI(game.model.shoupai[s],choices);continue;}
        let reply;
        if (index<replies.length) reply=replies[index];
        else if (request.op==='auto') { reply=selectAI(game.model.shoupai[s],choices); replies.push(reply); }
        else if (request.op==='action' && !actionUsed) {reply=request.choice;replies.push(reply);actionUsed=true;}
        else {pending=choices;break;}
        if (!choices.some(c=>JSON.stringify(c.reply)===JSON.stringify(reply))) throw Error('Illegal action in replay or request');
        game._reply[0]=reply; index++;
      }
      if (pending || done) break;
      game.next();
      if (done) break;
      if (steps===1999) throw Error('Simulation step limit');
    }
    if (index<replies.length) throw Error('Replay contains excess actions');
    if(request.op==='action'&&!actionUsed) throw Error('No decision available');
    const model=game.model,seat=model.player_id.indexOf(0);
    return {ok:true,state:{seed:state.seed,replies},hand:model.shoupai[seat]?.toString()||'',melds:model.shoupai.map(h=>h._fulou.slice()),discards:model.he.map(h=>h._pai.slice()),scores:model.defen.slice(),dora:model.shan?.baopai||[],wall:model.shan?.paishu||0,choices:pending||[],done,result,seat,status:game._status,mode:'single-hand-riichi'};
  } finally {Math.random=oldRandom;}
}
module.exports={execute,choicesFor,selectAI};
