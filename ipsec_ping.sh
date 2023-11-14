#!/bin/sh

name="ipsec-ping"
command="/root/${name}-script.sh"

rc_start() {
	# Make sure all process are stopped
	rc_stop

	# Start 
	pidnum=(${command} &)

	echo "ipsec-ping started (${pidnum})"
	/usr/bin/logger -p daemon.info -t ipsec-ping "ipsec-ping started"
}

rc_stop() {	
	pidnum="$(/bin/pgrep $name)"
	if [ -n "${pidnum}" ]; then
		/usr/bin/killall $name
		echo "ipsec-ping stopped (${pidnum})"
		/usr/bin/logger -p daemon.info -t ipsec-ping "ipsec-ping stopped"
	fi
}

rc_status() {	
	pidnum="$(/bin/pgrep $name)"
	if [ -n "${pidnum}" ]; then
		echo "ipsec-ping is running (${pidnum})"
	else
		echo "ipsec-ping is not running"
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
