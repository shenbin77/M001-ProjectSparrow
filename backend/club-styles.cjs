'use strict';
const M=require('../vendor/majiang-core/lib');
const ProfessionalPlayer=require('../vendor/majiang-ai/lib/player');

class TenseiPlayer extends ProfessionalPlayer {
  select_pingju(){ return false; }
  select_fulou(dapai, info){
    const m=super.select_fulou(dapai, info);
    if(!m) return m;
    const current=M.Util.xiangting(this.shoupai);
    if(M.Util.xiangting(this.shoupai.clone().fulou(m)) < current) return m;
    return undefined;
  }
}

class PressurePlayer extends ProfessionalPlayer {
  select_pingju(){ return this.allow_pingju(this.shoupai); }
  select_fulou(dapai, info){
    const inner=[];
    const m=super.select_fulou(dapai, inner);
    if(m) return m;
    const base=inner.find(e=>e.m==='');
    if(!base) return undefined;
    const cand=inner.find(e=>e.m && typeof e.ev==='number' && e.ev >= base.ev - 50);
    return cand ? cand.m : undefined;
  }
}

function getStyle(style){
  switch(style){
    case 'professional': return new ProfessionalPlayer();
    case 'pressure': return new PressurePlayer();
    case 'tensei': return new TenseiPlayer();
    case 'rookie': return null;
    default: throw new Error('Invalid AI style: '+String(style));
  }
}

module.exports={getStyle,TenseiPlayer,PressurePlayer};
