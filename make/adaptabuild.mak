# ----------------------------------------------------------------------------
# adaptabuild.mak - top level adaptabuild system include
#
# AVOID CHANGING THIS FILE - Any build customizations needed for your
#                            modules or product should be in the
#                            adaptabuild_product.mak file
#
# The goal of adaptabuild is to hide most of the makefile complexity from
# developers that don't want to learn the insides of yet another way to
# build their project.
#
# This file may change over time as we continue to develop adaptabuild
# ----------------------------------------------------------------------------

MKPATH := mkdir -p
PYTHON := python3

# ----------------------------------------------------------------------------
# NOTE: Create a way for all to be defined here so that it is the default
#       target, but make it a dependency further down so that the real
#       definition is later
#
# NOTE: We can add project or product specific overrides for any of these
#       steps
#
.SUFFIXES :

.NOTPARALLEL: # ensures that all deps are executed strictly in order

.PHONY : all foo bar bootloader pre_executable executable product baz bif clean

all: foo bar bootloader pre_executable executable product baz bif

# The default all: target can have multiple dependencies, and they are ALWAYS
# evaluated left to right. This allows you to configure a pipeline of
# tasks for your project.
#
# TODO: Expand on these dummy routines and add pre and post build steps for
#       things like unit testing, adding CRC or checksum, combining images
#       or even loading an image onto a real target.
#
# These targets may be expanded at any time by another rule - it's one
# really useful application of the double-colon rule feature in GNU make.
#

foo::
	$(call log_warning,adaptabuild foo)

bar::
	$(call log_warning,adaptabuild bar)

pre_executable::
	$(call log_warning,adaptabuild pre_executable)

baz::
	$(call log_warning,adaptabuild baz)

bif::
	$(call log_warning,adaptabuild bif)

# NOTE: THIS SHOULD BE EXTRACTED BY SPHINX/HAWKMOTH TO BE AUTOMATICALLY
#       ADDED TO THE ADAPTABUILD DOCUMENTATION!
#
#       see: https://www.sphinx-doc.org/en/master/usage/restructuredtext/directives.html#directive-literalinclude
#
# The adaptabuild system lets you run make for your project from anywhere
# in the file system. That might not seem like a big deal but it can really
# simplify your CI pipeline command structure. This means that:
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
# The make program has built-in functions to handle path manipulations, and
# we wil take advantage of them together with the text manipulation functions
# to generate clean path and filenames.
#
# We will use the following path to illustrate the three possibilities
# for pathnames that need to be handled in adaptabuild
#
# /home/you/path/to/project                             - "root" of the project to be build
# /home/you/path/to/project/adaptabuild                 - submodule containing the adaptabuild system
# /home/you/path/to/project/adaptabuild_root.mak        - top level adaptabuild makefile
# /home/you/path/to/project/$(BUILD_PATH)               * location of ALL generated output
# /home/you/path/to/project/$(SRC_PATH)                 * location of ALL source code
# /home/you/path/to/project/$(SRC_PATH)/foo             - location of product "foo" source code
# /home/you/path/to/project/$(SRC_PATH)/third-party/bar - location of third party module "baz" source code
#
# The first thing adaptabuild does is create the ROOT_PATH variable. This is
# defined as the path from where you are running make to the adaptabuild_config.mak
# file. Assuming your project is located at:
#
# /home/you/path/to/project
#
# There are three possibilities:
#
# 1. Run from /home/you/path/to/project -> ROOT_PATH = .
# 2. Run from /home/you                 -> ROOT_PATH = path/to/project/
# 3. Run from /                         -> ROOT_PATH = /home/you/path/to/project/
#
# Adaptabuild will trim any leading or trailing "/" characters to get a path that
# we can use in a make variable that can be used to build new paths.
#
# For example, the BUILD_PATH is where we put all of the intermediate
# object, dependency, and library files that go into building the final
# product binary. Having a BUILD_PATH allows us to separate these
# intermediate files from the source code so that it's easier to set up
# the `.gitignore` file.
#
# BUILD_PATH should never be the same as ROOT_PATH, and it should
# be a separate path that will be created by adaptabuild. for example:
#
# BUILD_PATH := $(ROOT_PATH)/path/to/build
#
# Similarly, we can define the SRC_PATH like this, but unlike BUILD_PATH
# is is allowable for SRC_PATH to be the same as ROOT_PATH.
#
# SRC_PATH := $(ROOT_PATH)/path/to/src
#
# SRC_PATH may be the same as ROOT_PATH if we are building a module for
# an automated unit test independent of a project, and the source for
# that project lives at the ROOT_PATH. The following forms are all
# equivalent:
#
# SRC_PATH := $(ROOT_PATH)
# SRC_PATH := $(ROOT_PATH)/
# SRC_PATH := $(ROOT_PATH)/.
#
# Finally, each of the modules or products in a project will have a path
# that is relative to the SRC_PATH. This is very important because it
# allows us to create module level source and include file lists that
# are _independent_ of where the module lives in your project's SRC_PATH. 
#
# One of the key design goals of the adaptabuild system is that the make
# runs from one directory - your current directory, and it can be anywhere
# in the filesystem.
#
# That means your module level makefiles don't care where they are
# located as long as they are below SRC_PATH - adaptabuild figures out
# all the paths to your source and build files.
#
# Rather than continuously applying macros to clean up the paths in
# multiple locations, we can take advantage of make's stem rules to
# simplify our dependency patterns.
#
# TARGET_STEM := $(BUILD_PATH)/$(MODULE_PATH)
# PREREQ_STEM := $(SRC_PATH)/$(MODULE_PATH)
#
# The stems are used in rules like this:
#
# $(TARGET_STEM)/%.o: $(PREREQ_STEM)/%.c
#
# We want the longest possible stems so that we can tell the difference
# between a filename that is common to two modules. For example, if there
# is a file called `util.c` in module_A and module_B, the stem rules
# for each of the modules look like this:
# 
# $(BUILD_PATH)/module_A/util.c
# $(BUILD_PATH)/module_B/util.c
#
# The % in the stem rules is just "util" and the stems are long enough that
# adaptabuild will automatically apply the correct module specific compiler
# definitions or flags that you set up.
#
# We will discuss how "module namespaces" are creates to ensure that each
# module has its own set of overrides for the build process.
#
# How does the $(MODULE_PATH) get set? The key is in the
# `adaptabuild_module.mak` file that is at the root of your module. Here
# is an example `adaptabuild_module.mak` for a module called `motor`:
#
# MODULE := motor
#
# MODULE_PATH := $(call make_current_module_path)
#
# $(MODULE)_PATH := $(MODULE_PATH)
#
# Just like ROOT_PATH and SRC_PATH, the MODULE_PATH can evaluate to "."
# under some conditions. The significance of this will become clear
# shortly.
#
# Your module specification doesn't need to worry about any external make
# variables, because the adapatabuild/make/library.mak file transforms
# your file list into something the stem rules can use. THe simplified
# transformation looks like this:
#
# motor_SRC := core/speed.c main.c
#
# Now it's time to transform the source file list to an object file list
# for the stem rules. The simplified transformation is something like this:
#
# $(MODULE)_OBJ := $(subst .c,.o,$($(MODULE)_SRC)))
#
# Which _should_ result in:
#
# motor_OBJ := core/speed.o main.o
#
# Now we can do a simple string substitution and use the stems once:
#
# $(MODULE)_SRC := $(addprefix $(PREREQ_STEM)/,$($(MODULE)_SRC))
# $(MODULE)_OBJ := $(addprefix $(TARGET_STEM)/,$($(MODULE)_OBJ))
#
# The adaptabuild system generates the correct procedure for building
# the motor module objects and library.

