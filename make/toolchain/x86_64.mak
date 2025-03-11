# ----------------------------------------------------------------------------
# toolchain_arm-none-eabi.mak - bare metal arm support
#
# There should be one of these files for every toolchain variant
# ----------------------------------------------------------------------------
 
CC      = gcc
CXX     = g++
LD      = g++
#LD      = ld
AR      = ar
OBJCOPY = objcopy

CFLAGS :=
CFLAGS += -g

CDEFS :=
CDEFS += 

LDFLAGS :=
LDFLAGS += -L /usr/lib/gcc/x86_64-linux-gnu/11

# ----------------------------------------------------------------------------
# See https://www.cmcrossroads.com/article/tips-and-tricks-automatic-dependency-generation-masters
# for the thinking behind the -MD -MP combination!
#
# NOTE: Consider using -MMD to check only user header files, not system header files

DEPFLAGS :=
DEPFLAGS += -MD -MP
