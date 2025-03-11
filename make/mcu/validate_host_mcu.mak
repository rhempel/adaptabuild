# ----------------------------------------------------------------------------
# validate_host_mcu.mak - target is host CPU (used mainly for off target test)
#
# NOTE: This file is included by validate_mcu.mak - do not include from
#       your makefile!
# ----------------------------------------------------------------------------

MCU_LIST := host

ifeq ($(filter $(MCU),$(MCU_LIST)),$(MCU))
  MCU_ARCH := x86-64
  include $(ADAPTABUILD_PATH)/make/toolchain/x86_64.mak
endif
