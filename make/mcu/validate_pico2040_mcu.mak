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
#       MCU_STARTUP_FILE := blinky/config/pico2040/quirks/pico-sdk/crt0.S
        MCU_LINKER_SCRIPT := default_pico2040.ld
        BOOT_LINKER_SCRIPT := boot_stage2.ld
    else
        $(error MCU_VARIANT not set for $(MCU))
    endif

    CDEFS += DNDEBUG
    CDEFS += LIB_PICO_BIT_OPS=1 LIB_PICO_BIT_OPS_PICO=1
    CDEFS += LIB_PICO_DIVIDER=1 LIB_PICO_DIVIDER_HARDWARE=1
    CDEFS += LIB_PICO_DOUBLE=1 LIB_PICO_DOUBLE_PICO=1
    CDEFS += LIB_PICO_FLOAT=1 LIB_PICO_FLOAT_PICO=1
    CDEFS += LIB_PICO_INT64_OPS=1 LIB_PICO_INT64_OPS_PICO=1
    CDEFS += LIB_PICO_MALLOC=1
    CDEFS += LIB_PICO_MEM_OPS=1 LIB_PICO_MEM_OPS_PICO=1
    CDEFS += LIB_PICO_PLATFORM=1
    CDEFS += LIB_PICO_PRINTF=1 LIB_PICO_PRINTF_PICO=1
    CDEFS += LIB_PICO_RUNTIME=1
    CDEFS += LIB_PICO_STANDARD_LINK=1
    CDEFS += LIB_PICO_STDIO=1 LIB_PICO_STDIO_UART=1
    CDEFS += LIB_PICO_STDLIB=1
    CDEFS += LIB_PICO_SYNC=1 LIB_PICO_SYNC_CRITICAL_SECTION=1 LIB_PICO_SYNC_MUTEX=1 LIB_PICO_SYNC_SEM=1
    CDEFS += LIB_PICO_TIME=1
    CDEFS += LIB_PICO_UTIL=1
#    CDEFS += PICO_BOARD=\"pico\" PICO_BUILD=1 PICO_CMAKE_BUILD_TYPE=\"Release\"
    CDEFS += PICO_COPY_TO_RAM=0
    CDEFS += PICO_CXX_ENABLE_EXCEPTIONS=0
#    CDEFS += PICO_NO_FLASH=0
    CDEFS += PICO_NO_HARDWARE=0
    CDEFS += PICO_ON_DEVICE=1
    CDEFS += PICO_TARGET_NAME=\"helloworld\"
    CDEFS += PICO_USE_BLOCKED_RAM=0
    CDEFS += PICO_TIME_DEFAULT_ALARM_POOL_DISABLED
#    CDEFS += __ARM_ARCH_6M__

    MCU_FAMILY := RPI_PICO
    MCU_ARCH := cortex-m0plus -march=armv6s-m
    MCU_LDPATH := thumb/v6-m/nofp

	include $(ADAPTABUILD_PATH)/make/toolchain/arm-none-eabi.mak

	MCU_MAK += third_party/cmsis_core/adaptabuild_module.mak
	MCU_MAK += third_party/pico-sdk/adaptabuild_module.mak

    MCU_INCPATH += third_party/cmsis_core/Include
    MCU_INCPATH += third_party/pico-sdk/src/common/pico_base/include
    MCU_INCPATH += third_party/pico-sdk/src/common/pico_binary_info/include
    MCU_INCPATH += third_party/pico-sdk/src/rp2_common/pico_platform/include
    MCU_INCPATH += third_party/pico-sdk/src/rp2_common/cmsis/stub/CMSIS/Device
    MCU_INCPATH += third_party/pico-sdk/src/rp2040/hardware_regs/include
endif
