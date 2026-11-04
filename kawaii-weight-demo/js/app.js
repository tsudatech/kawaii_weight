
const MOODS = {
  happy:{lg:'lg_happy', sm:'sm_happy', label:'るんるん'},
  good:{lg:'lg_good', sm:'sm_good', label:'グッド'},
  hmm:{lg:'lg_hmm', sm:'sm_hmm', label:'うーん'},
  trouble:{lg:'lg_trouble', sm:'sm_trouble', label:'こまった'},
  crying:{lg:'lg_crying', sm:'sm_crying', label:'なきそう'},
  angry:{lg:'lg_angry', sm:'sm_angry', label:'おこ'},
  tired:{lg:'lg_tired', sm:'sm_tired', label:'つかれ'},
  sleepy:{lg:'lg_sleepy', sm:'sm_sleepy', label:'ねむい'},
  surprise:{lg:'lg_surprise', sm:'sm_surprise', label:'びっくり'},
  doya:{lg:'lg_doya', sm:'sm_doya', label:'どやっ'},
  nightcap:{lg:'lg_nightcap', sm:'sm_nightcap', label:'ねぶそく'},
  cozy:{lg:'lg_cozy', sm:'sm_cozy', label:'ぬくぬく'},
  lonely:{lg:'lg_lonely', sm:'sm_lonely', label:'さみしい'},
  cheer:{lg:'lg_cheer', sm:'sm_cheer', label:'おうえん'}
};
const LINES = {
  happy:  ['やったー！ちゃんと減ってるよ！','この調子この調子♪','すごい！えらい！'],
  good:   ['いい感じ！','コツコツがいちばん！','今日もえらいね'],
  hmm:    ['うーん、横ばいだね','そういう日もあるよ','明日も一緒にはかろ'],
  trouble:['ちょっと増えちゃった…','そういう日もあるよ','気にしすぎないでね'],
  crying: ['えーん、増えてるよぉ','昨日なに食べた…？','明日がんばろ…'],
  angry:  ['ずっと増えてる！','もう！おやつ禁止！','いっしょに歩きに行くよ！'],
  tired:  ['きょうは休んでいいよ','ちょっとひとやすみ','焦らずいこ'],
  sleepy: ['まだはかってないよ〜','ふぁ…おはよう','体重計のってきて〜'],
  surprise:['えっ！こんなに減ってる！？','びっくりした〜！すごいよ','ほんとに？もう一回のってみて！'],
  doya:   ['さいしん最軽量！ふふん','記録更新だよ、どやっ','この調子でいくもんね〜'],
  workout:['運動したんだね、えらい！','汗かいたね〜おつかれさま','うごいたぶん、ちゃんと効いてるよ'],
  nightcap:['寝不足だと増えやすいの。きょうは早く寝よ','ふぁ…ねむねむ','睡眠もダイエットのうちだよ'],
  cozy:   ['きょうはゆっくり休もうね','あったかくして、のんびりしよ','お休みの日も大事だよ'],
  lonely: ['さみしかったよぉ…','また会えてうれしい…','きょうから、またいっしょにはかろ？'],
  cheer:  ['がんばれ〜！ずっと応援してるよ','フレー！フレー！','いっしょにゴールめざそ！'],
  congrats:['おめでと〜！！','やったね！ばんざーい！','いっしょにお祝いしよ！']
};
const TAGS = ['飲み会','外食','寝不足','のんびり','運動した'];
/* 増えた日にタグがあると、キャラがやさしく受け止める */
const TAG_REACT = {
  'のんびり':{mood:'cozy',  line:'のんびりした日も大事だよ。また明日ね'},
  '飲み会':{mood:'trouble', line:'飲み会たのしかった？2〜3日で戻るよ'},
  '外食':  {mood:'hmm',     line:'外食は塩分多めだもんね。すぐ戻るよ'},
  '寝不足':{mood:'nightcap',line:'寝不足だと増えやすいの。きょうは早く寝よ'}
};
const LV_TITLES = ['はじめまして','顔見知り','なかよし','しんゆう','ずっといっしょ'];
const BADGES = [
  {id:'first',   big:'1',   unit:'かいめ', name:'はじめての\nきろく', mood:'happy', title:'はじめてのきろく！', msg:'これから毎日いっしょにはかろうね', gift:'ごほうび：ひょうじょうずかん'},
  {id:'streak7', big:'7',   unit:'日',    name:'7日\nれんぞく',   mood:'doya', title:'7日れんぞく！',     msg:'1週間つづいたね。すごい！',     gift:'ごほうび：なかよし度 +5'},
  {id:'down1',   big:'1',   unit:'kg',    name:'1kg\nへった',     mood:'happy', title:'1kgへったよ！',     msg:'はじめた日から1kgも減ったよ。えらすぎる〜！', gift:'ごほうび：きせかえ「リボン」（準備中）'},
  {id:'streak30',big:'30',  unit:'日',    name:'30日\nれんぞく',  mood:'doya',  title:'30日れんぞく！',    msg:'1か月毎日きろく。もう習慣だね', gift:'ごほうび：きせかえ「パジャマ」（準備中）'},
  {id:'down3',   big:'3',   unit:'kg',    name:'3kg\nへった',     mood:'surprise', title:'3kgへったよ！',     msg:'見た目でもわかるくらいだよ！',   gift:'ごほうび：おへやの背景（準備中）'},
  {id:'rec50',   big:'50',  unit:'かい',  name:'きろく\n50回',    mood:'cheer',  title:'きろく50回！',      msg:'50回もはかってくれてありがとう', gift:'ごほうび：なかよし度 +10'},
  {id:'goal',    big:'🎯',  unit:'',      name:'もくひょう\n達成', mood:'happy', title:'もくひょう達成！',  msg:'ほんとにやったね！！いっしょにお祝いしよ', gift:'ごほうび：とくべつな表情（準備中）'},
  {id:'streak100',big:'100',unit:'日',    name:'100日\nれんぞく', mood:'happy', title:'100日れんぞく！',   msg:'伝説の100日…！ずっといっしょだよ', gift:'ごほうび：きんのかんむり（準備中）'}
];

/* ---- データ ---- */
const DAY = 864e5;
const today0 = () => { const d = new Date(); d.setHours(0,0,0,0); return d; };
const key = d => { const z = n => String(n).padStart(2,'0'); return `${d.getFullYear()}-${z(d.getMonth()+1)}-${z(d.getDate())}`; };
const parse = k => new Date(k+'T00:00:00');
const daysBetween = (a,b) => Math.round((parse(b)-parse(a))/DAY);
const esc = s => String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const DEFAULT_OPTS = {remind:true, time:'07:30', talk:true, move:true, strict:false, judge:'trend', hide:false, health:true, game:false};
const STORE = 'kawaii-weight-v5';
const hashK = k => [...k].reduce((h,c)=>(h*31 + c.charCodeAt(0)) >>> 0, 7);
const BOT_PAT = ['same','down','up','same','down'];

function sample(){
  // 約3か月分のサンプル（ゆるやかに減少・たまに抜けの日あり・今日は未記録）
  const logs = {}, meta = {}; let w = 60.4; const t = today0(); let s = 7;
  const rnd = () => (s = (s*16807) % 2147483647) / 2147483647;
  const skip = new Set([77,63,52,41,33]);
  const tagged = {3:{tags:['飲み会'],memo:'友だちと焼肉'},2:{tags:['外食']},6:{tags:['運動した'],memo:'30分ウォーキング'},
    9:{tags:['運動した']},12:{tags:['のんびり']},13:{tags:['のんびり']},16:{tags:['運動した']},25:{tags:['外食'],memo:'ラーメン'},19:{tags:['寝不足']}};
  for(let i=89;i>=1;i--){
    w += -0.06 + (rnd()-0.5)*0.7;
    if(i===3||i===2) w += 0.35;
    if(i===13||i===12) w += 0.25;
    if(i===48) w += 0.6;          // ごほうびの日の翌朝
    if(i===46) w -= 0.5;
    if(skip.has(i)) continue;
    const k = key(new Date(t - i*DAY));
    logs[k] = +w.toFixed(1);
    meta[k] = {fat: +(w*0.48 + (rnd()-0.5)*0.6).toFixed(1), ...(tagged[i]||{})};
  }
  // 体重よそう：直近40日のうち、ときどき予想している（6割くらい的中）
  const ks = Object.keys(logs).sort(), opts3 = ['up','same','down'];
  ks.forEach((k,n) => {
    if(!n || daysBetween(k, key(t)) > 40 || rnd() < 0.15) return;
    const d = +(logs[k]-logs[ks[n-1]]).toFixed(1), act = d>0.1?'up':d<-0.1?'down':'same';
    meta[k].guess = rnd() < 0.62 ? act : opts3.filter(x=>x!==act)[rnd()<.5?0:1];
    meta[k].bot = BOT_PAT[hashK(k) % 5];
  });
  const treats = {[key(new Date(t - 49*DAY))]: true};   // 49日前に「ごほうびの日」をせんげんしていた
  const st = {logs, meta, treats, goal:55.0, height:160, name:'', opts:{...DEFAULT_OPTS}, onboarded:true};
  st.badges = computeBadges(st);
  return st;
}
function load(){
  try{ const s = JSON.parse(localStorage.getItem(STORE));
    if(s && s.logs){ s.meta = s.meta||{}; s.treats = s.treats||{}; Object.values(s.meta).forEach(m => { if(m.tags) m.tags = m.tags.filter(x => TAGS.includes(x)); }); s.opts = {...DEFAULT_OPTS, ...(s.opts||{})}; s.badges = s.badges||computeBadges(s); if(s.onboarded===undefined) s.onboarded = true; return s; } }catch(e){}
  return sample();
}
function persist(){ try{ localStorage.setItem(STORE, JSON.stringify(state)); }catch(e){} }

/* ---- ごほうび判定 ---- */
function computeBadges(st){
  const ks = Object.keys(st.logs).sort(); if(!ks.length) return [];
  let best = 1, run = 1;
  for(let i=1;i<ks.length;i++){ run = daysBetween(ks[i-1],ks[i])===1 ? run+1 : 1; best = Math.max(best, run); }
  const first = st.logs[ks[0]], min = Math.min(...ks.map(k=>st.logs[k])), last = st.logs[ks[ks.length-1]];
  const got = ['first'];
  if(best>=7) got.push('streak7');
  if(first-min>=1) got.push('down1');
  if(best>=30) got.push('streak30');
  if(first-min>=3) got.push('down3');
  if(ks.length>=50) got.push('rec50');
  if(last<=st.goal) got.push('goal');
  if(best>=100) got.push('streak100');
  return got;
}

let state = load();
const sortedKeys = () => Object.keys(state.logs).sort();
const fmt = n => n.toFixed(1);
const sign = n => (Math.abs(n)<0.05?'±':n>0?'+':'−') + Math.abs(n).toFixed(1);
const $ = id => document.getElementById(id);
/* キャラ画像は assets/characters/ のファイル（lg_表情.png / sm_表情.png）を参照します。 */
const ASSET_DIR = 'assets/characters/';
/* 古い名前（yawn・cheer など）は新しい画像の名前に読みかえる */
const ALIAS = {"yawn": "lg_sleepy", "cheer": "lg_cheer", "surprise": "lg_surprise", "doya": "lg_doya", "nightcap": "lg_nightcap", "cozy": "lg_cozy", "lonely": "lg_lonely"};
const svgOf = name => {
  name = ALIAS[name] || name;
  return `<svg viewBox="0 0 100 100" aria-hidden="true" focusable="false"><image href="${ASSET_DIR}${name}.png" width="100" height="100"/></svg>`;
};
function markSeen(mood){
  state.seen = state.seen || [];
  if(!state.seen.includes(mood)){ state.seen.push(mood); persist(); }
}
const avg = a => a.reduce((x,y)=>x+y,0)/a.length;

/* ---- 表情判定 ---- */
function judge(k){
  const ks = sortedKeys(), i = ks.indexOf(k);
  if(i < 0) return {mood:'sleepy'};
  const w = state.logs[k], tags = (state.meta[k]||{}).tags || [];
  const trend = state.opts.judge === 'trend';
  let base = null;
  if(trend){ const prev = ks.slice(0,i).filter(x => daysBetween(x,k) <= 7); if(prev.length) base = avg(prev.map(x=>state.logs[x])); }
  else if(i > 0) base = state.logs[ks[i-1]];
  const diff = base==null ? null : +(w-base).toFixed(1);
  let mood;
  let firstLine = null;
  if(i === 0){ mood = 'happy'; firstLine = 'はじめてのきろく、ありがとう！ここがスタートだよ'; }
  else if(w <= state.goal) mood = 'good';
  else if(diff == null) mood = 'hmm';
  else if(!trend && i>=3 && [0,1,2].every(j => state.logs[ks[i-j]] > state.logs[ks[i-j-1]])) mood = 'angry';
  else if(trend && diff >= 1.0) mood = 'angry';
  else if(diff <= -0.8) mood = 'surprise';
  else if(diff < 0 && i > 0 && w < Math.min(...ks.slice(0,i).map(x=>state.logs[x]))) mood = 'doya';
  else {
    const cry = state.opts.strict ? 0.3 : 0.5;
    mood = diff <= -0.3 ? 'happy' : diff < -0.1 ? 'good' : diff <= 0.1 ? 'hmm' : diff < cry ? 'trouble' : 'crying';
  }
  let line = firstLine;
  if(diff != null && diff > 0.1){ for(const t of Object.keys(TAG_REACT)) if(tags.includes(t)){ mood = TAG_REACT[t].mood; line = TAG_REACT[t].line; break; } }
  if(diff != null && diff > 0.1 && treatHit(k)){ mood = 'cozy'; line = 'ごほうびの日、たのしかった？もどるまで見守るね'; }
  if(!line && tags.includes('運動した')){ line = diff!=null && diff<0 ? '運動したから減ったね！えらい！' : '運動したんだね、えらい！'; }
  return {mood, diff, base, line};
}
/* その日の顔：自分でえらんだ顔があればそれ、なければ体重から自動で決めた顔 */
const PICK_FACES = Object.keys(MOODS);
const FACE_REPLY = {
  happy:'るんるんな気分なんだね！いいね〜', good:'いい感じなんだね、よかった！', hmm:'うーん、な日もあるよね',
  trouble:'こまったことあった？むりしないでね', crying:'かなしい気分なんだね…そばにいるよ',
  angry:'ぷんぷんな気分なんだね。なにかあった？', tired:'つかれてるんだね。ゆっくりしてね', sleepy:'ねむいよね…きょうは早めに寝よ',
  surprise:'びっくりすることあった？', doya:'どやっ！な気分なんだね、いいね〜', nightcap:'ねぶそくなんだね。むりしないでね',
  cozy:'ぬくぬくしたい気分なんだね', lonely:'さみしい気分なんだね…そばにいるよ', cheer:'がんばるぞ！な気分なんだね。おうえんしてる！'
};
const moodFor = k => ((state.meta[k]||{}).face) || judge(k).mood;
function dayFace(k){
  const j = judge(k), f = (state.meta[k]||{}).face;
  return f && f !== j.mood ? {mood:f, line:FACE_REPLY[f] || LINES[f][0], picked:true, auto:j.mood} : {mood:j.mood, line:j.line, picked:false, auto:j.mood};
}

