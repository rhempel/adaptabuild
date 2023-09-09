# ----------------------------------------------------------------------------
# toolchain_arm-none-eabi.mak - bare metal arm support
#
# There should be one of these files for every toolchain variant
# ----------------------------------------------------------------------------
 
CC      = g++
LD      = g++
AR      = ar
OBJCOPY = objcopy

CFLAGS :=
CFLAGS += -g

ifeq (unittest,$(MAKECMDGOALS))

  CFLAGS += -I/usr/include/CppUTest
  CFLAGS += -I/usr/include/CppUTestExt

  CFLAGS += -ftest-coverage -fprofile-arcs
else
endif

CDEFS :=
CDEFS += 

LDFLAGS :=
LDFLAGS +=

# ----------------------------------------------------------------------------
# See https://www.cmcrossroads.com/article/tips-and-tricks-automatic-dependency-generation-masters
# for the thinking behind the -MD -MP combination!

DEPFLAGS :=
DEPFLAGS += -MD -MP
