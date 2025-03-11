# ----------------------------------------------------------------------------
# validate_mcu.mak - master list of MCU variants and families supported
#
# When building a firmware image, the developer MUST specify the exact
# variant of the MCU that is beign targeted. This file checks all of the
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
#   $(info We are making unittests!)
	override MCU := unittest

    include $(ADAPTABUILD_PATH)/make/toolchain/x86_64.mak

    MAKEFILE_DIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
    CPPUTEST_HOME=/usr/include/CppUTest
endif

# ----------------------------------------------------------------------------
# STM32F051 Variants
# ----------------------------------------------------------------------------

MCU_LIST := STM32F051C4 STM32F051C6 STM32F051C8
MCU_LIST += STM32F051K4 STM32F051K6 STM32F051K8
MCU_LIST += STM32F051R4 STM32F051R6 STM32F051R8
MCU_LIST +=                         STM32F051T8

ifneq ($(filter $(MCU),$(MCU_LIST)),)
    MCU_FAMILY := STM32F051xx
    MCU_VARIANT := STM32F051x8
    MCU_ARCH := cortex-m0

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

	MCU_MAK += $(SRC_PATH)/stm32f0xx_hal_driver/adaptabuild.mak
	MCU_MAK += $(SRC_PATH)/cmsis_device_f0/adaptabuild.mak
endif

# ----------------------------------------------------------------------------
# STM32L452 Variants
# ----------------------------------------------------------------------------

MCU_LIST := STM32L452CC STM32L452CE
MCU_LIST += STM32L452RC STM32L452RE
MCU_LIST += STM32L452VC STM32L452VE

ifneq ($(filter $(MCU),$(MCU_LIST)),)
    MCU_FAMILY := STM32L452xx

    $(error Need to define MCU_VARIANT and MCU_ARCH)
	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

	MCU_MAK += $(SRC_PATH)/stm32f0xx_hal_driver/adaptabuild.mak
	MCU_MAK += $(SRC_PATH)/cmsis_device_f0/adaptabuild.mak
endif

# ----------------------------------------------------------------------------
# STM32H7 Variants
# ----------------------------------------------------------------------------

MCU_LIST := STM32H7B3
MCU_LIST +=

ifneq ($(filter $(MCU),$(MCU_LIST)),)
    MCU_FAMILY := STM32H7B3xx
    MCU_VARIANT := STM32H7B3xx
    MCU_ARCH := cortex-m7

    CFLAGS += -mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-d16

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

# TODO: Add a project level variable to set the location of the HAL
#       makefile, or take it out of here completely
#   $(info MCU_MAK is $(MCU_MAK))
	MCU_MAK += stm32h7xx_hal_driver/adaptabuild.mak
#   $(info MCU_MAK is $(MCU_MAK))
endif