$(call log_info,ROOT_PATH is $(ROOT_PATH))

ABS_CWD_PATH := $(abspath .)
ABS_ROOT_PATH := $(abspath $(ROOT_PATH))
ABS_SRC_PATH := $(abspath $(SRC_PATH))

$(call log_info,ABS_CWD_PATH is $(ABS_CWD_PATH))
$(call log_info,ABS_ROOT_PATH is $(ABS_ROOT_PATH))
$(call log_info,ABS_SRC_PATH is $(ABS_SRC_PATH))

make_cwd_relative_path = $(or $(patsubst /%,%,$(patsubst $(ABS_CWD_PATH)%,%,$(1))),.)
make_src_relative_path = $(or $(patsubst /%,%,$(patsubst $(ABS_SRC_PATH)%,%,$(1))),.)

make_cwd_relative_files = $(patsubst /%,%,$(patsubst $(ABS_CWD_PATH)%,%,$(1)))
make_src_relative_files = $(patsubst /%,%,$(patsubst $(ABS_SRC_PATH)%,%,$(1)))

# This macro deserves some explaining ... the current module path can never
# be an empty string, otherwise it messes up the pattern matching on the stem
# rules.
#
# The make macros are easier to read if you start from the rightmost
# function(s) because that's how results are propagated in make functions.
#
# 1. $(abspath $(dir $(lastword $(MAKEFILE_LIST)))) creates the absolute
#    path to the `adaptabuild_module.mak` for the current module.
#
# 2. $(patsubst $(ABS_SRC_PATH)%,%,\ strips off the absolute source path
#    from the absolute module path resulting in the path of the module
#    relative to the source directory
#
# 3. $(patsubst /%,%,\ strips off the leading / characters if it exists
#
# 4. $(patsubst %/,%,\ strips off the trailing / characters if it exists
#
# 5. $(or (result of 1-4),.) ensures that for the corner case when the
#    module path is the same as the source path, that the module path
#    is at least '.' which is the current directory. This is normally
#    how the top level module of a product is created.
# 
make_current_module_path = $(or $(patsubst %/,%,\
                                  $(patsubst /%,%,\
                                    $(patsubst $(ABS_SRC_PATH)%,%,\
                                      $(abspath $(dir $(lastword $(MAKEFILE_LIST))))))),\
                                .)

