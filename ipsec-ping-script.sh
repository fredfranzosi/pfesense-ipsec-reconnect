source_ip="$(ifconfig -v vtnet1 | grep -o 'inet [^ ]*' | cut -f2 -d' ')"

while true; do
    /usr/local/sbin/ipsec status | awk '/con[0-9]+{[0-9]+}/ {gsub(/reqid|SPIs:|,|[a-zA-Z_]/, ""); print $4}' | awk '/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\//' | sort -u | awk -v source_ip="$source_ip" -F'.' '{print "ping -c 2 -S " source_ip " " $1 FS $2 FS $3 FS "1\nping -c 2 -S " source_ip " " $1 FS $2 FS $3 FS "254"}' | while read -r command; do
	    eval "$command"
    done
    sleep 10
done
