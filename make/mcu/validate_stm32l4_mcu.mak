# ----------------------------------------------------------------------------
# validate_stm32l4_mcu.mak - master list of STM32L4 variants
#
# NOTE: This file is included by validate_mcu.mak - do not include from
#       your makefile!
# ----------------------------------------------------------------------------

STM32L412xx_LIST := $(foreach _x_,C8 CB K8 KB R8 RB T8 TB,STM32L412$(_x_))
STM32L422xx_LIST := $(foreach _x_,CB KB RB TB,STM32L422$(_x_))
STM32L431xx_LIST := $(foreach _x_,CB CC KB KC RB RC VC,STM32L431$(_x_))
STM32L432xx_LIST := $(foreach _x_,KB KC,STM32L432$(_x_))
STM32L433xx_LIST := $(foreach _x_,CB CC RB RC VC,STM32L433$(_x_))
STM32L442xx_LIST := $(foreach _x_,KC,STM32L442$(_x_))
STM32L443xx_LIST := $(foreach _x_,CC RC VC,STM32L443$(_x_))
STM32L451xx_LIST := $(foreach _x_,CC CE RC RE VC VE,STM32L451$(_x_))
STM32L452xx_LIST := $(foreach _x_,CC CE RC RE VC VE,STM32L452$(_x_))
STM32L462xx_LIST := $(foreach _x_,CE RE VE,STM32L462$(_x_))
STM32L471xx_LIST := $(foreach _x_,QE QG RE RG VE VG ZE ZG,STM32L471$(_x_))
STM32L475xx_LIST := $(foreach _x_,RC RE RG VC VE VG,STM32L475$(_x_))
STM32L476xx_LIST := $(foreach _x_,JE JG ME MG QE QG RC RE RG VC VE VG ZE ZG,STM32L476$(_x_))
STM32L486xx_LIST := $(foreach _x_,JG QG RG VG ZG,STM32L486$(_x_))
STM32L496xx_LIST := $(foreach _x_,AE AG QE QG RE RG VE VG WG ZE ZG,STM32L496$(_x_))
STM32L4A6xx_LIST := $(foreach _x_,AG QG RG VG ZG,STM32L4A6$(_x_))

MCU_LIST := $(STM32L412xx_LIST) $(STM32L422xx_LIST)
MCU_LIST += $(STM32L431xx_LIST) $(STM32L432xx_LIST) $(STM32L433xx_LIST)
MCU_LIST += $(STM32L442xx_LIST) $(STM32L443xx_LIST)
MCU_LIST += $(STM32L451xx_LIST) $(STM32L452xx_LIST)
MCU_LIST += $(STM32L462xx_LIST)
MCU_LIST += $(STM32L471xx_LIST) $(STM32L475xx_LIST) $(STM32L476xx_LIST)
MCU_LIST += $(STM32L486xx_LIST)
MCU_LIST += $(STM32L496xx_LIST)
MCU_LIST += $(STM32L4A6xx_LIST)

ifeq ($(filter $(MCU),$(MCU_LIST)),$(MCU))

    # Pick the right MCU_VARIANT

    ifeq ($(filter $(MCU),$(STM32L412xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L412xx
    else ifeq ($(filter $(MCU),$(STM32L422xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L422xx
    else ifeq ($(filter $(MCU),$(STM32L431xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L431xx
    else ifeq ($(filter $(MCU),$(STM32L432xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L432xx
    else ifeq ($(filter $(MCU),$(STM32L433xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L433xx
    else ifeq ($(filter $(MCU),$(STM32L442xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L442xx
    else ifeq ($(filter $(MCU),$(STM32L443xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L443xx
    else ifeq ($(filter $(MCU),$(STM32L451xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L451xx
    else ifeq ($(filter $(MCU),$(STM32L452xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L452xx
    else ifeq ($(filter $(MCU),$(STM32L462xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L462xx
    else ifeq ($(filter $(MCU),$(STM32L471xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L471xx
    else ifeq ($(filter $(MCU),$(STM32L475xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L475xx
    else ifeq ($(filter $(MCU),$(STM32L476xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L476xx
    else ifeq ($(filter $(MCU),$(STM32L486xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L486xx
    else ifeq ($(filter $(MCU),$(STM32L496xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L496xx
    else ifeq ($(filter $(MCU),$(STM32L4A6xx_LIST)),$(MCU))
        MCU_VARIANT := STM32L4A6xx
    else
        $(error MCU_VARIANT not set for $(MCU))
    endif

    MCU_FAMILY := stm32l4xx
    MCU_ARCH := cortex-m4
    MCU_LDPATH := thumb/v7e-m+fp/hard

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

 	MCU_MAK += cmsis_core/adaptabuild.mak
 	MCU_MAK += cmsis_device_l4/adaptabuild.mak
	MCU_MAK += stm32l4xx_hal_driver/adaptabuild.mak
endif