/* ---- ごほうびの日（前もってせんげんした日と、その翌朝は増えてもおちこまない） ---- */
const isTreat = k => !!(state.treats||{})[k];
const prevDayKey = k => key(new Date(+parse(k) - DAY + 3600e3));
const nextDayKey = k => key(new Date(+parse(k) + DAY + 3600e3));
const treatHit = k => isTreat(k) || isTreat(prevDayKey(k));

/* ---- 体重よそう ---- */
const GUESS = {up:{l:'ふえた',a:'↑'}, same:{l:'おなじ',a:'→'}, down:{l:'へった',a:'↓'}};
const GM_TITLES = ['よそう見習い','よそう上手','よそう名人','よそう博士','よそうの神さま'];
function prevRec(k){ const ks = sortedKeys().filter(x => x < k); return ks.length ? ks[ks.length-1] : null; }
function botGuess(k){
  // キャラのよそう：飲み会・外食・ごほうびの日のあとは「へった」、ほかは気まぐれ
  const p = prevRec(k);
  if(p){ const tg = (state.meta[p]||{}).tags || []; if(tg.includes('飲み会') || tg.includes('外食') || treatHit(p)) return 'down'; }
  return BOT_PAT[hashK(k) % 5];
}
function actualOf(k){
  const p = prevRec(k); if(!p || !(k in state.logs)) return null;
  const d = +(state.logs[k] - state.logs[p]).toFixed(1); return d > 0.1 ? 'up' : d < -0.1 ? 'down' : 'same';
}
function guessResult(k){
  const me = state.meta[k]||{}; if(!me.guess) return null;
  const act = actualOf(k); if(!act) return null;
  const bot = me.bot || botGuess(k), hit = me.guess === act, botHit = bot === act;
  return {guess:me.guess, bot, act, hit, botHit, pts:(hit?10:0) + (hit && !botHit ? 5 : 0)};
}
function gameStats(){
  const ym = key(today0()).slice(0,7); let pts=0, n=0, hits=0, win=0, lose=0, mN=0, mH=0, run=0, best=0;
  sortedKeys().forEach(k => { const r = guessResult(k); if(!r) return;
    n++; pts += r.pts; if(r.hit){ hits++; run++; best = Math.max(best, run); } else run = 0;
    if(r.hit && !r.botHit) win++; if(!r.hit && r.botHit) lose++;
    if(k.slice(0,7) === ym){ mN++; if(r.hit) mH++; } });
  const lv = Math.floor(pts/100) + 1;
  return {pts, n, hits, win, lose, mRate: mN ? Math.round(mH/mN*100) : null, run, best, lv, inLv: pts % 100, title: GM_TITLES[Math.min(lv-1, GM_TITLES.length-1)]};
}

/* ---- もどるまで見守り：タグつきで増えた日から、もとの体重（その前の7日平均）にもどるまで ---- */
const WATCH_TAGS = ['飲み会','外食'];
function watches(){
  const ks = sortedKeys(), done = []; let cur = null;
  ks.forEach(k => {
    const w = state.logs[k];
    if(cur){
      if(w <= cur.base + 0.1){ cur.end = k; cur.days = daysBetween(cur.start, k); done.push(cur); cur = null; return; }
      if(daysBetween(cur.start, k) > 14) cur = null;      // 2週間もどらなければ、そっと終わり（失敗にはしない）
      else { cur.cur = w; cur.peak = Math.max(cur.peak, w); return; }
    }
    const tags = (state.meta[k]||{}).tags || [];
    const label = treatHit(k) ? 'ごほうびの日' : WATCH_TAGS.find(x => tags.includes(x));
    if(!label) return;
    const j = judge(k); if(j.base == null || j.diff == null || j.diff <= 0.1) return;
    cur = {start:k, label, base:+j.base.toFixed(1), peak:w, cur:w};
  });
  if(cur && daysBetween(cur.start, key(today0())) > 14) cur = null;
  return {done, active:cur};
}
const H = () => !!state.opts.hide;
const GAME = () => !!state.opts.game;   // 体重よそう（せっていでオンにした人だけ）
const CLOUD = s => `<svg viewBox="0 0 100 64" aria-hidden="true" style="transform:scale(${s})"><path d="M22 56a15 15 0 0 1 2-30 18 18 0 0 1 33-6 16 16 0 0 1 28 9 13 13 0 0 1 3 27z" fill="#DCE5E8" stroke="#4A3020" stroke-width="2.6" stroke-linejoin="round"/><path d="M40 40q4 4 8 0M58 40q4 4 8 0" fill="none" stroke="#4A3020" stroke-width="2.4" stroke-linecap="round"/></svg>`;
const SUN = `<svg viewBox="0 0 100 64" aria-hidden="true"><g stroke="#E9A94F" stroke-width="3" stroke-linecap="round"><path d="M50 4v8M50 52v8M24 32h-8M84 32h-8M31 13l5 5M64 46l5 5M69 13l-5 5M36 46l-5 5"/></g><circle cx="50" cy="32" r="15" fill="#F3CA89" stroke="#4A3020" stroke-width="2.6"/><path d="M44 30q2 -3 4 0M52 30q2 -3 4 0M45 37q5 4 10 0" fill="none" stroke="#4A3020" stroke-width="2.2" stroke-linecap="round"/></svg>`;

/* ---- ふきだし：2行に収まらないときだけ文字を小さくする ---- */
function setBubble(el, text){
  el.style.fontSize = ''; el.textContent = '';
  const s = document.createElement('span'); s.textContent = text; el.appendChild(s);
  if(!el.offsetParent) return;                 // 非表示中は測れないので、そのまま
  const cs = getComputedStyle(el), avail = el.clientHeight - parseFloat(cs.paddingTop) - parseFloat(cs.paddingBottom);
  let fs = parseFloat(cs.fontSize);
  while(s.offsetHeight > avail + 1 && fs > 11){ fs -= 1; el.style.fontSize = fs + 'px'; }
}

/* ---- キャラ表示 ---- */
const charSlots = {
  home:{el:'char', bub:'bubble', mood:null, idx:0, custom:null},
  room:{el:'char2', bub:'bubble2', mood:null, idx:0, custom:null}
};
function setChar(slot, mood, anim, custom){
  const s = charSlots[slot], el = $(s.el);
  if(s.mood !== mood){ el.innerHTML = svgOf(MOODS[mood].lg); s.mood = mood; s.idx = 0; }
  markSeen(mood);
  s.custom = custom || null;
  const L = LINES[mood];
  let line = s.idx===0 && s.custom ? s.custom : L[(s.idx - (s.custom?1:0)) % L.length];
  if(slot==='room' && state.name && s.idx===0) line = `${state.name}だよ。${line}`;
  setBubble($(s.bub), line);
  el.setAttribute('aria-label', MOODS[mood].label + '：タップでしゃべる');
  if(anim){ el.classList.remove('pop','shake'); void el.offsetWidth; el.classList.add(anim); }
  if(slot==='home') document.querySelectorAll('.face').forEach(f => f.setAttribute('aria-pressed', f.dataset.mood === mood));
  if(slot==='room') document.querySelectorAll('#dex button').forEach(f => f.setAttribute('aria-pressed', f.dataset.mood === mood));
}
['home','room'].forEach(slot=>{
  const el = $(charSlots[slot].el);
  const talk = () => { const s = charSlots[slot]; s.idx++; setChar(slot, s.mood, 'pop', s.custom); };
  el.addEventListener('click', talk);
  el.addEventListener('keydown', e => { if(e.key==='Enter'||e.key===' '){ e.preventDefault(); talk(); } });
});
let override = null, simAbsent = false;

function absentDays(){
  if(simAbsent) return 3;
  const ks = sortedKeys(), tk = key(today0());
  if(!ks.length || tk in state.logs) return 0;
  const g = daysBetween(ks[ks.length-1], tk); return g >= 3 ? g : 0;
}
function todayState(){
  const tk = key(today0()), gap = absentDays();
  if(!sortedKeys().length) return {mood:'cheer', line:'はじめまして！まずは、いまの体重を教えてね'};
  if(gap) return {mood:'lonely', line:`${gap}日もどこ行ってたの…さみしかったよぉ`};
  if(tk in state.logs){
    const f = dayFace(tk); let mood = f.mood, line = f.line;
    if(!f.picked){
      const cl = watches().done.find(x => x.end === tk), g = GAME() ? guessResult(tk) : null;
      if(cl){ mood = 'happy'; line = `もやもや、はれたよ！${cl.days}日でもとにもどったね`; }
      else if(g && g.hit && ['trouble','crying','angry'].includes(mood)) line = 'ふえたけど、よそうはあたり！さすがだね';
      else if(g && g.hit && !g.botHit) line = 'よそうでぼくに勝ったね！くやし〜';
    }
    return {mood, line};
  }
  if(sortedKeys().length && GAME()){
    const me = state.meta[tk]||{};
    return {mood:'sleepy', line: me.guess ? `「${GUESS[me.guess].l}」によそうしたね。のってきて〜` : 'ふえた？へった？はかる前によそうしてみて'};
  }
  return {mood:'sleepy', line:null};
}

/* ---- チャート ---- */
function drawChart(svgId, range, H, showAvg){
  const tk = today0(), pts = [];
  for(let i=range-1;i>=0;i--){ const k = key(new Date(tk - i*DAY)); if(k in state.logs) pts.push({i:range-1-i, w:state.logs[k], k}); }
  const svg = $(svgId), W=320, L=34, R=10, T=16, B=26;
  if(!pts.length){ svg.innerHTML = `<rect x="8" y="10" width="304" height="${H-20}" rx="16" fill="#FBF5F0" stroke="#EADDD1" stroke-dasharray="5 5"/><text x="160" y="${H/2-4}" text-anchor="middle" style="font-family:var(--font-ui);font-size:13px;fill:#8C7564;font-weight:700">きろくがたまると、ここにグラフが出るよ</text><text x="160" y="${H/2+16}" text-anchor="middle" style="font-family:var(--font-ui);font-size:11px;fill:#B5A193">まずは1日目をきろくしてみよう</text>`; return; }
  const ws = pts.map(p=>p.w).concat(state.goal);
  const lo = Math.floor(Math.min(...ws)-.3), hi = Math.ceil(Math.max(...ws)+.3);
  const x = i => L + (W-L-R) * (i/(range-1));
  const y = w => T + (H-T-B) * (1-(w-lo)/(hi-lo));
  const step = (hi-lo) > 6 ? 2 : 1;
  let g = '';
  for(let v=lo; v<=hi; v+=step) g += `<line x1="${L}" x2="${W-R}" y1="${y(v)}" y2="${y(v)}" stroke="#F1E6DC"/><text class="yl" x="${L-6}" y="${y(v)+4}" text-anchor="end">${v}</text>`;
  [[0,range-1],[Math.round((range-1)/2),range-1-Math.round((range-1)/2)],[range-1,0]].forEach(([i,ago])=>{
    const d = new Date(tk - ago*DAY);
    g += `<text x="${x(i)}" y="${H-6}" text-anchor="${i===0?'start':i===range-1?'end':'middle'}">${ago===0?'きょう':(d.getMonth()+1)+'/'+d.getDate()}</text>`;
  });
  g += `<line x1="${L}" x2="${W-R}" y1="${y(state.goal)}" y2="${y(state.goal)}" stroke="#9FD3C7" stroke-width="2" stroke-dasharray="5 5"/>`;
  g += `<text x="${W-R}" y="${y(state.goal)-6}" text-anchor="end" style="fill:#3E9B86">もくひょう<tspan class="yl"> ${fmt(state.goal)}</tspan></text>`;
  const path = pts.map((p,j)=>`${j?'L':'M'}${x(p.i).toFixed(1)} ${y(p.w).toFixed(1)}`).join(' ');
  const gid = svgId+'-g';
  g += `<defs><linearGradient id="${gid}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F9D2CC" stop-opacity=".9"/><stop offset="1" stop-color="#F9D2CC" stop-opacity="0"/></linearGradient></defs>`;
  g += `<path d="${path} L${x(pts[pts.length-1].i)} ${H-B} L${x(pts[0].i)} ${H-B} Z" fill="url(#${gid})"/>`;
  if(showAvg){
    const ks = sortedKeys();
    const ap = pts.map(p => { const win = ks.filter(k => { const d = daysBetween(k,p.k); return d>=0 && d<7; }); return `${x(p.i).toFixed(1)} ${y(avg(win.map(k=>state.logs[k]))).toFixed(1)}`; });
    g += `<path d="M${ap.join(' L')}" fill="none" stroke="rgba(74,48,32,.45)" stroke-width="2" stroke-linejoin="round"/>`;
  }
  g += `<path d="${path}" fill="none" stroke="#E58C86" stroke-width="${range>40?2.4:3}" stroke-linejoin="round" stroke-linecap="round"/>`;
  pts.forEach((p,j)=>{ const end = j===pts.length-1; const r = end?6:range>20?0:2.8;
    if(r) g += `<circle cx="${x(p.i)}" cy="${y(p.w)}" r="${r}" fill="${end?'#E58C86':'#fff'}" stroke="#E58C86" stroke-width="2"/>`; });
  const e = pts[pts.length-1];
  g += `<text class="yl" x="${Math.min(x(e.i), W-R-4)}" y="${y(e.w)-12}" text-anchor="end" style="fill:#4A3020;font-size:13px;font-weight:700">${fmt(e.w)}</text>`;
  svg.innerHTML = g;
}

