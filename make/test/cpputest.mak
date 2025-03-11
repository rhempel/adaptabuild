# ----------------------------------------------------------------------------
# cpputest.mak - support for building the CppUTest tests for a module
#
# This file should be conditionally included at the end of every module
# level adaptabuild.mak where unit testing us supported, like this:
# 
# ifeq (unittest,$(MAKECMDGOALS))
#     include $(ADAPTABUILD_PATH)/make/test/cpputest.mak
# endif
# ----------------------------------------------------------------------------

# Add the $(MODULE)_ prefix to create a unique OBJPATH for this module
# at build time

$(info  cpputest.mak SRC_PATH is $(SRC_PATH))
$(info  cpputest.mak BUILD_PATH is $(BUILD_PATH))
$(info  cpputest.mak MODULE_TESTPATH is $($(MODULE)_TESTPATH))

# # !!! Not needed as libabry.mak already does this work - consider encapsulating
# # all those common includes at the end of the adaptabuild.m files!
# #
# # Note the trick of adding a _ (underscore) at the front of the string
# # and the SRC_PATH - this is to prevent a $(MODULE)_SRCPATH)) like:
# #   src/module/src
# # from having BOTH occurences of src substituted!
# #
# $(MODULE)_OBJPATH := $(subst _$(SRC_PATH),$(BUILD_PATH),$($(MODULE)_SRCPATH))
# 
# $(info  MODULE_OBJPATH is $($(MODULE)_OBJPATH))
# 
# # # Force the creation of the build directory path(s) that are needed
# # # for this library
# # 
# # _ := $(shell $(MKPATH) $($(MODULE)_OBJPATH))
# 
# $($(MODULE)_OBJPATH):
# 	$(MKPATH) $($(MODULE)_OBJPATH)
# 
# $(BUILD_PATH)/$(MODULE_PATH)/$(MODULE)_test.a :: $($(MODULE)_OBJPATH)
# 	$(echo Making directories ...)
# 
# # Add the $(MODULE)_ prefix to create a unique source filename
# # for the c and assembler files in this module.
# 
# $(MODULE)_TEST_SRC := $(addprefix _$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_TEST_C))
# $(MODULE)_TEST_SRC += $(addprefix _$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_TEST_ASM))
# 
# $(info  $(MODULE)_TEST_SRC is $($(MODULE)_TEST_SRC))
# 
# # Now transform the filenames ending in .c, .s, and .S into .o files so
# # that we have unique object filenames.
# #
# # This allows us to generate and objects, libraries, and other artifacts
# # separately from the source tree.
# #
# # See the note above about the _ (underscore) trick when substituting
# 
# $(MODULE)_TEST_OBJ := $(subst _$(SRC_PATH),$(BUILD_PATH),\
#                        $(subst .c,.o,\
#                          $(subst .s,.o,\
#                            $(subst .S,.o,$($(MODULE)_TEST_SRC)))))
# 
# $(info  $(MODULE)_TEST_OBJ is $($(MODULE)_TEST_OBJ))
# 
# $(MODULE)_TEST_DEP := $(subst .o,.d,$($(MODULE)_TEST_OBJ))
# 
# $(info  $(MODULE)_TEST_DEP is $($(MODULE)_TEST_DEP))
# 
# # Add the module specific library to the list of modules that must
# # be built for the project. Note that we store the library with the
# # objects that are built for this configuration of the project. This
# # allows us to build multiple projects and guarantee that they are
# # all built from the same source but their object files are distinct.
# 
# MODULE_TEST_LIBS += $(BUILD_PATH)/$(MODULE_PATH)/$(MODULE)_test.a
# 
# # This module library depends on the list of objects in $($(MODULE)_OBJ)
# # which is handled in module_objects.mak
# 
# # $(BUILD_PATH)/$(MODULE_PATH)/$(MODULE).a : $($(MODULE)_OBJ) $($(MODULE)_OBJ_OPT3)
# $(BUILD_PATH)/$(MODULE_PATH)/$(MODULE)_test.a :: $($(MODULE)_TEST_OBJ) $($(MODULE)_TEST_OBJ_OPT3)
# 	@echo Building $@
# 	@$(AR) -cr $@ $?
#  
# # ----------------------------------------------------------------------------