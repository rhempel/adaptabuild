# ----------------------------------------------------------------------------
# adaptabuild.mak - top level adaptabuild compatible makefile for a project
#
# Invoke the build system with:
#
# make -f path/to/adaptabuild_config.mak MCU=xxx PRODUCT=yyy target
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

MKPATH := mkdir -p

# NOTE: THIS SHOULD BE EXTRACTED BY SPHINX/HAWKMOTH TO BE AUTOMATICALLY
#       ADDED TO THE ADAPTABUILD DOCUMENTATION!
#
# The adaptabuild system lets you run make for your project from anywhere
# in the file system. That might not seem like a big deal but it can really
# simplify your CI pipeline command structure.This means that:
#
# cd path/to/your/project
# make -f adptabuild_config.mak ....
#
# is the same as:
#
# make -f path/to/your/project/adaptabuild_config.mak
#
# Unfortunately this flexibility leads to a number of tricky corner cases
# when using ROOT_PATH and SRC_PATH because they can evaluate to just "."
# under some conditions. For reaons that will become clear later, these values
# must NEVER evaluate to an empty string.
#
# The make program has built-in functions to handle path maanipulations, and
# we wil take advantage of them together with the text manipulation functions
# to generate clean path and filenames.
#
# We will use the following path to illustrate the three possibilities
# for pathnames that need to be handled in adaptabuild
#
# /home/you/path/to/project                             - "root" of the project to be build
# /home/you/path/to/project/adaptabuild                 - submodule containing the adaptabuild system
# /home/you/path/to/project/adaptabuild_root.mak        - top level adaptabuild makefile
# /home/you/path/to/project/$(SRC_PATH)                 * location of ALL source code
# /home/you/path/to/project/$(SRC_PATH)/foo             - location of product "foo" source code
# /home/you/path/to/project/$(SRC_PATH)/third-party/bar - location of third party module "baz" source code
# /home/you/path/to/project/$(BUILD_PATH)               * location of ALL generated output
#
# The first thing adaptabuild does is create the ROOT_PATH variable. This is
# defined as the path from where you are running make to the adaptabuild_root.mak
# file. There are three possibilities:
#
# 1. Run from /home/you/path/to/project -> ROOT_PATH = .
# 2. Run from /home/you                 -> ROOT_PATH = path/to/project/
# 3. Run from /                         -> ROOT_PATH = /home/you/path/to/project/
#
# We will need to trim the leading and trailing "/" characters to get a path that
# we can use in a make variable so that it's easier to read. For example the 
# BUILD_PATH (which must not be a pre-existing diretory) is defined as:
#
# BUILD_PATH := $(ROOT_PATH)/build
#
# Similarly, we can define the SRC_PATH like this:
#
# SRC_PATH := $(ROOT_PATH)     --
# SRC_PATH := $(ROOT_PATH)/     |- These are all equivalent and result in .
# SRC_PATH := $(ROOT_PATH)/.   --
# SRC_PATH := $(ROOT_PATH)/src
#
# Note that there are some cases - such as a submodule that you want to reuse and have
# separate test cases and build procedures for - where one of the first three forms
# is preferred.
#
# Finally, each of the modules or products in a project will have a path that is
# relative to the SRC_PATH. This is very important because it allows us to create
# module level source and include file lists that are _independent_ of where the
# module lives in your project's SRC_PATH. 
#
# One of the key design goals of the adaptabuild syste is that the make runs from one
# dircetory - your current directory, and it can be anywhere in the filesystem.
#
# That means your module level makefiles don't care where they are located, adaptabuild
# figures out all the paths to your source and build files.
#
# Rather than continuously simplifying and cleaning up the paths, we do it once when
# building the patten stems...
  

