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

# # ----------------------------------------------------------------------------
# THIS MUST BE AFTER THE objects.mak so that the PREREQ AND TARTGET stems are correct?
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

# $(call log_notice,BUILD_FOLDERS: $(BUILD_FOLDERS))
# 
# BUILD_FOLDERS := $(abspath $(BUILD_FOLDERS))
# $(call log_notice,normalized BUILD_FOLDERS: $(BUILD_FOLDERS))
# 
# ifeq (/,$(ABS_CWD_PATH))
#   BUILD_FOLDERS := $(subst _$(ABS_CWD_PATH),,_$(BUILD_FOLDERS))
# else
#   BUILD_FOLDERS := $(subst _$(ABS_CWD_PATH)/,,_$(BUILD_FOLDERS))
# endif
# $(call log_notice,cwd relative BUILD_FOLDERS: $(BUILD_FOLDERS))



# # Now remove any trailing / or /. and replace /./ with /
# #
# BUILD_FOLDERS := $(patsubst %/,%,$(BUILD_FOLDERS))
# BUILD_FOLDERS := $(patsubst %/.,%,$(BUILD_FOLDERS))
# 
# BUILD_FOLDERS := $(subst /./,/,$(BUILD_FOLDERS))

# Now we can create the build folders ...
#
$(call log_notice,Forcing creation of: $(BUILD_FOLDERS))
_ := $(shell $(MKPATH) $(BUILD_FOLDERS))

# Add the $(MODULE)_ prefix to create a unique source filename
# for the c and assembler files in this module.
#
$(MODULE)_SRC :=
#$(MODULE)_SRC += $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C))
#$(MODULE)_SRC += $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_ASM))

# ADD A COMMENT HERE ABOUT THE _ TRICK!

# SRC_PREFIX := $(abspath $(SRC_PATH)/$(MODULE_PATH))
# 
# $(call log_info,SRC_PREFIX is $(SRC_PREFIX))
# 
# ifeq ($(ABS_SRC_PATH),$(SRC_PREFIX))
#   SRC_PREFIX := .
# else
#   SRC_PREFIX := $(subst _$(ABS_SRC_PATH)/,,_$(SRC_PREFIX))
# endif
# $(call log_info,SRC_PREFIX is $(SRC_PREFIX))


#$(MODULE)_SRC += $(addprefix f_$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C))
#$(MODULE)_SRC += $(addprefix f_$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_ASM))

# $(MODULE)_SRC += $(addprefix $(SRC_PREFIX)/,$(SRC_C))
# $(MODULE)_SRC += $(addprefix $(SRC_PREFIX)/,$(SRC_ASM))

#$(MODULE)_SRC := $(call make_src_relative_files,$(abspath $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C))))
$(call log_notice,SRC_C is $(SRC_C))

#$(MODULE)_SRC := $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C))
#$(call log_notice,$(MODULE)_SRC is $($(MODULE)_SRC))
#$(MODULE)_SRC := $(abspath $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C)))
#$(call log_notice,$(MODULE)_SRC is $($(MODULE)_SRC))


# Consider replacing $(SRC_PATH)/$(MODULE_PATH) with $(PREREQ_STEM)
$(MODULE)_SRC := $(call make_src_relative_files,$(abspath $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C))))
$(call log_notice,$(MODULE)_SRC is $($(MODULE)_SRC))

$(MODULE)_SRC += $(call make_src_relative_files,$(abspath $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_ASM))))
$(call log_notice,$(MODULE)_SRC is $($(MODULE)_SRC))

#ifeq (unittest,$(MAKECMDGOALS))
##  $(MODULE)_SRC += $(call make_src_relative_files,$(abspath $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_TEST))))
#  $(call log_notice,$(MODULE)_SRC is $($(MODULE)_SRC))
#else
#endif

$(call log_notice,$(MODULE)_SRC is $($(MODULE)_SRC))

#$(MODULE)_SRC := $(subst /./,/,$($(MODULE)_SRC))

#$(call log_notice,$(MODULE)_SRC is $($(MODULE)_SRC))

# Now transform the filenames ending in [cCsS] into .o files so
# that we have unique object filenames.
#
# This allows us to generate objects, libraries, and other artifacts
# separately fr suffixes here, and then add the prefixes om the source tree.
# later to $(MODULE)_SRC and $(MODULE)_OBJ)

### NOTE: We can simplify this! $(MODULE_SRC) is now a list of source relative files
#         so transform the

$(MODULE)_OBJ := $(subst .c,.o,\
                   $(subst .cpp,.o,\
                     $(subst .C,.o,\
                       $(subst .s,.o,\
                         $(subst .S,.o,$($(MODULE)_SRC))))))

$(call log_notice,$(MODULE)_OBJ is $($(MODULE)_OBJ))

$(MODULE)_DEP := $(subst .o,.d,$($(MODULE)_OBJ))

$(call log_notice,$(MODULE)_DEP is $($(MODULE)_DEP))

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

### TODO: FIx THIS OPT3 EXAMPLE

$(MODULE)_SRC_OPT3 := $(addprefix _$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_C_OPT3))
$(MODULE)_SRC_OPT3 := $(subst /./,/,$($(MODULE)_SRC_OPT3))

$(MODULE)_OBJ_OPT3 := $(subst _$(SRC_PATH),$(BUILD_PATH),\
                        $(subst .c,.o_opt3,$($(MODULE)_SRC_OPT3)))

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

