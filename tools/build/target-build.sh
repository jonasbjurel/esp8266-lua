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
# DESCRIPTION: Uploads and compiles a file ($INPUT) to/on targets and downloads/
# transfers it to the the $OUTPUT directory.
# Usage: $0 $COM_PATH $ESP_PORT $ESP_BAUD -o $OUTPUT_FILE $INPUT_FILE
##############################################################################

##############################################################################
# TODO:
# A proper argument parsing to mimic the luac compiler args options
##############################################################################
SCRIPT=$(readlink -f $0)
SCRIPT_PATH=`dirname $SCRIPT`
COM_DIR=$1
ESP_PORT=$2
ESP_BAUD=$3
OUTPUT_FILE=$5
INPUT_FILE=$6

INPUT_FILE_NAME=`basename $INPUT_FILE`
INPUT_FILE_BASE_NAME=${INPUT_FILE_NAME%%.*}

${COM_DIR}/nodemcu-uploader.py --port $ESP_PORT --baud $ESP_BAUD file format
${COM_DIR}/nodemcu-uploader.py --port $ESP_PORT --baud $ESP_BAUD node restart

mkdir -p ${SCRIPT_PATH}/tmp
cd ${SCRIPT_PATH}/tmp
echo "Un-commenting $INPUT_FILE"
sed '/^ *--/ d' $INPUT_FILE > $INPUT_FILE_NAME
echo "Uploading file ${INPUT_FILE_NAME} to target"
echo ${COM_DIR}/nodemcu-uploader.py --port $ESP_PORT --baud $ESP_BAUD upload $INPUT_FILE_NAME
${COM_DIR}/nodemcu-uploader.py --port $ESP_PORT --baud $ESP_BAUD upload $INPUT_FILE_NAME
${COM_DIR}/compile-file.sh $ESP_PORT $ESP_BAUD $INPUT_FILE_NAME
echo "Downloading file ${INPUT_FILE_BASE_NAME}.lc to host"
${COM_DIR}/nodemcu-uploader.py --port $ESP_PORT --baud $ESP_BAUD download ${INPUT_FILE_BASE_NAME}.lc
cp ${INPUT_FILE_BASE_NAME}.lc $OUTPUT_FILE
cd ..
rm -rf ${SCRIPT_PATH}/tmp
${COM_DIR}/nodemcu-uploader.py --port $ESP_PORT --baud $ESP_BAUD file format
exit 0