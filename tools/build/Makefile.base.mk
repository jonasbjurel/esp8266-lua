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
# Description: The base Makefile which should be sourced by the target 
# Makefiles
#
##############################################################################

##############################################################################
# TODO:
##############################################################################

##############################################################################
# Input args variables, default values is set in Makefile.config.mk
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

##############################################################################
# Help variables - defined in <git_root/tools/build/Makefile.base1.mk>
#SHELL = /bin/bash
#BUILD_PATH:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
#BUILDFILES := $(LIBS) 
#BUILDFILES += $(BASEFILES)
#NOBUILDFILES := $(addsuffix .nobuild,$(BUILDFILES))
#NOBUILDSUBDIRS := $(addsuffix .nobuild,$(SUBDIRS))
# END of Help variables
#############################################################################

##############################################################################
# Build variables - is to be defined in the target Makefiles
#
# Build LIBS - needed library dependencies, LIB_PATH being defined by
# 'git_root'/tools/build/Makefile.config.mk
#LIBS := $(LIB_PATH)/foo
#LIBS += $(LIB_PATH)/bar
#
#Build base - local directory files to be built
#BASEFILES := $(BUILD_PATH)/my_current_dir_file_1
#BASEFILES += $(BUILD_PATH)/my_current_dir_file_2
#.
#.
#BASEFILES += $(BUILD_PATH)/my_current_dir_file_n
#
# Build subclasses - subclasses/sub-directories to be atonomously built
# with their own Makefile context, but with the same Makefile.config.mk
# and config.base.mk
#SUBDIRS := my_subclass_dir_1
#SUBDIRS := my_subclass_dir_2
#.
#.
#SUBDIRS := my_subclass_dir_n
# 
# Init file defines the file to be initialized on target after successful
# build - there can only be one init file throughout the global build tree.
#INITFILE := my_one_init_file
# END of Build variables
##############################################################################

##############################################################################
# Help variables
SHELL = /bin/bash
BUILDFILES := $(LIBS) 
BUILDFILES += $(BASEFILES)
NOBUILDFILES := $(addsuffix .nobuild,$(BUILDFILES))
NOBUILDSUBDIRS := $(addsuffix .nobuild,$(SUBDIRS))
# END of Help variables
#############################################################################

.PHONY: all
all:    build install runlc

.PHONY: help
help:
	@echo make methods supported:
	@echo help: Prints this text
	@echo clean: Cleans out all previous build artifacts
	@echo all/-: Compiles the input artifacts on the ESP8266/NodeMCU target and executes the INIT_FILE
	@echo no-compile: Doesnt compile input artifacts but upload source code to ESP8266/NodeMCU and executes the INIT_FILE
	@echo x-compile: Cross compiles the input artifacts, uploads them to the ESP8266/NodeMCU target and executes the INIT_FILE
	@echo
	@echo Input environment variables [Default value]:
	@echo ESP_PORT [/dev/ttyUSB0]: Sets the serial port device.
	@echo ESP_BAUD [9600]: Sets the serial port speed.
	@echo CC [$(BUILD_TOOL_PATH)/target-build.sh $(COM_PATH) $(ESP_PORT) $(ESP_BAUD)]: Sets the target compiler script path and related fixed arguments, default is target compiling - makee all/-.
	@echo XCC [~/elua/luac.cross]: Sets a host cross compiler path and related fixed arguments used for make target x-compile.
	@echo RELEASE_PATH [$(BUILD_PATH)/release]: Sets the path for resulting build artifacts.


.PHONY: no-compile
no-compile: nobuild install runlua

# It appears that cross compiling with elua on host produces ~30% larger 
# foot-print - so default is the slower target method.
.PHONY: x-compile
x-compile:
	@$(MAKE) -C $(BUILD_PATH) -f Makefile all CC="$(XCC) -cci 32 -cce little -ccn int 32"

.PHONY: clean
clean:
	@echo "Removing all old artifacts from build system"
	@rm -rf $(RELEASE_PATH)
	@echo "Removing all old artifacts from target system"
	@$(COM_PATH)/nodemcu-uploader.py --port $(ESP_PORT) --baud $(ESP_BAUD) node restart
	@$(COM_PATH)/nodemcu-uploader.py --port $(ESP_PORT) --baud $(ESP_BAUD) file format
	@$(COM_PATH)/nodemcu-uploader.py --port $(ESP_PORT) --baud $(ESP_BAUD) node restart

PHONY: build
build: $(SUBDIRS) $(BUILDFILES)

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	@mkdir -p $(RELEASE_PATH)
	@echo "Building subclass $@"
	@$(MAKE) -C $@ -f Makefile build RELEASE_PATH=$(RELEASE_PATH) CC="$(CC)" 

.PHONY: $(BUILDFILES)
$(BUILDFILES):
	@mkdir -p $(RELEASE_PATH)
	@echo "Building $@"
	@$(CC) -o $(RELEASE_PATH)/$(notdir $@.lc) $@.lua

.PHONY: nobuild
nobuild: $(NOBUILDSUBDIRS) $(NOBUILDFILES)

$(NOBUILDSUBDIRS): %.nobuild:
	@mkdir -p $(RELEASE_PATH)
	@$(MAKE) -C $* -f Makefile nobuild RELEASE_PATH=$(RELEASE_PATH) CC="$(CC)"

$(NOBUILDFILES): %.nobuild:
	@mkdir -p $(RELEASE_PATH)
	@echo "un-commenting $*.lua"
	@sed '/^ *--/ d' $*.lua > $(RELEASE_PATH)/$(shell basename $*).lua

.PHONY: install
install:
	@echo "Installing build artifacts to target system: $@ \n\n"
	@$(BUILD_TOOL_PATH)/install.sh $(ESP_PORT) $(ESP_BAUD) $(COM_PATH) $(RELEASE_PATH)

.PHONY: runlua
runlua:
	@echo "Initiating target system to run $(INITFILE).lua \n\n"
	@$(COM_PATH)/dofile.sh $(ESP_PORT) $(ESP_BAUD) $(INITFILE).lua

.PHONY: runlc
runlc:
	@echo "Initiating target system to run $(INITFILE).lc \n\n"
	@$(COM_PATH)/dofile.sh $(ESP_PORT) $(ESP_BAUD) $(INITFILE).lc
