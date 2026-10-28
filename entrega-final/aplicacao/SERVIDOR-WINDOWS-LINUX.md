# Servidor Linux e Windows

O mesmo gateway Node.js atende Windows e Linux. Não é necessário SDK nem npm install. O mínimo técnico do código é Node.js 18; use uma versão LTS ainda suportada na implantação. Instale Node.js a partir de https://nodejs.org/ e confira `node --version`. No Linux, o comando deve estar disponível como `node` no PATH. Python 3 só é necessário para reconstruir o COM ou usar o backup do SD.

## Linux: execução interativa

Abra Bash na pasta `entrega-final/aplicacao`. Os comandos seguintes usam os mesmos IPs de exemplo do manual; substitua pelos endereços reais do servidor e do Expert.

```bash
cd /caminho/msx-chatgpt-terminal/entrega-final/aplicacao
node --version
read -r -s -p 'Chave da API OpenAI: ' OPENAI_API_KEY
printf '\n'
export OPENAI_API_KEY
export OPENAI_MODEL='ID_DO_MODELO_COM_ACESSO'
sh ./RUN-GATEWAY.sh --check-config
sh ./RUN-GATEWAY.sh --bind 192.168.1.10 --peer 192.168.1.50 --port 8765 --state "$HOME/.local/state/msxchat-openai"
```

O prompt mascarado acima é de Bash. A chave não entra no histórico do shell. O iniciador é POSIX e também pode ser chamado por `sh`; preserva argumentos com espaços, usa a própria pasta para localizar o JavaScript e repassa sinais/código de saída ao Node via exec. Aplica umask 077 aos novos arquivos e diretórios. Use um caminho absoluto para --state: caminhos relativos são resolvidos a partir da pasta atual do terminal. Reutilize sempre o mesmo diário ao reiniciar. Não aponte para o SD ou para o cache do servidor manual.

`--check-config` valida somente a configuração local, sem chamar a API ou comprovar acesso ao modelo. Para conferir o diário após parar o gateway, não é necessária chave:

```bash
sh ./RUN-GATEWAY.sh --inspect --state "$HOME/.local/state/msxchat-openai"
```

Encerre com Ctrl+C e aguarde a chamada em andamento terminar. Para backup consistente, com o gateway parado:

```bash
mkdir -p "$HOME/msxchat-backups"
umask 077
tar -C "$HOME/.local/state" -czf "$HOME/msxchat-backups/gateway-$(date +%Y%m%d-%H%M%S).tar.gz" msxchat-openai
unset OPENAI_API_KEY OPENAI_MODEL
```

Se houver gateway.lock depois de uma queda, verifique o processo anterior e preserve o diário antes de remover somente o lock, conforme o manual principal. Nunca apague job/started/done para reenviar pedidos incertos.

## Rede e diagnóstico

O servidor precisa alcançar api.openai.com por HTTPS (TCP 443), resolver DNS e ter relógio e certificados CA corretos. A entrada TCP 8765 deve ser permitida somente a partir do Expert na rede privada. O programa exige IPs privados numéricos e confere o peer. Não encaminhe a porta no roteador.

Se o Linux já utiliza UFW, exemplo de regra restrita (ajuste IPs/porta; não habilite ou redefina um firewall sem revisar as regras existentes):

```bash
sudo ufw allow from 192.168.1.50 to 192.168.1.10 port 8765 proto tcp
```

Confira o endereço com `ip -4 addr` e o listener com `ss -ltn 'sport = :8765'`. No Expert, o comando permanece `MSXCHAT 192.168.1.10 8765`. Um firewall ou uma configuração incorreta de IP pode impedir a conexão mesmo quando --check-config passa.

Para ensaio manual de LAN, sem API, use uma pasta de estado separada:

```bash
sh ./RUN-LAN.sh --bind 192.168.1.10 --peer 192.168.1.50 --port 8765 --state "$HOME/.local/state/msxchat-lan-test" --reply 'Teste LAN Linux'
```

Pare o gateway de produção antes de usar o mesmo endereço/porta no servidor manual.

## Linux: serviço systemd opcional

