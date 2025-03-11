# ----------------------------------------------------------------------------
# validate_pico2040_mcu.mak - master list of pico2040 variants
#
# NOTE: This file is included by validate_mcu.mak - do not include from
#       your makefile!
# ----------------------------------------------------------------------------

PICO2040_LIST := $(foreach _x_,2040,pico$(_x_))

MCU_LIST := $(PICO2040_LIST)

ifeq ($(filter $(MCU),$(MCU_LIST)),$(MCU))

    # Pick the right MCU_VARIANT

    ifeq ($(filter $(MCU),$(PICO2040_LIST)),$(MCU))
        MCU_VARIANT := PICO_2040
        MCU_STARTUP_FILE := crt0.S
#        MCU_SYSTEM_FILE := system_nrf52
        MCU_LINKER_SCRIPT := memmap_no_flash.ld
#       MCU_LINKER_SCRIPT := memmap_default.ld
        BOOT_LINKER_SCRIPT := boot_stage2.ld
    else
        $(error MCU_VARIANT not set for $(MCU))
    endif

    MCU_FAMILY := RPI_PICO
    MCU_ARCH := cortex-m0plus
    MCU_LDPATH := thumb/v6-m/nofp

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

	MCU_MAK += third_party/cmsis_core/adaptabuild_module.mak
	MCU_MAK += third_party/pico-sdk/adaptabuild_module.mak
endif
