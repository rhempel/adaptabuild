# ----------------------------------------------------------------------------
# validate_mcu.mak - master list of MCU variants and families supported
#
# When building a firmware image, the developer MUST specify the exact
# variant of the MCU that is being targeted. This file checks all of the
# known MCU variants and if one is found:
#
# - Sets MCU_FAMILY choose a vendor specific library
# - Imports a toolchain/xyz.mak file that sets up toolchain variables
# - Potentially sets link time variables for FLASH/RAM size, etc
#
# There should be one section for each MCU supplier, with subsections
# for each MCU family from that vendor.
# ----------------------------------------------------------------------------

ifndef MCU
  $(error you need to at least specify the MCU variable!)
endif

# ----------------------------------------------------------------------------
# Check for any MCUs that we support
# ----------------------------------------------------------------------------

include $(ADAPTABUILD_PATH)/make/mcu/validate_host_mcu.mak

include $(ADAPTABUILD_PATH)/make/mcu/validate_stm32f0_mcu.mak
include $(ADAPTABUILD_PATH)/make/mcu/validate_stm32g0_mcu.mak
include $(ADAPTABUILD_PATH)/make/mcu/validate_stm32g4_mcu.mak
include $(ADAPTABUILD_PATH)/make/mcu/validate_stm32h7_mcu.mak
include $(ADAPTABUILD_PATH)/make/mcu/validate_stm32l4_mcu.mak

include $(ADAPTABUILD_PATH)/make/mcu/validate_nrf51_mcu.mak
include $(ADAPTABUILD_PATH)/make/mcu/validate_nrf52_mcu.mak

include $(ADAPTABUILD_PATH)/make/mcu/validate_pico2040_mcu.mak

include $(ADAPTABUILD_PATH)/make/mcu/validate_max32xxx_mcu.mak

# ----------------------------------------------------------------------------
# Bail out of we still don't know the MCU_ARCH or MCU_VARIANT
# ----------------------------------------------------------------------------

ifeq ($(MCU_ARCH),)
    $(error MCU_ARCH is undefined! Was MCU specified correctly?)
endif

MCU_MAK := $(addprefix $(SRC_PATH)/,$(MCU_MAK))
