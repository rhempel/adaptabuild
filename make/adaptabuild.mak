# ----------------------------------------------------------------------------
# adaptabuild.mak - top level adaptabuild compatible makefile for a project
#
# Invoke the build system with:
#
# make -f path/to/adaptabuild.mak
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
$(info SRC_PATH is $(SRC_PATH))

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
$(info MCU_MAK is $(MCU_MAK))

# ----------------------------------------------------------------------------
# Do NOT move this include - it MUST be after the definition of MCU_MAK
#                                  and before the definition of BUILD_PATH
include $(ROOT_PATH)/adaptabuild_product.mak

BUILD_PATH := $(ROOT_PATH)/build/$(PRODUCT)/$(MCU)
$(info BUILD_PATH is $(BUILD_PATH))

ARTIFACTS_PATH := $(ROOT_PATH)/artifacts/$(PRODUCT)/$(MCU)
$(info ARTIFACTS_PATH is $(ARTIFACTS_PATH))

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

all: foo bar baz bif

foo:
    $(info foo)

bar:
    $(info bar)

baz:
    $(info baz)

bif: $(BUILD_PATH)/product/$(PRODUCT)/$(PRODUCT)

# ----------------------------------------------------------------------------
# Do NOT move this include - it MUST be after the definition of BUILD_PATH
#                            and before anythiong that depends on MODULE_LIBS
include $(ROOT_PATH)/adaptabuild_artifacts.mak

# ----------------------------------------------------------------------------
# Do NOT move this include - it cannot be before any target definitions
#
include $(MCU_MAK)

include $(SRC_PATH)/product/$(PRODUCT)/adaptabuild.mak

# ----------------------------------------------------------------------------
# Default target for now:
#
# LDSCRIPT should be named based on the project and target cpu
#
# Simplify to path to the product source and product_main and executable

LDSCRIPT = $(SRC_PATH)/product/$(PRODUCT)/config/$(MCU)/linker_script.ld

$(BUILD_PATH)/product/$(PRODUCT)/$(PRODUCT): LDFLAGS +=  -T$(LDSCRIPT)
$(BUILD_PATH)/product/$(PRODUCT)/$(PRODUCT): $(MODULE_LIBS) $(LDSCRIPT)
	$(LD) -o $@ $(SYSTEM_STARTUP_OBJ) < \
	            $(BUILD_PATH)/product/$(PRODUCT)/src/$(PRODUCT)_main.o \
              --start-group $(MODULE_LIBS) --end-group $(LDFLAGS) \
              -Map=$@.map

# SYSTEM_MAIN_OBJ := $(ROOT_PATH)/$(BUILD_PATH)/$(MODULE_PATH)/main.o

# ----------------------------------------------------------------------------
# Set up for unit testing of a specific module

$(info TEST_MODULE is $(TEST_MODULE))
$(info TESTABLE_MODULES is $(TESTABLE_MODULES))

ifeq (unittest,$(MAKECMDGOALS))
    ifneq ($(filter $(TEST_MODULE),$(TESTABLE_MODULES)),)
    else
      $(error TEST_MODULE must be one of $(TESTABLE_MODULES))
    endif
endif

# LD_LIBRARIES := -Wl,-whole-archive build/foo/unittest/umm_malloc/umm_malloc.a
# LD_LIBRARIES += -Wl,-no-whole-archive -lstdc++ -lCppUTest -lCppUTestExt -lgcov

#$(MODULE_TEST_LIBS)

# Find a way to change to a directory and make all subsequent calls
# relative to that location

$(info BUILD_PATH/TEST_MODULE is $(BUILD_PATH)/$(TEST_MODULE))

TEST_MODULE_LIB := $(BUILD_PATH)/$(TEST_MODULE)/$(TEST_MODULE).a

$(info TEST_MODULE_LIB is $(TEST_MODULE_LIB))

unittest: $(BUILD_PATH)/$(TEST_MODULE)/$(TEST_MODULE)_unittest $(TEST_MODULE_LIB) artifacts_foo

# TODO: Consider moving some of the library requirements to the module level test defines

# $(BUILD_PATH)/$(TEST_MODULE)/unittest: $(MODULE_LIBS)  -lstdc++ -lgcov --copy-dt-needed-entries
$(BUILD_PATH)/$(TEST_MODULE)/$(TEST_MODULE)_unittest:
$(BUILD_PATH)/$(TEST_MODULE)/$(TEST_MODULE)_unittest: LDFLAGS := $(TEST_MODULE_LIB) $(LDFLAGS) -lCppUTest -lCppUTestExt -lm -lgcov
$(BUILD_PATH)/$(TEST_MODULE)/$(TEST_MODULE)_unittest: $(TEST_MODULE_LIB)
	$(LD) -o $@ \
         $(LDFLAGS)

# NOTE: the BUILD_PATH now has the ROOT_PATH built-in - so be careful how we update
#       using the ABS_PATH!

artifacts_foo:
  # Create the artifacts folder
	mkdir -p $(ARTIFACTS_PATH)/$(TEST_MODULE)

  # Create a baseline for code coverage
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE) && \
    lcov -z -d --rc lcov_branch_coverage=1 $(ABS_PATH)/$(BUILD_PATH)/$(TEST_MODULE)/src

  # Run the test suite
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE) && \
    $(ABS_PATH)/$(BUILD_PATH)/$(TEST_MODULE)/$(TEST_MODULE)_unittest -k $(TEST_MODULE) -ojunit

  # Create the test report
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE) && \
    junit2html --merge $(TEST_MODULE).xml *.xml && \
	  junit2html $(TEST_MODULE).xml $(TEST_MODULE).html && \
	  rm $(TEST_MODULE).xml

  # Update the incremental code coverage
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE) && \
    lcov -c -d --rc lcov_branch_coverage=1 $(ABS_PATH)/$(BUILD_PATH)/$(TEST_MODULE)/src -o $(TEST_MODULE).info

  # Create the code coverage report
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE) && \
    genhtml --rc genhtml_branch_coverage=1 *.info


# $(BUILD_PATH)/umm_malloc/unittest/umm_malloc_test
#	mkdir -p artifacts/umm_malloc
#    # Create a baseline for code coverage
#	- cd artifacts/umm_malloc && \
#      lcov -z -d ../../$(BUILD_PATH)/umm_malloc/src
#    # Run the test suite
#	- cd artifacts/umm_malloc && \
#	  ../../$(BUILD_PATH)/umm_malloc/unittest/umm_malloc_test -k umm_malloc -ojunit
#    # Create the test report
#	- cd artifacts/umm_malloc && \
#	  junit2html --merge cpputest_umm_malloc.xml *.xml && \
#	  junit2html cpputest_umm_malloc.xml umm_malloc.html && \
#	  rm cpputest_umm_malloc.xml

#    # Update the incremental code coverage
#	- cd artifacts/umm_malloc && \
#      lcov -c -d ../../$(BUILD_PATH)/umm_malloc/src -o umm_malloc.info
#    # Create the code coverage report
#	- cd artifacts/umm_malloc && \
#      genhtml *.info

# $(BUILD_PATH)/umm_malloc/unittest/umm_malloc_test: $(MODULE_LIBS)
#	@echo Building $@ from $<
#	$(LD) -o $@ $(LD_LIBRARIES)

#./umm_malloc_test -ojunit
#junit2html cpputest_FirstTestGroup.xml
#gcov -j main test
#lcov -c -i -d . -o main.info
#lcov -c  -d . -o main_test.info
#lcov -a main.info -a main_test.info -o total.info
#genhtml *.info

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
