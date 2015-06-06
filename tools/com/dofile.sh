#!/bin/bash
set -e
##############################################################################
# Copyright (c) 2015 Jonas Bjurel and others as listed below:
# jonas.bjurel@hotmail.com 
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

##############################################################################
# DESCRIPTION: Executes a given file on ESP8266 target
# Useage: $0 $ESP_PORT $ESP_BAUD $INIT_FILE
##############################################################################

##############################################################################
# TODO:
# Error handling, launching an input shell...., migration (through contribution)# to upstream  nodemcu-uploader.py project
##############################################################################
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

ESP_PORT=$1
ESP_BAUD=$2
INIT_FILE=$3

stty < /dev/ttyUSB0 `cat ${SCRIPTPATH}/tty-settings`
stty -F $ESP_PORT $ESP_BAUD
echo "rebooting target before run"
${SCRIPTPATH}/nodemcu-uploader.py --port $ESP_PORT --baud $ESP_BAUD node restart
sleep 5
echo "Execute init file:" $INIT_FILE
echo 'dofile("'${INIT_FILE}'")' > ${ESP_PORT}
cat ${ESP_PORT}
exit 0