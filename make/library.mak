# ----------------------------------------------------------------------------
# library.mak - support for building the library for a modukle
#
# This file is included at the end of every module level adaptabuild_module.mak
# file, like this:
#
#   include $(ADAPTABUILD_PATH)/make/library.mak
# ----------------------------------------------------------------------------

ifeq (unittest,$(MAKECMDGOALS))
  COVFLAGS := -ftest-coverage -fprofile-arcs
else
endif

include $(ADAPTABUILD_PATH)/make/objects.mak

# # ----------------------------------------------------------------------------
# THIS MUST BE AFTER THE objects.mak so that the PREREQ AND TARTGET stems are correct.
# # Include the unit test framework makefile that works for this module
# # if the target is cpputest
# 
ifeq (unittest,$(MAKECMDGOALS))
  TESTABLE_MODULES += $(MODULE)_UNITTEST
  $(MODULE)_test_main := cpputest/main.o
  include $(ADAPTABUILD_PATH)/make/test/cpputest.mak
endif

# This section transforms the module source file list into a list of
# directories that must be created in the BUILD_PATH for the module.
#
# Without these directories already in place, the dependency and object
# files cannot be created.
#
BUILD_FOLDERS := $(addprefix $(MODULE_PATH)/,$(sort $(dir $(SRC_C) $(SRC_ASM) $(SRC_TEST))))
BUILD_FOLDERS := $(addprefix $(BUILD_PATH)/,$(BUILD_FOLDERS))

# Normalize the BUILD_FOLDERS

$(call log_notice,BUILD_FOLDERS: $(BUILD_FOLDERS))

BUILD_FOLDERS := $(call make_cwd_relative_path,$(abspath $(BUILD_FOLDERS)))
$(call log_notice,adjusted BUILD_FOLDERS: $(BUILD_FOLDERS))

# Now we can create the build folders ...
#
$(call log_notice,Forcing creation of: $(BUILD_FOLDERS))
_ := $(shell $(MKPATH) $(BUILD_FOLDERS))

# Force a module specific source files variable to be empty
#
$(MODULE)_SRC :=

$(call log_notice,SRC_C is $(SRC_C))
$(call log_notice,SRC_ASM is $(SRC_ASM))

# Add the module specific C and ASM file to the source list

$(MODULE)_SRC := $(SRC_C) $(SRC_ASM)

$(call log_notice,$(MODULE)_SRC is $($(MODULE)_SRC))

# Now transform the filenames ending in [cCsS] into .o files so
# that we have unique object filenames.
#
$(MODULE)_OBJ := $(subst .c,.o,\
                   $(subst .cpp,.o,\
                     $(subst .C,.o,\
                       $(subst .s,.o,\
                         $(subst .S,.o,$($(MODULE)_SRC))))))

$(call log_notice,$(MODULE)_OBJ is $($(MODULE)_OBJ))

$(MODULE)_DEP := $(subst .o,.d,$($(MODULE)_OBJ))

$(call log_notice,$(MODULE)_DEP is $($(MODULE)_DEP))

# Magic here: Add the PREREQ_STEM to the source file list
#             and the TARGET_STEM to the object and dependency lists
#  
$(MODULE)_SRC := $(addprefix $(PREREQ_STEM)/,$($(MODULE)_SRC))
$(MODULE)_OBJ := $(addprefix $(TARGET_STEM)/,$($(MODULE)_OBJ))
$(MODULE)_DEP := $(addprefix $(TARGET_STEM)/,$($(MODULE)_DEP))

$(call log_notice,$(MODULE)_SRC is $($(MODULE)_SRC))
$(call log_notice,$(MODULE)_OBJ is $($(MODULE)_OBJ))
$(call log_notice,$(MODULE)_DEP is $($(MODULE)_DEP))

-include $(MODULE)_DEP

# This is an example of a way to specify a specific kind of object
# file option and compile time - in this case we want to compile
# these objects with an optimization level of -o3 (OPT3) and
# we need to add the correct dircetory prefixes and file type
# suffixes

$(MODULE)_OBJ_OPT3 := $(subst .c,.o_opt3,$($(MODULE)_SRC_OPT3))

$(MODULE)_DEP_OPT3 := $(subst .o_opt3,.d,$($(MODULE)_OBJ_OPT3))

-include $(MODULE)_DEP_OPT3

# Add the module specific library to the list of modules that must
# be built for the project. Note that we store the library with the
# objects that are built for this configuration of the project. This
# allows us to build multiple projects and guarantee that they are
# all built from the same source but their object files are distinct.

MODULE_LIBS += $(TARGET_STEM)/$(MODULE).a
$(call log_debug,MODULE_LIBS is: $(MODULE_LIBS))

# This module library depends on the list of objects in $($(MODULE)_OBJ)
# which is handled in module_objects.mak

$(TARGET_STEM)/$(MODULE).a : $($(MODULE)_OBJ) $($(MODULE)_OBJ_OPT3)
	@echo Building $@ from $?
	@$(AR) -cr $@ $?

# ----------------------------------------------------------------------------
