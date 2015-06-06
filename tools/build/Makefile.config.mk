#############################################################################
# Copyright (c) 2015 Jonas Bjurel and others as listed below:
# jonasbjurel@hotmail.com 
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

##############################################################################
# Description: The configuration Makefile which should be sourced by the target 
# Makefiles
# This file needs to be edited according to the system configuration.
#
##############################################################################

##############################################################################
# TODO:
##############################################################################

##############################################################################
# Input args variables, default values is set in Makefile.config.mk
# Serial port device:
ESP_PORT=/dev/ttyUSB0
# Serial port speed:
ESP_BAUD=9600
# Target compile script path:
CC=$(BUILD_TOOL_PATH)/target-build.sh $(COM_PATH) $(ESP_PORT) $(ESP_BAUD)
# Host Cross compiler path:
XCC=~/elua/luac.cross
# Release artifacts path:
RELEASE_PATH=$(BUILD_PATH)/release
# Library path:
LIB_PATH=$(shell git rev-parse --show-toplevel)/lib
# Communication tools path:
COM_PATH=$(shell git rev-parse --show-toplevel)/tools/com
# Build tools path:
BUILD_TOOL_PATH=$(shell git rev-parse --show-toplevel)/tools/build
# END of Input args variables
#############################################################################
