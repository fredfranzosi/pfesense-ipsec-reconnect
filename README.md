# pfesense-ipsec-reconnect
Ao utilizar a VPN IPSec (site-to-site) do pfSense fechada, é notado que esporadicamente a mesma perde a comunicação entre as subredes e a conexão somente é retornada após uma intervenção manual. Esse serviço checa periodicamente as conexões ativas e tenta reestabelecer as conexões que estiverem inativas de modo a manter sempre os túneis ativos.

O `install.sh` baixa um script, que checa periodicamente algumas conexões IPSeC descritas na variável CONNECTIONS dentro do script check_conn_ipsec.sh. O teste é executado a cada 10 segundos, controlado pelo serviço ipsec_check.sh

### Funcionalidades
- Crontab para atualização do script todos os dias, as 00:00 horas
- Serviço no daemon do sistema para iniciar e parar o script 

### Instalação
Rodar o seguinte comando na CLI (Diagnostics > Command Prompt) do pfSense para efetuar a instalação:

```
rm /root/install.sh || true ; fetch -o /root/install.sh https://raw.githubusercontent.com/matheus-nicolay/pfesense-ipsec-reconnect/main/install.sh ; chmod +x /root/install.sh ; /root/install.sh install
```

Para verificar o status do serviço:
```
service ipsec_ping.sh status
```

Para iniciar/reiniciar o serviço:
```
service ipsec_ping.sh start
```

Para parar o serviço:
```
service ipsec_ping.sh stop
```
