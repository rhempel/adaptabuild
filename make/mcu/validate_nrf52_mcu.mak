# ----------------------------------------------------------------------------
# validate_nrf52_mcu.mak - master list of NRF52 variants
#
# NOTE: This file is included by validate_mcu.mak - do not include from
#       your makefile!
# ----------------------------------------------------------------------------

NRF52832_LIST := $(foreach _x_,832,nRF52$(_x_))

MCU_LIST += $(NRF52832_LIST)

ifeq ($(filter $(MCU),$(MCU_LIST)),$(MCU))

    # Pick the right MCU_VARIANT

    ifeq ($(filter $(MCU),$(NRF52832_LIST)),$(MCU))
        MCU_VARIANT := NRF52832_XXAA
        MCU_STARTUP_FILE := gcc_startup_nrf52
        MCU_SYSTEM_FILE := system_nrf52
        MCU_LINKER_SCRIPT := nrf52_xxaa
    else
        $(error MCU_VARIANT not set for $(MCU))
    endif

    MCU_FAMILY := NRF52
    MCU_ARCH := cortex-m4
    MCU_LDPATH := thumb/v7e-m+fp/hard

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

 	MCU_MAK += cmsis_core/adaptabuild.mak
 	MCU_MAK += nrfx/adaptabuild.mak
endif