##     #
##     # BUILD_PATH is generated from the ROOT_PATH, PRODUCT, and MCU variables
##     # to guarantee a unique location for object files for each variant.
##     #
##     # TARGET_STEM := $(BUILD_PATH)/$(MODULE_PATH)
##     # PREREQ_STEM := $(SRC_PATH)/$(MODULE_PATH)
##     #
##     # When we build a library, the MODULE_PATH is guaranteeed to be relative
##     # to SRC_PATH, and has no leading / characters.
##     #
##     # SRC_PATH is specified with ROOT_PATH as its base - this leads to the
##     # following cases:
##     #
##     # 1. SRC_PATH := $(ROOT_PATH)/some/path
##     # 2. SRC_PATH := $(ROOT_PATH)/.
##     # 3. SRC_PATH := $(ROOT_PATH)
##     #
##     # The stems are used in rules like this:
##     #
##     # $(TARGET_STEM)/%.o: $(PREREQ_STEM)/%.c
##     #
##     # That works as long as the transformation of a list of source files from
##     # your module is consistent with this simple pattern match. An example will
##     # make all of this clear. Let's assume the following minimal example.
##     #
##     # MODULE = motor
##     # SRC_C = core/speed.c main.c
##     #
##     # Your module specification calls a function to generate a path to the
##     # module source that is relative to the ROOT_PATH.
##     #
##     # MODULE_PATH := $(call make_current_module_path)
##     #
##     # Just like ROOT_PATH and SRC_PATH, the MODULE_PATH can evaluate to "."
##     # under some conditions. The significance of this will become clean
##     # shortly.
##     #
##     # Your module specification doesn't need to worry about any external
##     # variables, because the adapatabuild/make/library.mak file transforms
##     # your file list into something the stem rules can use. THe simplified
##     # transformation looks like this:
##     #
##     # $(MODULE)_SRC := $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C))
##     #
##     # In the most complex case, this evaluates to soething like this:
##     #
##     # motor_SRC := ././core/speed.c ././main.c
##     #
##     # Now its time to transform the source file list to an object file list
##     # for the stem rules. The simplified transformation is something like this:
##     #
##     # $(MODULE)_OBJ := $(subst $(SRC_PATH),$(BUILD_PATH),\
##     #                    $(subst .c,.o,$($(MODULE)_SRC)))
##     #
##     # Which _should_ result in:
##     #
##     # motor_OBJ := path/to/build/core/speed.c path/to/build/main.c
##     #
##     # ... but it doesn't because the $(subst from,to,text) function will
##     # substitute ALL occurences of the from parameter, and if it's just "."
##     # the result is multiple substitutions.
##     #
##     # The key to fixing the problem is similar to how you fix endianness
##     # issues. Figure out the permutaitons and FIX IT IN ONE PLACE - ideally
##     # before you generate the substitutions so you never have to worry
##     # about it again.
##     #
##     # The good news is that make has the $(abspath names...) function to
##     # transform a string into an absolute value wthout any . or .. components
##     # nor any repeated path separators (/). For example:
##     #
##     # $(abspath ./foo/././../foo///bar)
##     #
##     # returns:
##     #
##     # /path/to/your/current/directory/foo/bar
##     #
##     # To get the value of that complex path relative to ROOT_PATH we can do
##     # something like this:
##     #
##     # $(subst _$(abspath .),,_$(abspath ./foo/././../foo///bar)))
##     #
##     # Note the following special features of this transformation:
##     #
##     # 1. There is  "_" prefix character before the from and text parameters
##     #    to prevent the special case of running make from the root of
##     #    your filesystem from breaking the subst function.
##     # 2. The to string is empty, which is represented by ",," - it's the
##     #    only way to represent nothing in make.
##     #
##     # We can now make a summary and tests for all of the special cases that
##     # we need to cover:
##     #
##     # 
##     #

strip_trailing_slash = $(patsubst %/,%,$(1))

$(call log_info,ROOT_PATH is $(ROOT_PATH))

ABS_CWD_PATH := $(abspath .)
ABS_ROOT_PATH := $(abspath $(ROOT_PATH))
ABS_SRC_PATH := $(abspath $(SRC_PATH))

$(call log_info,ABS_CWD_PATH is $(ABS_CWD_PATH))
$(call log_info,ABS_ROOT_PATH is $(ABS_ROOT_PATH))
$(call log_info,ABS_SRC_PATH is $(ABS_SRC_PATH))

# Add a note about the underscore prefix trick to avoid substituring ALL of
# the / when ABS_CWD_PATH is the root of the file system.

make_cwd_relative_path = $(or $(patsubst /%,%,$(patsubst $(ABS_CWD_PATH)%,%,$(1))),.)
make_src_relative_path = $(or $(patsubst /%,%,$(patsubst $(ABS_SRC_PATH)%,%,$(1))),.)

