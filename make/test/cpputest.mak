# ----------------------------------------------------------------------------
# cpputest.mak - support for building the CppUTest tests for a module
#
# This file should be conditionally included at the end of every module
# level adaptabuild_module.mak where unit testing us supported, like this:
# 
# ifeq (unittest,$(MAKECMDGOALS))
#     TESTABLE_MODULES += $(MODULE)_UNITTEST
#     $(MODULE)_test_main := path/to/your/test/main.o
#     include $(ADAPTABUILD_PATH)/make/test/cpputest.mak
# endif
# ----------------------------------------------------------------------------

$(call log_notice,SRC_TEST is $(SRC_TEST))

#$(MODULE)_SRC_TEST := $(addprefix _$(SRC_PATH)/$(MODULE_PATH)/,$(SRC_TEST))
#$(call log_notice,MODULE_SRC_TEST is $($(MODULE)_SRC_TEST))
##$(MODULE)_SRC_TEST := $(subst /./,/,$($(MODULE)_SRC_TEST))
#$(call log_notice,MODULE_SRC_TEST is $($(MODULE)_SRC_TEST))

$(MODULE)_SRC_TEST := $(call make_src_relative_files,$(abspath $(addprefix $(SRC_PATH)/$(MODULE_PATH)/,$(SRC_TEST))))
$(call log_notice,$(MODULE)_SRC_TEST is $($(MODULE)_SRC_TEST))

# Now transform the filenames ending in .c snd .cpp into .o files so
# that we have unique object filenames.
#
# This allows us to generate any objects, libraries, and other artifacts
# separately from the source tree.
#
$(MODULE)_OBJ_TEST := $(subst .c,.o,\
                        $(subst .cpp,.o,$($(MODULE)_SRC_TEST)))

$(call log_notice,MODULE_OBJ_TEST is $($(MODULE)_OBJ_TEST))

$(MODULE)_DEP_TEST := $(subst .o,.d,$($(MODULE)_OBJ_TEST))

$(call log_notice,MODULE_DEP_TEST is $($(MODULE)_DEP_TEST))

$(MODULE)_SRC_TEST := $(subst _$(SRC_PATH),$(SRC_PATH),$($(MODULE)_SRC_TEST))
$(call log_notice,MODULE_SRC_TEST is $($(MODULE)_SRC_TEST))

$(MODULE)_SRC_TEST := $(addprefix $(PREREQ_STEM)/,$($(MODULE)_SRC_TEST))
$(MODULE)_OBJ_TEST := $(addprefix $(TARGET_STEM)/,$($(MODULE)_OBJ_TEST))
$(MODULE)_DEP_TEST := $(addprefix $(TARGET_STEM)/,$($(MODULE)_DEP_TEST))

$(call log_notice,$(MODULE)_SRC_TEST is $($(MODULE)_SRC_TEST))
$(call log_notice,$(MODULE)_OBJ_TEST is $($(MODULE)_OBJ_TEST))
$(call log_notice,$(MODULE)_DEP_TEST is $($(MODULE)_DEP_TEST))

-include $(MODULE)_DEP_TEST

# Add the module specific library to the list of modules that must
# be built for the project. Note that we store the library with the
# objects that are built for this configuration of the project. This
# allows us to build multiple projects and guarantee that they are
# all built from the same source but their object files are distinct.

MODULE_LIBS_TEST += $(TARGET_STEM)/$(MODULE)_test.a

$(call log_notice,MODULE_LIBS_TEST is $(MODULE_LIBS_TEST))

# This module library depends on the list of objects in $($(MODULE)_OBJ_TEST)
# which is handled in module_objects.mak

$(TARGET_STEM)/$(MODULE)_test.a: $($(MODULE)_OBJ_TEST)
	@echo Building $@ from $?
	@$(AR) -cr $@ $?

$(TARGET_STEM)/$(MODULE)_test: TEST_MAIN_OBJ := $(TARGET_STEM)/$($(MODULE)_test_main)
$(TARGET_STEM)/$(MODULE)_test: $(TARGET_STEM)/$(MODULE)_test.a $(TARGET_STEM)/$(MODULE).a
	@echo Building $@ from object $(TEST_MAIN_OBJ)
	$(LD) -o $@ $(TEST_MAIN_OBJ) $? -lstdc++ -lgcov -lCppUTest -lCppUTestExt -lm 

# # ----------------------------------------------------------------------------
#
# NOTE: This stackoverflow gives us a good way to combine coverage runs if we
# want to.
#
# https://stackoverflow.com/a/35120225
#

.PHONY: $(MODULE)_UNITTEST

$(MODULE)_UNITTEST: TEST_MODULE := $(MODULE)
$(MODULE)_UNITTEST: TEST_MODULE_PATH := $(MODULE_PATH)
$(MODULE)_UNITTEST: $(TARGET_STEM)/$(MODULE)_test
    # Create the artifacts folders
	mkdir -p $(ARTIFACTS_PATH)/$(TEST_MODULE_PATH)/coverage
	mkdir -p $(ARTIFACTS_PATH)/$(TEST_MODULE_PATH)/unittest

    # Create a baseline for code coverage
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE_PATH)/coverage && \
		lcov -z -d --rc branch_coverage=1 $(ABS_BUILD_PATH)/$(TEST_MODULE_PATH)/src

    # Run the test suite, ignoring errors (that's what the - is for) so that
    # failing tests still genreate a report
	- cd $(ARTIFACTS_PATH)/$(TEST_MODULE_PATH)/unittest && \
		$(ABS_BUILD_PATH)/$(TEST_MODULE_PATH)/$(TEST_MODULE)_test -k $(TEST_MODULE) -ojunit
  
    # Create the test report
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE_PATH)/unittest && \
		junit2html --merge $(TEST_MODULE).xml *.xml && \
		junit2html $(TEST_MODULE).xml index.html

    # TODO: Add support for transforming the xml test results into
    #       Jira/Xray JSON format for automatic upload

    # Update the incremental code coverage
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE_PATH)/coverage && \
		lcov -c -d --rc branch_coverage=1 $(ABS_BUILD_PATH)/$(TEST_MODULE_PATH)/src -o $(TEST_MODULE).info

    # Create the code coverage report
	cd $(ARTIFACTS_PATH)/$(TEST_MODULE_PATH)/coverage && \
		genhtml --rc branch_coverage=1 -o . *.info && \
	    rm *.info

# ----------------------------------------------------------------------------