# Now that we have the MODULE_PATH normalized, we can do the same for the
# ROOT_PATH and SRC_PATH, because they are used to build the TARGET_STEM
# and PREREQ_STEM.
#
# Here we modify the existing values to make them relative to the
# directory we are in when running make.
#
ROOT_PATH := $(call make_cwd_relative_path,$(ABS_ROOT_PATH))
SRC_PATH := $(call make_cwd_relative_path,$(ABS_SRC_PATH))

$(call log_info,adjusted ROOT_PATH is $(ROOT_PATH))
$(call log_info,adjusted SRC_PATH is $(SRC_PATH))

$(call log_info,-----------------------------------)

# ----------------------------------------------------------------------------
# The are GLOBAL variables that may be updated by included makefiles
#
# We define them to be empty strings here so that it's clear that they are
# needed.
#
# Note, there is a mechanism for module-level variables as well.
#
CDEFS :=
CFLAGS :=
LDFLAGS :=
DEPFLAGS :=

MODULE_LIBS :=

TESTABLE_MODULES :=

# ----------------------------------------------------------------------------
# Do NOT move this include - it MUST be after the definition of SRC_PATH
#                            and before the including adaptabuild_product.mak
#
# The following variables are defined within validate_mcu.mak. They will be
# specific to each MCU family (and possibly variant)
#
# MCU_MAK     - a list of adaptabuild files to build the MCU support modules
# MCU_INCPATH - a list of include paths for the MCU support libraries
# MCU_CDEFS   - a list of defines that will be passed to the compiler
#
MCU_MAK :=
MCU_INCPATH :=
MCU_CDEFS :=

include $(ADAPTABUILD_PATH)/make/mcu/validate_mcu.mak
$(call log_info,MCU_MAK is $(MCU_MAK))

# ----------------------------------------------------------------------------
# Do NOT move this include - it MUST be after the definition of MCU_MAK
#                                  and before the definition of BUILD_PATH
#
# The `adaptabuild_product.mak` file validates PRODUCT commandline argument
#
include $(ROOT_PATH)/adaptabuild_product.mak
$(call log_info,PRODUCT is $(PRODUCT))

# Now that we know the ROOT_PATH, PRODUCT and MCU, we can create the fullly
# qualified BUILD_PATH for this combination. By convention, we use `build`
# as the pathname but it could be any thing as long as there is no loss
# of source code if the file is deleted.
#
# By specifying the BUILD_PATH in terms of the PRODUCT and MCU, we are
# able to build the same source for multiple products or targets without
# mixing up the resulting object files.
#
BUILD_PATH := $(ROOT_PATH)/build/$(PRODUCT)/$(MCU)
$(call log_info,BUILD_PATH is $(BUILD_PATH))

ABS_BUILD_PATH := $(abspath $(BUILD_PATH))
$(call log_info,ABS_BUILD_PATH is $(ABS_BUILD_PATH))

BUILD_PATH := $(call make_cwd_relative_path,$(ABS_BUILD_PATH))
$(call log_info,adjusted BUILD_PATH is $(BUILD_PATH))

# Now do the same for the ARTIFACTS_PATH

ARTIFACTS_PATH := $(ROOT_PATH)/artifacts/$(PRODUCT)/$(MCU)
$(call log_info,ARTIFACTS_PATH is $(ARTIFACTS_PATH))

ABS_ARTIFACTS_PATH := $(abspath $(ARTIFACTS_PATH))
$(call log_info,ABS_ARTIFACTS_PATH is $(ABS_ARTIFACTS_PATH))

ARTIFACTS_PATH := $(call make_cwd_relative_path,$(ABS_ARTIFACTS_PATH))
$(call log_info,ARTIFACTS_PATH is $(ARTIFACTS_PATH))


# ----------------------------------------------------------------------------
# Do NOT move this include - it MUST be before the definition of any target
#                            artifacts or the top level module so that any
#                            low level MCU specific definitions are in place
#
# This includes the list of files generated by validate_mcu.mak
#
include $(MCU_MAK)

# ----------------------------------------------------------------------------
# Do NOT move this include - it MUST be after the definition of BUILD_PATH
#                            and after the MCU specific artifacts so that
#                            any MCU definitions are in place
#
# This will include the modules needed to build the top level PRODUCT libs
# for a specific project
#
include $(ROOT_PATH)/adaptabuild_artifacts.mak

