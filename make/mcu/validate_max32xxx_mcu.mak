# ----------------------------------------------------------------------------
# validate_nrf52_mcu.mak - master list of NRF52 variants
#
# NOTE: This file is included by validate_mcu.mak - do not include from
#       your makefile!
# ----------------------------------------------------------------------------

MAX32xxx_LIST := $(foreach _x_,690,max32$(_x_))

MCU_LIST := $(MAX32xxx_LIST)

ifeq ($(filter $(MCU),$(MCU_LIST)),$(MCU))

    # Pick the right MCU_VARIANT - for the AD/MAXIM devices we make sure the
    # MCU_VARIANT is in upper case form so that variables are substituted
    # with values that make sene
    #
    # This decouples our adaptabuild MCU naming convention from the vendor
    # supplied file and directory names
    #
    ifeq (max32690,$(MCU))
        MCU_VARIANT := MAX32690
        MCU_TARGET := 32690
        MCU_TARGET_REV := 0x4131
        MCU_LINKER_SCRIPT := max32690.ld
        MCU_STARTUP_FILE := startup_max32690.S
        
        MCU_CDEFS += CONFIG_SOC_MAX32690
    else
        $(error MCU_VARIANT not set for $(MCU))
    endif

    MCU_SYSTEM_FILE := 
    BOOT_LINKER_SCRIPT :=

    MCU_FAMILY := MAX32xxx
    MCU_ARCH := cortex-m4
    MCU_LDPATH := thumb/v7e-m+fp/hard
    MCU_FLOAT := hard

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

	MCU_MAK += third_party/cmsis_core/adaptabuild_module.mak
	MCU_MAK += third_party/hal_adi/adaptabuild_module.mak

    MCU_INCPATH += third_party/cmsis_core/Include
    MCU_INCPATH += third_party/hal_adi/MAX/Include
    MCU_INCPATH += third_party/hal_adi/MAX/Libraries/CMSIS/Device/Include
    MCU_INCPATH += third_party/hal_adi/MAX/Libraries/CMSIS/Device/Maxim/$(MCU_VARIANT)/Include
endif
