# pfesense-ipsec-reconnect
Ao utilizar a VPN IPSec (site-to-site) do pfSense fechada com um Mikrotik, é notado que esporadicamente a mesma perde a comunicação entre as subredes e a conexão retornar após efetuar um ping da rede interna do pfSense para qualquer IP da rede interna remota.

O `install.sh` gera dinamicamente um script, contendo um ping com o IP da LAN do pfSense e os IP's da rede interna remota (substituindo o 0/24 por 1 ou 254 nas classes de IP). Cada ping é executado a cada 10 segundos, controlado pelo service ipsec_ping.sh

### Funcionalidades
- Ping do IP LAN para todas as classes remotas configuradas
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

### Issues
- Limitado a tentar pingar apenas para IP's internos remotos com final 254 e 1
- Caso não existam IP's internos remotos com final 254 e 1, o script irá constantemente reiniciar a VPN
- Pode não funcionar para IPSEC com mais de uma fase 2 por conexão
- Pela interface o serviço fica como parado, mesmo estando rodando:
  ![2023-11-17_14-42](https://github.com/matheus-nicolay/pfesense-ipsec-reconnect/assets/58345766/4882b296-ad0b-48e5-86c9-ce6de1d5a7ca)
