# ----------------------------------------------------------------------------
# library.mak - support for building the library for a modukle
#
# This file is included at the end of every module level adaptabuild.mak
# file, like this:
#
#   include $(ADAPTABUILD_PATH)/make/library.mak
# ----------------------------------------------------------------------------

include $(ADAPTABUILD_PATH)/make/objects.mak

# Add the $(MODULE)_ prefix to create a unique OBJPATH for this module
# at build time

# Note the trick of adding a _ (underscore) at the front of each element
# in the SRC_PATH - this is to prevent a $(MODULE)_SRCPATH)) like:
#   src/module/src/foo.c
# from having BOTH occurences of src substituted!

$(MODULE)_SRCPATH := $(addprefix _,$($(MODULE)_SRCPATH))

$(MODULE)_OBJPATH := $(subst _$(SRC_PATH),$(OBJ_PATH),$($(MODULE)_SRCPATH))

# Force the creation of the build directory path(s) that are needed
# for this library

# What about something like:
#
# $(OBJ_PATH)/$(MODULE_PATH)/$(MODULE).a : $($(MODULE)_OBJPATH))
# $($(MODULE)_OBJPATH)):
#     $(MKPATH) $($(MODULE)_OBJPATH))

_ := $(shell $(MKPATH) $($(MODULE)_OBJPATH))

# Add the $(MODULE)_ prefix to create a unique source filename
# for the c and assembler files in this module.

$(MODULE)_SRC := $(addprefix _$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C))
$(MODULE)_SRC += $(addprefix _$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_ASM))

$(info  41 src_c is $(SRC_C))
$(info  41 src_test is $(SRC_TEST))
ifeq (unittest,$(MAKECMDGOALS))
  $(MODULE)_SRC += $(addprefix _$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_TEST))
else
endif
$(info  46 module_src is $($(MODULE)_SRC))

# Now transform the filenames ending in .c, .s, and .S into .o files so
# that we have unique object filenames.
#
# This allows us to generate and objects, libraries, and other artifacts
# separately from the source tree.
#
# See the note above about the _ (underscore) trick when substituting

$(MODULE)_OBJ   := $(subst _$(SRC_PATH),$(OBJ_PATH),\
                     $(subst .c,.o,\
                       $(subst .s,.o,\
                         $(subst .S,.o,$($(MODULE)_SRC)))))

$(MODULE)_DEP := $(subst .o,.d,$($(MODULE)_OBJ))

# This is an example of a way to specify a specific kind of object
# file option and compile time - in this case we want to compile
# these objects with an optimization level of -o3 (OPT3) and
# we need to add the correct dircetory prefixes and file type
# suffixes

$(MODULE)_SRC_OPT3 := $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C_OPT3))

$(MODULE)_OBJ_OPT3 := $(subst $(SRC_PATH),$(OBJ_PATH),\
                        $(subst .c,.o_opt3,$($(MODULE)_SRC_OPT3)))

$(MODULE)_DEP_OPT3 := $(subst .o_opt3,.d,$($(MODULE)_OBJ_OPT3))

-include $(MODULE)_DEP $(MODULE)_DEP_OPT3

# Add the module specific library to the list of modules that must
# be built for the project. Note that we store the library with the
# objects that are built for this configuration of the project. This
# allows us to build multiple projects and guarantee that they are
# all built from the same source but their object files are distinct.

MODULE_LIBS += $(OBJ_PATH)/$(MODULE_PATH)/$(MODULE).a

# This module library depends on the list of objects in $($(MODULE)_OBJ)
# which is handled in module_objects.mak

$(OBJ_PATH)/$(MODULE_PATH)/$(MODULE).a : $($(MODULE)_OBJ) $($(MODULE)_OBJ_OPT3)
	@echo Building $@
	@$(AR) -cr $@ $?
 
# ----------------------------------------------------------------------------