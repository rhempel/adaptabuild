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

CFLAGS :=
CFLAGS += -g -mcpu=$(MCU_ARCH)

CDEFS :=
CDEFS := $(MCU_VARIANT)

LDFLAGS :=
LDFLAGS += -nostdlib -gc-sections
LDFLAGS += -L /usr/lib/gcc/arm-none-eabi/10.3.1 
LDFLAGS += -lgcc

# ----------------------------------------------------------------------------
# See https://www.cmcrossroads.com/article/tips-and-tricks-automatic-dependency-generation-masters
# for the thinking behind the -MD -MP combination!

DEPFLAGS :=
DEPFLAGS += -MD -MP
