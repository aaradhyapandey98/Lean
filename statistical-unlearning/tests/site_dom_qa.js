/* Functional UI checks using a minimal DOM/event harness.
 * This is not a browser layout test and does not verify CSS or pixel rendering.
 * Run from any directory: node tests/site_dom_qa.js
 */
const fs=require('fs');
const vm=require('vm');
const cp=require('child_process');
const path=require('path');
const assert=require('assert/strict');
const root=path.resolve(__dirname,'../site');
const tree=JSON.parse(cp.execFileSync('python3',['-c',String.raw`
import json, sys
from html.parser import HTMLParser
from pathlib import Path
class P(HTMLParser):
 def __init__(self):super().__init__();self.root={'tag':'document','attrs':{},'children':[]};self.stack=[self.root]
 def handle_starttag(self,tag,attrs):
  node={'tag':tag,'attrs':dict(attrs),'children':[]};self.stack[-1]['children'].append(node)
  if tag not in ['area','base','br','col','embed','hr','img','input','link','meta','param','source','track','wbr']:self.stack.append(node)
 def handle_endtag(self,tag):
  for i in range(len(self.stack)-1,0,-1):
   if self.stack[i]['tag']==tag:self.stack=self.stack[:i];return
 def handle_data(self,data):self.stack[-1]['children'].append(data)
p=P();p.feed(Path(sys.argv[1]).read_text(encoding='utf-8'));print(json.dumps(p.root))
`,path.join(root,'index.html')],{encoding:'utf8'}));
function harness(extraEntry){
 let document,window;
 class N{
  constructor(tag,text=''){this.tagName=tag.toUpperCase();this.children=[];this.attrs={};this.listeners={};this.parentElement=null;this._text=text;this.value='';this.disabled=false;this.tabIndex=0;this.dataset={};}
  get textContent(){return this._text+this.children.map(x=>x.textContent).join('');}
  set textContent(v){this._text=String(v??'');this.children=[];}
  get className(){return this.attrs.class||'';}
  set className(v){this.attrs.class=v;}
  get classList(){const self=this;return {toggle(name,force){let arr=self.className.split(/\s+/).filter(Boolean);const has=arr.includes(name);const on=force===undefined?!has:force;if(on&&!has)arr.push(name);else if(!on)arr=arr.filter(x=>x!==name);self.className=arr.join(' ');return on;},contains(name){return self.className.split(/\s+/).includes(name);}};}
  get hidden(){return Object.hasOwn(this.attrs,'hidden');}
  set hidden(value){if(value)this.attrs.hidden='';else delete this.attrs.hidden;}
  get id(){return this.attrs.id;}
  set id(v){this.attrs.id=v;}
  get href(){return this.attrs.href||'';}
  set href(v){this.attrs.href=v;}
  setAttribute(k,v){this.attrs[k]=String(v);if(k.startsWith('data-'))this.dataset[k.slice(5).replace(/-([a-z])/g,(_,x)=>x.toUpperCase())]=String(v);}
  getAttribute(k){return this.attrs[k]??null;}
  removeAttribute(k){delete this.attrs[k];}
  append(...nodes){for(let node of nodes){if(typeof node==='string')node=new N('#text',node);node.parentElement=this;this.children.push(node);}}
  replaceChildren(...nodes){this.children=[];this._text='';this.append(...nodes);}
  addEventListener(kind,fn){(this.listeners[kind]??=[]).push(fn);}
  async dispatch(kind,event={}){for(const fn of this.listeners[kind]||[])await fn({preventDefault(){},target:this,...event});}
  async click(){if(this.disabled)return;await this.dispatch('click');if(this.tagName==='A'&&this.href.startsWith('#'))window.location.hash=this.href;}
  focus(){document.activeElement=this;}
  blur(){document.activeElement=document.body;}
  matches(sel){sel=sel.trim();return sel[0]==='.'?this.classList.contains(sel.slice(1)):sel[0]==='#'?this.id===sel.slice(1):this.tagName.toLowerCase()===sel;}
  querySelectorAll(selector){const sels=selector.split(',');const parts=[];function visit(node){for(const child of node.children){if(sels.some(s=>child.matches(s)))parts.push(child);visit(child);}}visit(this);return parts;}
  querySelector(sel){return this.querySelectorAll(sel)[0]||null;}
 }
 function from(data){if(typeof data==='string')return new N('#text',data);const n=new N(data.tag);for(const[k,v]of Object.entries(data.attrs))n.setAttribute(k,v??'');for(const child of data.children)n.append(from(child));return n;}
 document=from(tree);document.getElementById=id=>document.querySelector('#'+id);document.createElement=tag=>new N(tag);document.createTextNode=text=>new N('#text',text);document.body=document.querySelector('body');document.activeElement=document.body;document.title='';
 let hash='';const location={get hash(){return hash;},set hash(v){hash=v.startsWith('#')?v:'#'+v;window.dispatch('hashchange');}};
 window=new N('window');window.location=location;let copied='';
 const context=vm.createContext({window,document,location,URL,navigator:{clipboard:{async writeText(text){copied=text;}}},setTimeout(){},console});
 vm.runInContext(fs.readFileSync(root+'/data/proofs.js','utf8'),context);
 if(extraEntry)window.PROOF_DATA.entries.push(extraEntry);
 vm.runInContext(fs.readFileSync(root+'/app.js','utf8'),context);
 return {window,document,get copied(){return copied;},context,$:id=>document.getElementById(id)};
}
(async()=>{
 const h=harness(),{$,document,window}=h,entries=window.PROOF_DATA.entries;
 assert.equal(document.querySelectorAll('#contents').length,1);
 const links=()=>document.querySelectorAll('a').filter(x=>x.parentElement?.className==='nav-group');
 assert.equal(links().length,entries.length);
 assert.equal($('statement-title').textContent,entries[0].title);
 assert.equal($('lean-file').textContent,entries[0].lean.file);
 assert.equal($('lean-scope-note').textContent,entries[0].notes,'Correspondence notes remain visible beside Lean');
 assert.equal($('paper-frame').getAttribute('src'),'https://arxiv.org/html/2605.16645v1#S2.SS1','The paper pane must show the original versioned HTML');
 window.location.hash='gaussian-region';
 assert.equal($('paper-frame').getAttribute('src'),'https://arxiv.org/html/2605.16645v1#S3.SS1','HTML selection must navigate to the corresponding source section');
 await $('paper-pdf-view').click();
 assert.equal($('paper-frame').getAttribute('src'),'https://arxiv.org/pdf/2605.16645v1#page=5','Source selection must navigate to the corresponding PDF page');
 await $('paper-html-view').click();
 window.location.hash=entries[0].id;
 assert.equal($('checked-count').textContent,String(entries.filter(e=>e.status==='checked').length));
 const sourceText=()=> $('lean-code').children.map(row=>row.children.slice(1).map(n=>n.textContent).join('')).join('\n');
 assert.equal(sourceText(),entries[0].lean.code,'Displayed source must preserve exact Unicode source');
 $('search').value='type-I budget';await $('search').dispatch('input');assert.equal(links().length,1);
 assert.match(links()[0].textContent,/More type-I budget/);
 $('search').value='StatisticalUnlearning.tradeOff_antitone';await $('search').dispatch('input');assert.equal(links().length,1,'Search declaration name');
 $('search').value='nothing-matches-this';await $('search').dispatch('input');assert.equal(links().length,0);assert.equal($('no-results').hidden,false);
 $('search').value='';await $('search').dispatch('input');
 const filterButtons=document.querySelectorAll('.filter');
 await filterButtons.find(e=>e.dataset.filter==='checked').click();assert.equal(links().length,entries.filter(e=>e.status==='checked').length);
 await filterButtons.find(e=>e.dataset.filter==='open').click();assert.equal(links().length,entries.filter(e=>e.status!=='checked').length);
 await filterButtons.find(e=>e.dataset.filter==='all').click();
 await $('next-entry').click();assert.equal($('statement-title').textContent,entries[1].title);
 await $('previous-entry').click();assert.equal($('statement-title').textContent,entries[0].title);
 const target=entries.find(e=>e.id==='trade-off-antitone');window.location.hash=target.id;assert.equal($('statement-title').textContent,target.title);assert.equal(sourceText(),target.lean.code);
 await $('copy-code').click();assert.equal(h.copied,target.lean.code,'Copied code excludes line numbers');
 await $('lean-tab').click();assert.equal($('paired-panels').classList.contains('show-lean'),true);assert.equal($('lean-tab').getAttribute('aria-selected'),'true');assert.equal($('paper-tab').tabIndex,-1);
 await document.querySelector('.mobile-tabs').dispatch('keydown',{key:'Home'});assert.equal($('paired-panels').classList.contains('show-lean'),false);assert.equal(document.activeElement,$('paper-tab'));
 await document.dispatch('keydown',{key:'/'});assert.equal(document.activeElement,$('search'));
 $('search').value='abc';await document.dispatch('keydown',{key:'Escape'});assert.equal($('search').value,'');
 const pending=entries.find(e=>e.status==='pending'&&!e.lean);window.location.hash=pending.id;assert.equal($('empty-proof').hidden,false);assert.equal($('code-body').hidden,true);assert.equal($('copy-code').hidden,true);
 const injection='<img src=x onerror="window.PWNED=1"><script>window.PWNED=1</script>';
 const bad={id:'unsafe',title:injection,kind:'Example',section:'Security test',status:'unverified',statement:injection,lean:{code:injection,file:injection,url:'javascript:window.PWNED=1'},sourceUrl:'javascript:window.PWNED=1'};
 const ih=harness(bad);ih.window.location.hash='unsafe';assert.equal(ih.window.PWNED,undefined);assert.equal(ih.$('statement-title').textContent,injection);assert.equal(ih.document.querySelectorAll('img').length,0);assert.equal(ih.$('source-link').hidden,true);assert.equal(ih.$('entry-paper-link').hidden,true);
 assert.equal(ih.document.querySelectorAll('script').length,2,'No source-created scripts');
 console.log(JSON.stringify({passed:true,entries:entries.length,checks:['initial render','exact Unicode source','search title','search declaration','empty results','checked/open filters','next/previous navigation','hash selection','clipboard source','mobile tabs','tab keyboard','search keyboard','pending proof state','HTML injection isolation','unsafe URL rejection'],limitation:'Minimal DOM/event harness; no browser layout engine available.'},null,2));
})().catch(error=>{console.error(error);process.exitCode=1;});