/* ---- タグ chips ---- */
function chipsHTML(sel){ return TAGS.map(t => `<button class="chip" data-tag="${t}" aria-pressed="${sel.includes(t)}">${t}</button>`).join(''); }
function bindChips(container){ container.querySelectorAll('.chip').forEach(c => c.addEventListener('click', ()=> c.setAttribute('aria-pressed', c.getAttribute('aria-pressed')!=='true'))); }
const readChips = container => [...container.querySelectorAll('.chip[aria-pressed="true"]')].map(c=>c.dataset.tag);

/* ---- ホーム ---- */
function renderHome(){
  const ks = sortedKeys(), tk = key(today0());
  const recorded = tk in state.logs;
  const lastW = ks.length ? state.logs[ks[ks.length-1]] : null;
  const t = new Date();
  $('today').textContent = `${t.getMonth()+1}月${t.getDate()}日（${'日月火水木金土'[t.getDay()]}）`;
  let s = 0, d = today0(); if(!recorded) d = new Date(d - DAY);
  if(!simAbsent) while(state.logs[key(d)] !== undefined){ s++; d = new Date(d - DAY); }
  $('streak').textContent = s;
  $('absentBar').hidden = !simAbsent;
  const j = recorded ? judge(tk) : null;
  // 記録前＝A案（入力カードを上に）、記録後＝E案（結果を大きく）
  $('hero').classList.toggle('done', recorded);
  $('doneInfo').hidden = !recorded; $('heroStats').hidden = recorded; $('recCard').hidden = recorded;
  if(recorded){
    $('dW').textContent = H() ? 'きろくしたよ' : fmt(state.logs[tk]);
    const lbl = state.opts.judge==='trend' ? '7日平均から' : 'まえの日から';
    const word = d => d <= -0.1 ? 'いい流れだよ' : d <= 0.1 ? 'いつもどおり' : 'ちょっとふえ気味';
    $('dDelta').innerHTML = j.diff==null ? 'はじめての記録だよ' : H() ? `<span class="${j.diff<0?'down':j.diff>0?'up':''}" style="font-family:var(--font-ui)">${word(j.diff)}</span>` : `${lbl} <span class="${j.diff<0?'down':j.diff>0?'up':''}">${sign(j.diff)}kg</span>`;
  }
  $('facePick').hidden = !recorded || simAbsent;
  if(recorded) renderFacePick(tk);
  const prev7 = ks.filter(k => k < tk && daysBetween(k, tk) <= 7);
  $('sDiffL').textContent = '7日平均';
  $('sDiff').innerHTML = prev7.length ? `${fmt(avg(prev7.map(k=>state.logs[k])))}<small>kg</small>` : '<span style="font-size:15px">—</span>';
  $('sGoal').innerHTML = `${fmt(state.goal)}<small>kg</small>`;
  const left = lastW==null ? null : Math.max(0, lastW - state.goal);
  $('sLeft').innerHTML = left==null ? '—' : left===0 ? '<span class="down" style="font-size:16px">達成！</span>' : `${fmt(left)}<small>kg</small>`;
  $('recState').textContent = recorded ? (H() ? '記録ずみ' : `記録ずみ ${fmt(state.logs[tk])}kg`) : 'まだ記録してないよ';
  $('hkBtn').hidden = !state.opts.health;
  $('save').textContent = recorded ? 'きろくを更新' : 'きろくする';
  $('save').classList.toggle('done', recorded);
  $('homeTags').innerHTML = chipsHTML((state.meta[tk]||{}).tags||[]); bindChips($('homeTags'));
  drawChart('chartHome', 14, 170, false);
  $('hist').innerHTML = ks.slice().reverse().slice(0,10).map(k=>{
    const i = ks.indexOf(k), w = state.logs[k], dd = i>0 ? w - state.logs[ks[i-1]] : null;
    const m = moodFor(k), dt = parse(k), me = state.meta[k]||{};
    const sub = (isTreat(prevDayKey(k)) ? '<span class="tagS">🍰ごほうび</span>' : '') + (me.tags||[]).map(t=>`<span class="tagS">${t}</span>`).join('') + (me.memo ? '📝'+esc(me.memo) : (me.tags&&me.tags.length?'':MOODS[m].label + (me.fat&&!H()?` ・ ${fmt(me.fat)}%`:'')));
    return `<li><button class="hrow" data-k="${k}"><span class="ic">${svgOf(MOODS[m].sm)}</span>
      <span class="d">${dt.getMonth()+1}月${dt.getDate()}日<small>${sub}</small></span>
      <span class="w">${fmt(w)}<small class="${dd==null?'':dd<0?'down':dd>0?'up':''}">${dd==null?'':sign(dd)}</small></span></button></li>`;
  }).join('');
  if(!ks.length) $('hist').innerHTML = '<li class="emptyLi">まだきろくがないよ。<br>上のカードから、きょうの体重をきろくしてね</li>';
  $('hist').querySelectorAll('.hrow').forEach(b => b.addEventListener('click', ()=> openDay(b.dataset.k, 'りれき')));
  renderGoal(); renderGuess(); renderWatch(); renderTreat();
  if(!override){ const ts = todayState(); setChar('home', ts.mood, null, ts.line); }
}

/* ---- ホーム：体重よそう ---- */
function renderGuess(){
  const tk = key(today0()), recorded = tk in state.logs, p = prevRec(tk), me = state.meta[tk]||{};
  $('guessBox').hidden = recorded || !p || !GAME();
  if(p && !recorded){
    const ref = daysBetween(p, tk) === 1 ? 'きのう' : `${parse(p).getMonth()+1}/${parse(p).getDate()}`;
    $('gRef').innerHTML = H() ? `${ref}より` : `${ref}<span class="nv"> ${fmt(state.logs[p])}</span>より`;
    $('gBtns').querySelectorAll('button').forEach(b => {
      b.setAttribute('aria-pressed', b.dataset.g === me.guess);
      b.querySelector('.botMk')?.remove();
      if(me.guess && b.dataset.g === me.bot) b.insertAdjacentHTML('beforeend', '<span class="botMk">キャラ</span>');
    });
    $('gBot').textContent = me.guess ? `キャラは「${GUESS[me.bot].l}」。ちがうよそうで当てると +5pt` : 'あたると 10pt。キャラもこっそりよそうするよ';
  }
  // 記録後の結果
  const show = recorded && !!p && GAME(); $('guessRes').hidden = !show; if(!show) return;
  const g = guessResult(tk), s = gameStats();
  $('grPts').textContent = `よそう名人 Lv.${s.lv}・${s.pts}pt`;
  if(g){
    const vs = g.hit && !g.botHit ? 'キャラに勝ったよ！' : g.hit ? 'キャラもあたりで、ひきわけ' : g.botHit ? 'キャラの勝ち…' : 'どっちもはずれ';
    $('grBody').innerHTML = `<span class="gStamp ${g.hit?'':'miss'}">${g.hit?'あたり':'ざんねん'}</span>
      <span class="gTxt"><b>よそう「${GUESS[g.guess].l}」→ ほんとは「${GUESS[g.act].l}」</b><small>キャラは「${GUESS[g.bot].l}」。${vs}</small></span>
      <span class="gPts">${g.pts ? '+'+g.pts : '±0'}<small style="font-size:12px">pt</small></span>`;
  } else {
    $('grBody').innerHTML = `<span class="gStamp miss">？</span><span class="gTxt"><b>あしたは、はかる前によそうしてみてね</b><small>まえの記録より「ふえた・おなじ・へった」を当てるゲームだよ</small></span><span></span>`;
  }
  $('grFoot').innerHTML = footHTML(s);
}
const footHTML = s => `<span>こんげつの的中<b>${s.mRate==null?'—':s.mRate+'%'}</b></span><span>れんぞく的中<b>${s.run}回</b></span><span>キャラと<b>${s.win}勝${s.lose}敗</b></span>`;
$('gBtns').querySelectorAll('button').forEach(b => b.addEventListener('click', ()=>{
  const tk = key(today0()), me = state.meta[tk] = state.meta[tk] || {};
  if(me.guess === b.dataset.g) delete me.guess; else { me.guess = b.dataset.g; me.bot = me.bot || botGuess(tk); }
  persist(); renderGuess(); override = null;
  setChar('home', 'sleepy', 'pop', me.guess ? `「${GUESS[me.guess].l}」ね！ぼくは「${GUESS[me.bot].l}」。のってきて〜` : todayState().line);
}));

/* ---- ホーム：もどるまで見守り ---- */
function renderWatch(){
  const {done, active} = watches(), tk = key(today0()), cl = done.find(x => x.end === tk), el = $('watchCard');
  el.hidden = !active && !cl; if(el.hidden) return;
  el.classList.toggle('clear', !!cl);
  const md = k => `${parse(k).getMonth()+1}/${parse(k).getDate()}`;
  if(cl){
    $('wSince').textContent = `${md(cl.start)}〜${md(cl.end)}`;
    $('wCloud').innerHTML = SUN; $('wTitle').textContent = `${cl.label}のもやもや、はれた！`;
    $('wSub').textContent = `${cl.days}日でもとの体重にもどったよ。キャラタブに記録したよ`;
    $('wBar').style.width = '100%'; return;
  }
  const a = active, span = a.peak - a.base, prog = span > 0 ? Math.max(0, Math.min(1, (a.peak - a.cur)/span)) : 0;
  const left = Math.max(0.1, +(a.cur - a.base - 0.1).toFixed(1)), n = daysBetween(a.start, tk) + 1;
  $('wSince').textContent = `${md(a.start)}から ${n}日目`;
  $('wCloud').innerHTML = CLOUD(1 - prog*0.4);
  $('wTitle').textContent = `${a.label}のもやもや`;
  $('wSub').textContent = H() ? 'もとの体重にもどったら はれるよ。いっしょに見守ってるね' : `もとの ${fmt(a.base)}kg にもどったら はれるよ（あと ${fmt(left)}kg）`;
  $('wBar').style.width = Math.max(6, prog*100) + '%';
}

/* ---- ホーム：ごほうびの日せんげん ---- */
function renderTreat(){
  const tk = key(today0()), tm = nextDayKey(tk), el = $('treatCard');
  el.hidden = !(tk in state.logs); if(el.hidden) return;
  const on = isTreat(tm); el.classList.toggle('on', on);
  el.innerHTML = `<span class="ti"><svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#4A3020" stroke-width="1.8" stroke-linejoin="round"><path d="M4 12h16v8H4z" fill="#FFF6EE"/><path d="M4 15c2 1.4 4 1.4 6 0s4-1.4 6 0 3 1 4 .5" /><path d="M5 12c0-3 3-5 7-5s7 2 7 5" fill="#F9D2CC"/><circle cx="12" cy="5" r="1.6" fill="#E58C86"/></svg></span>
    <span class="tt">${on ? '<b>あしたは ごほうびの日</b>ふえてもだいじょうぶ。もどるまで見守るよ' : '<b>あしたは ごほうびの日？</b>食べる予定があれば、先に伝えておいてね'}</span>
    <button id="treatBtn">${on ? 'とりけす' : 'せんげんする'}</button>`;
  $('treatBtn').addEventListener('click', ()=>{
    state.treats = state.treats || {};
    if(on) delete state.treats[tm]; else state.treats[tm] = true;
    persist(); renderTreat(); override = null;
    setChar('home', on ? charSlots.home.mood : 'happy', 'pop', on ? 'わかった、とりけしたよ' : 'わかった！あしたは思いっきりたのしんでね');
    toast(on ? 'ごほうびの日をとりけしました' : 'あしたを ごほうびの日にしました');
  });
}
$('hkBtn').addEventListener('click', ()=>{
  const v = +(lastWeight() + (hashK(key(today0()))%5 - 3)*0.1).toFixed(1);
  clampSet(inp, v, 20, 200);
  toast(H() ? 'ヘルスケアから読みこみました（デモ）' : `ヘルスケアから ${fmt(v)}kg を読みこみました（デモ）`);
});


/* ---- きょうの顔をえらびなおす ---- */
let fpKeep = null;
function renderFacePick(tk){
  // 自動で決まった顔を先頭に、そのあと全部の表情をならべる
  const f = dayFace(tk), opts = [f.auto, ...PICK_FACES.filter(m => m !== f.auto)];
  $('fpRow').innerHTML = opts.map(m => `<button class="fp" data-m="${m}" aria-pressed="${m===f.mood}">${svgOf(MOODS[m].sm)}${MOODS[m].label}</button>`).join('');
  const sel = $('fpRow').querySelector('.fp[aria-pressed="true"]');
  const r = $('fpRow');
  if(fpKeep != null){ r.scrollLeft = fpKeep; fpKeep = null; }   // えらんだ直後はスクロール位置をそのまま
  else if(sel){ r.scrollLeft = Math.max(0, sel.offsetLeft - r.clientWidth/2 + sel.offsetWidth/2); }
  $('fpRow').querySelectorAll('.fp').forEach(b => b.addEventListener('click', ()=>{
    const m = b.dataset.m, me = state.meta[tk] = state.meta[tk] || {};
    if(m === f.auto) delete me.face; else me.face = m;
    persist(); override = null; charSlots.home.mood = null;
    fpKeep = $('fpRow').scrollLeft; renderHome();
    const ts = todayState(); setChar('home', ts.mood, 'pop', ts.line);
  }));
}

