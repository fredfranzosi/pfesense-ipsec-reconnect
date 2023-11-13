#!/bin/sh

# PROVIDE: ipsec-ping
# REQUIRE: NETWORKING
# KEYWORD: shutdown

. /etc/rc.subr

name="ipsec-ping"
rcvar="ipsec_ping_enable"

start_cmd="/root/ipsec-ping.sh"

load_rc_config $name
: ${ipsec_ping_enable:=no}

run_rc_command "$1"
