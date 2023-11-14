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
    $(info We are making unittests!)
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
# STM32H7 Variants - note, we do not have the Q variants mapped out yet!
# ----------------------------------------------------------------------------

STM32H723XX_LIST := $(foreach _v_,VE VG ZE ZG,STM32H723$(_v_))
STM32H725XX_LIST := $(foreach _v_,AE AG IE IG RE RG VE VG ZE ZG,STM32H723$(_v_))

STM32H730XX_LIST := $(foreach _v_,AB IB VB ZB,STM32H730$(_v_))
STM32H733XX_LIST := $(foreach _v_,VG ZG,STM32H733$(_v_))
STM32H735XX_LIST := $(foreach _v_,AG IG RG VG ZG,STM32H735$(_v_))

STM32H742XX_LIST := $(foreach _v_,AG AI BG BI IG II VG VI XG XI ZG ZI,STM32H742$(_v_))
STM32H743XX_LIST := $(foreach _v_,AG AI BG BI IG II VG VI XG XI ZG ZI,STM32H743$(_v_))
STM32H745XX_LIST := $(foreach _v_,BG BI IG II XG XI ZG ZI,STM32H745$(_v_))
STM32H747XX_LIST := $(foreach _v_,AG AI BG BI IG II XG XI ZI,STM32H747$(_v_))

STM32H750XX_LIST := $(foreach _v_,IB VB XB ZB,STM32H750$(_v_))
STM32H753XX_LIST := $(foreach _v_,AI BI II VI XI ZI,STM32H753$(_v_))
STM32H755XX_LIST := $(foreach _v_,BI II XI ZI,STM32H755$(_v_))
STM32H757XX_LIST := $(foreach _v_,AI BI II XI ZI,STM32H757$(_v_))

STM32H7A3XX_LIST := $(foreach _v_,AG AI IG II LG LI NG NI QI RG RI VG VI ZG ZI,STM32H7A3$(_v_))

STM32H7B0XX_LIST := $(foreach _v_,AB IB RB VB ZB,STM32H7B0$(_v_))
STM32H7B3XX_LIST := $(foreach _v_,AI II LI NI RI VI ZI,STM32H7B3$(_v_))

MCU_LIST := $(STM32H723XX_LIST) $(STM32H725XX_LIST)
MCU_LIST += $(STM32H730XX_LIST)
MCU_LIST += $(STM32H733XX_LIST) $(STM32H735XX_LIST)
MCU_LIST += $(STM32H742XX_LIST) $(STM32H743XX_LIST)
MCU_LIST += $(STM32H745XX_LIST) $(STM32H747XX_LIST)
MCU_LIST += $(STM32H750XX_LIST) $(STM32H753XX_LIST)
MCU_LIST += $(STM32H755XX_LIST) $(STM32H757XX_LIST)
MCU_LIST += $(STM32H7A3XX_LIST)
MCU_LIST += $(STM32H7B0XX_LIST) $(STM32H7B3XX_LIST)

ifeq ($(filter $(MCU),$(MCU_LIST)),$(MCU))

    # Pick the right MCU_VARIANT

    ifeq ($(filter $(MCU),$(STM32H723XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H723XX
    else ifeq ($(filter $(MCU),$(STM32H725XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H725XX
    else ifeq ($(filter $(MCU),$(STM32H730XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H730XX
    else ifeq ($(filter $(MCU),$(STM32H733XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H733XX
    else ifeq ($(filter $(MCU),$(STM32H735XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H735XX
    else ifeq ($(filter $(MCU),$(STM32H742XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H742XX
    else ifeq ($(filter $(MCU),$(STM32H743XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H743XX
    else ifeq ($(filter $(MCU),$(STM32H745XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H745XX
    else ifeq ($(filter $(MCU),$(STM32H747XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H747XX
    else ifeq ($(filter $(MCU),$(STM32H750XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H750XX
    else ifeq ($(filter $(MCU),$(STM32H753XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H753XX
    else ifeq ($(filter $(MCU),$(STM32H755XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H755XX
    else ifeq ($(filter $(MCU),$(STM32H757XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H757XX
    else ifeq ($(filter $(MCU),$(STM32H7A3XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H7A3XX
    else ifeq ($(filter $(MCU),$(STM32H7B0XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H7B0XX
    else ifeq ($(filter $(MCU),$(STM32H7B3XX_LIST)),$(MCU))
        MCU_VARIANT := STM32H7B3XX
    else
        $(error MCU_VARIANT not set for $(MCU))
    endif

    MCU_FAMILY := STM32H7xx
    MCU_ARCH := cortex-m7

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

	MCU_MAK += $(SRC_PATH)/stm32h7xx_hal_driver/adaptabuild.mak
	MCU_MAK += $(SRC_PATH)/cmsis_device_h7/adaptabuild.mak
endif
