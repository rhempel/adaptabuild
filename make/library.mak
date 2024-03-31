# ----------------------------------------------------------------------------
# library.mak - support for building the library for a modukle
#
# This file is included at the end of every module level adaptabuild.mak
# file, like this:
#
#   include $(ADAPTABUILD_PATH)/make/library.mak
# ----------------------------------------------------------------------------

ifeq (unittest,$(MAKECMDGOALS))
  COVFLAGS := -ftest-coverage -fprofile-arcs
else
endif

include $(ADAPTABUILD_PATH)/make/objects.mak

$(MODULE)_OBJPATH := $(addprefix $(BUILD_PATH)/,$($(MODULE)_SRCPATH))
$(call log_debug,Forcing creation of: $($(MODULE)_OBJPATH))

_ := $(shell $(MKPATH) $($(MODULE)_OBJPATH))

# Add the $(MODULE)_ prefix to create a unique source filename
# for the c and assembler files in this module.

$(MODULE)_SRC :=
$(MODULE)_SRC += $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C))
$(MODULE)_SRC += $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_ASM))
ifeq (unittest,$(MAKECMDGOALS))
  $(MODULE)_SRC += $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_TEST))
else
endif

# Now transform the filenames ending in [cCsS] into .o files so
# that we have unique object filenames.
#
# This allows us to generate objects, libraries, and other artifacts
# separately from the source tree.

$(MODULE)_OBJ   := $(subst $(SRC_PATH),$(BUILD_PATH),\
                     $(subst .c,.o,\
                       $(subst .cpp,.o,\
                         $(subst .C,.o,\
                           $(subst .s,.o,\
                             $(subst .S,.o,$($(MODULE)_SRC)))))))

$(MODULE)_DEP := $(subst .o,.d,$($(MODULE)_OBJ))

-include $(MODULE)_DEP

# This is an example of a way to specify a specific kind of object
# file option and compile time - in this case we want to compile
# these objects with an optimization level of -o3 (OPT3) and
# we need to add the correct dircetory prefixes and file type
# suffixes

$(MODULE)_SRC_OPT3 := $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C_OPT3))

$(MODULE)_OBJ_OPT3 := $(subst $(SRC_PATH),$(BUILD_PATH),\
                        $(subst .c,.o_opt3,$($(MODULE)_SRC_OPT3)))

$(MODULE)_DEP_OPT3 := $(subst .o_opt3,.d,$($(MODULE)_OBJ_OPT3))

-include $(MODULE)_DEP_OPT3

# Add the module specific library to the list of modules that must
# be built for the project. Note that we store the library with the
# objects that are built for this configuration of the project. This
# allows us to build multiple projects and guarantee that they are
# all built from the same source but their object files are distinct.

MODULE_LIBS += $(BUILD_PATH)/$(MODULE_PATH)/$(MODULE).a
$(call log_debug,MODULE_LIBS is: $(MODULE_LIBS))

# This module library depends on the list of objects in $($(MODULE)_OBJ)
# which is handled in module_objects.mak

$(BUILD_PATH)/$(MODULE_PATH)/$(MODULE).a : $($(MODULE)_OBJ) $($(MODULE)_OBJ_OPT3)
	@echo Building $@
	@$(AR) -cr $@ $?

# ----------------------------------------------------------------------------