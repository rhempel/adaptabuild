# ----------------------------------------------------------------------------
# validate_stm32g4_mcu.mak - master list of STM32G4 variants
#
# NOTE: This file is included by validate_mcu.mak - do not include from
#       your makefile!
# ----------------------------------------------------------------------------

STM32G431xx_LIST := $(foreach _x_,xx C6 C8 CB K6 K8 KB M6 M8 MB R6 R8 RB V6 V8 VB,         STM32G431$(_x_))
STM32G441xx_LIST := $(foreach _x_,xx CB KB MB RB VB,                                       STM32G441$(_x_))
STM32G473xx_LIST := $(foreach _x_,xx CB CC CE MB MC ME PB PC PE QB QC QE RB RC RE VB VC VE,STM32G473$(_x_))
STM32G474xx_LIST := $(foreach _x_,xx CB CC CE MB MC ME PB PC PE QB QC QE RB RC RE VB VC VE,STM32G474$(_x_))
STM32G483xx_LIST := $(foreach _x_,xx CE ME PE QE RE VE,                                    STM32G483$(_x_))
STM32G484xx_LIST := $(foreach _x_,xx CE ME PE QE RE VE,                                    STM32G484$(_x_))
STM32G491xx_LIST := $(foreach _x_,xx CC CE KC KE MC ME RC RE VC VE,                        STM32G491$(_x_))
STM32G4A1xx_LIST := $(foreach _x_,xx  CE KE ME RE VE,                                      STM32G4A1$(_x_))

MCU_LIST := $(STM32G431xx_LIST)  $(STM32G441xx_LIST)
MCU_LIST += $(STM32G473xx_LIST)  $(STM32G474xx_LIST)
MCU_LIST += $(STM32G483xx_LIST)  $(STM32G484xx_LIST)
MCU_LIST += $(STM32G491xx_LIST)  
MCU_LIST += $(STM32G4A1xx_LIST)

ifeq ($(filter $(MCU),$(MCU_LIST)),$(MCU))

    # Pick the right MCU_VARIANT

    ifeq ($(filter $(MCU),$(STM32G431xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G431xx
    else ifeq ($(filter $(MCU),$(STM32G441xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G441xx
    else ifeq ($(filter $(MCU),$(STM32G473xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G473xx
    else ifeq ($(filter $(MCU),$(STM32G474xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G474xx
    else ifeq ($(filter $(MCU),$(STM32G483xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G483xx
    else ifeq ($(filter $(MCU),$(STM32G484xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G484xx
    else ifeq ($(filter $(MCU),$(STM32G491xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G491xx
    else ifeq ($(filter $(MCU),$(STM32G4A1xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G4A1xx
   else
        $(error MCU_VARIANT not set for $(MCU))
    endif

    MCU_FAMILY := stm32g4xx
    MCU_ARCH := cortex-m4  -mfpu=fpv4-sp-d16
#    MCU_LDPATH := thumb/v7e-m+fp/hard
#    MCU_FLOAT := hard
# -- NO FP FOR CMRX FOR NOW ...
    MCU_LDPATH := thumb/v7-m/nofp
    MCU_FLOAT := soft
    MCU_LINKER_SCRIPT := linker_script.ld

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

	MCU_MAK += third_party/cmsis_core/adaptabuild_module.mak
	MCU_MAK += third_party/cmsis-device-g4/adaptabuild_module.mak
	MCU_MAK += third_party/stm32g4xx-hal-driver/adaptabuild_module.mak

    MCU_INCPATH += third_party/cmsis-device-g4/Include
    MCU_INCPATH += third_party/cmsis_core/Include
endif
