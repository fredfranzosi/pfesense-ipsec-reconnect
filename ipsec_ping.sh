#!/bin/sh

name="ipsec_ping"
command="/root/${name}-script.sh &"

rc_start() {
	# Make sure all process are stopped
	rc_stop

	# Start 
	$command
	
	pidnum="$(/bin/pgrep -f '/root/ipsec_ping-script.sh')"

	if [ -n "${pidnum}" ]; then
		echo "ipsec_ping started  (pid ${pidnum})"
		/usr/bin/logger -p daemon.info -t ipsec_ping "ipsec_ping started (${pidnum})"
	else
		echo "ipsec_ping failed to start"
		/usr/bin/logger -p daemon.info -t ipsec_ping "ipsec_ping failed to start"
	fi
}

rc_stop() {	
	pidnum="$(/bin/pgrep -f '/root/ipsec_ping-script.sh')"
	if [ -n "${pidnum}" ]; then
		kill -9 $pidnum
		echo "ipsec_ping stopped"
		/usr/bin/logger -p daemon.info -t ipsec_ping "ipsec_ping stopped (${pidnum})"
	fi
}

rc_status() {	
	pidnum="$(/bin/pgrep -f '/root/ipsec_ping-script.sh')"
	if [ -n "${pidnum}" ]; then
		echo "ipsec_ping is running (pid ${pidnum})"
	else
		echo "ipsec_ping is not running"
	fi
}

case $1 in
	start)
		rc_start
		;;
	stop)
		rc_stop
		;;
	restart)
		rc_stop
		rc_start
		;;
	status)
		rc_status
		;;
esac
