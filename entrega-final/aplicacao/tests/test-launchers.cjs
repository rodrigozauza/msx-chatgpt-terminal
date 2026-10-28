'use strict';
const fs=require('node:fs/promises'),path=require('node:path'),os=require('node:os'),assert=require('node:assert/strict');
const {spawnSync}=require('node:child_process');
async function main(){
 const shell=process.env.MSXCHAT_TEST_SHELL||(process.platform==='win32'?null:'/bin/sh');
 if(!shell){console.log(JSON.stringify({skipped:true,reason:'POSIX shell required; Ubuntu CI runs these cases'}));return;}
 const dir=await fs.mkdtemp(path.join(os.tmpdir(),'msxchat-launchers-'));
 const results=[];
 try{
  const app=path.resolve(__dirname,'..'),copy=path.join(dir,'app with spaces'),bin=path.join(dir,'bin');
  await fs.mkdir(copy);await fs.mkdir(bin);
  // Convert Windows temp paths for Git Bash; Linux paths are already POSIX.
  const posix=p=>process.platform==='win32'?p.replace(/\\/g,'/').replace(/^([A-Za-z]):/,(_,d)=>'/'+d.toLowerCase()):p;
  const run=(script,args=[],extra={})=>spawnSync(shell,[posix(script),...args],{cwd:dir,encoding:'utf8',timeout:10000,env:{...process.env,...extra}});
  const fake=path.join(bin,'node');
  await fs.writeFile(fake,"#!/bin/sh\nprintf '%s\\n' \"$@\"\nexit \"${STUB_STATUS:-0}\"\n");await fs.chmod(fake,0o755);
  for(const [file,target] of [['RUN-GATEWAY.sh','GATEWAY.cjs'],['RUN-LAN.sh','LAN-SERVER.cjs']]){
   const script=path.join(copy,file);await fs.copyFile(path.join(app,file),script);
   const syntax=spawnSync(shell,['-n',posix(script)],{encoding:'utf8'});assert.equal(syntax.status,0,syntax.stderr);
   const r=run(script,['--state','state with spaces','--reply','ação Linux'],{PATH:posix(bin),STUB_STATUS:'23'});
   assert.equal(r.status,23,r.stderr);assert.deepEqual(r.stdout.trim().split(/\r?\n/),[posix(copy)+'/'+target,'--state','state with spaces','--reply','ação Linux']);
   results.push({test:file+' locates script from other cwd, preserves Unicode/spaces and exit code',status:'PASS'});
   const missing=run(script,[],{PATH:posix(dir)});assert.equal(missing.status,127);assert.match(missing.stderr,/Node.js nao encontrado/);
   results.push({test:file+' fails clearly without node',status:'PASS'});
  }
  // A real Node child checks inherited environment and validates config without network.
  const real=spawnSync(shell,[posix(path.join(app,'RUN-GATEWAY.sh')),'--check-config'],{cwd:dir,encoding:'utf8',timeout:10000,
   env:{...process.env,PATH:posix(path.dirname(process.execPath))+':'+(process.env.PATH||''),OPENAI_API_KEY:'TEST_ONLY_NOT_A_REAL_KEY',OPENAI_MODEL:'test-model',NODE_DEBUG:'',NODE_TLS_REJECT_UNAUTHORIZED:'1'}});
  assert.equal(real.status,0,real.stderr);assert.equal(JSON.parse(real.stdout).configured,true);assert.ok(!real.stdout.includes('TEST_ONLY_NOT_A_REAL_KEY'));
  results.push({test:'Gateway launcher runs real local configuration check without exposing synthetic key',status:'PASS'});
  console.log(JSON.stringify({passed:results.length,total:results.length,platform:process.platform,shell,liveOpenAI:false,results},null,2));
 }finally{await fs.rm(dir,{recursive:true,force:true});}
}
main().catch(e=>{console.error(e);process.exitCode=1;});
