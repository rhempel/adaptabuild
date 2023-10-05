# ----------------------------------------------------------------------------
# objects.mak - support for building the objects infor a module
#
# Note that objects.mak may be included multiple times - for example
# when creating objects with code coverage support we will need certain
# CFLAGS to be defined.
# ----------------------------------------------------------------------------
# Add the $(MODULE)_ prefix to create unique compiler flags for this module
# at build time

ifeq (unittest,$(MAKECMDGOALS))
  COVFLAGS := -ftest-coverage -fprofile-arcs
else
endif

$(MODULE)_INCPATH := $(addprefix -I ,$($(MODULE)_INCPATH))

$(MODULE)_CDEFS := $(addprefix -D ,$($(MODULE)_CDEFS) $(CDEFS))

$(MODULE)_CFLAGS := $($(MODULE)_CFLAGS) $(CFLAGS)

# This is a rule to build an object file from a .c file - we take advantage
# of make's ability to create variables for each object file at build time to
# set up the INCPATH and CDEFS, the CFLAGS are set at the library_objects.mak
# level,
#
# If you need to create an object file from some other input file type then
# create another code block like this with the correct object and source suffixes
# and modufy the build command as needed.

$(BUILD_PATH)/$(MODULE_PATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(BUILD_PATH)/$(MODULE_PATH)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$(BUILD_PATH)/$(MODULE_PATH)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$(BUILD_PATH)/$(MODULE_PATH)/%.o: $(SRC_PATH)/$(MODULE_PATH)/%.c
	@echo Building $@ from $<
	$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COVFLAGS) -o $@ $<

$(BUILD_PATH)/$(MODULE_PATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(BUILD_PATH)/$(MODULE_PATH)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$(BUILD_PATH)/$(MODULE_PATH)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$(BUILD_PATH)/$(MODULE_PATH)/%.o: $(SRC_PATH)/$(MODULE_PATH)/%.C
	@echo Building $@ from $<
	$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COVFLAGS) -o $@ $<

$(BUILD_PATH)/$(MODULE_PATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(BUILD_PATH)/$(MODULE_PATH)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$(BUILD_PATH)/$(MODULE_PATH)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$(BUILD_PATH)/$(MODULE_PATH)/%.o: $(SRC_PATH)/$(MODULE_PATH)/%.s
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COV_FLAGS) -o $@ $<

$(BUILD_PATH)/$(MODULE_PATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(BUILD_PATH)/$(MODULE_PATH)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$(BUILD_PATH)/$(MODULE_PATH)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$(BUILD_PATH)/$(MODULE_PATH)/%.o: $(SRC_PATH)/$(MODULE_PATH)/%.S
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COV_FLAGS) -o $@ $<

# Special handling for _OPT3 objects ...

$(BUILD_PATH)/$(MODULE_PATH)/%.o_opt3: INCPATH := $($(MODULE)_INCPATH)
$(BUILD_PATH)/$(MODULE_PATH)/%.o_opt3: CDEFS   := $($(MODULE)_CDEFS)
$(BUILD_PATH)/$(MODULE_PATH)/%.o_opt3: CFLAGS  := $($(MODULE)_CFLAGS)
$(BUILD_PATH)/$(MODULE_PATH)/%.o_opt3: $(SRC_PATH)/$(MODULE_PATH)/%.c
	@echo Building $@ from $<
	@$(CC) -c -o3 $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COV_FLAGS) -o $@ $<

# Special support for building test sources with different flags

$($(MODULE)_TEST_BUILDPATH)/%.o: INCPATH := $($(MODULE)_INCPATH) -I/usr/include/CppUTest -I/usr/include/CppUTestExt
$($(MODULE)_TEST_BUILDPATH)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$($(MODULE)_TEST_BUILDPATH)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$($(MODULE)_TEST_BUILDPATH)/%.o: $($(MODULE)_TEST_SRCPATH)/%.c
	@echo Building $@ from $<
	$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) -o $@ $<

# ----------------------------------------------------------------------------
