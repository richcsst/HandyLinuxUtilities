#!/bin/bash

if ! [[ -v WHATISMYIP ]]; then
	if [ $# -gt 0 ]; then
        WHATISMYIP_KEY=$1;
        WHATISMYIP_URL="https://api.whatismyip.com/ip.php?key=${WHATISMYIP_KEY}";
        export WHATISMYIP=` curl -s "${WHATISMYIP_URL}" `;
        WHATISMYIP_INFO_URL="https://api.whatismyip.com/ip-address-lookup.php?key=${WHATISMYIP_KEY}&input=${WHATISMYIP}";
        export WHATISMYIP_INFO=` curl -s "${WHATISMYIP_INFO_URL}" `;

        if [ ${WHATISMYIP} = 3 ]; then
            unset WHATISMYIP
        fi
        if [ ${WHATISMYIP_INFO} = 3 ]; then
            unset WHATISMYIP_INFO
        fi
	else
	    echo "Missing What is my IP key"
		exit 2
	fi
fi

