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
# DESCRIPTION: Installs all files residing in $INSTALL_PATH to the ESP8266 
# target
# Useage: $0 $ESP_PORT $ESP_BAUD $COM_PATH $INSTALL_PATH
##############################################################################

##############################################################################
# TODO:
# -
##############################################################################

ESP_PORT=$1
ESP_BAUD=$2
COM_PATH=$3
INSTALL_PATH=$4

echo "Cleaning target before install...."
${COM_PATH}/nodemcu-uploader.py --port $ESP_PORT --baud $ESP_BAUD file format
${COM_PATH}/nodemcu-uploader.py --port $ESP_PORT --baud $ESP_BAUD node restart

cd ${INSTALL_PATH}
for filename in *; do 
  echo Installing ${filename} 
  ${COM_PATH}/nodemcu-uploader.py --port $ESP_PORT --baud $ESP_BAUD upload $filename 
done