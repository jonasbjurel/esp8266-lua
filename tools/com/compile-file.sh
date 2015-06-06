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
# DESCRIPTION: Compiles a file to bytecode on targe ESP866 system.
# Usage: $0 $(ESP_PORT) $(ESP_BAUD) $(COMPILE_FILE)
##############################################################################

##############################################################################
# TODO:
# Error handling....., migration (through contribution) to upstream 
# nodemcu-uploader.py project 
##############################################################################

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

ESP_PORT=$1
ESP_BAUD=$2
COMPILE_FILE=$3

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

echo "Compiling ${COMPILE_FILE} on target"
stty < /dev/ttyUSB0 `cat ${SCRIPTPATH}/tty-settings`
stty -F $ESP_PORT $ESP_BAUD
echo 'node.compile("'${COMPILE_FILE}'")' > ${ESP_PORT}
sleep 5
exit 0