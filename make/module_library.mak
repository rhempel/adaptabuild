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

$(MODULE)_OBJPATH := $(addprefix $(OBJ_PATH)/,$($(MODULE)_SRCPATH))

# Add the $(MODULE)_ prefix to create a unique source filename
# for the c and assembler files in this module.

$(MODULE)_SRC := $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C))
$(MODULE)_SRC += $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_ASM))

# Now transform the filenames ending in .c and .s into .o files so
# that we have unique object filenames.
#
# This allows us to generate and objects, libraries, and other artifacts
# separately from the source tree.

$(MODULE)_OBJ   := $(subst $(SRC_PATH),$(OBJ_PATH),\
                     $(subst .c,.o,\
                       $(subst .s,.o,$($(MODULE)_SRC))))

# It is possible to set up unique object file suffixes for a group of
# files - for example if we have a list of files that need to be compiled
# with a specific optimization level, we can do something like this:

$(MODULE)_SRC_OPT3 := $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C_OPT3))

$(MODULE)_OBJ_OPT3 := $(subst $(SRC_PATH),$(OBJ_PATH),\
                          $(subst .c,.o.opt3,$($(MODULE)_SRC_OPT3)))
 
# Add the module specific library to the list of modules that must
# be built for the project. Note that we store the library with the
# objects that are built for this configuration of the project. This
# allows us to build multiple projects and guarantee that they are
# all built from the same source but their object files are distinct.

MODULE_LIBS += $(OBJ_PATH)/$(MODULE_PATH)/$(MODULE).a

# ----------------------------------------------------------------------------
# Note the double-colon rules here. The first form of the library depends
# on the object directories. The second form depends on the object files!
#
# Also note the rule-specific variable that's used in the directory rule.
# It makes sure that the path list is set correctly for the current module. 

$(OBJ_PATH)/$(MODULE_PATH)/$(MODULE).a :: $(MODULE)_mkdirs

$(MODULE)_mkdirs: MODULE_OBJPATH := $($(MODULE)_OBJPATH)
$(MODULE)_mkdirs:
	@$(MKPATH) $(MODULE_OBJPATH)

# This module library depends on the list of objects in $($(MODULE)_OBJ)
# which is handled in module_objects.mak

$(OBJ_PATH)/$(MODULE_PATH)/$(MODULE).a :: $($(MODULE)_OBJ)
	@$(AR) -r $@ $?

# ----------------------------------------------------------------------------