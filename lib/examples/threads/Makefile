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
# Description: A Project example showing hoe to use the threads library
#
##############################################################################

##############################################################################
# TODO:
##############################################################################

##############################################################################
# Input args variables, DEFAULT VALUES ARE NOT SET HERE!!!! 
# but in  <git_root/tools/build/Makefile.config.mk>
# Serial port device:
#ESP_PORT=/dev/ttyUSB0
# Serial port speed:
#ESP_BAUD=9600
# Target compile script path:
#CC=$(BUILD_TOOL_PATH)/target-build.sh $(COM_PATH) $(ESP_PORT) $(ESP_BAUD)
# Host Cross compiler path:
#XCC=~/elua/luac.cross
# Release artifacts path:
#RELEASE_PATH=$(BUILD_PATH)/release
# Library path:
#LIB_PATH=$(shell git rev-parse --show-toplevel)/lib
# Communication tools path:
#COM_PATH=$(shell git rev-parse --show-toplevel)/tools/com
# Build tools path:
#BUILD_TOOL_PATH=$(shell git rev-parse --show-toplevel)/tools/build
# END of Input args variables
#############################################################################

#############################################################################
# Make template defenitions
MAKE_PATH=$(shell git rev-parse --show-toplevel)/tools/build
BUILD_PATH:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
# END of Make template defenitions
############################################################################

############################################################################
# BEGIN of Include definitions 1
#
# YOU MIGHT NEED TO EDIT THE MAKE_CONFIG_PATH
include $(MAKE_PATH)/Makefile.config.mk
# END of Include definitions 1
############################################################################

##############################################################################
# Build variables - TO BE EDITED IN THIS FILE!
#
# Build LIBS - needed library dependencies, LIB_PATH being defined by
# 'git_root'/tools/build/Makefile.config.mk
LIBS := $(LIB_PATH)/threads
LIBS += $(LIB_PATH)/common
#.
#.
#LIBS += $(LIB_PATH)/foo_bar.lib
#
#Build base - local directory files to be built
BASEFILES := $(BUILD_PATH)/start
#BASEFILES += $(BUILD_PATH)/my_current_dir_file_2
#.
#.
#BASEFILES += $(BUILD_PATH)/my_current_dir_file_n
#
# Build subclasses - subclasses/sub-directories to be atonomously built
# with their own Makefile context, but with the same Makefile.config.mk
# and config.base.mk
SUBDIRS := threads
#SUBDIRS += my_subclass_dir_2
#.
#.
#SUBDIRS += my_subclass_dir_n
# 
# Init file defines the file to be initialized on target after successful
# build - there can only be one init file throughout the global build tree.
INITFILE := start
# END of Build variables
##############################################################################

############################################################################
# BEGIN of Include definitions 2
include $(MAKE_PATH)/Makefile.base.mk
# END Include definitions 2
#############################################################################