/* ---- もくひょう達成度とおうえん ---- */
const CHEERS = [
  {upTo:0,     face:'lg_hmm',     lines:['ここがスタートライン！いっしょにいこ','あせらず、まずは毎日はかろうね']},
  {upTo:10,    face:'lg_good',    lines:['いいスタート！最初の一歩がいちばんえらい','はじめたこと自体がすごいんだよ']},
  {upTo:25,    face:'cheer',      lines:['もう{p}%進んだよ！ちゃんと前に進んでる','コツコツがちゃんと数字に出てるね']},
  {upTo:50,    face:'cheer',      lines:['4分の1こえたね！このままいこ〜','半分まで、あと{toHalf}kgだよ！']},
  {upTo:75,    face:'lg_happy',   lines:['もう半分こえた！折り返しだよ〜','ここまで来たの、ほんとにすごい']},
  {upTo:90,    face:'cheer',      lines:['ゴールが見えてきた！あと{left}kg','いっしょにゴールテープ切ろうね']},
  {upTo:100,   face:'cheer',      lines:['あとちょっと！ラストスパート！','あと{left}kg…どきどきしてきた！']},
  {upTo:Infinity, face:'lg_happy', lines:['もくひょう達成おめでとう！これからはキープしよ','ほんとにがんばったね。ずっと見てたよ']}
];
let previewPct = null, cheerIdx = 0, lastBand = -1;
function goalInfo(){
  const ks = sortedKeys(); if(!ks.length) return null;
  const start = state.logs[ks[0]], goal = state.goal, span = start - goal;
  let latest = state.logs[ks[ks.length-1]];
  if(previewPct != null) latest = start - span * previewPct/100;
  const pct = span > 0 ? (start - latest)/span*100 : (latest <= goal ? 100 : 0);
  // 直近30日の傾き（kg/日）から到着日を予想
  const tk = key(today0()), rec = ks.filter(k => daysBetween(k,tk) < 30);
  let slope = 0;
  if(rec.length >= 5){
    const xs = rec.map(k => -daysBetween(k,tk)), ys = rec.map(k => state.logs[k]), mx = avg(xs), my = avg(ys);
    slope = xs.reduce((s,x,i)=>s+(x-mx)*(ys[i]-my),0) / xs.reduce((s,x)=>s+(x-mx)**2,0);
  }
  return {start, goal, latest, pct, left: Math.max(0, latest-goal), span, slope};
}
function renderGoal(){
  const g = goalInfo();
  if(!g){
    $('gPct').textContent = '0'; $('gFill').style.width = '0%'; $('gRunner').style.left = '0%'; $('gRunner').innerHTML = svgOf('sm_good');
    document.querySelectorAll('#track .tick').forEach(t => t.classList.remove('past'));
    $('gStart').textContent = '—'; $('gGoal').textContent = fmt(state.goal)+'kg';
    $('cheerFace').innerHTML = svgOf('cheer');
    $('cheerMsg').textContent = 'はじめての記録が、スタート地点になるよ';
    $('cheerSub').textContent = `もくひょうは ${fmt(state.goal)}kg。いっしょにがんばろうね`;
    return;
  }
  const pct = g.pct, shown = Math.max(0, Math.min(100, pct));
  $('gPct').textContent = Math.floor(Math.max(0, pct));
  $('gFill').style.width = shown + '%';
  $('gRunner').style.left = shown + '%';
  $('gRunner').innerHTML = svgOf(pct >= 100 ? 'sm_good' : pct < 0 ? 'sm_hmm' : 'sm_good');
  document.querySelectorAll('#track .tick').forEach(t => t.classList.toggle('past', parseFloat(t.style.left) <= shown));
  $('gStart').textContent = fmt(g.start)+'kg'; $('gGoal').textContent = fmt(g.goal)+'kg';
  const band = pct <= 0 ? 0 : CHEERS.findIndex((c,i) => i>0 && pct < c.upTo);
  if(band !== lastBand){ cheerIdx = 0; lastBand = band; }
  const c = CHEERS[band];
  const toHalf = Math.max(0, g.latest - (g.start - g.span/2));
  $('cheerFace').innerHTML = svgOf(c.face);
  const fm = Object.keys(MOODS).find(m => MOODS[m].lg === (ALIAS[c.face] || c.face)); if(fm) markSeen(fm);
  $('cheerMsg').textContent = c.lines[cheerIdx % c.lines.length]
    .replace('{p}', Math.floor(pct)).replace('{left}kg', H() ? 'もう少し' : fmt(g.left)+'kg').replace('{toHalf}kg', H() ? 'もう少し' : fmt(toHalf)+'kg');
  let sub;
  if(pct >= 100) sub = `${fmt(g.start)}kg → ${fmt(g.latest)}kg、${fmt(g.start - g.latest)}kg へったよ`;
  else if(previewPct != null) sub = `あと ${fmt(g.left)}kg（デモで達成度を変えています）`;
  else if(g.slope < -0.005){
    const days = Math.ceil(g.left / -g.slope);
    if(days > 365) sub = `あと ${fmt(g.left)}kg。ゆっくり確実にいこうね`;
    else { const eta = new Date(+today0() + days*DAY); sub = `このペースだと ${eta.getMonth()+1}月${eta.getDate()}日ごろゴールできそう（週 ${fmt(-g.slope*7)}kg ペース）`; }
  } else sub = `あと ${fmt(g.left)}kg。ペースはゆっくりでOK、続けることが大事だよ`;
  $('cheerSub').textContent = H() ? '数字はかくしているよ。このままのペースでいこうね' : sub;
  const sl = $('pctSlider'); if(sl && previewPct == null) { sl.value = Math.round(Math.max(-5, Math.min(110, pct))); $('pctVal').textContent = Math.floor(pct)+'%（実データ）'; }
}
$('cheer').addEventListener('click', ()=>{
  cheerIdx++; renderGoal();
  const c = $('cheer'); c.classList.remove('pop'); void c.offsetWidth; c.classList.add('pop');
});

/* ---- グラフ ---- */
let bigRange = 30, calOffset = 0;
function renderGraph(){
  drawChart('chartBig', bigRange, 200, true);
  const tk = today0(), ws = [];
  for(let i=bigRange-1;i>=0;i--){ const k = key(new Date(tk - i*DAY)); if(k in state.logs) ws.push(state.logs[k]); }
  if(ws.length){
    const ch = ws[ws.length-1]-ws[0], minI = ws.indexOf(Math.min(...ws));
    $('stats').innerHTML = [
      ['へいきん', fmt(avg(ws))+'<small>kg</small>', `${ws.length}日分のきろく`],
      ['この期間の変化', `<span class="${ch<0?'down':ch>0?'up':''}">${sign(ch)}</span><small>kg</small>`, ch<0?'いい流れ！':'ここから巻き返そ'],
      ['いちばん軽い', fmt(Math.min(...ws))+'<small>kg</small>', minI===ws.length-1?'さいしんが最軽量！':'更新をめざそう'],
      ['いちばん重い', fmt(Math.max(...ws))+'<small>kg</small>', `差は ${fmt(Math.max(...ws)-Math.min(...ws))}kg`]
    ].map(([a,b,c])=>`<div class="stat"><span>${a}</span><b>${b}</b><em>${c}</em></div>`).join('');
  } else $('stats').innerHTML = '';
  $('stats').hidden = !ws.length;
  const ks = sortedKeys();
  if(ks.length){
    const w = state.logs[ks[ks.length-1]], h = state.height/100, bmi = w/(h*h);
    const cat = bmi<18.5?['やせぎみ','tired']:bmi<25?['ふつう','good']:bmi<30?['ちょっと多め','trouble']:['多め','crying'];
    $('bmiNum').innerHTML = `${bmi.toFixed(1)}<small>${cat[0]}（最新 ${fmt(w)}kg）</small>`;
    $('bmiFace').innerHTML = svgOf(MOODS[cat[1]].sm);
    const pos = b => b<=18.5 ? b : b<=25 ? 18.5+(b-18.5)/6.5*32.5 : b<=30 ? 51+(b-25)/5*25 : Math.min(100, 76+(b-30)/10*24);
    $('bmiMk').style.left = pos(bmi)+'%';
    const fk = ks.slice().reverse().find(k => (state.meta[k]||{}).fat);
    $('fatNow').innerHTML = fk ? `<b>${fmt(state.meta[fk].fat)}</b>%` : '—';
    $('bmiMk').hidden = false;
  } else {
    $('bmiNum').innerHTML = `—<small>体重をきろくすると計算するよ</small>`; $('bmiFace').innerHTML = svgOf(MOODS.hmm.sm);
    $('bmiMk').hidden = true; $('fatNow').innerHTML = '—';
  }
  $('bmiH').textContent = `身長 ${state.height}cm で計算`;
  renderCal();
}
function renderCal(){
  const base = today0(); const m = new Date(base.getFullYear(), base.getMonth()+calOffset, 1);
  $('calTitle').textContent = `${m.getFullYear()}.${m.getMonth()+1}`;
  $('calNext').disabled = calOffset>=0; $('calNext').style.opacity = calOffset>=0?.3:1;
  $('calPrev').disabled = calOffset<=-3; $('calPrev').style.opacity = calOffset<=-3?.3:1;
  let html = '日月火水木金土'.split('').map(c=>`<div class="wd">${c}</div>`).join('');
  for(let i=0;i<m.getDay();i++) html += '<div></div>';
  const days = new Date(m.getFullYear(), m.getMonth()+1, 0).getDate(), tk = key(base);
  for(let d=1; d<=days; d++){
    const k = key(new Date(m.getFullYear(), m.getMonth(), d));
    const has = k in state.logs, cls = 'cell'+(has?' has':'')+(k===tk?' today':'');
    const tag = (((state.meta[k]||{}).tags||[]).length ? '<span class="dot"></span>' : '') + (isTreat(k) ? '<span class="cake" aria-label="ごほうびの日">🍰</span>' : '');
    if(k > tk) html += `<div class="${cls}"><span class="n">${d}</span>${isTreat(k) ? '<span class="cake" aria-label="ごほうびの日">🍰</span>' : ''}</div>`;
    else html += has ? `<button class="${cls}" data-k="${k}" aria-label="${d}日 ${fmt(state.logs[k])}kg"><span class="n">${d}</span>${svgOf(MOODS[moodFor(k)].sm)}<span class="w">${fmt(state.logs[k])}</span>${tag}</button>`
                     : `<button class="${cls}" data-k="${k}" aria-label="${d}日 未記録"><span class="n">${d}</span></button>`;
  }
  $('cal').innerHTML = html;
  $('cal').querySelectorAll('button.cell').forEach(b => b.addEventListener('click', ()=> openDay(b.dataset.k, 'カレンダー')));
}
document.querySelectorAll('#rangeSeg button').forEach(b => b.addEventListener('click', ()=>{
  bigRange = +b.dataset.range; document.querySelectorAll('#rangeSeg button').forEach(x=>x.setAttribute('aria-pressed', x===b)); renderGraph();
}));
$('calPrev').addEventListener('click', ()=>{ calOffset--; renderCal(); });
$('calNext').addEventListener('click', ()=>{ calOffset++; renderCal(); });

/* ---- キャラ ---- */
function renderChara(){
  const ks = sortedKeys(), n = ks.length;
  $('totalRec').textContent = n;
  const lv = Math.floor(n/15)+1, inLv = n%15;
  $('lvNum').textContent = 'Lv.'+lv;
  $('lvTitle').textContent = LV_TITLES[Math.min(lv-1, LV_TITLES.length-1)];
  $('lvBar').style.width = (inLv/15*100)+'%';
  $('lvNext').textContent = `あと${15-inLv}回でLv.${lv+1}`;
  $('badgeCount').textContent = `${state.badges.length} / ${BADGES.length}`;
  $('badges').innerHTML = BADGES.map(b => {
    const on = state.badges.includes(b.id), nm = b.name.replace('\n','<br>');
    return on ? `<button class="badge" data-b="${b.id}"><span class="medal">${b.big}<small>${b.unit}</small></span>${nm}</button>`
              : `<div class="badge off"><span class="medal">？</span>${nm}</div>`;
  }).join('');
  $('badges').querySelectorAll('button.badge').forEach(b => b.addEventListener('click', ()=> celebrate(b.dataset.b)));
  const s = gameStats(); $('gmCard').hidden = !GAME();
  $('gmPts').textContent = `${s.pts}pt`; $('gmLv').textContent = 'Lv.'+s.lv; $('gmTitle').textContent = s.title;
  $('gmBar').style.width = s.inLv + '%'; $('gmFoot').innerHTML = footHTML(s);
  const {done, active} = watches(), md = k => `${parse(k).getMonth()+1}/${parse(k).getDate()}`;
  const ds = done.slice().reverse();
  $('clCount').textContent = done.length ? `${done.length}こ・さいそく ${Math.min(...done.map(x=>x.days))}日` : '';
  $('clList').innerHTML = (active ? `<li class="now"><span>${md(active.start)} ${active.label}</span><b>見守り中</b></li>` : '')
    + ds.slice(0,5).map(x => `<li><span>${md(x.start)} ${x.label}</span><b>${x.days}日ではれた</b></li>`).join('')
    || '<li><span>まだないよ</span><b>—</b></li>';
  const counts = {}; ks.forEach(k=>{ const m = moodFor(k); counts[m]=(counts[m]||0)+1; });
  const seen = new Set(state.seen || []);
  // ずかんは最初から全部ひらいておく（数字は、その顔になった日の回数）
  const keys = Object.keys(MOODS), open = () => true;
  $('dexCount').textContent = `${keys.length}しゅるい`;
  $('dex').innerHTML = keys.map(k => open(k)
    ? `<button data-mood="${k}" aria-pressed="false">${svgOf(MOODS[k].sm)}${MOODS[k].label}<span class="cnt">${counts[k]?counts[k]+'回':'—'}</span></button>`
    : `<button class="locked" disabled aria-label="まだ見つけていない表情">${svgOf(MOODS[k].sm)}？？？<span class="cnt">—</span></button>`).join('');
  document.querySelectorAll('#dex button[data-mood]').forEach(b => b.addEventListener('click', ()=> setChar('room', b.dataset.mood, 'pop')));
  $('charName').value = state.name || '';
  const ts = todayState();
  setChar('room', charSlots.room.mood || ts.mood, null, charSlots.room.mood ? null : ts.line);
}
$('charName').addEventListener('change', e => { state.name = e.target.value.trim(); persist(); charSlots.room.idx = 0; setChar('room', charSlots.room.mood, 'pop'); toast(state.name ? `「${state.name}」になったよ` : 'なまえを消しました'); });

