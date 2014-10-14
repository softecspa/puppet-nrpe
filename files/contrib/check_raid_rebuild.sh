#!/bin/bash

################################################
# Lorenzo Cocchi <lorenzo.cocchi@softecspa.it> #
# Nagios check RAID rebuild                    #
# Version 0.2                                  #
################################################

E_OK="0"
E_WARNING="1"
E_CRITICAL="2"
E_UNKNOWN="3"

MDSTAT="/proc/mdstat"

RETURN_CODE="${E_OK}"
OUTPUT=""

for md in $(egrep ^md ${MDSTAT} | awk '{ print $1 }'); do
    o="$(egrep -A 2 ${md} ${MDSTAT} | egrep '\[.*>.*\]')"
    if [ $? -ne 0 ]; then
        OUTPUT="${OUTPUT} ${md}=OK"
    elif [ $? -eq 1 ]; then
        RETURN_CODE="${E_CRITICAL}"
        o="$(echo ${o} | awk '{ print $1, $2$3$4 }')"
        OUTPUT="$OUTPUT ${md}=${o}"
    elif [ $? -eq 2 ]; then
        RETURN_CODE="${E_UNKNOWN}"
    fi
done

if [ -z "${OUTPUT}" ]; then
    RETURN_CODE="${E_UNKNOWN}"
    exit "${RETURN_CODE}"
fi

OUTPUT=$(echo ${OUTPUT} | sed -r -e 's/^\s+//' -e 's/(\s+md[0-9])/,\1/g')

echo "${OUTPUT}"
exit "${RETURN_CODE}"

# EOF
