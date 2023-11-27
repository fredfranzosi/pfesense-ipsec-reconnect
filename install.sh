#!/bin/sh
pkg-static install -y python311-3.11.6

if [ -f "/root/ipsec_ping-script.py" ]; then
    rm /root/ipsec_ping-script.py
fi

#Verificar se existe configuração de IPSec
check_ipsec=$(/usr/local/sbin/ipsec status)

#Colocar serviço na configuração de inicialização do pfSense apenas se o parâmetro "install" for passado
if [ "$1" = "install" ]; then
    echo '<service><name>ipsec_ping</name><rcfile>ipsec_ping.sh</rcfile><executable>ipsec_ping</executable></service>' > /tmp/temp_service.xml

    sed '/<\/acme>/r /tmp/temp_service.xml' /conf/config.xml > /conf/config.xml.tmp && mv /conf/config.xml.tmp /conf/config.xml

    (crontab -l ; echo "0 0 * * * /root/install.sh") | crontab -

    rm /tmp/temp_service.xml
fi

if [ -n "$check_ipsec" ]; then
    fetch -o /root/ipsec_ping-script.py https://raw.githubusercontent.com/matheus-nicolay/pfesense-ipsec-reconnect/main/ipsec_ping-script.py
    chmod +x /root/ipsec_ping-script.py

    #Criar serviço rc.d no padrão do pfSense
    echo "Criando serviço no sistema..."

    if [ -f "/usr/local/etc/rc.d/ipsec_ping.sh" ]; then
        rm /usr/local/etc/rc.d/ipsec_ping.sh
    fi

    fetch -o /usr/local/etc/rc.d/ipsec_ping.sh https://raw.githubusercontent.com/matheus-nicolay/pfesense-ipsec-reconnect/main/ipsec_ping.sh 
    chmod +x /usr/local/etc/rc.d/ipsec_ping.sh

    #inicia o serviço
    service ipsec_ping.sh start
    echo "Serviço criado"
else
    echo "Não existe nenhuma IPSec configurada"
fi
