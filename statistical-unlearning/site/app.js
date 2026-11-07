/* No remote dependencies. Formal source is always rendered as text, never executed. */
(() => {
  'use strict';
  const data = window.PROOF_DATA || {paper:{},build:{},entries:[]};
  const entries = Array.isArray(data.entries) ? data.entries : [];
  const byId = new Map(entries.map(entry => [entry.id, entry]));
  const $ = id => document.getElementById(id);
  let current = null;
  let filter = 'all';
  let paperMode = 'html';
  const labels = {checked:'Lean checked', unverified:'Not yet checked', pending:'Planned'};
  const statusOf = entry => ['checked','unverified','pending'].includes(entry.status) ? entry.status : 'pending';
  const setText = (id,text) => { $(id).textContent = text || ''; };
  const link = (element,url) => {
    let safe = null;
    try { const parsed = new URL(url); if (['https:','http:'].includes(parsed.protocol)) safe = parsed.href; } catch (_) { /* missing or invalid link */ }
    element.hidden = !safe;
    if (safe) element.href = safe;
    else element.removeAttribute('href');
  };
  const shortLabel = entry => [entry.kind,entry.number].filter(Boolean).join(' ');
  const filteredEntries = () => {
    const query = $('search').value.trim().toLocaleLowerCase();
    return entries.filter(entry => (filter==='all' || (filter==='checked' ? statusOf(entry)==='checked' : statusOf(entry)!=='checked')) && (!query || [entry.title,entry.kind,entry.number,entry.section,entry.summary,entry.statement,entry.lean?.declaration].join(' ').toLocaleLowerCase().includes(query)));
  };

  function renderNavigation() {
    const shown = filteredEntries();
    const contents = $('contents');
    contents.replaceChildren();
    let section = null, group = null;
    for (const entry of shown) {
      if (entry.section !== section) {
        section = entry.section;
        group = document.createElement('div'); group.className = 'nav-group';
        const heading = document.createElement('h3'); heading.className='nav-section'; heading.textContent=section || 'Statements';
        group.append(heading); contents.append(group);
      }
      const anchor = document.createElement('a'); anchor.href='#'+encodeURIComponent(entry.id);
      anchor.setAttribute('aria-current',String(entry.id===current?.id));
      const dot = document.createElement('span');dot.className='status-dot '+statusOf(entry);dot.setAttribute('aria-hidden','true');
      const label = document.createElement('span'); label.className='nav-title';
      const kind = document.createElement('span');kind.className='nav-kind';kind.textContent=shortLabel(entry);
      label.append(kind,document.createTextNode(entry.title));anchor.append(dot,label);
      anchor.title=entry.title+' · '+labels[statusOf(entry)];
      anchor.addEventListener('click',() => { if (current?.id===entry.id) selectEntry(entry.id); });
      group.append(anchor);
    }
    $('no-results').hidden=shown.length>0;
  }

  function highlightLean(code, startLine) {
    const target=$('lean-code');target.replaceChildren();
    let commentDepth=0;
    const keywords=new Set(['theorem','lemma','def','abbrev','structure','class','instance','where','by','fun','if','then','else','let','in','namespace','end','variable','section','noncomputable','open','import','attribute','example','private','protected','public','opaque','inductive','mutual','deriving','extends','set_option']);
    const tactics=new Set(['intro','intros','exact','apply','refine','rw','simp','simpa','simp_all','constructor','rcases','obtain','have','show','calc','aesop','linarith','nlinarith','norm_num','positivity','omega','rfl','rintro','cases','induction','ext','funext','assumption','contradiction','first','all_goals','sorry','admit']);
    code.split('\n').forEach((line,index) => {
      const row=document.createElement('span');row.className='code-line';
      const number=document.createElement('span');number.className='line-number';number.setAttribute('aria-hidden','true');number.textContent=String((startLine||1)+index);row.append(number);
      const append=(value,type)=>{if(type){const span=document.createElement('span');span.className='token-'+type;span.textContent=value;row.append(span);}else row.append(document.createTextNode(value));};
      let position=0;
      while(position<line.length){
        const rest=line.slice(position);
        if(commentDepth||rest.startsWith('/-')){
          const begin=position;
          if(!commentDepth){commentDepth=1;position+=2;}
          while(position<line.length){
            if(line.startsWith('/-',position)){commentDepth++;position+=2;}
            else if(line.startsWith('-/',position)){commentDepth--;position+=2;if(!commentDepth)break;}
            else position++;
          }
          append(line.slice(begin,position),'comment');
        }else if(rest.startsWith('--')){append(rest,'comment');position=line.length;}
        else if(rest[0]==='"'){
          const begin=position++;
          while(position<line.length){if(line[position]==='\\'){position+=2;}else if(line[position++]==='"')break;}
          append(line.slice(begin,position),'string');
        }else{
          const match=/^(?:[A-Za-z_][A-Za-z_0-9']*|\d+(?:\.\d+)?)/.exec(rest);
          if(match){const token=match[0];append(token,keywords.has(token)?'keyword':tactics.has(token)?'tactic':/^\d/.test(token)?'number':'');position+=token.length;}
          else{append(line[position],'');position++;}
        }
      }
      target.append(row);
    });
  }

  function renderEvidence(entry) {
    const state=statusOf(entry), build=data.build||{};
    setText('verification-icon',state==='checked'?'✓':state==='unverified'?'◌':'○');
    setText('verification-heading',state==='checked'?'Lean compilation recorded':state==='unverified'?'Source awaiting verification':'Formalization pending');
    const detail=entry.verification || (state==='checked'?'The recorded build accepted this declaration. Inspect its assumptions and source before using the result.':state==='unverified'?'Lean source is available, but a successful compiler check has not been recorded. This entry is not claimed as verified.':'No completed formal proof is claimed for this entry. The mathematical statement is retained as an explicit formalization target.');
    setText('verification-detail',detail);
    link($('source-link'),entry.lean?.url);
    link($('build-run-link'),build.url);
    const facts=[['Build status',build.status||'Not recorded'],['Build command',build.command||'Not recorded'],['Source revision',build.revision||'Not recorded']];
    if(build.toolchain)facts.push(['Lean toolchain',build.toolchain]);
    if(build.mathlib)facts.push(['Mathlib revision',build.mathlib]);
    if(entry.axioms)facts.push(['Declaration axioms',Array.isArray(entry.axioms)?entry.axioms.join(', ')||'None':entry.axioms]);
    if(data.generatedAt)facts.push(['Manifest generated',data.generatedAt]);
    $('build-facts').replaceChildren();
    for(const [key,value] of facts){const dt=document.createElement('dt'),dd=document.createElement('dd');dt.textContent=key;dd.textContent=String(value);$('build-facts').append(dt,dd);}
  }

  function selectEntry(id) {
    const entry=byId.get(id)||entries[0];if(!entry)return;
    current=entry;const state=statusOf(entry);
    // The paper is the source itself, not a reconstructed or summarized copy.
    // Cross-origin restrictions mean scrolling is independent of this reader.
    const paperPages = {
      'randomized-tests':3, 'trade-off':3, 'zero-type-i':3,
      'zero-type-ii':3, 'trade-off-antitone':3, 'trade-off-upper-bound':3,
      'unlearning':3, 'consistency':3, 'feasible-region':4,
      'feasible-membership':4, 'feasible-monotonicity':4,
      'geometric-region':5, 'geometric-membership':5, 'geometric-subset':5,
      'geometric-point-bound':5, 'geometric-zero':5, 'geometric-necessary':5,
      'geometric-whole-ball':5, 'inverse-order':14,
      'representation-bridge':3, 'blackwell':15, 'gaussian-region':5,
      'composition':4, 'other-families':6, 'finite-sample':7
    };
    const paperSections = {
      'randomized-tests':'S2.SS1', 'trade-off':'S2.SS1', 'zero-type-i':'S2.SS1',
      'zero-type-ii':'S2.SS1', 'trade-off-antitone':'S2.SS1', 'trade-off-upper-bound':'S2.SS1',
      'unlearning':'S2.SS1', 'consistency':'S2.SS1', 'feasible-region':'S2.SS2',
      'feasible-membership':'S2.SS2', 'feasible-monotonicity':'S2.SS2',
      'geometric-region':'S3.SS1', 'geometric-membership':'S3.SS1', 'geometric-subset':'S3.SS1',
      'geometric-point-bound':'S3.SS1', 'geometric-zero':'S3.SS1', 'geometric-necessary':'S3.SS1',
      'geometric-whole-ball':'S3.SS1', 'representation-bridge':'S2.SS1',
      'inverse-order':'A1.SS4', 'blackwell':'A1.SS5',
      'gaussian-region':'S3.SS1', 'composition':'S2.SS3', 'other-families':'S3', 'finite-sample':'S4'
    };
    const page = paperPages[entry.id] || 3;
    const frame = $('paper-frame');
    const paperUrl = paperMode === 'pdf'
      ? 'https://arxiv.org/pdf/2605.16645v1#page=' + page
      : 'https://arxiv.org/html/2605.16645v1#' + (paperSections[entry.id] || 'S2');
    if (frame && frame.getAttribute('src') !== paperUrl) frame.setAttribute('src', paperUrl);
    setText('statement-kind',shortLabel(entry));setText('statement-status',labels[state]);$('statement-status').className='status-badge '+state;
    setText('statement-title',entry.title);setText('statement-summary',entry.summary);$('statement-summary').hidden=!entry.summary;
    setText('statement-text',entry.statement);$('statement-text').hidden=!entry.statement;
    link($('entry-paper-link'),entry.sourceUrl||data.paper?.arxiv);
    $('assumptions-list').replaceChildren();
    for(const assumption of entry.assumptions||[]){const li=document.createElement('li');li.textContent=assumption;$('assumptions-list').append(li);}
    $('assumptions-section').hidden=!entry.assumptions?.length;
    $('dependencies').replaceChildren();
    for(const id of entry.dependencies||[]){const target=byId.get(id);const a=document.createElement('a');a.href='#'+encodeURIComponent(id);a.textContent=target?target.title:id;$('dependencies').append(a);}
    $('dependencies-section').hidden=!entry.dependencies?.length;
    setText('entry-note',entry.notes);$('entry-note').hidden=!entry.notes;
    setText('lean-scope-note',entry.notes);$('lean-scope-note').hidden=!entry.notes;
    $('lean-assumptions').replaceChildren();
    for(const assumption of entry.assumptions||[]){const li=document.createElement('li');li.textContent=assumption;$('lean-assumptions').append(li);}
    $('lean-assumptions').hidden=!entry.assumptions?.length;
    $('lean-scope').hidden=!entry.notes&&!entry.assumptions?.length;
    const source=entry.lean?.code||'';const hasCode=Boolean(source.trim());
    $('code-body').hidden=!hasCode;$('empty-proof').hidden=hasCode;$('copy-code').hidden=!hasCode;
    setText('lean-file',entry.lean?.file||'No formal source yet');
    setText('declaration-name',entry.lean?.declaration);$('declaration-name').hidden=!entry.lean?.declaration;
    if(hasCode)highlightLean(source,entry.lean?.lines?.[0]||entry.lean?.startLine||1);
    renderEvidence(entry);renderNavigation();
    const index=entries.indexOf(entry);setText('entry-position',`${index+1} / ${entries.length}`);$('previous-entry').disabled=index===0;$('next-entry').disabled=index===entries.length-1;
    document.title=entry.title+' · Statistical Unlearning';
    $('announcement').textContent=entry.title+'. '+labels[state]+'.';
  }

  function setTab(isLean) {
    $('paired-panels').classList.toggle('show-lean',isLean);
    $('paper-tab').setAttribute('aria-selected',String(!isLean));$('lean-tab').setAttribute('aria-selected',String(isLean));
    $('paper-tab').tabIndex=isLean?-1:0;$('lean-tab').tabIndex=isLean?0:-1;
  }

  const checked=entries.filter(entry=>statusOf(entry)==='checked').length;
  setText('checked-count',String(checked));setText('pending-count',String(entries.length-checked));setText('entry-total',String(entries.length));
  if(data.paper?.authors)setText('authors',Array.isArray(data.paper.authors)?data.paper.authors.join('  &  '):data.paper.authors);
  if(data.paper?.version)setText('paper-version','arXiv:'+data.paper.version.replace(/^arXiv:/,''));
  link($('paper-link'),data.paper?.arxiv||'https://arxiv.org/abs/2605.16645');link($('repository-link'),data.repositoryUrl);
  if(data.build?.status==='checked'||data.build?.status==='passed')setText('build-label','Successful Lean build recorded');
  else if(data.build?.status==='failed')setText('build-label','Build incomplete · see individual entries');
  else if(data.build?.status==='unverified'||data.build?.status==='blocked')setText('build-label','Compiler verification not yet recorded');
  $('search').addEventListener('input',renderNavigation);
  document.querySelectorAll('.filter').forEach(button=>button.addEventListener('click',()=>{filter=button.dataset.filter;document.querySelectorAll('.filter').forEach(item=>{item.classList.toggle('active',item===button);item.setAttribute('aria-pressed',String(item===button));});renderNavigation();}));
  $('previous-entry').addEventListener('click',()=>{const index=entries.indexOf(current);if(index>0)location.hash=encodeURIComponent(entries[index-1].id);});
  $('next-entry').addEventListener('click',()=>{const index=entries.indexOf(current);if(index<entries.length-1)location.hash=encodeURIComponent(entries[index+1].id);});
  window.addEventListener('hashchange',()=>{let id='';try{id=decodeURIComponent(location.hash.slice(1));}catch(_){}selectEntry(id);});
  $('paper-tab').addEventListener('click',()=>setTab(false));$('lean-tab').addEventListener('click',()=>setTab(true));
  for (const mode of ['html','pdf']) $('paper-'+mode+'-view').addEventListener('click',()=>{
    paperMode=mode;
    for (const choice of ['html','pdf']) $('paper-'+choice+'-view').setAttribute('aria-pressed',String(choice===mode));
    if(current) selectEntry(current.id);
  });
  document.querySelector('.mobile-tabs').addEventListener('keydown',event=>{if(['ArrowLeft','ArrowRight','Home','End'].includes(event.key)){event.preventDefault();const lean=event.key==='End'||(event.key!=='Home'&&$('paper-tab').getAttribute('aria-selected')==='true');setTab(lean);$(lean?'lean-tab':'paper-tab').focus();}});
  document.addEventListener('keydown',event=>{if(event.key==='/'&&!['INPUT','TEXTAREA','SELECT'].includes(document.activeElement.tagName)){event.preventDefault();$('search').focus();}if(event.key==='Escape'&&document.activeElement===$('search')){$('search').value='';renderNavigation();$('search').blur();}});
  $('copy-code').addEventListener('click',async()=>{const code=current?.lean?.code;if(!code)return;try{await navigator.clipboard.writeText(code);$('announcement').textContent='Lean source copied.';$('copy-code').querySelector('.copy-label').textContent='Copied';setTimeout(()=>$('copy-code').querySelector('.copy-label').textContent='Copy',1600);}catch(_){$('announcement').textContent='Clipboard unavailable. Select the Lean source to copy it.';const range=document.createRange();range.selectNodeContents($('lean-code'));const selection=window.getSelection();selection.removeAllRanges();selection.addRange(range);}});
  if(entries.length){let id='';try{id=decodeURIComponent(location.hash.slice(1));}catch(_){}selectEntry(id);}else{setText('statement-title','The library is being prepared');setText('statement-summary','Formal statements and their evidence will appear here.');$('paper-content').querySelectorAll('section,aside,.result-meta,.mathematical-statement').forEach(element=>element.hidden=true);$('empty-proof').hidden=false;$('code-body').hidden=true;$('copy-code').hidden=true;$('previous-entry').disabled=true;$('next-entry').disabled=true;renderEvidence({status:'pending'});}
})();
