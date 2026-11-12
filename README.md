# msx-chatgpt-terminal
Como amante da retrocomputação, resolvi pedir a IA para fazer um terminal em modo gráfico em micros de 8 bits, padrão MSX v1, a partir de um projeto inicial que fiz dessa interface em 1985. Acho que ficou legal. Com o tempo, vou incrementar novas funcionalidades. Fique a vontade também se você é conhecedor do assunto ! divirta-se ! Terminal ChatGPT para MSX1 — SCREEN 2, 64 colunas

## Entrega final

MSX ChatGPT Terminal para Gradiente Expert MSX1: Assembly Z80, SCREEN 2 com 64 colunas, editor multilinha, historico JSON, TCP/IP UNAPI e gateway HTTPS no PC.

- [Baixar pacote completo](FASE6-ENTREGA-FINAL.zip)
- [MSXCHAT.COM v0.5](entrega-final/aplicacao/MSXCHAT.COM)
- [Manual de instalacao e configuracao](entrega-final/aplicacao/README.md)
- [Entrega final e registro de aceite](entrega-final/README.md)
- [Fontes Assembly Z80](entrega-final/aplicacao/src)
- [Gateway](entrega-final/aplicacao/GATEWAY.cjs)
- [Arquitetura](entrega-final/aplicacao/ARQUITETURA.md)

O executavel tem 15608 bytes e SHA-256 `8c29446e75635afccb8cd90f373fce0e9ff24222b6d1433119c43233bda62ba4`. A entrega final preserva integralmente a versao funcional 0.5 da Fase 5; a Fase 6 consolida verificacoes e o aceite por premissa solicitado pelo usuario. Os resultados locais, historicos e a premissa de homologacao estao identificados separadamente nos documentos.

## Conferir integridade

Com Node.js 18+, depois de clonar:

```text
cd entrega-final
node VERIFICAR-ENTREGA.cjs
```

O pacote nao inclui chave de API. `OPENAI_API_KEY` e `OPENAI_MODEL` sao configurados exclusivamente no PC. Os arquivos TLS em `tests/fixtures` sao dados sinteticos publicos usados apenas nos testes de loopback.

Codigo proprio sob MIT; ferramentas de terceiros conservam suas licencas nos arquivos incluidos.

## Servidor Windows ou Linux

Consulte [o manual multiplataforma](entrega-final/aplicacao/SERVIDOR-WINDOWS-LINUX.md). A revisão `fase6-linux-r1` inclui `RUN-GATEWAY.sh`, `RUN-LAN.sh`, exemplos Bash de configuração e backup e um serviço systemd opcional. Os iniciadores Windows continuam disponíveis; `MSXCHAT.COM` e o gateway JavaScript mantêm seus bytes originais.

Os manifestos e o ZIP foram regenerados. Passaram 75 casos locais (Windows/Git Bash e HTTP/TLS em loopback, API sintética). A [automação Ubuntu/Windows](https://github.com/rodrigozauza/msx-chatgpt-terminal/actions) executa os testes a cada atualização; a instalação do serviço systemd e a chamada real da API dependem da configuração do seu servidor.
