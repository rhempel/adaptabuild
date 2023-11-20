# ----------------------------------------------------------------------------
# validate_stm32h7_mcu.mak - master list of STM32H7 variants
#
# NOTE: This file is included by validate_mcu.mak - do not include from
#       your makefile!
# ----------------------------------------------------------------------------

STM32H723xx_LIST := $(foreach _v_,VE VG ZE ZG,STM32H723$(_v_))
STM32H725xx_LIST := $(foreach _v_,AE AG IE IG RE RG VE VG ZE ZG,STM32H723$(_v_))

STM32H730xx_LIST := $(foreach _v_,AB IB VB ZB,STM32H730$(_v_))
STM32H733xx_LIST := $(foreach _v_,VG ZG,STM32H733$(_v_))
STM32H735xx_LIST := $(foreach _v_,AG IG RG VG ZG,STM32H735$(_v_))

STM32H742xx_LIST := $(foreach _v_,AG AI BG BI IG II VG VI XG XI ZG ZI,STM32H742$(_v_))
STM32H743xx_LIST := $(foreach _v_,AG AI BG BI IG II VG VI XG XI ZG ZI,STM32H743$(_v_))
STM32H745xx_LIST := $(foreach _v_,BG BI IG II XG XI ZG ZI,STM32H745$(_v_))
STM32H747xx_LIST := $(foreach _v_,AG AI BG BI IG II XG XI ZI,STM32H747$(_v_))

STM32H750xx_LIST := $(foreach _v_,IB VB XB ZB,STM32H750$(_v_))
STM32H753xx_LIST := $(foreach _v_,AI BI II VI XI ZI,STM32H753$(_v_))
STM32H755xx_LIST := $(foreach _v_,BI II XI ZI,STM32H755$(_v_))
STM32H757xx_LIST := $(foreach _v_,AI BI II XI ZI,STM32H757$(_v_))

STM32H7A3xx_LIST := $(foreach _v_,AG AI IG II LG LI NG NI QI RG RI VG VI ZG ZI,STM32H7A3$(_v_))

STM32H7B0xx_LIST := $(foreach _v_,AB IB RB VB ZB,STM32H7B0$(_v_))
STM32H7B3xx_LIST := $(foreach _v_,AI II LI NI RI VI ZI,STM32H7B3$(_v_))

MCU_LIST := $(STM32H723xx_LIST) $(STM32H725xx_LIST)
MCU_LIST += $(STM32H730xx_LIST)
MCU_LIST += $(STM32H733xx_LIST) $(STM32H735xx_LIST)
MCU_LIST += $(STM32H742xx_LIST) $(STM32H743xx_LIST)
MCU_LIST += $(STM32H745xx_LIST) $(STM32H747xx_LIST)
MCU_LIST += $(STM32H750xx_LIST) $(STM32H753xx_LIST)
MCU_LIST += $(STM32H755xx_LIST) $(STM32H757xx_LIST)
MCU_LIST += $(STM32H7A3xx_LIST)
MCU_LIST += $(STM32H7B0xx_LIST) $(STM32H7B3xx_LIST)

ifeq ($(filter $(MCU),$(MCU_LIST)),$(MCU))

    # Pick the right MCU_VARIANT

    ifeq ($(filter $(MCU),$(STM32H723xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H723xx
    else ifeq ($(filter $(MCU),$(STM32H725xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H725xx
    else ifeq ($(filter $(MCU),$(STM32H730xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H730xx
    else ifeq ($(filter $(MCU),$(STM32H733xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H733xx
    else ifeq ($(filter $(MCU),$(STM32H735xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H735xx
    else ifeq ($(filter $(MCU),$(STM32H742xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H742xx
    else ifeq ($(filter $(MCU),$(STM32H743xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H743xx
    else ifeq ($(filter $(MCU),$(STM32H745xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H745xx
    else ifeq ($(filter $(MCU),$(STM32H747xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H747xx
    else ifeq ($(filter $(MCU),$(STM32H750xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H750xx
    else ifeq ($(filter $(MCU),$(STM32H753xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H753xx
    else ifeq ($(filter $(MCU),$(STM32H755xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H755xx
    else ifeq ($(filter $(MCU),$(STM32H757xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H757xx
    else ifeq ($(filter $(MCU),$(STM32H7A3xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H7A3xx
    else ifeq ($(filter $(MCU),$(STM32H7B0xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H7B0xx
    else ifeq ($(filter $(MCU),$(STM32H7B3xx_LIST)),$(MCU))
        MCU_VARIANT := STM32H7B3xx
    else
        $(error MCU_VARIANT not set for $(MCU))
    endif

    MCU_FAMILY := stm32h7xx
    MCU_ARCH := cortex-m7
    MCU_LDPATH := thumb/v7e-m+fp/hard

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

 	MCU_MAK += cmsis_core/adaptabuild.mak
	MCU_MAK += cmsis_device_h7/adaptabuild.mak
	MCU_MAK += stm32h7xx_hal_driver/adaptabuild.mak
endif
