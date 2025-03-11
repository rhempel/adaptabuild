# ----------------------------------------------------------------------------
# validate_nrf52_mcu.mak - master list of NRF52 variants
#
# NOTE: This file is included by validate_mcu.mak - do not include from
#       your makefile!
# ----------------------------------------------------------------------------

NRF51822_LIST := $(foreach _x_,822,nRF51$(_x_))

MCU_LIST := $(NRF51822_LIST)

ifeq ($(filter $(MCU),$(MCU_LIST)),$(MCU))

    # Pick the right MCU_VARIANT

    ifeq ($(filter $(MCU),$(NRF51822_LIST)),$(MCU))
        MCU_VARIANT := NRF51822_XXAA
        MCU_STARTUP_FILE := gcc_startup_nrf51.S
        MCU_SYSTEM_FILE := system_nrf51.c
        MCU_LINKER_SCRIPT := nrf51_xxaa.ld
        BOOT_LINKER_SCRIPT :=
    else
        $(error MCU_VARIANT not set for $(MCU))
    endif

    MCU_FAMILY := NRF51
    MCU_ARCH := cortex-m0
    MCU_LDPATH := thumb/v6-m/nofp

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

	MCU_MAK += third_party/cmsis_core/adaptabuild_module.mak
	MCU_MAK += third_party/nrfx/adaptabuild_module.mak
endif
