# ----------------------------------------------------------------------------
# validate_stm32f0_mcu.mak - master list of STM32F0 variants
#
# NOTE: This file is included by validate_mcu.mak - do not include from
#       your makefile!
# ----------------------------------------------------------------------------

STM32F030x4_LIST := $(foreach _x_,F,STM32F030$(_x_)4)
STM32F030x6_LIST := $(foreach _x_,C K,STM32F030$(_x_)6)
STM32F030x8_LIST := $(foreach _x_,C R,STM32F030$(_x_)8)
STM32F030xC_LIST := $(foreach _x_,C R,STM32F030$(_x_)C)

STM32F031x4_LIST := $(foreach _x_,C F G K,STM32F031$(_x_)4)
STM32F031x6_LIST := $(foreach _x_,C E F G K,STM32F031$(_x_)6)

STM32F038x6_LIST := $(foreach _x_,C E F G K,STM32F038$(_x_)6)

STM32F042x4_LIST := $(foreach _x_,C F G K,STM32F042$(_x_)4)
STM32F042x6_LIST := $(foreach _x_,C F G K T,STM32F042$(_x_)6)

STM32F048x6_LIST := $(foreach _x_,C G T,STM32F048$(_x_)6)

STM32F051x4_LIST := $(foreach _x_,C K R,STM32F051$(_x_)4)
STM32F051x6_LIST := $(foreach _x_,C K R,STM32F051$(_x_)6)
STM32F051x8_LIST := $(foreach _x_,C K R T,STM32F051$(_x_)8)

STM32F058x8_LIST := $(foreach _x_,C R T,STM32F058$(_x_)8)

STM32F070x6_LIST := $(foreach _x_,C F,STM32F070$(_x_)6)
STM32F070xB_LIST := $(foreach _x_,C R,STM32F070$(_x_)B)

STM32F071x8_LIST := $(foreach _x_,C V,STM32F071$(_x_)8)
STM32F071xB_LIST := $(foreach _x_,C R V,STM32F071$(_x_)B)

STM32F072x8_LIST := $(foreach _x_,C R V,STM32F072$(_x_)8)
STM32F072xB_LIST := $(foreach _x_,C R V,STM32F072$(_x_)B)

STM32F078xB_LIST := $(foreach _x_,C R V,STM32F078$(_x_)B)

STM32F091xB_LIST := $(foreach _x_,C R V,STM32F091$(_x_)B)
STM32F091xC_LIST := $(foreach _x_,C R V,STM32F091$(_x_)C)

STM32F098xC_LIST := $(foreach _x_,C R V,STM32F098$(_x_)C)

MCU_LIST := $(STM32F030x4_LIST) $(STM32F030x6_LIST) $(STM32F030x8_LIST) $(STM32F030xC_LIST)
MCU_LIST += $(STM32F031x4_LIST) $(STM32F031x6_LIST)
MCU_LIST += $(STM32F038x6_LIST)
MCU_LIST += $(STM32F042x4_LIST) $(STM32F042x6_LIST)
MCU_LIST += $(STM32F048x6_LIST)
MCU_LIST += $(STM32F051x4_LIST) $(STM32F051x6_LIST) $(STM32F051x8_LIST)
MCU_LIST += $(STM32F058x8_LIST)
MCU_LIST += $(STM32F070x6_LIST) $(STM32F070xB_LIST)
MCU_LIST += $(STM32F071x8_LIST) $(STM32F071xB_LIST)
MCU_LIST += $(STM32F072x8_LIST) $(STM32F072xB_LIST)
MCU_LIST += $(STM32F078xB_LIST)
MCU_LIST += $(STM32F091xB_LIST) $(STM32F091xC_LIST)
MCU_LIST += $(STM32F098xC_LIST)

ifeq ($(filter $(MCU),$(MCU_LIST)),$(MCU))

    # Pick the right MCU_VARIANT

    ifeq ($(filter $(MCU),$(STM32F030x4_LIST) $(STM32F030x6_LIST)),$(MCU))
        MCU_VARIANT := STM32F030x6
    else ifeq ($(filter $(MCU),$(STM32F030x8_LIST)),$(MCU))
        MCU_VARIANT := STM32F030x8
    else ifeq ($(filter $(MCU),$(STM32F030xC_LIST)),$(MCU))
        MCU_VARIANT := STM32F030xC
    else ifeq ($(filter $(MCU),$(STM32F031x4_LIST) $(STM32F031x6_LIST)),$(MCU))
        MCU_VARIANT := STM32F031x6
    else ifeq ($(filter $(MCU),$(STM32F038x6_LIST)),$(MCU))
        MCU_VARIANT := STM32F038xx
    else ifeq ($(filter $(MCU),$(STM32F042x4_LIST) $(STM32F042x6_LIST)),$(MCU))
        MCU_VARIANT := STM32F042x6
    else ifeq ($(filter $(MCU),$(STM32F048x6_LIST)),$(MCU))
        MCU_VARIANT := STM32F048xx
    else ifeq ($(filter $(MCU),$(STM32F051x4_LIST) $(STM32F051x6_LIST) $(STM32F051x8_LIST)),$(MCU))
        MCU_VARIANT := STM32F051x8
    else ifeq ($(filter $(MCU),$(STM32F058x8_LIST)),$(MCU))
        MCU_VARIANT := STM32F058xx
    else ifeq ($(filter $(MCU),$(STM32F070x6_LIST)),$(MCU))
        MCU_VARIANT := STM32F070x6
    else ifeq ($(filter $(MCU),$(STM32F070xB_LIST)),$(MCU))
        MCU_VARIANT := STM32F070xB
    else ifeq ($(filter $(MCU),$(STM32F071x8_LIST) $(STM32F071xB_LIST)),$(MCU))
        MCU_VARIANT := STM32F071xB
    else ifeq ($(filter $(MCU),$(STM32F072x8_LIST) $(STM32F072xB_LIS)T),$(MCU))
        MCU_VARIANT := STM32F072xB
    else ifeq ($(filter $(MCU),$(STM32F078xB_LIST)),$(MCU))
        MCU_VARIANT := STM32F078xx
    else ifeq ($(filter $(MCU),$(STM32F091xB_LIST) $(STM32F091xC_LIST)),$(MCU))
        MCU_VARIANT := STM32F091xC
    else ifeq ($(filter $(MCU),$(STM32F098xC_LIST)),$(MCU))
        MCU_VARIANT := STM32F098xx
    else
        $(error MCU_VARIANT not set for $(MCU))
    endif

    MCU_FAMILY := stm32f0xx
    MCU_ARCH := cortex-m0
    MCU_LDPATH := thumb/v6-m/nofp
    MCU_LINKER_SCRIPT := linker_script.ld

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

	MCU_MAK += third_party/cmsis_core/adaptabuild_module.mak
	MCU_MAK += third_party/cmsis_device_f0/adaptabuild_module.mak
	MCU_MAK += third_party/stm32f0xx_hal_driver/adaptabuild_module.mak
endif
