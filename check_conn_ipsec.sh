#conexoes para buscar

#Iterando sobre as conexoes
while true; do
  for conexao in $CONNECTIONS; do
    /usr/local/sbin/ipsec status | grep -q "$conexao"
    if [ $? -ne 0 ]; then
      #echo "Nao encontrei a conexao $conexao. Reiniciando..."
      /usr/local/sbin/ipsec down $conexao
      /usr/local/sbin/ipsec up $conexao
    fi
  done
  sleep 60
done