/* ---- せってい ---- */
function renderSettings(){
  $('vHeight').innerHTML = `${state.height}<small style="font-size:12px">cm</small>`;
  $('vGoal').innerHTML = `${fmt(state.goal)}<small style="font-size:12px">kg</small>`;
  document.querySelectorAll('[data-opt]').forEach(i => i.checked = !!state.opts[i.dataset.opt]);
  document.querySelectorAll('#judgeSeg button').forEach(b => b.setAttribute('aria-pressed', b.dataset.j===state.opts.judge));
  $('optTime').value = state.opts.time; $('optTime').disabled = !state.opts.remind;
  $('bye').innerHTML = svgOf('sm_sleepy') + 'きょうもおつかれさま';
}
document.querySelectorAll('[data-adj]').forEach(b => b.addEventListener('click', ()=>{
  const k = b.dataset.adj, d = +b.dataset.d;
  if(k==='height') state.height = Math.min(220, Math.max(120, state.height + d));
  else state.goal = +Math.min(150, Math.max(30, state.goal + d)).toFixed(1);
  persist(); renderSettings();
}));
document.querySelectorAll('[data-opt]').forEach(i => i.addEventListener('change', ()=>{
  state.opts[i.dataset.opt] = i.checked; persist(); applyOpts(); renderSettings();
  if(i.dataset.opt === 'game'){ toast(i.checked ? '体重よそうをオンにしました。ホームに出るよ' : '体重よそうをオフにしました'); charSlots.home.mood = null; }
  if(i.dataset.opt === 'hide') toast(i.checked ? '体重の数字をかくしました' : '数字を表示します');
  if(i.dataset.opt === 'health') toast(i.checked ? 'ヘルスケアと同期します（デモ）' : 'ヘルスケアとの同期をやめました');
}));
document.querySelectorAll('#judgeSeg button').forEach(b => b.addEventListener('click', ()=>{
  state.opts.judge = b.dataset.j; persist(); renderSettings(); charSlots.home.mood = null;
  toast(b.dataset.j==='trend' ? '7日平均とくらべるよ（やさしめ）' : '前日とくらべるよ');
}));
$('optTime').addEventListener('change', e => { state.opts.time = e.target.value; persist(); toast(`毎朝 ${e.target.value} にお知らせします`); });
function applyOpts(){
  $('phone').classList.toggle('still', !state.opts.move);
  $('phone').classList.toggle('quiet', !state.opts.talk);
  $('phone').classList.toggle('hideNum', !!state.opts.hide);
}

/* ---- タブ ---- */
const RENDER = {home:renderHome, graph:renderGraph, chara:renderChara, settings:renderSettings};
let curTab = 'home';
function showTab(name){
  closeDetail();
  curTab = name;
  document.querySelectorAll('.tab').forEach(t => t.setAttribute('aria-selected', t.dataset.tab===name));
  document.querySelectorAll('.screen').forEach(s => s.hidden = s.id !== 'sc-'+name);
  $('scroll').scrollTop = 0; RENDER[name]();
}
const rerender = () => RENDER[curTab]();
document.querySelectorAll('.tab').forEach(t => t.addEventListener('click', ()=> showTab(t.dataset.tab)));

/* ---- 数値入力ユーティリティ ---- */
function clampSet(input, v, min, max){ v = Math.min(max, Math.max(min, v)); if(input.tagName==='INPUT') input.value = fmt(v); else input.textContent = fmt(v); }
function hold(btn, input, delta, min, max){
  let t1, t2;
  const val = () => parseFloat(input.tagName==='INPUT' ? input.value : input.textContent) || 0;
  const tick = () => clampSet(input, val() + delta, min, max);
  btn.addEventListener('pointerdown', e => { e.preventDefault(); tick(); t1 = setTimeout(()=> t2 = setInterval(tick, 70), 380); });
  const stop = () => { clearTimeout(t1); clearInterval(t2); };
  ['pointerup','pointerleave','pointercancel'].forEach(ev => btn.addEventListener(ev, stop));
  btn.addEventListener('keydown', e => { if(e.key==='Enter'||e.key===' '){ e.preventDefault(); tick(); } });
}
const inp = $('wInput');
function lastWeight(){ const ks = sortedKeys(); return ks.length ? state.logs[ks[ks.length-1]] : 58; }
function resetInput(){ clampSet(inp, state.logs[key(today0())] ?? lastWeight(), 20, 200); }
resetInput();
hold($('minus'), inp, -0.1, 20, 200); hold($('plus'), inp, 0.1, 20, 200);
inp.addEventListener('blur', ()=>{ const v = parseFloat(inp.value.replace(',','.')); clampSet(inp, isNaN(v)?58:v, 20, 200); });

let toastT;
function toast(msg){ const t=$('toast'); t.textContent=msg; t.classList.add('show'); clearTimeout(toastT); toastT=setTimeout(()=>t.classList.remove('show'),1800); }

/* ---- 保存の共通処理（バッジ判定つき） ---- */
function afterChange(){
  const now = computeBadges(state), fresh = now.filter(b => !state.badges.includes(b));
  state.badges = Array.from(new Set([...state.badges, ...now]));
  persist();
  return fresh;
}

$('save').addEventListener('click', ()=>{
  const v = parseFloat(inp.value); if(isNaN(v)) return;
  const tk = key(today0());
  state.logs[tk] = +v.toFixed(1);
  const tags = readChips($('homeTags'));
  state.meta[tk] = {...(state.meta[tk]||{}), tags};
  simAbsent = false; override = null;
  const fresh = afterChange();
  charSlots.home.mood = null; charSlots.room.mood = null; renderHome();
  const ts = todayState();
  setChar('home', ts.mood, ['trouble','crying','angry'].includes(ts.mood) ? 'shake' : 'pop', ts.line);
  $('scroll').scrollTo({top:0, behavior:'smooth'});
  const g = GAME() ? guessResult(tk) : null, cl = watches().done.find(x => x.end === tk);
  toast((H() ? '記録しました' : `${fmt(v)}kg を記録しました`) + (g ? (g.hit ? ` ・ よそうあたり！+${g.pts}pt` : ' ・ よそうははずれ') : ''));
  if(cl && !matchMedia('(prefers-reduced-motion: reduce)').matches) setTimeout(confetti, 300);
  if(fresh.length) setTimeout(()=> celebrate(fresh[0]), 700);
});

/* ---- 記録シート ---- */
let editKey = null, delArmed = false;
const MIN_BACK = 119;
function openSheet(k){
  editKey = k; delArmed = false; fillSheet();
  $('sheet').inert = false; $('sheet').classList.add('open'); $('sheetBack').classList.add('open');
}
function closeSheet(){ $('sheet').classList.remove('open'); $('sheetBack').classList.remove('open'); $('sheet').inert = true; }
/* ---- シートの「この日の顔」 ---- */
let shFace = {sel:null, touched:false};
function fillSheetFaces(k, has){
  const auto = has ? judge(k).mood : null, cur = has ? (((state.meta[k]||{}).face) || auto) : null;
  shFace = {sel:cur, touched:false};
  const order = auto ? [auto, ...Object.keys(MOODS).filter(m => m !== auto)] : Object.keys(MOODS);
  $('shFaces').innerHTML = order.map(m => `<button class="fp" data-m="${m}" aria-pressed="${m===cur}">${svgOf(MOODS[m].sm)}${MOODS[m].label}</button>`).join('');
  $('shFaceNote').textContent = has ? 'えらびなおせるよ' : 'えらばなければ体重から自動できまるよ';
  const r = $('shFaces'), sel = r.querySelector('.fp[aria-pressed="true"]');
  r.scrollLeft = 0; if(sel) r.scrollLeft = Math.max(0, sel.offsetLeft - r.clientWidth/2 + sel.offsetWidth/2);
  r.querySelectorAll('.fp').forEach(b => b.addEventListener('click', ()=>{
    const on = !(b.getAttribute('aria-pressed') === 'true' && !has);   // 未記録の日は、もう一度押すと選択を外せる
    r.querySelectorAll('.fp').forEach(x => x.setAttribute('aria-pressed', on && x === b));
    shFace = {sel: on ? b.dataset.m : null, touched:true};
  }));
}
function fillSheet(){
  const k = editKey, d = parse(k), tk = key(today0()), has = k in state.logs, me = state.meta[k]||{};
  const ago = daysBetween(k, tk);
  $('shDate').textContent = `${d.getMonth()+1}月${d.getDate()}日（${'日月火水木金土'[d.getDay()]}）` + (ago===0?'':'');
  $('shState').textContent = ago===0 ? 'きょう' : has ? '記録ずみ・修正できるよ' : 'まだ記録がない日';
  $('shPrev').disabled = ago >= MIN_BACK; $('shNext').disabled = ago <= 0;
  let near = state.logs[k];
  if(near == null){ const ks = sortedKeys(); const before = ks.filter(x => x < k); near = before.length ? state.logs[before[before.length-1]] : lastWeight(); }
  clampSet($('shW'), near, 20, 200);
  const fk = sortedKeys().slice().reverse().find(x => (state.meta[x]||{}).fat);
  $('shFatOn').checked = !!me.fat || (!has && !!fk);
  clampSet($('shFat'), me.fat || (fk ? state.meta[fk].fat : 28), 3, 70);
  $('fatRow').classList.toggle('off', !$('shFatOn').checked);
  $('shTags').innerHTML = chipsHTML(k===tk && !has ? readChips($('homeTags')) : (me.tags||[])); bindChips($('shTags'));
  $('shMemo').value = me.memo || '';
  fillSheetFaces(k, has);
  $('shSave').textContent = has ? '修正を保存' : 'この日をきろくする';
  $('shDel').hidden = !has; $('shDel').textContent = 'この日の記録を削除';
}
hold($('shMinus'), $('shW'), -0.1, 20, 200); hold($('shPlus'), $('shW'), 0.1, 20, 200);
hold($('shFatM'), $('shFat'), -0.1, 3, 70); hold($('shFatP'), $('shFat'), 0.1, 3, 70);
$('shW').addEventListener('blur', ()=>{ const v = parseFloat($('shW').value.replace(',','.')); clampSet($('shW'), isNaN(v)?58:v, 20, 200); });
$('shFatOn').addEventListener('change', ()=> $('fatRow').classList.toggle('off', !$('shFatOn').checked));
$('shPrev').addEventListener('click', ()=>{ editKey = key(new Date(parse(editKey) - DAY)); delArmed=false; fillSheet(); });
$('shNext').addEventListener('click', ()=>{ editKey = key(new Date(+parse(editKey) + DAY + 3600e3)); delArmed=false; fillSheet(); });
$('shClose').addEventListener('click', closeSheet);
$('sheetBack').addEventListener('click', closeSheet);
$('shSave').addEventListener('click', ()=>{
  const k = editKey, w = parseFloat($('shW').value); if(isNaN(w)) return;
  state.logs[k] = +w.toFixed(1);
  const m = {tags: readChips($('shTags'))};
  if($('shFatOn').checked) m.fat = +parseFloat($('shFat').textContent).toFixed(1);
  const memo = $('shMemo').value.trim(); if(memo) m.memo = memo;
  const prevMeta = state.meta[k]||{}, prevFace = prevMeta.face;
  if(prevMeta.guess){ m.guess = prevMeta.guess; m.bot = prevMeta.bot; }
  state.meta[k] = m;
  // 顔：えらび直したときはそれを、触っていなければ前の選択をそのまま残す（自動と同じなら保存しない）
  if(shFace.touched){ const auto = judge(k).mood; if(shFace.sel && shFace.sel !== auto) m.face = shFace.sel; }
  else if(prevFace) m.face = prevFace;
  if(k === key(today0())){ simAbsent = false; override = null; resetInput(); }
  const fresh = afterChange();
  charSlots.home.mood = null; charSlots.room.mood = null;
  closeSheet(); rerender(); if(detailKey) renderDetail();
  const d = parse(k); toast(`${d.getMonth()+1}月${d.getDate()}日を保存しました`);
  if(k === key(today0()) && curTab==='home'){ const ts = todayState(); setChar('home', ts.mood, 'pop', ts.line); }
  if(fresh.length) setTimeout(()=> celebrate(fresh[0]), 600);
});
$('shDel').addEventListener('click', ()=>{
  if(!delArmed){ delArmed = true; $('shDel').textContent = 'もう一度おすと削除します'; return; }
  delete state.logs[editKey]; delete state.meta[editKey]; persist();
  if(editKey === key(today0())) resetInput();
  charSlots.home.mood = null; charSlots.room.mood = null;
  if(detailKey === editKey) closeDetail(); else if(detailKey) renderDetail();
  closeSheet(); rerender(); toast('記録を削除しました');
});
$('openToday').addEventListener('click', ()=> openSheet(key(today0())));
$('dEdit').addEventListener('click', ()=> openSheet(key(today0())));
$('addPast').addEventListener('click', ()=>{
  const t = today0(); let k = null;
  for(let i=1;i<=MIN_BACK;i++){ const c = key(new Date(t - i*DAY)); if(!(c in state.logs)){ k = c; break; } }
  openSheet(k || key(new Date(t - DAY)));
});


