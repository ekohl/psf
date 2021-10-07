#!/bin/bash

set -e

SOCKET_DIR=${SOCKET_DIR:-/run/psf}
ENC_TIMEOUT=10
FACT_TIMEOUT=10
REPORT_TIMEOUT=10

enc() {
	echo "$1" | socat -t $ENC_TIMEOUT - unix:${SOCKET_DIR}/enc
}

facts() {
	if [[ ! -f $1 ]] ; then
		echo "File '$1' not found"
		exit 1
	fi
	cat "$1" | socat -t $FACT_TIMEOUT - unix:${SOCKET_DIR}/facts
}

report() {
	if [[ ! -f $1 ]] ; then
		echo "File '$1' not found"
		exit 1
	fi
	cat "$1" | socat -t $REPORT_TIMEOUT - unix:${SOCKET_DIR}/report
}

action=$1

if ! shift ; then
	echo "Usage: $0 [enc|facts|report] ARGUMENT"
	exit 1
fi

case $action in
	enc)
		if [[ -z $1 ]] ; then
			echo "Usage: $0 $action HOSTNAME"
			exit 1
		fi
		enc "$1"
		;;
	facts)
		if [[ -z $1 ]] ; then
			echo "Usage: $0 $action FACT_FILE.[json|yaml]"
			exit 1
		fi
		facts "$1"
		;;
	report)
		if [[ -z $1 ]] ; then
			echo "Usage: $0 $action REPORT.[json|yaml]"
			exit 1
		fi
		report "$1"
		;;
	*)
		echo "Unknown action '$action'"
		exit 1
		;;
esac