# Not sure if this is needed - do we need a rule about how to name a module?
# or if a product should have at least a dummy file - normally we have main.c
# in the product folder
#
-include $(SRC_PATH)/$(PRODUCT)/adaptabuild_module.mak

# Inform the user about all of the modules that have unit tests available
#
$(call log_notice,TESTABLE_MODULES is $(TESTABLE_MODULES))

# ----------------------------------------------------------------------------
# Rules for building a bootloader (if needed)
#
# NOTE: Improve the method of detecting if a bootloader is needed by
# adding a top_level define in the ?adaptabuild_product.mak? file
#
# NOTE: Consider something other than WEAK_OVERRIDES - maybe ADDITIONAL_OBJECTS
#
# NOTE: This bootloader generation is specifically for RP2040. Consider
#       making the boodloader post processing specific to a product of
#       MCU?
#
ifeq ($(BOOT_LINKER_SCRIPT),)
    bootloader :
else
    bootloader : $(BUILD_PATH)/$(PRODUCT)/$(PRODUCT).boot
    WEAK_OVERRIDES += $(BUILD_PATH)/$(PRODUCT)/$(PRODUCT).boot.padded_checksummed.o
endif

BOOT_LDSCRIPT := $(SRC_PATH)/$(PRODUCT)/config/$(MCU)/$(BOOT_LINKER_SCRIPT)

$(BUILD_PATH)/$(PRODUCT)/$(PRODUCT).boot: LDFLAGS += -T $(BOOT_LDSCRIPT)
$(BUILD_PATH)/$(PRODUCT)/$(PRODUCT).boot: LDGROUP =
$(BUILD_PATH)/$(PRODUCT)/$(PRODUCT).boot: $(MODULE_LIBS) $(BOOT_LDSCRIPT)
	$(LD) -g -o $@.elf  $(SYSTEM_BOOT_OBJ) \
              $(LDGROUP) $(LDFLAGS) $(LDMAP) --cref
	$(OBJCOPY) -O binary $@.elf $@.bin
	$(PYTHON) $(SRC_PATH)/$(pico-sdk_PATH)/src/rp2_common/boot_stage2/pad_checksum \
              -s 0xffffffff \
              $@.bin $@.padded_checksummed.s
	$(CC) -c $(CFLAGS) $(DEPFLAGS) $(COVFLAGS) -o $@.padded_checksummed.o $@.padded_checksummed.s

# ----------------------------------------------------------------------------
# Default target for now:
#
# LDSCRIPT should be named based on the project and target cpu
#
# Simplify to path to the product source and product_main and executable
#
executable : $(BUILD_PATH)/$(PRODUCT)/$(PRODUCT)
	$(call log_warning,adaptabuild executable)

ifneq ($(strip $(LDSCRIPT_PATH) $(CUSTOM_LINKER_SCRIPT_PATH)),)
  LDSCRIPT_PATH := $(addprefix -L ,$(LDSCRIPT_PATH) $(CUSTOM_LINKER_SCRIPT_PATH))
endif

ifneq ($(strip $(CUSTOM_LINKER_SCRIPT)),)
  LDSCRIPT := $(CUSTOM_LINKER_SCRIPT_PATH)/$(CUSTOM_LINKER_SCRIPT)
else
  LDSCRIPT := $(SRC_PATH)/$(PRODUCT)/config/$(MCU)/$(MCU_LINKER_SCRIPT)
endif

# TODO: Separate the linker options between host and embedded builds.
#       Host builds use g++ which does not support --start-group
#       Embedded builds need --start-group

# THIS OBJECT IS ONLY NEEDED FOR rp2040 targets - add it as an additional
# MCU specific prerequisite that is a general bootloader object for builds
# that will include a bootloader

#          $(BUILD_PATH)/$(PRODUCT)/$(PRODUCT).boot.padded_checksummed.o \

$(BUILD_PATH)/$(PRODUCT)/$(PRODUCT): LDFLAGS += $(LDSCRIPT_PATH) -T$(LDSCRIPT) --gc-sections
$(BUILD_PATH)/$(PRODUCT)/$(PRODUCT): $(MODULE_LIBS) $(LDSCRIPT)
	$(LD) -g -o $@.elf $(SYSTEM_STARTUP_OBJ) < \
          $(BUILD_PATH)/$(PRODUCT_MAIN).o \
          $(WEAK_OVERRIDES) \
          $(LDGROUP) $(LDFLAGS) $(LDMAP) --cref
	$(OBJCOPY) -O ihex $@.elf $@.hex
	$(OBJCOPY) -O binary $@.elf $@.bin

unittest : $(TESTABLE_MODULES)
	@echo Testable Modules $(TESTABLE_MODULES)

# ----------------------------------------------------------------------------
# .PHONY targets that provide some eye candy for the make log
# ----------------------------------------------------------------------------


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
