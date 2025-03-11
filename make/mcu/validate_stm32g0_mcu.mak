# ----------------------------------------------------------------------------
# validate_stm32g0_mcu.mak - master list of STM32G0 variants
#
# NOTE: This file is included by validate_mcu.mak - do not include from
#       your makefile!
# ----------------------------------------------------------------------------

STM32G030xx_LIST := $(foreach _x_,x,STM32G030$(_x_)x)
STM32G050xx_LIST := $(foreach _x_,x,STM32G050$(_x_)x)
STM32G070xx_LIST := $(foreach _x_,x,STM32G070$(_x_)x)                  
STM32G0B0xx_LIST := $(foreach _x_,x,STM32G0B0$(_x_)x)
STM32G031xx_LIST := $(foreach _x_,x,STM32G031$(_x_)x)
STM32G041xx_LIST := $(foreach _x_,x,STM32G041$(_x_)x)
STM32G051xx_LIST := $(foreach _x_,x,STM32G051$(_x_)x)
STM32G061xx_LIST := $(foreach _x_,x,STM32G061$(_x_)x)
STM32G071xx_LIST := $(foreach _x_,x,STM32G071$(_x_)x)
STM32G081xx_LIST := $(foreach _x_,x,STM32G081$(_x_)x)
STM32G0B1xx_LIST := $(foreach _x_,x,STM32G0B1$(_x_)x)
STM32G0C1xx_LIST := $(foreach _x_,x,STM32G0C1$(_x_)x)

MCU_LIST := $(STM32G030xx_LIST)                     $(STM32G050xx_LIST) 
MCU_LIST += $(STM32G031xx_LIST) $(STM32G041xx_LIST) $(STM32G051xx_LIST) $(STM32G061xx_LIST) 
MCU_LIST += $(STM32G070xx_LIST)                     $(STM32G0B0xx_LIST)
MCU_LIST += $(STM32G071xx_LIST) $(STM32G081xx_LIST) $(STM32G0B1xx_LIST) $(STM32G0C1xx_LIST)

ifeq ($(filter $(MCU),$(MCU_LIST)),$(MCU))

    # Pick the right MCU_VARIANT

    ifeq ($(filter $(MCU),$(STM32G030xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G030xx
    else ifeq ($(filter $(MCU),$(STM32G050xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G050xx
    else ifeq ($(filter $(MCU),$(STM32G070xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G070xx
    else ifeq ($(filter $(MCU),$(STM32G0B0xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G0B0xx
    else ifeq ($(filter $(MCU),$(STM32G031xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G031xx
    else ifeq ($(filter $(MCU),$(STM32G041xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G041xx
    else ifeq ($(filter $(MCU),$(STM32G051xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G051xx
    else ifeq ($(filter $(MCU),$(STM32G061xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G061xx
    else ifeq ($(filter $(MCU),$(STM32G071xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G071xx
    else ifeq ($(filter $(MCU),$(STM32G081xx_LIST),$(MCU)))
        MCU_VARIANT := STM32G081xx
    else ifeq ($(filter $(MCU),$(STM32G0B1xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G0B1xx
    else ifeq ($(filter $(MCU),$(STM32G0C1xx_LIST)),$(MCU))
        MCU_VARIANT := STM32G0C1xx
   else
        $(error MCU_VARIANT not set for $(MCU))
    endif

    MCU_FAMILY := stm32g0xx
#   MCU_ARCH := cortex-m0plus -march=armv6s-m
    MCU_ARCH := cortex-m0
    MCU_LDPATH := thumb/v6-m/nofp
    MCU_LINKER_SCRIPT := linker_script.ld

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

	MCU_MAK += third_party/cmsis_core/adaptabuild_module.mak
	MCU_MAK += third_party/cmsis_device_g0/adaptabuild_module.mak
	MCU_MAK += third_party/stm32g0xx_hal_driver/adaptabuild_module.mak

    MCU_INCPATH += third_party/cmsis_device_g0/Include
    MCU_INCPATH += third_party/cmsis_core/Include
endif
