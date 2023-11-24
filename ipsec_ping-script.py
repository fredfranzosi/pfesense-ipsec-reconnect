#!/usr/local/bin/python3.11

import subprocess
import time

def get_connections():
    output = subprocess.check_output(
        "/usr/local/sbin/ipsec status | awk '/con[0-9]+{[0-9]+}/ {gsub(/reqid|SPIs:|,|[a-zA-Z_]/, \"\"); print $4, $7}' | awk '/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\//' | sort | uniq | awk -F'/' '{gsub(/0$/,\"1\",$1); gsub(/0$/,\"254\",$1); print $1; gsub(/1$/,\"254\",$1); print $1}'",
        shell=True,
        text=True
    )
    connections = output.split()
    return [(connections[i], connections[i + 1]) for i in range(0, len(connections), 2)]

def main():
    connections = get_connections()

    source_ip=subprocess.check_output("ifconfig -v vtnet1 | grep -o 'inet [^ ]*' | cut -f2 -d' '", shell=True, text=True).strip()

    while True:
        for ip_pair in connections:
            con_index = connections.index(ip_pair) + 1
            ip1, ip2 = ip_pair

            ping_ip1 = subprocess.call(f"ping -c 3 -t 2 -S {source_ip} {ip1} > /dev/null", shell=True)
            ping_ip2 = subprocess.call(f"ping -c 3 -t 2 -S {source_ip} {ip2} > /dev/null", shell=True)

            if ping_ip1 != 0 and ping_ip2 != 0:
                #print(f"Reiniciando conexão con{con_index}...")
                subprocess.call(f"/usr/local/sbin/ipsec down con{con_index} ; /usr/local/sbin/ipsec up con{con_index}", shell=True)
        
        time.sleep(5)

if __name__ == "__main__":
    main()
