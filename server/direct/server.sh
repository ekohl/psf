#!/bin/bash

set -e

SOCKET_DIR=/run/psf
SCRIPT_DIR=.
ACTION=$1

if [[ -z $ACTION ]] ; then
	echo "Usage: $0 ACTION"
	exit 1
fi

systemd-socket-activate -l ${SOCKET_DIR}/${ACTION} -- ${SCRIPT_DIR}/puppetserver-foreman ${ACTION}
