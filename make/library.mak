# ----------------------------------------------------------------------------
# library.mak - support for building the library for a modukle
#
# This file is included at the end of every module level adaptabuild.mak
# file, like this:
#
#   include $(ADAPTABUILD_PATH)/make/library.mak
# ----------------------------------------------------------------------------

include $(ADAPTABUILD_PATH)/make/objects.mak

# NOTE: The trick of prepending _ may not be needed because the $(ROOT_PATH)
# already makes the prefix unique with a .

# Transform the $(SRC_PATH) prefix to $(BUILD_PATH) so that we know where
# to put the built dependencies, objects, and libraries.
#
# Note the trick of adding a _ (underscore) at the front of each element
# in the SRC_PATH - this is to prevent a $(MODULE)_SRCPATH)) like:
#   src/module/src/foo.c
# from having BOTH occurences of src substituted!

# $(info $(MODULE)_SRCPATH is $($(MODULE)_SRCPATH))

# $(info SRC_PATH is $(SRC_PATH))
# $(info BUILD_PATH is $(BUILD_PATH))

# $(MODULE)_SRCPATH := _$(SRC_PATH)/$(MODULE_PATH)
#$(MODULE)_SRCPATH := $(addprefix _$(SRC_PATH)/$(MODULE_PATH)/,$($(MODULE)_SRCPATH))

#$(MODULE)_SRCPATH := $(addprefix _,$($(MODULE)_SRCPATH))
#$(info $(MODULE)_SRCPATH is $($(MODULE)_SRCPATH))

#$(MODULE)_OBJPATH := $(subst _$(SRC_PATH),$(BUILD_PATH),$($(MODULE)_SRCPATH))
#$(MODULE)_OBJPATH := $(subst $(SRC_PATH),$(BUILD_PATH),$($(MODULE)_SRCPATH))

$(MODULE)_OBJPATH := $(addprefix $(ROOT_PATH)/$(BUILD_PATH)/,$($(MODULE)_SRCPATH))

# $(info $(MODULE)_OBJPATH is $($(MODULE)_OBJPATH))

# Force the creation of the build directory path(s) that are needed
# for this library

# What about something like:
#
# $(BUILD_PATH)/$(MODULE_PATH)/$(MODULE).a : $($(MODULE)_OBJPATH))
# $($(MODULE)_OBJPATH)):
#     $(MKPATH) $($(MODULE)_OBJPATH))
$(info Forcing creation of: $($(MODULE)_OBJPATH))

_ := $(shell $(MKPATH) $($(MODULE)_OBJPATH))

# Add the $(MODULE)_ prefix to create a unique source filename
# for the c and assembler files in this module.

$(MODULE)_SRC :=
$(MODULE)_SRC += $(addprefix $(ROOT_PATH)/$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C))
# $(MODULE)_SRC += $(SRC_C)
#$(info $(MODULE)_SRC is $($(MODULE)_SRC))
$(MODULE)_SRC += $(addprefix $(ROOT_PATH)/$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_ASM))
# $(MODULE)_SRC += $(SRC_ASM)

ifeq (unittest,$(MAKECMDGOALS))
$(MODULE)_SRC += $(addprefix $(ROOT_PATH)/$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_TEST))
# $(MODULE)_SRC += $(SRC_TEST)
else
endif
# $(info $(MODULE)_SRC is $($(MODULE)_SRC))

$(info $(MODULE)_SRC is $($(MODULE)_SRC))

# Now transform the filenames ending in .c, .s, and .S into .o files so
# that we have unique object filenames.
#
# This allows us to generate and objects, libraries, and other artifacts
# separately from the source tree.
#
# NOTE: May not need the _ now :-)
#       See the note above about the _ (underscore) trick when substituting

$(MODULE)_OBJ   := $(subst $(ROOT_PATH)/$(SRC_PATH),$(ROOT_PATH)/$(BUILD_PATH),\
                     $(subst .c,.o,\
                       $(subst .C,.o,\
                         $(subst .s,.o,\
                           $(subst .S,.o,$($(MODULE)_SRC))))))
$(info $(MODULE)_OBJ is $($(MODULE)_OBJ))

$(MODULE)_DEP := $(subst .o,.d,$($(MODULE)_OBJ))
# $(info $(MODULE)_DEP is $($(MODULE)_DEP))

# This is an example of a way to specify a specific kind of object
# file option and compile time - in this case we want to compile
# these objects with an optimization level of -o3 (OPT3) and
# we need to add the correct dircetory prefixes and file type
# suffixes

$(MODULE)_SRC_OPT3 := $(addprefix $(ROOT_PATH)/$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C_OPT3))

$(MODULE)_OBJ_OPT3 := $(subst $(ROOT_PATH)/$(SRC_PATH),$(ROOT_PATH)/$(BUILD_PATH),\
                        $(subst .c,.o_opt3,$($(MODULE)_SRC_OPT3)))

$(MODULE)_DEP_OPT3 := $(subst .o_opt3,.d,$($(MODULE)_OBJ_OPT3))

-include $(MODULE)_DEP $(MODULE)_DEP_OPT3

# Add the module specific library to the list of modules that must
# be built for the project. Note that we store the library with the
# objects that are built for this configuration of the project. This
# allows us to build multiple projects and guarantee that they are
# all built from the same source but their object files are distinct.

MODULE_LIBS += $(ROOT_PATH)/$(BUILD_PATH)/$(MODULE_PATH)/$(MODULE).a

# This module library depends on the list of objects in $($(MODULE)_OBJ)
# which is handled in module_objects.mak

$(ROOT_PATH)/$(BUILD_PATH)/$(MODULE_PATH)/$(MODULE).a : $($(MODULE)_OBJ) $($(MODULE)_OBJ_OPT3)
	@echo Building $@
	@$(AR) -cr $@ $?
 
# ----------------------------------------------------------------------------