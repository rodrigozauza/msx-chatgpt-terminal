# msx-chatgpt-terminal
A simple terminal to chatGPT via MSX 1 on screen2 ! Enjoy !

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
