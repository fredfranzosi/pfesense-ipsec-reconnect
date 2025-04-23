#conexoes para buscar
CONNECTIONS="con1 con5"

#Iterando sobre as conexoes
while true; do
  for conexao in $CONNECTIONS; do
    echo "checando conexao ${conexao}"
    /usr/local/sbin/ipsec status | grep -q "$conexao"
    if [ $? -ne 0 ]; then
      echo "Nao encontrei a conexao $conexao. Reiniciando..."
      /usr/local/sbin/ipsec down $conexao
      /usr/local/sbin/ipsec up $conexao
    fi
  done
  sleep 60
done