/* ---- 日の詳細（日記ページ） ---- */
let detailKey = null, detailFrom = 'もどる';
function openDay(k, from){
  if(!(k in state.logs)){ openSheet(k); return; }   // 記録がない日は入力シートへ
  detailFrom = from || 'もどる'; detailKey = k; renderDetail();
  const d = $('detail'); d.inert = false; d.scrollTop = 0; d.classList.add('open');
}
function closeDetail(){ detailKey = null; const d = $('detail'); d.classList.remove('open'); d.inert = true; }
function renderDetail(){
  const k = detailKey; if(!k || !(k in state.logs)) return closeDetail();
  const ks = sortedKeys(), i = ks.indexOf(k), w = state.logs[k], me = state.meta[k]||{}, dt = parse(k);
  const df = dayFace(k), j = {...judge(k), mood:df.mood, line:df.line};
  $('dBack').textContent = '‹ ' + detailFrom;
  $('dTitle').textContent = `${dt.getMonth()+1}月${dt.getDate()}日（${'日月火水木金土'[dt.getDay()]}）`;
  $('dChar').innerHTML = svgOf(MOODS[j.mood].lg); markSeen(j.mood);
  setBubble($('dBubble'), j.line || LINES[j.mood][0]);
  $('dWeight').textContent = fmt(w);
  $('dSub').textContent = [MOODS[j.mood].label, me.fat ? `体脂肪 ${fmt(me.fat)}%` : null].filter(Boolean).join(' ・ ');
  // 指標
  const cls = v => v<0?'down':v>0?'up':'';
  const cell = (lbl, v) => `<div><span>${lbl}</span><b class="${v==null?'':cls(v)}">${v==null?'—':sign(v)+'<small>kg</small>'}</b></div>`;
  const prevK = i>0 ? ks[i-1] : null;
  const prevLbl = prevK && daysBetween(prevK,k)===1 ? 'まえの日から' : 'まえの記録から';
  const win = ks.slice(0,i).filter(x => daysBetween(x,k) <= 7);
  const left = w - state.goal;
  $('dMetrics').innerHTML = cell(prevLbl, prevK ? +(w-state.logs[prevK]).toFixed(1) : null)
    + cell('7日平均から', win.length ? +(w-avg(win.map(x=>state.logs[x]))).toFixed(1) : null)
    + `<div><span>もくひょうまで</span><b>${left<=0?'<span class="down" style="font-size:15px">達成！</span>':fmt(left)+'<small>kg</small>'}</b></div>`;
  // 前後1週間グラフ
  drawWeek(k);
  // メモ
  const tags = me.tags||[];
  $('dTags').innerHTML = tags.map(x=>`<span class="chip" aria-pressed="true">${esc(x)}</span>`).join('');
  $('dTags').hidden = !tags.length;
  $('dMemoTxt').textContent = me.memo || (tags.length ? '' : 'タグもメモもない日だよ。「編集」から書きこめるよ');
  $('dMemoTxt').className = me.memo ? '' : 'none';
  $('dMemoTxt').hidden = !me.memo && tags.length > 0;
  const gr = GAME() ? guessResult(k) : null;
  $('dGuess').hidden = !gr && !treatHit(k);
  $('dGuess').textContent = [isTreat(prevDayKey(k)) ? '🍰 まえの日は ごほうびの日' : isTreat(k) ? '🍰 この日は ごほうびの日' : '',
    gr ? `よそう「${GUESS[gr.guess].l}」→ ${gr.hit ? 'あたり！+'+gr.pts+'pt' : 'はずれ'}（キャラは「${GUESS[gr.bot].l}」）` : ''].filter(Boolean).join('　');
  // 前後の記録
  const nb = (key2, dir) => {
    if(!key2) return `<span>${dir<0?'これより前の記録はないよ':'これより後の記録はないよ'}</span>`;
    const d2 = parse(key2), face = svgOf(MOODS[moodFor(key2)].sm), txt = `<span>${d2.getMonth()+1}/${d2.getDate()}<br><b>${fmt(state.logs[key2])}</b></span>`;
    return dir<0 ? `‹ ${face}${txt}` : `${txt}${face} ›`;
  };
  const nextK = i < ks.length-1 ? ks[i+1] : null;
  $('dPrev').innerHTML = nb(prevK,-1); $('dPrev').disabled = !prevK; $('dPrev').dataset.k = prevK||'';
  $('dNext').innerHTML = nb(nextK, 1); $('dNext').disabled = !nextK; $('dNext').dataset.k = nextK||'';
}
function drawWeek(k){
  const W=320, H=150, L=30, R=12, T=18, B=24, c = parse(k), pts = [];
  for(let o=-7;o<=7;o++){ const kk = key(new Date(+c + o*DAY + 3600e3)); if(kk in state.logs) pts.push({o, w:state.logs[kk], k:kk}); }
  const ws = pts.map(p=>p.w), lo = Math.floor(Math.min(...ws)-.2), hi = Math.ceil(Math.max(...ws)+.2);
  const x = o => L + (W-L-R)*((o+7)/14), y = v => T + (H-T-B)*(1-(v-lo)/(hi-lo));
  let g = '';
  for(let v=lo; v<=hi; v+= (hi-lo)>4?2:1) g += `<line x1="${L}" x2="${W-R}" y1="${y(v)}" y2="${y(v)}" stroke="#F1E6DC"/><text class="yl" x="${L-6}" y="${y(v)+4}" text-anchor="end">${v}</text>`;
  const lbl = o => { const d = new Date(+c + o*DAY + 3600e3); return `${d.getMonth()+1}/${d.getDate()}`; };
  g += `<text x="${x(-7)}" y="${H-6}">${lbl(-7)}</text><text x="${x(7)}" y="${H-6}" text-anchor="end">${lbl(7)}</text>`;
  const path = pts.map((p,n)=>`${n?'L':'M'}${x(p.o).toFixed(1)} ${y(p.w).toFixed(1)}`).join(' ');
  g += `<defs><linearGradient id="dwg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F9D2CC" stop-opacity=".9"/><stop offset="1" stop-color="#F9D2CC" stop-opacity="0"/></linearGradient></defs>`;
  if(pts.length>1) g += `<path d="${path} L${x(pts[pts.length-1].o)} ${H-B} L${x(pts[0].o)} ${H-B} Z" fill="url(#dwg)"/><path d="${path}" fill="none" stroke="#E58C86" stroke-width="2.6" stroke-linejoin="round" stroke-linecap="round"/>`;
  pts.forEach(p => { if(p.o) g += `<circle cx="${x(p.o)}" cy="${y(p.w)}" r="2.6" fill="#fff" stroke="#E58C86" stroke-width="2"/>`; });
  const me = pts.find(p=>p.o===0);
  g += `<line x1="${x(0)}" x2="${x(0)}" y1="${T-6}" y2="${H-B}" stroke="#4A3020" stroke-width="1" stroke-dasharray="3 3"/>`;
  g += `<circle cx="${x(0)}" cy="${y(me.w)}" r="6.5" fill="#E58C86" stroke="#fff" stroke-width="2.5"/>`;
  g += `<text x="${x(0)}" y="${H-6}" text-anchor="middle" style="fill:#4A3020;font-weight:700">この日</text>`;
  $('dChart').innerHTML = g;
}
$('dBack').addEventListener('click', closeDetail);
$('dEditBtn').addEventListener('click', ()=> detailKey && openSheet(detailKey));
['dPrev','dNext'].forEach(id => $(id).addEventListener('click', ()=>{
  const k = $(id).dataset.k; if(!k) return; detailKey = k; renderDetail();
  $('detail').scrollTo({top:0, behavior:'smooth'});
  const c = $('dChar'); c.classList.remove('pop'); void c.offsetWidth; c.classList.add('pop');
}));

/* ---- ごほうび演出 ---- */
let confettiRAF = null;
function celebrate(id){
  const b = BADGES.find(x=>x.id===id); if(!b) return;
  $('rwTitle').textContent = b.title;
  $('rwChar').innerHTML = svgOf(MOODS[b.mood].lg); markSeen(b.mood);
  $('rwMsg').textContent = (state.name ? state.name+'：' : '') + b.msg;
  $('rwGift').textContent = b.gift;
  const r = $('reward'); r.inert = false; r.setAttribute('aria-hidden','false'); r.classList.add('open');
  if(!matchMedia('(prefers-reduced-motion: reduce)').matches) confetti();
}
function confetti(){
  const c = $('confetti'), ctx = c.getContext('2d'), box = $('phone').getBoundingClientRect();
  const dpr = devicePixelRatio||1; c.width = box.width*dpr; c.height = box.height*dpr; ctx.scale(dpr,dpr);
  const cols = ['#F9D2CC','#E58C86','#F3CA89','#9FD3C7','#B4E1E4','#FFFFFF'];
  const ps = Array.from({length:110}, () => ({x:box.width/2+(Math.random()-.5)*60, y:box.height*.38, vx:(Math.random()-.5)*9, vy:-Math.random()*11-4,
    s:4+Math.random()*6, r:Math.random()*6, vr:(Math.random()-.5)*.3, c:cols[Math.random()*cols.length|0], round:Math.random()<.4}));
  cancelAnimationFrame(confettiRAF); let f = 0;
  (function step(){
    ctx.clearRect(0,0,box.width,box.height);
    ps.forEach(p => { p.vy += .28; p.vx *= .99; p.x += p.vx; p.y += p.vy; p.r += p.vr;
      ctx.save(); ctx.translate(p.x,p.y); ctx.rotate(p.r); ctx.fillStyle = p.c;
      if(p.round){ ctx.beginPath(); ctx.arc(0,0,p.s/2,0,7); ctx.fill(); } else ctx.fillRect(-p.s/2,-p.s/4,p.s,p.s/2);
      ctx.restore(); });
    if(++f < 200) confettiRAF = requestAnimationFrame(step); else ctx.clearRect(0,0,box.width,box.height);
  })();
}
$('rwClose').addEventListener('click', ()=>{ const r = $('reward'); r.classList.remove('open'); r.inert = true; r.setAttribute('aria-hidden','true'); });

/* ---- 通知プレビュー ---- */
let notifT;
function showNotif(){
  const tk = key(today0()), recorded = tk in state.logs, nm = state.name || 'キャラ';
  const mood = recorded ? 'good' : 'sleepy';
  $('notifIcon').innerHTML = svgOf(MOODS[mood].sm);
  $('notifTitle').textContent = recorded ? `${nm}「きょうもえらい！」` : `${nm}「おはよ〜」`;
  $('notifBody').textContent = recorded ? 'あしたの朝も、いっしょにはかろうね' : `${state.opts.time}だよ。体重計のってきて〜 ふぁ…`;
  const n = $('notif'); n.classList.remove('show'); void n.offsetWidth; n.classList.add('show'); n.tabIndex = 0;
  clearTimeout(notifT); notifT = setTimeout(hideNotif, 5000);
}
function hideNotif(){ $('notif').classList.remove('show'); $('notif').tabIndex = -1; }
$('notif').addEventListener('click', ()=>{ hideNotif(); closeSpring(); showTab('home'); inp.focus(); });

/* ---- ウィジェットプレビュー ---- */
function openSpring(){
  const ks = sortedKeys(), tk = key(today0()), recorded = tk in state.logs;
  const ts = todayState(), w = ks.length ? state.logs[ks[ks.length-1]] : null;
  const j = recorded ? judge(tk) : null;
  const last7 = ks.filter(k => daysBetween(k,tk) < 7);
  const vs = last7.map(k=>state.logs[k]); if(!vs.length) vs.push(0,0); const lo = Math.min(...vs), hi = Math.max(...vs);
  const sp = vs.map((v,i)=>`${(i/(Math.max(1,vs.length-1))*100).toFixed(1)},${(30-(hi===lo?.5:(v-lo)/(hi-lo))*26).toFixed(1)}`).join(' ');
  let s = 0, d = today0(); if(!recorded) d = new Date(d - DAY); while(state.logs[key(d)] !== undefined){ s++; d = new Date(d - DAY); }
  const apps = ['カレンダー','写真','カメラ','天気','メモ','時計','ミュージック','マップ'];
  const ico = n => `<span class="ico"><i></i>${n}</span>`;
  $('sbGrid').innerHTML =
    `<div class="wdg s"><span class="wf">${svgOf(MOODS[ts.mood].sm)}</span><span><span class="wk">${recorded?'きょう':'さいしん'}</span><br><span class="wn">${w==null?'—':fmt(w)}<small>kg</small></span><br><span class="wd ${j&&j.diff<0?'down':j&&j.diff>0?'up':''}">${j&&j.diff!=null?sign(j.diff)+'kg':'まだはかってないよ'}</span></span></div>` +
    ico(apps[0]) + ico(apps[1]) + ico(apps[2]) + ico(apps[3]) +
    `<span class="sbLabel">たいかん！（小）</span><span></span><span></span>` +
    `<div class="wdg m"><span class="wf">${svgOf(MOODS[ts.mood].lg)}</span><span style="min-width:0"><span class="wk">${state.name||'キャラ'}「${(ts.line||LINES[ts.mood][0]).slice(0,16)}」</span><br><span class="wn">${w==null?'—':fmt(w)}<small>kg</small></span> <span class="wd">🔥${s}日</span><svg class="spark" viewBox="0 0 100 32" preserveAspectRatio="none"><polyline points="${sp}" fill="none" stroke="#E58C86" stroke-width="2.5" stroke-linejoin="round" vector-effect="non-scaling-stroke"/></svg></span></div>` +
    `<span class="sbLabel m">たいかん！（中）</span>` +
    ico(apps[4]) + ico(apps[5]) + `<span class="ico"><span class="appIcon">${svgOf('sm_good')}</span>たいかん！</span>` + ico(apps[6]);
  const sb = $('springboard'); sb.inert = false; sb.setAttribute('aria-hidden','false'); sb.classList.add('open');
  $('statusBar').style.color = '#fff';
}
function closeSpring(){ const sb = $('springboard'); sb.classList.remove('open'); sb.inert = true; sb.setAttribute('aria-hidden','true'); $('statusBar').style.color = ''; }
$('sbClose').addEventListener('click', closeSpring);



