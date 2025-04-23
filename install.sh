#!/bin/sh

#Verificar se existe configuração de IPSec
check_ipsec=$(/usr/local/sbin/ipsec status)

#Colocar serviço na configuração de inicialização do pfSense apenas se o parâmetro "install" for passado
if [ "$1" = "install" ]; then
    echo '<service><name>ipsec_check</name><rcfile>ipsec_check_service.sh</rcfile><executable>ipsec_check</executable></service>' > /tmp/temp_service.xml

    sed '/<\/acme>/r /tmp/temp_service.xml' /conf/config.xml > /conf/config.xml.tmp && mv /conf/config.xml.tmp /conf/config.xml

    (crontab -l ; echo "0 0 * * * /root/install.sh") | crontab -

    rm /tmp/temp_service.xml
fi

if [ -n "$check_ipsec" ]; then
    fetch -o /root/check_con_ipsec.sh https://raw.githubusercontent.com/fredfranzosi/pfesense-ipsec-reconnect/main/check_con_ipsec.sh
    chmod +x /root/check_con_ipsec.sh

    #Criar serviço rc.d no padrão do pfSense
    echo "Criando serviço no sistema..."

    if [ -f "/usr/local/etc/rc.d/ipsec_check.sh" ]; then
        rm /usr/local/etc/rc.d/ipsec_check.sh
    fi

    fetch -o /usr/local/etc/rc.d/ipsec_check_.sh https://raw.githubusercontent.com/matheus-nicolay/pfesense-ipsec-reconnect/main/ipsec_check.sh 
    chmod +x /usr/local/etc/rc.d/ipsec_check.sh

    #inicia o serviço
    service ipsec_check.sh start
    echo "Serviço criado"
else
    echo "Não existe nenhuma IPSec configurada"
fi