O exemplo em linux/msxchat-gateway.service pressupõe Linux com systemd, executável Node em /usr/bin/node e conta dedicada sem login. Confira `command -v node`; ajuste ExecStart se o caminho for diferente. Runtimes instalados apenas na sessão de um usuário (por exemplo nvm) não são herdados pelo serviço. Os comandos administrativos seguintes são exemplos para executar no seu servidor, a partir de aplicacao; não foram executados automaticamente pela entrega:

```bash
sudo useradd --system --user-group --home-dir /var/lib/msxchat --no-create-home --shell /usr/sbin/nologin msxchat
sudo install -d -m 0755 /opt/msxchat
sudo cp -R . /opt/msxchat/
sudo chown -R root:root /opt/msxchat
sudo chmod -R go-w /opt/msxchat
sudo install -d -m 0700 /etc/msxchat
sudo install -m 0600 linux/gateway.env.example /etc/msxchat/gateway.env
sudoedit /etc/msxchat/gateway.env
sudo install -m 0644 linux/msxchat-gateway.service /etc/systemd/system/msxchat-gateway.service
sudo systemctl daemon-reload
sudo systemctl enable --now msxchat-gateway
sudo systemctl status msxchat-gateway
sudo journalctl -u msxchat-gateway -n 50 --no-pager
```

Crie a conta apenas se ainda não existir. Copie uma entrega limpa, sem diários nem credenciais. Preencha chave/modelo e IPs em /etc/msxchat/gateway.env antes de iniciar. É um EnvironmentFile de systemd, sem export; não execute source nesse arquivo. Ele fica fora do repositório, legível somente pelo root. O systemd cria /var/lib/msxchat com dono correto e permissão 0700. Na primeira inicialização essa pasta deve estar vazia; nas seguintes, preserve todo seu conteúdo. Cada instância usa seu próprio diário. Para migrar de Windows, pare a instância antiga e restaure o diário completo mantendo o mesmo peer; nunca execute ambas sobre cópias divergentes do diário.

O serviço usa SIGTERM e aguarda até 180 s para encerrar, cobrindo o timeout de API permitido de até 120 s. Restart=no evita ciclos de reinício diante de lock/estado inválido. Depois de falha, inspecione o diário antes de iniciar manualmente. Parar, reiniciar após alterações e desabilitar:

```bash
sudo systemctl stop msxchat-gateway
sudo systemctl restart msxchat-gateway
sudo systemctl disable --now msxchat-gateway
```

Não remova o diário ao atualizar o código. Faça backup com o serviço parado, por exemplo `sudo tar -C /var/lib -czf /root/msxchat-state-backup.tar.gz msxchat`.

## Windows

Os iniciadores RUN-GATEWAY.cmd e RUN-LAN.cmd continuam disponíveis. Abra PowerShell em aplicacao:

```powershell
$msxKey = Read-Host 'Chave da API OpenAI' -AsSecureString
$env:OPENAI_API_KEY = ([System.Net.NetworkCredential]::new('', $msxKey)).Password
Remove-Variable msxKey
$env:OPENAI_MODEL = 'ID_DO_MODELO_COM_ACESSO'
.\RUN-GATEWAY.cmd --check-config
.\RUN-GATEWAY.cmd --bind 192.168.1.10 --peer 192.168.1.50 --port 8765 --state C:/MSXCHAT-OPENAI
```

Depois de parar o servidor: `Remove-Item Env:OPENAI_API_KEY`. O manual README.md detalha limites, mensagens de erro e recuperação. Nos dois sistemas a chave fica somente no servidor e OPENAI_MODEL continua obrigatório.

## Verificação local e regressão

Na raiz entrega-final, execute `node VERIFICAR-ENTREGA.cjs`. Em uma cópia de trabalho, a partir de aplicacao:

```bash
node tests/test-launchers.cjs
node tests/test-gateway.cjs
node tests/test-gateway.cjs /tmp --real
node tests/test-lan-server.cjs
node tests/test-helper.cjs
```

Os testes HTTP/TLS são locais e usam respostas e credenciais sintéticas. Os testes existentes atualizam seus relatórios na cópia de trabalho. Para uma chamada autenticada real opcional: `node tests/smoke-live.cjs --live` (pode gerar cobrança). Os registros históricos não constituem homologação desta revisão em Linux. A automação do repositório executa a regressão em Ubuntu e Windows; consulte o resultado de cada execução.
