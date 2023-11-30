#!/usr/local/bin/python3.11

import subprocess
import time

def get_connections():
    try:
        output1 = subprocess.check_output("/usr/local/sbin/ipsec status", shell=True, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        output1 = str(e.output)

    output = subprocess.check_output(
        "/usr/local/sbin/ipsec status | awk '/con[0-9]+{[0-9]+}/ {gsub(/reqid|SPIs:|,|[a-zA-Z_]/, \"\"); print $4, $7}' | awk '/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\//'",
        shell=True,
        text=True
    )
    output=output.split("\n")

    ips = []
    strings_vistas = set()
    con_indexes = []

    for string in output:
        if string not in strings_vistas and string != '':
            con_indexes.append(output1.split(string.strip())[0].split("con")[-1].split("{")[0])
            ips.append(string.replace('0/24|/0', '1').rstrip())
            ips.append(string.replace('0/24|/0', '254').rstrip())
            strings_vistas.add(string)

    ips = list(filter(None, ips))
    connections = [(ips[i], ips[i + 1]) for i in range(0, len(ips), 2)]

    return connections, con_indexes

def main():
    connections, con_indexes = get_connections()

    source_ip=subprocess.check_output("ifconfig -v vtnet1 | grep -o 'inet [^ ]*' | cut -f2 -d' '", shell=True, text=True).strip()

    while True:
        count = 0
        for ip_pair in connections:
            con_index = con_indexes[count]
            ip1, ip2 = ip_pair

            ping_ip1 = subprocess.call(f"ping -c 3 -t 2 -S {source_ip} {ip1} > /dev/null", shell=True)
            ping_ip2 = subprocess.call(f"ping -c 3 -t 2 -S {source_ip} {ip2} > /dev/null", shell=True)

            if ping_ip1 != 0 and ping_ip2 != 0:
                subprocess.call(f"/usr/local/sbin/ipsec down con{con_index} ; /usr/local/sbin/ipsec up con{con_index}", shell=True)
        
            count+=1

        time.sleep(5)

if __name__ == "__main__":
    main()
