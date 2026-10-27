'use strict';
const fs=require('node:fs/promises'),path=require('node:path'),crypto=require('node:crypto');
async function main(){
 const root=__dirname,manifest=await fs.readFile(path.join(root,'SHA256SUMS.txt'),'utf8');let checked=0;
 for(const line of manifest.split(/\r?\n/).filter(Boolean)){
  const match=/^([0-9a-f]{64})  (.+)$/.exec(line);if(!match)throw Error('Manifesto invalido');
  const target=path.resolve(root,match[2]);if(!target.startsWith(path.resolve(root)+path.sep))throw Error('Caminho fora da entrega');
  const stat=await fs.lstat(target);if(!stat.isFile()||stat.isSymbolicLink())throw Error('Arquivo irregular: '+match[2]);
  const actual=crypto.createHash('sha256').update(await fs.readFile(target)).digest('hex');
  if(actual!==match[1])throw Error('Arquivo alterado: '+match[2]);checked++;
 }
 const release=JSON.parse(await fs.readFile(path.join(root,'RELEASE.json'),'utf8'));
 const com=await fs.readFile(path.join(root,'aplicacao/MSXCHAT.COM'));
 const sha=crypto.createHash('sha256').update(com).digest('hex');
 if(sha!==release.application.sha256||com.length!==release.application.bytes)throw Error('COM diferente da versao aceita');
 console.log(JSON.stringify({integridade:'PASS',arquivos:checked,comBytes:com.length,comSHA256:sha,
  escopo:'Integridade dos arquivos locais. Aceite Expert/API registrado separadamente como premissa do usuario.'},null,2));
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
