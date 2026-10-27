# Testes e critérios de aceite — Fase 5

## Resultado efetivo

- 175/175 casos do COM real em CPU Z80 com DOS, BIOS, VRAM e UNAPI simulados.
- 37 casos-base do gateway; a execução completa de 39/39 inclui esses 37 e mais dois cenários com sockets reais.
- HTTP em loopback: reserva/202, consulta, resultado 200 e replay sem segunda chamada ao adaptador simulado.
- HTTPS/TLS em loopback: certificado não confiável recusado antes de enviar Bearer; CA de teste explícita aceita; corpo em partes normalizado e segredo fictício redigido.
- Regressões: servidor manual 18/18, publicador offline 12/12, backup/rotação 16/16.
- Montagem reproduzível e inspeção das prévias de VRAM.
- API OpenAI real: NÃO EXECUTADA. LIVE-API-RESULTS.json contém NOT_RUN.

GATEWAY-REAL-RESULTS.json é o registro completo dos 39 casos. GATEWAY-RESULTS.json separa os 37 casos-base desse mesmo registro; não é uma execução adicional nem deve ser somado aos 39.

## Cobertura nova do terminal

Oito casos novos, além dos 167 anteriores:
- 202 preserva editor/REQ e não cria RSP/ACK;
- consulta automática usa o mesmo pedido e importa o resultado;
- Ctrl+T pausa rede; consulta manual continua;
- falha desarma novas tentativas automáticas de rede;
- cancelamento desarma consulta e não envia nova pergunta automaticamente;
- reinício exige o primeiro contato manual com o pedido pendente;
- status 2020 não é aceito como 202;
- falha de cleanup mantém a propriedade da conexão e é informada.

Continuam os guardas de RAM, pilha, ARG, vídeo, DTA, ausência de funções DOS2 e de portas mapper. As prévias são renderizações da VRAM simulada, não imagens do Expert.

## Cobertura do gateway

Endpoint/hostname HTTPS fixos, verificação de certificado, Bearer apenas no cabeçalho, nenhum segredo no corpo, modelo obrigatório e recusa de configurações inseguras de debug/TLS.

Extração em vários itens output, Unicode e área privada MSX, corte por escalares, recusa, saída vazia/incomplete/failed, status HTTP, ausência de retries automáticos, timeout, rede, UTF-8 inválido e limite de 1 MiB.

Diário: reserva/início confirmados antes da geração; polling concorrente com uma única chamada; conflito de ID; replay após reinício; contexto e seu limite; erros excluídos de turnos bem-sucedidos; lock; início sem resultado; configuração alterada; reserva corrompida; falha no commit do resultado; ordem de IDs; inspeção sem corpos; desligamento sem despachar trabalho ainda na fila.

As credenciais de teste são fictícias. O certificado/chave de tests/fixtures são sintéticos e públicos nesta entrega. Nenhum teste de gateway conecta à OpenAI, exceto se o operador executar explicitamente smoke-live.cjs --live com credenciais configuradas.

## Reprodução

```
python -S build.py
node tests/test-msxchat.cjs
node tests/test-gateway.cjs DIRETORIO_TEMPORARIO
node tests/test-gateway.cjs DIRETORIO_TEMPORARIO --real
node tests/test-lan-server.cjs DIRETORIO_TEMPORARIO
node tests/test-helper.cjs DIRETORIO_TEMPORARIO
python -S tests/test-backup.py DIRETORIO_TEMPORARIO
```
Python 3 e Node 18+, sem npm/pip. O teste --real abre somente loopback HTTP/TLS; as respostas de API continuam simuladas.

Teste autenticado opcional, com chave/modelo configurados no PC:
```
node tests/smoke-live.cjs --live
```
Ele faz uma chamada real, pode gerar uso cobrado e registra status/IDs/uso disponíveis sem imprimir a chave. Falha ou NOT_RUN não é aprovação da API.

## Aceite pendente

Não foram executados este COM em Expert físico/emulador MSX completo nem chamada autenticada real. A Fase 4 foi aceita por premissa; isso não comprova a nova integração.

Para aceitar: teste real da API aprovado; pergunta originada pelo Expert; resposta correspondente persistida uma vez; segunda pergunta com contexto esperado; reinício preservando diário; consultas repetidas sem nova geração; erros/cancelamento preservando editor; e ambiente DOS restaurado. Preencher HOMOLOGACAO.csv separando emulador, Expert e PC. Registrar versões do sistema/pilha/modelo e IDs remotos disponíveis.

A Fase 6 deverá repetir o conjunto nos sistemas suportados e no hardware. Não atribuir aprovação física às simulações ou aos sockets locais do PC.
