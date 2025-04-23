#!/bin/sh

#Verificar se existe configuração de IPSec
check_ipsec=$(/usr/local/sbin/ipsec status)

#Colocar serviço na configuração de inicialização do pfSense apenas se o parâmetro "install" for passado
if [ "$1" = "install" ]; then
    echo '<service><name>ipsec_check</name><rcfile>ipsec_check.sh</rcfile><custom_php_service_status_command>mwexec(&quot;/usr/local/etc/rc.d/ipsec_check.sh status&quot;) == 0;</custom_php_service_
status_command><description><![CDATA[IPSEC Check Service]]></description></service>' > /tmp/temp_service.xml
    awk '/<\/installedpackages>/ { exit } { print } ' /conf/config.xml >  /tmp/conf1.xml
    echo "</installedpackages>" >  /tmp/conf2.xml
    awk '{ lines[NR] = $0 } /<\/installedpackages>/ { last = NR } END { for (i = last + 1; i <= NR; i++) print lines[i] }' /conf/config.xml > /tmp/conf3.xml
    cat /tmp/conf1.xml /tmp/temp_service.xml /tmp/conf2.xml /tmp/conf3.xml > /conf/config.xml.tmp && mv /conf/config.xml.tmp /conf/config.xml



    (crontab -l ; echo "0 0 * * * /root/install.sh") | crontab -

    rm /tmp/temp_service.xml
fi

if [ -n "$check_ipsec" ]; then
    fetch -o /root/check_conn_ipsec.sh https://raw.githubusercontent.com/fredfranzosi/pfesense-ipsec-reconnect/main/check_conn_ipsec.sh
    chmod +x /root/check_conn_ipsec.sh

    #Criar serviço rc.d no padrão do pfSense
    echo "Criando serviço no sistema..."

    if [ -f "/usr/local/etc/rc.d/ipsec_check.sh" ]; then
        rm /usr/local/etc/rc.d/ipsec_check.sh
    fi

    fetch -o /usr/local/etc/rc.d/ipsec_check.sh https://raw.githubusercontent.com/fredfranzosi/pfesense-ipsec-reconnect/main/ipsec_check.sh
    chmod +x /usr/local/etc/rc.d/ipsec_check.sh

    #inicia o serviço
    service ipsec_check.sh start
    echo "Serviço criado"
else
    echo "Não existe nenhuma IPSec configurada"
fi
