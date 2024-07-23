# ----------------------------------------------------------------------------
# adaptabuild.mak - top level adaptabuild compatible makefile for a project
#
# Invoke the build system with:
#
# make -f path/to/adaptabuild.mak MCU=xxx PRODUCT=yyy target
#
# AVOID CHANGING THIS FILE - your project specific includes come from the
#                            adaptabuild.project.mak file
#
# The goal of adaptabuild is to hide most of the makefile complexity from
# developers that don't want to learn the insides of yet another way to
# build their project.
#
# This file may change over time as we continue to develop adaptabuild
# ----------------------------------------------------------------------------

include $(ADAPTABUILD_PATH)/make/log.mak

MKPATH := mkdir -p

# Note the use of = (not :=) to defer evaluation until it is called
#
# Note also that for this conditional to work, $(ROOT_PATH) must be defined before
# the conditional is evaluated
#
ifeq (.,$(ROOT_PATH))
  make_current_module_path = $(patsubst $(SRC_PATH)/%/,%,$(ROOT_PATH)/$(dir $(lastword $(MAKEFILE_LIST))))
else
  make_current_module_path = $(patsubst $(SRC_PATH)/%/,%,$(dir $(lastword $(MAKEFILE_LIST))))
endif

# ----------------------------------------------------------------------------
# The are GLOBAL variables that may be updated by included makefiles
#
# We define them to be empty strings here so that it's clear that they are
# needed.
#

CDEFS :=
CFLAGS :=
LDFLAGS :=
DEPFLAGS :=

MODULE_LIBS :=

TESTABLE_MODULES :=

# ----------------------------------------------------------------------------
# Do NOT move this include - it MUST be before the definition of MCU_MAK
#
SRC_PATH   := $(ROOT_PATH)/src
$(call log_info,SRC_PATH is $(SRC_PATH))

# ----------------------------------------------------------------------------
# Do NOT move this include - it MUST be after the definition of SRC_PATH
#                            and before the including adaptabuild_product.mak
#
# MCU_MAK is created as part of validate_mcu.mak - it is a list of files
#         that is included later in this script that define targets for
#         the MCU support libraries.
#
MCU_MAK :=

include $(ADAPTABUILD_PATH)/make/mcu/validate_mcu.mak
$(call log_info,MCU_MAK is $(MCU_MAK))

# ----------------------------------------------------------------------------
# Do NOT move this include - it MUST be after the definition of MCU_MAK
#                                  and before the definition of BUILD_PATH
include $(ROOT_PATH)/adaptabuild_product.mak
$(call log_info,PRODUCT is $(PRODUCT))

BUILD_PATH := $(ROOT_PATH)/build/$(PRODUCT)/$(MCU)
$(call log_notice,BUILD_PATH is $(BUILD_PATH))

ABS_BUILD_PATH := $(ABS_PATH)/build/$(PRODUCT)/$(MCU)
$(call log_notice,ABS_BUILD_PATH is $(ABS_BUILD_PATH))

ARTIFACTS_PATH := $(ROOT_PATH)/artifacts/$(PRODUCT)/$(MCU)
$(call log_notice,ARTIFACTS_PATH is $(ARTIFACTS_PATH))

# ----------------------------------------------------------------------------

.SUFFIXES :

.PHONY : all clean

# ----------------------------------------------------------------------------
# The default all: target can have multiple dependencies, and they are ALWAYS
# evaluated left to right. This allows you to configure a pipeline of
# tasks for your project.
#
# TODO: Expand on these dummy routines and add pre and post build steps for
#       things like unit testing, adding CRC or checksum, combining images
#       or even loading an image onto a real target.

all: foo bar product baz bif

foo:
    $(call log_info,adaptabuild foo)

bar:
    $(call log_info,adaptabuild bar)

product: $(BUILD_PATH)/$(PRODUCT)/$(PRODUCT)

baz:
    $(call log_info,adaptabuild baz)

bif:
    $(call log_info,adaptabuild bif)

# ----------------------------------------------------------------------------
# Do NOT move this include - it MUST be after the definition of BUILD_PATH
#                            and before anythiong that depends on MODULE_LIBS
include $(ROOT_PATH)/adaptabuild_artifacts.mak

# ----------------------------------------------------------------------------
# Do NOT move this include - it cannot be before any target definitions
#
include $(MCU_MAK)

# Not sure if this is needed - do we need a rule about how to name a module?
# or if a product should have at least a dummy file - normally we have main.c
# in the product folder
include $(SRC_PATH)/$(PRODUCT)/adaptabuild.mak

$(call log_notice,TESTABLE_MODULES is $(TESTABLE_MODULES))

# ----------------------------------------------------------------------------
# Default target for now:
#
# LDSCRIPT should be named based on the project and target cpu
#
# Simplify to path to the product source and product_main and executable

LDSCRIPT = $(SRC_PATH)/$(PRODUCT)/config/$(MCU)/$(MCU_LINKER_SCRIPT).ld

# TODO: Separate the linker options between host and embedded builds.
#       Host builds use g++ which does not support --start-group
#       Embedded builds need --start-group
#
# TODO: Add support for high priority object files, for example
#       strong overrides for weak symbols s shown below for
#       stm32h7xx_it.o
#
#       This should probably be something like $(WEAK_OVERRIDES)
#
# TODO: Add some way of overriding the hiding of command lines at the
#       top build level
#
$(BUILD_PATH)/$(PRODUCT)/$(PRODUCT): LDFLAGS += -T$(LDSCRIPT)
$(BUILD_PATH)/$(PRODUCT)/$(PRODUCT): $(MODULE_LIBS) $(LDSCRIPT)
	$(LD) -g -o $@.elf $(SYSTEM_STARTUP_OBJ) < \
	      $(BUILD_PATH)/$(PRODUCT_MAIN).o \
	      $(BUILD_PATH)/HAL/STM/H7xx/LDD_T-RaCPU_H7B3RIT6/Src/stm32h7xx_it.o \
              $(LDGROUP) $(LDFLAGS) $(LDMAP) --cref
	      
unittest : $(TESTABLE_MODULES)
	@echo dkfjvndkfjvnkjn $(TESTABLE_MODULES)

# ----------------------------------------------------------------------------
# .PHONY targets that provide some eye candy for the make log

#clean:
#	rm -rf build/$(PRODUCT)
#	rm -rf artifacts/$(PRODUCT)

#begin:
#	@echo
#	@echo $(MSG_BEGIN)
	
#finished:
#	@echo $(MSG_ERRORS_NONE)

#end:
#	@echo $(MSG_END)
#	@echo
	
#gccversion :
#	@$(CC) --version
