#!/bin/sh

name="ipsec_check"
command="/root/check_conn_ipsec.sh &"

rc_start() {
	# Make sure all process are stopped
	rc_stop

	if [ -f "/root/check_conn_ipsec.sh" ]; then
    	# Start 
		$command &
		
		pidnum="$(/bin/pgrep -f '/root/check_conn_ipsec.sh')"

		if [ -n "${pidnum}" ]; then
			echo "ipsec_check started  (pid ${pidnum})"
			/usr/bin/logger -p daemon.info -t ipsec_check "ipsec_check started (${pidnum})"
		else
			echo "ipsec_ping failed to start"
			/usr/bin/logger -p daemon.info -t ipsec_check "ipsec_check failed to start"
		fi
	else
		echo "ipsec_check failed to start - script /root/check_conn_ipsec.sh doesn't exist"
		/usr/bin/logger -p daemon.info -t ipsec_check "ipsec_check failed to start - script /root/check_conn_ipsec.sh doesn't exist"
	fi

	
}

rc_stop() {	
	pidnum="$(/bin/pgrep -f '/root/check_conn_ipsec.sh')"
        pidnum1="$(/bin/pgrep -f '/bin/sh service ipsec_check.sh start')"
	if [ -n "${pidnum}" ]; then
		kill -9 $pidnum
  		if [ -n "${pidnum1}" ]; then
                	kill -9 $pidnum1 || true
		fi
  
		echo "ipsec_check stopped (pid ${pidnum})"
		/usr/bin/logger -p daemon.info -t ipsec_check "ipsec_check stopped (${pidnum})"
	fi
}

rc_status() {	
	pidnum="$(/bin/pgrep -f '/root/check_conn_ipsec.sh')"
	if [ -n "${pidnum}" ]; then
		echo "ipsec_check is running (pid ${pidnum})"
	else
		echo "ipsec_check is not running"
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
