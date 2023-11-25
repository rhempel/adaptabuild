# ----------------------------------------------------------------------------
# toolchain_arm-none-eabi.mak - bare metal arm support
#
# There should be one of these files for every toolchain variant
# ----------------------------------------------------------------------------
 
TOOLCHAIN_PREFIX := arm-none-eabi

CC      = $(TOOLCHAIN_PREFIX)-gcc
LD      = $(TOOLCHAIN_PREFIX)-ld
AR      = $(TOOLCHAIN_PREFIX)-ar
OBJCOPY = $(TOOLCHAIN_PREFIX)-objcopy

# TODO: Move the -f options to the project level - not toolchain
#       level - this should only specify the minimum number of flags
#       and options - same for MICRO_STM32_GCC

CFLAGS += -g -mcpu=$(MCU_ARCH) -ffunction-sections -fdata-sections -ffreestanding

CDEFS += $(MCU_VARIANT) MICRO_STM32_GCC

# TODO: Move the actual libraries to be linked into the project level, but
#       leave the search paths here
#
# TODO: Make the architectrure specific path (v5te) a variable that is set
#       in the mcu verification process

LDFLAGS += --gc-sections
LDFLAGS += -L /usr/lib/gcc/arm-none-eabi/10.3.1/$(MCU_LDPATH)

# ----------------------------------------------------------------------------
# See https://www.cmcrossroads.com/article/tips-and-tricks-automatic-dependency-generation-masters
# for the thinking behind the -MD -MP combination!

DEPFLAGS += -MD -MP
