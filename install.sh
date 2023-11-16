#!/bin/sh
rm /root/ipsec_ping-script.sh

# Obter o endereço IP da interface
source_ip="$(ifconfig -v vtnet1 | grep -o 'inet [^ ]*' | cut -f2 -d' ')"

# Comando para obter sub-redes modificadas
subnets=$(/usr/local/sbin/ipsec status | awk '/con[0-9]+{[0-9]+}/ {gsub(/reqid|SPIs:|,|[a-zA-Z_]/, ""); print $4, $7}' | awk '/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\//' | sort | uniq | awk -F'/' '{gsub(/0$/,"1",$1); gsub(/0$/,"254",$1); print $1; gsub(/1$/,"254",$1); print $1}')

echo "while true; do" >> /root/ipsec_ping-script.sh

# Criar arquivo e adicionar linhas de comando ping
echo "$subnets" | while read -r subnet; do
  echo "ping -c 3 -S $source_ip $subnet > "/dev/null" &" >> /root/ipsec_ping-script.sh
done

echo "sleep 10" >> /root/ipsec_ping-script.sh
echo "done" >> /root/ipsec_ping-script.sh

chmod +x /root/ipsec_ping-script.sh

echo "Arquivo /root/ipsec_ping-script.sh criado"
echo "Criando serviço no sistema..."

rm /usr/local/etc/rc.d/ipsec_ping.sh

fetch -o /usr/local/etc/rc.d/ipsec_ping.sh https://raw.githubusercontent.com/matheus-nicolay/pfesense-ipsec-reconnect/main/ipsec_ping.sh 
chmod +x /usr/local/etc/rc.d/ipsec_ping.sh

echo '<service><name>ipsec_ping</name><rcfile>ipsec_ping.sh</rcfile><executable>ipsec_ping</executable></service>' > /tmp/temp_service.xml

sed '/<\/acme>/r /tmp/temp_service.xml' /conf/config.xml > /conf/config.xml.tmp && mv /conf/config.xml.tmp /conf/config.xml

rm /tmp/temp_service.xml

service ipsec_ping.sh start &

echo "Serviço criado"