/* ---- シェア：体重カードを画像（1080×1350）にする ---- */
const APP_NAME = 'たいかん！';
const SH_BG = [['#FBE3DF','#F6CFC8'],['#E3F3EF','#C7E6DE'],['#FFF3D9','#F6DFAE'],['#E9EEF7','#CED9EC']];
const SHARE = {k:null, kind:'day', num:false, bg:0};
const imgCache = {};
function charSrc(name){
  const s = svgOf(name), m = s.match(/<image href="([^"]+)"/);
  if(m) return m[1];
  return 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(s.replace('<svg', '<svg width="440" height="440"'));
}
function loadImg(name){
  return imgCache[name] = imgCache[name] || new Promise(r => { const i = new Image(); i.onload = () => r(i); i.onerror = () => r(null); i.src = charSrc(name); });
}
const FT = (w, s, num) => `${w} ${s}px ${num ? '"Baloo 2", ' : ''}"Zen Maru Gothic", "Hiragino Maru Gothic ProN", sans-serif`;
function rr(c, x, y, w, h, r){ c.beginPath(); c.moveTo(x+r,y); c.arcTo(x+w,y,x+w,y+h,r); c.arcTo(x+w,y+h,x,y+h,r); c.arcTo(x,y+h,x,y,r); c.arcTo(x,y,x+w,y,r); c.closePath(); }
function wrap(c, text, maxW, maxL){
  const lines = []; let cur = '';
  for(const ch of text){ if(c.measureText(cur+ch).width > maxW && cur){ lines.push(cur); cur = ch; } else cur += ch; }
  if(cur) lines.push(cur);
  if(lines.length > maxL){ lines.length = maxL; lines[maxL-1] = lines[maxL-1].slice(0,-1) + '…'; }
  return lines;
}
const flowWord = d => d == null ? 'はじめて' : d <= -0.1 ? 'いい流れ' : d <= 0.1 ? 'いつもどおり' : 'ふえ気味';
function streakAt(k){ let s = 0, d = parse(k); while(state.logs[key(d)] !== undefined){ s++; d = new Date(d - DAY); } return s; }
function shStat(c, x, y, w, label, val, num, col){
  rr(c, x, y, w, 150, 36); c.fillStyle = '#FFFFFF'; c.fill(); c.lineWidth = 4; c.strokeStyle = '#EADDD1'; c.stroke();
  c.textAlign = 'center'; c.fillStyle = '#8C7564'; c.font = FT(700, 27); c.fillText(label, x+w/2, y+46);
  c.fillStyle = col || '#4A3020'; c.font = num ? FT(800, 56, true) : FT(900, 40);
  c.fillText(val, x+w/2, y + (num ? 118 : 112));
}
function shFrame(c){
  const [a,b] = SH_BG[SHARE.bg], g = c.createLinearGradient(0,0,0,1350); g.addColorStop(0,a); g.addColorStop(1,b);
  c.fillStyle = g; c.fillRect(0,0,1080,1350);
  rr(c, 60, 60, 960, 1230, 64); c.fillStyle = '#FFF9F3'; c.fill(); c.lineWidth = 6; c.strokeStyle = 'rgba(74,48,32,.12)'; c.stroke();
  c.textAlign = 'center'; c.fillStyle = '#B5A193'; c.font = FT(700, 28); c.fillText('たいかん！ ・ #たいかん', 540, 1262);
}
async function drawShareDay(c, k){
  const w = state.logs[k], j = judge(k), df = dayFace(k), dt = parse(k), tk = key(today0());
  const line = k === tk ? (todayState().line || LINES[df.mood][0]) : (df.line || LINES[df.mood][0]);
  const img = await loadImg(MOODS[df.mood].lg);
  shFrame(c);
  c.textAlign = 'left'; c.fillStyle = '#4A3020'; c.font = FT(900, 46);
  c.fillText(`${dt.getMonth()+1}月${dt.getDate()}日（${'日月火水木金土'[dt.getDay()]}）`, 120, 168);
  c.textAlign = 'right'; c.fillStyle = '#8C7564'; c.font = FT(700, 30); c.fillText(`🔥 ${streakAt(k)}日れんぞく`, 960, 166);
  const g = c.createLinearGradient(0,210,0,860); g.addColorStop(0,'#FFEFE9'); g.addColorStop(1,'#FFF6F0');
  rr(c, 120, 210, 840, 650, 52); c.fillStyle = g; c.fill(); c.lineWidth = 4; c.strokeStyle = '#F6DCD3'; c.stroke();
  if(img) c.drawImage(img, 280, 236, 520, 520);
  c.textAlign = 'center'; c.fillStyle = '#4A3020'; c.font = FT(900, 40); c.fillText(MOODS[df.mood].label, 540, 818);
  // よそうがあたった日はスタンプ
  const gr = GAME() ? guessResult(k) : null;
  if(gr && gr.hit){
    c.save(); c.translate(860, 330); c.rotate(-0.18);
    c.beginPath(); c.arc(0,0,92,0,7); c.fillStyle = '#E58C86'; c.fill(); c.lineWidth = 8; c.strokeStyle = '#FFFFFF'; c.stroke();
    c.fillStyle = '#FFFFFF'; c.font = FT(900, 30); c.fillText('よそう', 0, -8); c.font = FT(900, 38); c.fillText('あたり！', 0, 36); c.restore();
  }
  // ふきだし
  c.font = FT(900, 40); const ls = wrap(c, line, 760, 2), bh = 60 + ls.length*54;
  rr(c, 120, 900, 840, bh, 40); c.fillStyle = '#FFFFFF'; c.fill(); c.lineWidth = 5; c.strokeStyle = '#4A3020'; c.stroke();
  c.beginPath(); c.moveTo(510, 903); c.lineTo(540, 870); c.lineTo(570, 903); c.fillStyle = '#FFFFFF'; c.fill();
  c.beginPath(); c.moveTo(505, 902); c.lineTo(540, 864); c.lineTo(575, 902); c.strokeStyle = '#4A3020'; c.stroke();
  c.fillStyle = '#4A3020'; ls.forEach((l,i) => c.fillText(l, 540, 900 + 68 + i*54));
  const sy = 900 + bh + 32, d = j.diff, col = d == null ? null : d < -0.05 ? '#3E9B86' : d > 0.05 ? '#D06A63' : null;
  if(SHARE.num){
    shStat(c, 120, sy, 266, 'この日の体重', fmt(w) + 'kg', true);
    shStat(c, 407, sy, 266, state.opts.judge==='trend' ? '7日平均から' : 'まえの日から', d == null ? '—' : sign(d) + 'kg', true, col);
  } else {
    shStat(c, 120, sy, 266, 'ながれ', flowWord(d), false, col);
    shStat(c, 407, sy, 266, 'きろく', `${sortedKeys().filter(x => x <= k).length}回め`, false);
  }
  if(GAME()){ const s = gameStats(); shStat(c, 694, sy, 266, 'よそう', `Lv.${s.lv}`, true); }
  else shStat(c, 694, sy, 266, 'れんぞく', `${streakAt(k)}日`, false);
}
async function drawShareWeek(c, k){
  const end = parse(k), days = [];
  for(let o=6;o>=0;o--){ const kk = key(new Date(+end - o*DAY + 3600e3)); days.push(kk); }
  const recs = days.filter(x => x in state.logs);
  const imgs = await Promise.all(days.map(x => x in state.logs ? loadImg(MOODS[moodFor(x)].sm) : null));
  const big = await loadImg(MOODS[recs.length >= 6 ? 'doya' : recs.length >= 3 ? 'good' : 'cheer'].lg);
  shFrame(c);
  const s0 = parse(days[0]);
  c.textAlign = 'left'; c.fillStyle = '#4A3020'; c.font = FT(900, 52); c.fillText('この1週間', 120, 170);
  c.fillStyle = '#8C7564'; c.font = FT(700, 30); c.fillText(`${s0.getMonth()+1}/${s0.getDate()} 〜 ${end.getMonth()+1}/${end.getDate()}`, 120, 218);
  // 7日の顔
  days.forEach((x,i) => {
    const cx = 120 + i*120 + 60, d = parse(x);
    c.textAlign = 'center'; c.fillStyle = d.getDay()===0 ? '#D06A63' : '#8C7564'; c.font = FT(700, 28); c.fillText('日月火水木金土'[d.getDay()], cx, 300);
    if(imgs[i]){ c.beginPath(); c.arc(cx, 375, 54, 0, 7); c.fillStyle = '#FFF1EC'; c.fill(); c.drawImage(imgs[i], cx-50, 325, 100, 100); }
    else { c.beginPath(); c.arc(cx, 375, 50, 0, 7); c.setLineDash([10,10]); c.lineWidth = 4; c.strokeStyle = '#E3D5C9'; c.stroke(); c.setLineDash([]); }
    if(SHARE.num && x in state.logs){ c.fillStyle = '#4A3020'; c.font = FT(700, 30, true); c.fillText(fmt(state.logs[x]), cx, 468); }
  });
  // ながれ（目盛りなしの線）
  const gy = SHARE.num ? 510 : 480;
  rr(c, 120, gy, 840, 420, 44); c.fillStyle = '#FFF1EC'; c.fill();
  const pts = days.map((x,i) => x in state.logs ? {i, w:state.logs[x]} : null).filter(Boolean);
  if(pts.length > 1){
    const ws = pts.map(p => p.w), lo = Math.min(...ws) - .2, hi = Math.max(...ws) + .2;
    const X = i => 180 + i*120, Y = v => gy + 70 + (280)*(1 - (v-lo)/(hi-lo));
    c.beginPath(); pts.forEach((p,n) => n ? c.lineTo(X(p.i), Y(p.w)) : c.moveTo(X(p.i), Y(p.w)));
    c.lineWidth = 10; c.lineJoin = 'round'; c.lineCap = 'round'; c.strokeStyle = '#E58C86'; c.stroke();
    pts.forEach(p => { c.beginPath(); c.arc(X(p.i), Y(p.w), 12, 0, 7); c.fillStyle = '#FFFFFF'; c.fill(); c.lineWidth = 6; c.stroke(); });
  } else { c.textAlign = 'center'; c.fillStyle = '#B5A193'; c.font = FT(700, 30); c.fillText('きろくが2日分たまると線が出るよ', 540, gy + 220); }
  // 数字
  const sy = gy + 460, ch = pts.length > 1 ? +(pts[pts.length-1].w - pts[0].w).toFixed(1) : null;
  const hits = days.filter(x => { const r = guessResult(x); return r && r.hit; }).length;
  shStat(c, 120, sy, 270, 'きろく', `${recs.length} / 7日`, false);
  if(SHARE.num) shStat(c, 410, sy, 270, 'この週の変化', ch == null ? '—' : sign(ch) + 'kg', true, ch == null ? null : ch < -0.05 ? '#3E9B86' : ch > 0.05 ? '#D06A63' : null);
  else if(GAME()) shStat(c, 410, sy, 270, 'よそう', `${hits}回あたり`, false);
  else shStat(c, 410, sy, 270, 'れんぞく', `${streakAt(k)}日`, false);
  if(big) c.drawImage(big, 690, sy - 120, 290, 290);
}
let shareTok = 0;
async function drawShare(){
  const tok = ++shareTok, cv = $('shareCv'), c = cv.getContext('2d');
  try{ await Promise.all([document.fonts.load(FT(900, 40)), document.fonts.load(FT(800, 40, true))]); }catch(e){}
  const off = document.createElement('canvas'); off.width = 1080; off.height = 1350; const oc = off.getContext('2d');
  oc.textBaseline = 'alphabetic';
  if(SHARE.kind === 'week') await drawShareWeek(oc, SHARE.k); else await drawShareDay(oc, SHARE.k);
  if(tok !== shareTok) return;
  c.clearRect(0,0,1080,1350); c.drawImage(off, 0, 0);
}
function openShare(k){
  const ks = sortedKeys(); k = k || (key(today0()) in state.logs ? key(today0()) : ks[ks.length-1]);
  if(!k){ toast('きろくすると、カードが作れるよ'); return; }
  SHARE.k = k; SHARE.num = false;
  $('shNum').checked = false;
  $('shKind').querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', b.dataset.kind === SHARE.kind));
  $('shBg').innerHTML = SH_BG.map((c,i) => `<button style="background:linear-gradient(180deg,${c[0]},${c[1]})" data-i="${i}" aria-pressed="${i===SHARE.bg}" aria-label="いろ ${i+1}"></button>`).join('');
  $('shBg').querySelectorAll('button').forEach(b => b.addEventListener('click', ()=>{ SHARE.bg = +b.dataset.i; $('shBg').querySelectorAll('button').forEach(x => x.setAttribute('aria-pressed', x===b)); drawShare(); }));
  const s = $('shareSheet'); s.inert = false; s.scrollTop = 0; s.classList.add('open'); $('shareBack').classList.add('open');
  drawShare();
}
function closeShare(){ $('shareSheet').classList.remove('open'); $('shareBack').classList.remove('open'); $('shareSheet').inert = true; }
$('shareClose').addEventListener('click', closeShare);
$('shareBack').addEventListener('click', closeShare);
$('shNum').addEventListener('change', e => { SHARE.num = e.target.checked; drawShare(); });
$('shKind').querySelectorAll('button').forEach(b => b.addEventListener('click', ()=>{
  SHARE.kind = b.dataset.kind; $('shKind').querySelectorAll('button').forEach(x => x.setAttribute('aria-pressed', x===b)); drawShare();
}));
$('shTargets').querySelectorAll('button').forEach(b => b.addEventListener('click', async ()=>{
  const t = b.dataset.t;
  // 実機（Safari）で共有メニューが使えるときは、画像ファイルとして共有する
  try{
    const blob = await new Promise(r => $('shareCv').toBlob(r, 'image/png'));
    const file = blob && new File([blob], 'weight-card.png', {type:'image/png'});
    if(file && navigator.canShare && navigator.canShare({files:[file]})){ await navigator.share({files:[file], title:APP_NAME}); return; }
  }catch(e){}
  toast(t === 'save' ? '実機では「写真」に保存します（デモ）' : `実機では ${t} に画像を送ります（デモ）`);
}));
$('dShareHome').addEventListener('click', ()=> openShare(key(today0())));
$('dShareDay').addEventListener('click', ()=> detailKey && openShare(detailKey));

