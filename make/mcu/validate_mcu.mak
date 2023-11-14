# ----------------------------------------------------------------------------
# validate_mcu.mak - master list of MCU variants and families supported
#
# When building a firmware image, the developer MUST specify the exact
# variant of the MCU that is being targeted. This file checks all of the
# known MCU variants and if one is found:
#
# - Sets MCU_FAMILY choose a vendor specific library
# - Imports a toolchain/xyz.mak file that sets up toolchain variables
# - Potentially sets link time variables for FLASH/RAM size, etc
#
# There should be one section for each MCU supplier, with subsections
# for each MCU family from that vendor.
# ----------------------------------------------------------------------------

ifndef MCU
  $(error you need to at least specify the MCU variable!)
endif

# ----------------------------------------------------------------------------
# Off-target unit testing
# ----------------------------------------------------------------------------

ifeq (unittest,$(MAKECMDGOALS))
    $(info We are making unittests!)
	override MCU := unittest

    include $(ADAPTABUILD_PATH)/make/toolchain/x86_64.mak

    MAKEFILE_DIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
    CPPUTEST_HOME=/usr/include/CppUTest
endif

include $(ADAPTABUILD_PATH)/make/mcu/validate_stm32f0_mcu.mak
include $(ADAPTABUILD_PATH)/make/mcu/validate_stm32h7_mcu.mak

ifeq ($(MCU_ARCH),)
    $(error MCU_ARCH is undefined! Was MCU specified correctly?)
endif
