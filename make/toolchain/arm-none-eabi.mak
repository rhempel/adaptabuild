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

CFLAGS += -g -specs=picolibc.specs
CFLAGS += -mcpu=$(MCU_ARCH) -mthumb
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing

ifeq (hard,$(MCU_FLOAT))
    CFLAGS += -mfpu=fpv5-d16  -mfloat-abi=hard
else
    # Do nothing
endif

CDEFS += $(MCU_VARIANT) MICRO_STM32_GCC

LDFLAGS += --gc-sections

LDFLAGS += -L /usr/lib/picolibc/arm-none-eabi/lib/$(MCU_LDPATH)
LDFLAGS += -lc -lm

# TODO: This library path should be a symlink so that it's not
#       version dependent - set this up when building the 
#       Docker image
#
# LDFLAGS += -L /usr/lib/gcc/arm-none-eabi/10.3.1/$(MCU_LDPATH)
LDFLAGS += -L /usr/lib/gcc/arm-none-eabi/12.2.1/$(MCU_LDPATH)
LDFLAGS += -lgcc


# Choose one of these two for picolab - dummyhost for now ...
#LDFLAGS +=  -lsemihost
# LDFLAGS +=  -ldummyhost


# NOTE: These variables are not expanded at assignment time - they are
#       deferred variables that are expanded when they are used!!!
#
# That's so we can use shortcut variables like $@ that we cannot know
# the value of until they are used.

LDGROUP = --start-group $(MODULE_LIBS) --end-group
LDMAP = -Map=$@.map

# ----------------------------------------------------------------------------
# See https://www.cmcrossroads.com/article/tips-and-tricks-automatic-dependency-generation-masters
# for the thinking behind the -MD -MP combination!
#
# NOTE: Consider using -MMD to check only user header files, not system header files

DEPFLAGS += -MD -MP
