# MSX ChatGPT Terminal — Fase 6: entrega final

27/10/2026. O escopo original termina na Fase 6 — Homologação. Não há Fase 7 prevista.

Esta entrega consolida o projeto sob a premissa solicitada de homologação bem-sucedida do conjunto da Fase 5. O executável permanece na versão 0.5: 15608 bytes, idêntico ao já aceito. O gateway JavaScript e os fontes Assembly também foram preservados. A revisão linux-r1 acrescenta iniciadores Linux/POSIX, manual Windows/Linux e modelo systemd.

## Conteúdo

- aplicacao/: aplicação da Fase 5 com os acréscimos multiplataforma da revisão linux-r1; COM, gateway JavaScript e fontes Assembly preservados.
- validacao-local/: novas verificações de integridade, reconstrução e regressão no PC.
- ACEITE-PREMISSA.md e REGISTRO-HOMOLOGACAO.json: registro da sua instrução e limites de sua classificação.
- MATRIZ-ACEITE.csv: distinção entre aceite geral presumido e ambientes não discriminados.
- RELEASE.json: identificação exata da versão entregue.
- VERIFICAR-ENTREGA.cjs e SHA256SUMS.txt: conferência local de integridade.

A aplicação continua com o título FASE 5 porque essa é sua versão funcional. A Fase 6 é o marco de homologação e consolidação.

## Instalação e operação

Use aplicacao/MSXCHAT.COM no Expert. No servidor Windows, execute aplicacao/RUN-GATEWAY.cmd; no Linux, sh aplicacao/RUN-GATEWAY.sh. Consulte [o manual Windows/Linux](aplicacao/SERVIDOR-WINDOWS-LINUX.md) para configurar, operar, fazer backup e instalar o serviço opcional. Mantenha os arquivos de dados do SD e a pasta de estado do gateway já usados na homologação.

As instruções completas de chave/modelo, IPs, operação, backup e recuperação estão em aplicacao/README.md. OPENAI_API_KEY e OPENAI_MODEL continuam exclusivamente na configuração do PC; o pacote não contém credenciais.

No Expert:
```
MSXCHAT IP_DO_PC PORTA
```
Ctrl+Q publica; Ctrl+W transmite/consulta; Ctrl+T controla a consulta automática; Ctrl+Y abre o histórico. A chave da API não é parâmetro desse comando.

## Conferir o pacote

Com Node.js 18+, na pasta extraída:
```
node VERIFICAR-ENTREGA.cjs
```
Execute antes de gerar novos relatórios ou alterar arquivos. Testes como smoke-live podem atualizar relatórios em aplicacao; essas alterações serão apontadas pelo verificador.

## Evidências e aceite

A pasta aplicacao conserva os registros produzidos durante a Fase 5, inclusive LIVE-API-RESULTS.json com NOT_RUN pelo agente naquela ocasião. Esse registro histórico não foi convertido artificialmente em PASS.

A sua nova premissa de homologação bem-sucedida está em ACEITE-PREMISSA.md. Nesta etapa não foram executados novos testes físicos no Expert, emulador MSX completo ou chamadas autenticadas à API. Os ensaios locais e a reconstrução são registrados separadamente.

O aceite geral presumido não identifica individualmente DOS1, DOS2, Nextor, modelo da API ou versões efetivamente usadas. Esses detalhes podem ser anexados aos registros existentes sem alterar o software.

## Encerramento

Entrega consolidada para uso e arquivamento, considerando a homologação informada como premissa. O pacote inclui código-fonte e procedimentos de reprodução para manutenção futura.

## Revisão linux-r1

Esta revisão regenera os manifestos e o ZIP. Foram aprovados 75 casos locais: 5 dos iniciadores em Git Bash/Windows, 39 do gateway com HTTP/TLS local, 19 do servidor manual e 12 do publicador. API e credenciais são sintéticas. A automação Ubuntu/Windows foi acrescentada ao repositório; seu resultado deve ser consultado no GitHub Actions. Não houve execução nativa Linux/systemd nem nova homologação física pelo agente. Consulte validacao-local/LINUX-R1-RESULTS.json.