make_cwd_relative_files = $(patsubst /%,%,$(patsubst $(ABS_CWD_PATH)%,%,$(1)))
make_src_relative_files = $(patsubst /%,%,$(patsubst $(ABS_SRC_PATH)%,%,$(1)))

# make_current_module_path = $(dir $(lastword $(MAKEFILE_LIST)))
make_current_module_path = $(or $(patsubst %/,%,$(patsubst /%,%,$(patsubst $(ABS_SRC_PATH)%,%,$(abspath $(dir $(lastword $(MAKEFILE_LIST))))))),.)
#make_current_module_path = $(or $(patsubst /%,%,$(patsubst $(ABS_SRC_PATH)%,%,$(dir $(lastword $(MAKEFILE_LIST))))),.)
#make_current_module_path = $(or $(patsubst /%,%,$(patsubst $(ABS_SRC_PATH)%,%,$(dir $(lastword $(MAKEFILE_LIST))))),.)
#make_current_module_path = $(or $(patsubst /%,%,$(patsubst $(ABS_SRC_PATH)%,%,$(dir $(lastword $(MAKEFILE_LIST))))),.)

ROOT_PATH := $(call make_cwd_relative_path,$(ABS_ROOT_PATH))
SRC_PATH := $(call make_cwd_relative_path,$(ABS_SRC_PATH))

$(call log_info,adjusted ROOT_PATH is $(ROOT_PATH))
$(call log_info,adjusted SRC_PATH is $(SRC_PATH))

# ABS_ROOT_PATH := $(abspath $(ROOT_PATH))
# ABS_SRC_PATH := $(abspath $(SRC_PATH))
# 
# $(call log_info,ABS_CWD_PATH is $(ABS_CWD_PATH))
# $(call log_info,ABS_ROOT_PATH is $(ABS_ROOT_PATH))
# $(call log_info,ABS_SRC_PATH is $(ABS_SRC_PATH))
# 
# # Handle the special cases of substitutions if running from /
# #
# ifeq (/,$(ABS_CWD_PATH))
#   make_cwd_relative_path = $(subst _/,,_$1)
# else
#   make_cwd_relative_path = $(subst _$(ABS_CWD_PATH)/,,_$1)
# endif
# 
# # Normalize the ROOT_PATH relative to the CWD_PATH taking care of
# # the special case when they are equal
# #
# ifeq ($(ABS_CWD_PATH),$(ABS_ROOT_PATH))
#   ROOT_PATH := .
# else
#   ROOT_PATH :=  $(call make_cwd_relative_path,$(ABS_ROOT_PATH))
# endif
# 
# $(call log_info,adjusted ROOT_PATH is $(ROOT_PATH))
# 
# # Normalize the SRC_PATH relative to the CWD_PATH taking care of
# # the special case when they are equal
# #
# ifeq ($(ABS_CWD_PATH),$(ABS_SRC_PATH))
#   SRC_PATH := .
# else
#   SRC_PATH :=  $(call make_cwd_relative_path,$(ABS_SRC_PATH))
# endif
# 
# $(call log_info,adjusted SRC_PATH is $(SRC_PATH))
# 

$(call log_info,-----------------------------------)

### 
### COMPLEX_PATH := ./foo/././../foo///bar
### 
### $(call log_info,COMPLEX_PATH is $(COMPLEX_PATH))
### 
### ABS_COMPLEX_PATH := $(abspath $(COMPLEX_PATH))
### 
### $(call log_info,ABS_COMPLEX_PATH is $(ABS_COMPLEX_PATH))
### 
### make_root_relative_path = $(subst _$(ABS_ROOT_PATH),,_$1)
### 
### SIMPLIFIED_PATH := $(call make_cwd_relative_path,$(ABS_COMPLEX_PATH))
### $(call log_info,simplified cwd relative path is $(SIMPLIFIED_PATH))
### 
### SIMPLIFIED_PATH := $(call make_root_relative_path,$(ABS_COMPLEX_PATH))
### $(call log_info,simplified root relative path is $(SIMPLIFIED_PATH))
### 
### 
### # The library builder 
### # For TARGET_STEM and PREREQ_STEM to be useful as patterns in rules, they
### # must follow a couple of simple rules:
### #
### # 1. They must NEVER be blank because the resulting path would be relative
### #    to the root of the file system.
### # 2. They must 
### 
### $(call log_info,-----------------------------------)
### $(call log_info,CWD_PATH is $(abspath .))
### $(call log_info,complex relative path is $(abspath ./foo/././../foo///bar/fibblesnork.c))
### 
### $(call log_info,simplified relative path is $(subst _$(abspath .),,_$(abspath ./foo/././../foo///bar)))
### 
### $(call log_info,MAKEFILE_LIST is $(MAKEFILE_LIST))
### 
### $(call log_info,this makefile is $(lastword $(MAKEFILE_LIST)))
### 
$(call log_info,-----------------------------------)