/* ---- ロック画面ウィジェット・Siri プレビュー ---- */
function openOv(id){ closeSpring(); hideNotif(); closeOvs(); const o = $(id); o.inert = false; o.setAttribute('aria-hidden','false'); o.classList.add('open'); $('statusBar').style.color = '#fff'; }
function closeOvs(){ ['lockOv','siriOv'].forEach(id => { const o = $(id); if(!o) return; o.classList.remove('open'); o.inert = true; o.setAttribute('aria-hidden','true'); }); $('statusBar').style.color = ''; }
function openLock(){
  const ks = sortedKeys(), tk = key(today0()), rec = tk in state.logs, ts = todayState();
  const p7 = ks.filter(k => daysBetween(k,tk) < 7), a7 = p7.length ? avg(p7.map(k=>state.logs[k])) : null;
  let s = 0, d = today0(); if(!rec) d = new Date(d - DAY); while(state.logs[key(d)] !== undefined){ s++; d = new Date(d - DAY); }
  const g = goalInfo(), pct = g ? Math.max(0, Math.min(100, g.pct)) : 0, C = 2*Math.PI*30;
  const t = new Date();
  $('lockOv').innerHTML = `
    <div class="lkDate">${t.getMonth()+1}月${t.getDate()}日 ${'日月火水木金土'[t.getDay()]}曜日</div>
    <div class="lkInline">🔥${s}日れんぞく ・ ${rec ? 'きょうは記録ずみ' : 'まだはかってないよ'}</div>
    <div class="lkTime">9:41</div>
    <div class="lkW">
      <span class="lkC"><span class="f">${svgOf(MOODS[ts.mood].sm)}</span></span>
      <span class="lkR"><small>7日平均</small><b class="nv">${a7==null?'—':fmt(a7)}<small>kg</small></b><small>${rec ? (H() ? 'きょうも記録したよ' : `きょう ${fmt(state.logs[tk])}kg`) : 'タップしてきろく'}</small></span>
      <span class="lkC"><svg class="ring" viewBox="0 0 64 64"><circle cx="32" cy="32" r="30" fill="none" stroke="rgba(255,255,255,.3)" stroke-width="4"/><circle cx="32" cy="32" r="30" fill="none" stroke="#fff" stroke-width="4" stroke-linecap="round" stroke-dasharray="${(C*pct/100).toFixed(1)} ${C.toFixed(1)}" transform="rotate(-90 32 32)"/></svg><span class="rt">${Math.floor(pct)}<small>%</small><small>もくひょう</small></span></span>
    </div>
    <div class="lkCtl"><span aria-hidden="true">🔦</span><span class="rec"><span class="f" style="width:44px;height:44px;border-radius:50%;background:#FFF6EE;display:grid;place-items:center">${svgOf(MOODS.good.sm)}</span><i>体重をきろく</i></span></div>
    <div class="sbNote"><span>ロック画面ウィジェットとコントロールのみため（プレビュー）。右下のボタンから、ロックしたまま記録できます</span><button id="lockClose">アプリにもどる</button></div>`;
  openOv('lockOv'); $('lockClose').addEventListener('click', closeOvs);
}
function openSiri(){
  const ks = sortedKeys(), tk = key(today0());
  const v = +(lastWeight() - 0.3).toFixed(1), p7 = ks.filter(k => k < tk && daysBetween(k,tk) <= 7), a7 = p7.length ? avg(p7.map(k=>state.logs[k])) : v;
  const d = +(v - a7).toFixed(1), mood = d < -0.1 ? 'happy' : d <= 0.1 ? 'good' : 'trouble';
  const kg = Math.floor(v), dec = Math.round((v - kg)*10);
  $('siriOv').innerHTML = `
    <div class="siriSay"><small>「Hey Siri」</small>体重を${kg}.${dec}キロで記録して</div>
    <div class="siriCard"><span class="f">${svgOf(MOODS[mood].lg)}</span><span><span class="ap">たいかん！</span><b>${H() ? 'きろくしたよ！' : `${fmt(v)}kg をきろくしたよ！`}</b><small>${H() ? (d<=0.1?'いい流れだよ。きょうもえらい！':'ちょっとふえ気味。気にしすぎないでね') : `7日平均から ${sign(d)}kg。${d<=0.1?'きょうもえらい！':'気にしすぎないでね'}`}</small></span></div>
    <div class="siriList"><h4>Siri に言えること</h4><ul>
      <li>「Hey Siri、体重を52キロで記録」</li><li>「Hey Siri、きょうの体重は？」</li>${GAME() ? '<li>「Hey Siri、体重よそう、へった」</li>' : '<li>「Hey Siri、7日平均は？」</li>'}</ul>
      <div class="sc"><span>体重をきろく<small>ショートカットのアクション</small></span><span>7日平均をみる<small>ショートカットのアクション</small></span></div></div>
    <div class="siriGlow"></div>
    <div class="sbNote"><span>Siri とショートカットのみため（プレビュー）。デモなので保存はしません</span><button id="siriClose">アプリにもどる</button></div>`;
  openOv('siriOv'); $('siriClose').addEventListener('click', closeOvs);
}

/* ---- はじめての起動 ---- */
function emptyState(){ return {logs:{}, meta:{}, treats:{}, goal:55.0, height:160, name:'', opts:{...DEFAULT_OPTS}, badges:[], seen:[], onboarded:false}; }
const ONB = [
  {face:'lg_happy', bubble:'はじめまして！', title:'まいにちの体重を<br>いっしょにきろくしよう', text:'朝いちばんに体重計にのって、ここにきろくしてね。増えた日も減った日も、ちゃんとそばにいるよ。', btn:'はじめる'},
  {face:'lg_hmm', bubble:'からだのことを教えてね', kind:'body', text:'もくひょうまでの進み具合と、BMIの計算につかうよ。あとから変えられるよ。', btn:'つぎへ'},
  {face:'yawn', bubble:'毎朝、声をかけてもいい？', kind:'notif', text:'はかり忘れないように、決まった時間におしらせするよ。', btn:'おしらせをうけとる', skip:'いまはいい'},
  {face:'cheer', bubble:'じゅんびできた！', title:'さっそく、はかってみよう', text:'さいしょの体重が、ゴールまでのスタート地点になるよ。', btn:'きょうの体重をきろくする'}
];
let onbStep = 0;
function openOnboarding(){ onbStep = 0; renderOnb(); const o = $('onb'); o.inert = false; o.classList.add('open'); }
function closeOnboarding(){ const o = $('onb'); o.classList.remove('open'); o.inert = true; }
function renderOnb(){
  const s = ONB[onbStep], nm = state.name || 'わたし';
  $('onbDots').innerHTML = ONB.map((_,i)=>`<i class="${i===onbStep?'on':''}"></i>`).join('');
  $('onbBack').style.visibility = onbStep ? 'visible' : 'hidden';
  let body = '';
  if(s.kind==='name') body = `<div class="onbField"><input type="text" id="onbName" maxlength="10" placeholder="なまえを入れてね" value="${esc(state.name||'')}" aria-label="キャラのなまえ"></div><p class="onbNote">あとから「キャラ」タブで変えられるよ</p>`;
  if(s.kind==='body') body = `<div class="onbField">
      <div class="row"><span class="lbl">身長</span><button class="mini" data-oadj="height" data-d="-1" aria-label="身長を1cm減らす">−</button><span class="val" id="oH"></span><button class="mini" data-oadj="height" data-d="1" aria-label="身長を1cm増やす">+</button></div>
      <div class="row"><span class="lbl">もくひょう体重</span><button class="mini" data-oadj="goal" data-d="-0.5" aria-label="目標を0.5kg減らす">−</button><span class="val" id="oG"></span><button class="mini" data-oadj="goal" data-d="0.5" aria-label="目標を0.5kg増やす">+</button></div></div>`;
  if(s.kind==='notif') body = `<div class="onbField"><div class="row"><label for="onbTime" class="lbl">おしらせの時間</label><input type="time" id="onbTime" value="${state.opts.time}"></div></div><p class="onbNote">実機ではここで iPhone の通知の許可をたずねます</p>`;
  $('onbStep').innerHTML = `<div class="bubble b">${esc(s.bubble.replace('{name}', nm))}</div><div class="oChar" id="oChar">${svgOf(s.face)}</div>`
    + (s.title ? `<h2>${s.title}</h2>` : '') + (s.text ? `<p>${s.text}</p>` : '') + body;
  $('onbNext').textContent = s.btn;
  // 「いまはいい」がないステップも場所だけ確保して、メインボタンの位置をそろえる
  const sk = $('onbSkip'); sk.textContent = s.skip || 'いまはいい'; sk.style.visibility = s.skip ? 'visible' : 'hidden'; sk.tabIndex = s.skip ? 0 : -1; sk.setAttribute('aria-hidden', s.skip ? 'false' : 'true');
  if(s.kind==='body'){
    const upd = () => { $('oH').innerHTML = `${state.height}<small style="font-size:12px">cm</small>`; $('oG').innerHTML = `${fmt(state.goal)}<small style="font-size:12px">kg</small>`; };
    upd();
    document.querySelectorAll('[data-oadj]').forEach(b => b.addEventListener('click', ()=>{
      const d = +b.dataset.d;
      if(b.dataset.oadj==='height') state.height = Math.min(220, Math.max(120, state.height + d));
      else state.goal = +Math.min(150, Math.max(30, state.goal + d)).toFixed(1);
      upd();
    }));
  }
  const c = $('oChar'); c.classList.remove('pop'); void c.offsetWidth; c.classList.add('pop');
}
function onbCommit(skipped){
  const s = ONB[onbStep];
  if(s.kind==='name' && !skipped) state.name = ($('onbName').value||'').trim();
  if(s.kind==='notif'){ state.opts.remind = !skipped; if(!skipped) state.opts.time = $('onbTime').value || state.opts.time; }
  if(onbStep < ONB.length-1){ onbStep++; renderOnb(); return; }
  state.onboarded = true; persist(); closeOnboarding(); applyOpts(); showTab('home');
}
$('onbNext').addEventListener('click', ()=> onbCommit(false));
$('onbSkip').addEventListener('click', ()=> onbCommit(true));
$('onbBack').addEventListener('click', ()=>{ if(onbStep){ onbStep--; renderOnb(); } });
function startFresh(){
  closeSpring(); closeOvs(); hideNotif(); closeDetail(); closeSheet(); closeShare();
  state = emptyState(); persist(); override = null; simAbsent = false; previewPct = null;
  charSlots.home.mood = charSlots.room.mood = null; resetInput(); applyOpts(); showTab('home'); openOnboarding();
}

/* ---- ひさしぶりプレビュー ---- */
function startAbsent(){ closeSpring(); simAbsent = true; override = null; charSlots.home.mood = null; showTab('home'); setChar('home','lonely','shake', todayState().line); }
$('absentOff').addEventListener('click', ()=>{ simAbsent = false; charSlots.home.mood = null; renderHome(); });

/* ---- プレビューボタン（アプリ内・サイド共通） ---- */
const PREVIEW = {
  notif: ()=>{ closeSpring(); closeOvs(); showNotif(); },
  widget: ()=>{ closeOvs(); openSpring(); },
  absent: startAbsent,
  reward: ()=>{ closeSpring(); closeOvs(); celebrate('down1'); },
  fresh: startFresh,
  onb: ()=>{ closeSpring(); closeOvs(); hideNotif(); closeDetail(); closeSheet(); openOnboarding(); },
  lock: openLock,
  share: ()=>{ closeSpring(); closeOvs(); hideNotif(); openShare(detailKey); },
  siri: openSiri,
  hide: ()=>{ closeSpring(); closeOvs(); state.opts.hide = !state.opts.hide; persist(); applyOpts(); rerender(); toast(state.opts.hide ? '見ないモード：体重の数字をかくしました' : '数字を表示します'); },
  game: ()=>{ closeSpring(); closeOvs(); state.opts.game = !state.opts.game; persist(); charSlots.home.mood = null; showTab('home'); toast(state.opts.game ? '体重よそう：オン（体重入力のところに出るよ）' : '体重よそう：オフ'); },
  treatDemo: ()=>{
    closeSpring(); closeOvs(); closeDetail(); closeSheet(); showTab('home');
    const tk = key(today0());
    if(!(tk in state.logs)){ toast('先にきょうの体重をきろくすると、せんげんできるよ'); $('save').focus(); return; }
    const sc = $('scroll'), el = $('treatCard'); sc.scrollTo({top: sc.scrollTop + el.getBoundingClientRect().top - sc.getBoundingClientRect().top - 160, behavior:'smooth'});
  }
};
document.querySelectorAll('[data-preview]').forEach(b => b.addEventListener('click', ()=> PREVIEW[b.dataset.preview]()));

$('reset').addEventListener('click', ()=>{
  state = sample(); persist(); override = null; simAbsent = false; charSlots.home.mood = charSlots.room.mood = null;
  resetInput(); applyOpts(); renderSettings(); toast('サンプルデータに戻しました');
});

/* ---- サイドパネル ---- */
$('faces').innerHTML = Object.entries(MOODS).map(([k,m]) =>
  `<button class="face" data-mood="${k}" aria-pressed="false">${svgOf(m.sm)}${m.label}</button>`).join('');
document.querySelectorAll('.face').forEach(f => f.addEventListener('click', ()=>{
  override = f.dataset.mood; showTab('home'); setChar('home', override, 'pop');
}));
$('rules').innerHTML = '<b>表情が変わるルール</b>（7日平均とくらべる場合）<br>' + [
  ['happy','0.3kg 以上減'],['good','少し減 / 目標達成'],['hmm','±0.1kg の横ばい'],
  ['trouble','0.1〜0.5kg 増'],['crying','0.5kg 以上増'],['angry','1kg 以上増'],['sleepy','今日まだ未記録'],
  ['surprise','0.8kg 以上減'],['doya','いちばん軽い記録を更新'],
  ['cozy','増えた日に「のんびり」タグ'],['nightcap','増えた日に「寝不足」タグ'],
  ['lonely','3日以上あいて開いたとき'],['cheer','もくひょうカード（10〜100%）']
].map(([k,r])=>`${MOODS[k].label}：${r}`).join('<br>');

document.addEventListener('keydown', e => { if(e.key==='Escape'){ if($('shareSheet').classList.contains('open')) closeShare(); else if($('sheet').classList.contains('open')) closeSheet(); else closeDetail(); closeSpring(); closeOvs(); $('rwClose').click(); hideNotif(); } });

$('pctSlider').addEventListener('input', e => {
  previewPct = +e.target.value; $('pctVal').textContent = previewPct + '%（デモ）';
  if(curTab !== 'home') showTab('home'); renderGoal();
});
$('pctReset').addEventListener('click', ()=>{ previewPct = null; renderGoal(); });

applyOpts();
showTab('home');
if(!state.onboarded) openOnboarding();
