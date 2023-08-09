# ----------------------------------------------------------------------------
# module_library.mak - support for building the library for a modukle
#
# This file is included at the end of every module level adaptabuild.mak
# file, like this:
#
#   include adaptabuild/make/module_objects.mak
#   include adaptabuild/make/module_library.mak
#
# ----------------------------------------------------------------------------
# Add the $(MODULE)_ prefix to create a unique OBJPATH for this module
# at build time

include $(ADAPTABUILD_PATH)/make/adaptabuild_objects.mak

$(MODULE)_OBJPATH := $(addprefix $(OBJ_PATH)/,$($(MODULE)_SRCPATH))

# Force the creation of the build dircetory path(s) that are needed
# for this library

$(shell $(MKPATH) $($(MODULE)_OBJPATH))

# Add the $(MODULE)_ prefix to create a unique source filename
# for the c and assembler files in this module.

$(MODULE)_SRC := $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C))
$(MODULE)_SRC += $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_ASM))

# Now transform the filenames ending in .c, .s, and .S into .o files so
# that we have unique object filenames.
#
# This allows us to generate and objects, libraries, and other artifacts
# separately from the source tree.

$(MODULE)_OBJ   := $(subst $(SRC_PATH),$(OBJ_PATH),\
                     $(subst .c,.o,\
                       $(subst .s,.o,\
                         $(subst .S,.o,$($(MODULE)_SRC)))))

# Transform the list of object files into a list of dependency files
# that are created right next to the objects. Note that gcc has
# an option to create include dependencies automagically using
# the -M options (and some variants). It can even handle includes
# in assembler files if they use the .S (upper case) suffiX.

$(MODULE)_DEP := $(subst .o,.dep,$($(MODULE)_OBJ))

include $($(MODULE)_DEP)

# It is possible to set up unique object file suffixes for a group of
# files - for example if we have a list of files that need to be compiled
# with a specific optimization level, we can do something like this:

$(MODULE)_SRC_OPT3 := $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C_OPT3))

$(MODULE)_OBJ_OPT3 := $(subst $(SRC_PATH),$(OBJ_PATH),\
                        $(subst .c,.o_opt3,$($(MODULE)_SRC_OPT3)))

$(MODULE)_DEP_OPT3 := $(subst .o_opt3,.dep_opt3,$($(MODULE)_OBJ_OPT3))

include $($(MODULE)_DEP_OPT3)

# $(info  MODULE_OBJ is $($(MODULE)_OBJ))
# $(info  MODULE_OBJ_OPT3 is $($(MODULE)_OBJ_OPT3))
# $(info  MODULE_DEP is $($(MODULE)_DEP))
# (info  MODULE_DEP_OPT3 is $($(MODULE)_DEP_OPT3))


# Add the module specific library to the list of modules that must
# be built for the project. Note that we store the library with the
# objects that are built for this configuration of the project. This
# allows us to build multiple projects and guarantee that they are
# all built from the same source but their object files are distinct.

MODULE_LIBS += $(OBJ_PATH)/$(MODULE_PATH)/$(MODULE).a

# This module library depends on the list of objects in $($(MODULE)_OBJ)
# which is handled in module_objects.mak
#
$(OBJ_PATH)/$(MODULE_PATH)/$(MODULE).a : $($(MODULE)_OBJ) $($(MODULE)_OBJ_OPT3)
	@$(AR) -r $@ $?

# These includes stop the makefie processing and cuase the dependency files
# to be created immediately - if these includes are placed before the
# $(MODULE).a definition then the directories where the dependencies live
# won't heve been created ...
# 
#include $($(MODULE)_DEP)
#include $($(MODULE)_DEP_OPT3)

# ----------------------------------------------------------------------------