### $(call log_info,ROOT_PATH is $(ROOT_PATH))
### $(call log_info,ADAPTABUILD_PATH is $(ADAPTABUILD_PATH))
### $(call log_info,SRC_PATH is $(SRC_PATH))
### 
### 
### # We use substitution using the wildcard (%) pattern to simplifying the
### # generated file and path names. Unfortunately the pattern matching
### # breaks down under some conditions, so we need to normalize the
### # path names as much as possible.
### #
### ABS_PATH := $(patsubst %/,%,$(realpath ./$(ROOT_PATH)))
### ABS_ROOT_PATH := $(abspath $(ROOT_PATH))
### ABS_SRC_PATH := $(abspath $(SRC_PATH))
### 
### $(call log_info,ABS_PATH is $(ABS_PATH))
### $(call log_info,absolute ROOT_PATH is $(abspath $(ABS_ROOT_PATH)))
### $(call log_info,absolute SRC_PATH is $(abspath $(ABS_SRC_PATH)))
### 
### ifeq ($(ABS_ROOT_PATH),$(ABS_SRC_PATH))
###   SRC_PATH := .
### else
###   SRC_PATH := $(subst $(ABS_ROOT_PATH)/,,$(ABS_SRC_PATH))
### endif
### 
### 
### # ROOT_RELATIVE_SRC_PATH := $(subst $(ABS_ROOT_PATH)/,,$(ABS_SRC_PATH))
### # 
### # $(call log_info,root relative SRC_PATH is $(ROOT_RELATIVE_SRC_PATH))
### # 
### # # If the ROOT_RELATIVE_SRC_PATH is blank, set SRC_PATH to .
### # #
### # ifeq (,$(ROOT_RELATIVE_SRC_PATH))
### #   SRC_PATH := .
### # else
### #   SRC_PATH := ./$(ROOT_RELATIVE_SRC_PATH)
### # endif
### # 
### # #SRC_PATH := $(ROOT_RELATIVE_SRC_PATH)
###   
### $(call log_info,SRC_PATH is $(SRC_PATH))


# The $(make_current_module_path module) is used to create the $(MODULE_PATH) variable
# that has local file scope. From there the 
# Note the use of = (not :=) to defer evaluation until it is called
#
# Note also that for this conditional to work, $(ROOT_PATH) must be defined before
# the conditional is evaluated
#

#ifeq (,$(SRC_PATH))
#  make_current_module_path = $(patsubst $(SRC_PATH)/%/,%,$(ROOT_PATH)/$(dir $(lastword $(MAKEFILE_LIST))))
#else
#ifeq (./.,$(SRC_PATH))
#  make_current_module_path = $(patsubst $(SRC_PATH)/%/,%,$(ROOT_PATH)/$(dir $(lastword $(MAKEFILE_LIST))))

# ifeq ($(SRC_PATH),$(ROOT_PATH))
#   make_current_module_path = .
# #else ifeq (.,$(ROOT_PATH))
# #  make_current_module_path = $(patsubst $(SRC_PATH)/%/,%,$(ROOT_PATH)/$(dir $(lastword $(MAKEFILE_LIST))))
# else
#   make_current_module_path = $(patsubst $(SRC_PATH)/%,%,$(dir $(lastword $(MAKEFILE_LIST))))
# endif

#make_current_module_path = $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

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
# SRC_PATH   := $(ROOT_PATH)/src
# $(call log_info,SRC_PATH is $(SRC_PATH))

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

# Create BUILD_PATH, taking care of the special case when ROOT_PATH is
# empty if we are running from the project root already.

# BUILD_PATH := $(or $(ROOT_PATH),.)/build/$(PRODUCT)/$(MCU)
BUILD_PATH := $(ROOT_PATH)/build/$(PRODUCT)/$(MCU)

$(call log_info,BUILD_PATH is $(BUILD_PATH))

ABS_BUILD_PATH := $(abspath $(BUILD_PATH))

$(call log_info,ABS_BUILD_PATH is $(ABS_BUILD_PATH))

# Normalize the BUILD_PATH relative to the CWD_PATH taking care of
# the special case when they are equal
#
BUILD_PATH := $(call make_cwd_relative_path,$(ABS_BUILD_PATH))

$(call log_info,adjusted BUILD_PATH is $(BUILD_PATH))

# Now do the same for artifacts path

ARTIFACTS_PATH := $(ROOT_PATH)/artifacts/$(PRODUCT)/$(MCU)
ABS_ARTIFACTS_PATH := $(abspath $(ARTIFACTS_PATH))
ARTIFACTS_PATH := $(call make_cwd_relative_path,$(ABS_ARTIFACTS_PATH))

$(call log_info,ARTIFACTS_PATH is $(ARTIFACTS_PATH))

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

all: foo bar bootloader executable baz bif

foo:
    $(call log_notice,adaptabuild foo)

bar:
    $(call log_notice,adaptabuild bar)

product: $(BUILD_PATH)/$(PRODUCT)/$(PRODUCT)

baz:
    $(call log_notice,adaptabuild baz)

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
-include $(SRC_PATH)/$(PRODUCT)/adaptabuild_module.mak

$(call log_notice,TESTABLE_MODULES is $(TESTABLE_MODULES))

# $(BUILD_PATH)/$(PRODUCT)/$(PRODUCT): LDFLAGS += -T$(LDSCRIPT)
# $(BUILD_PATH)/$(PRODUCT)/$(PRODUCT): $(MODULE_LIBS) $(LDSCRIPT)

#  $(call log_notice,adaptabuild bootloader)

ifeq ($(BOOT_LINKER_SCRIPT),)
    bootloader :
else
    bootloader : $(BUILD_PATH)/$(PRODUCT)/$(PRODUCT).boot
endif

#    $(call log_notice,adaptabuild bootloader)

BOOT_LDSCRIPT := $(SRC_PATH)/$(PRODUCT)/config/$(MCU)/$(BOOT_LINKER_SCRIPT)

$(BUILD_PATH)/$(PRODUCT)/$(PRODUCT).boot: LDFLAGS += -T $(BOOT_LDSCRIPT)
$(BUILD_PATH)/$(PRODUCT)/$(PRODUCT).boot: LDGROUP  =
$(BUILD_PATH)/$(PRODUCT)/$(PRODUCT).boot: $(MODULE_LIBS) $(BOOT_LDSCRIPT)
	$(LD) -g -o $@  $(SYSTEM_BOOT_OBJ) \
              $(LDGROUP) $(LDFLAGS) $(LDMAP) --cref

# ----------------------------------------------------------------------------
# Default target for now:
#
# LDSCRIPT should be named based on the project and target cpu
#
# Simplify to path to the product source and product_main and executable
executable : $(BUILD_PATH)/$(PRODUCT)/$(PRODUCT)
    $(call log_notice,adaptabuild executable)

LDSCRIPT := $(SRC_PATH)/$(PRODUCT)/config/$(MCU)/$(MCU_LINKER_SCRIPT)

# TODO: Separate the linker options between host and embedded builds.
#       Host builds use g++ which does not support --start-group
#       Embedded builds need --start-group

$(BUILD_PATH)/$(PRODUCT)/$(PRODUCT): LDFLAGS += -T$(LDSCRIPT)
$(BUILD_PATH)/$(PRODUCT)/$(PRODUCT): $(MODULE_LIBS) $(LDSCRIPT)
	$(LD) -g -o $@.elf $(SYSTEM_STARTUP_OBJ) < \
          $(BUILD_PATH)/$(PRODUCT_MAIN).o $(WEAK_OVERRIDES) \
          $(LDGROUP) $(LDFLAGS) $(LDMAP) --cref
	$(OBJCOPY) -O ihex $@.elf $@.hex
	$(OBJCOPY) -O binary $@.elf $@.bin

unittest : $(TESTABLE_MODULES)
	@echo Testable Modules $(TESTABLE_MODULES)

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
