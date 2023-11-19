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

$(MODULE)_INCPATH := $(addprefix -I $(ROOT_PATH)/$(SRC_PATH)/,$($(MODULE)_INCPATH))
# $(info $(MODULE)_INCPATH is $($(MODULE)_INCPATH))

$(MODULE)_CDEFS := $(addprefix -D ,$($(MODULE)_CDEFS) $(CDEFS))
# $(info $(MODULE)_CDEFS is $($(MODULE)_CDEFS))

$(MODULE)_CFLAGS := $($(MODULE)_CFLAGS) $(CFLAGS)
# $(info $(MODULE)_CFLAGS is $($(MODULE)_CFLAGS))

# This is a rule to build an object file from a .c file - we take advantage
# of make's ability to create variables for each object file at build time to
# set up the INCPATH and CDEFS, the CFLAGS are set at the library_objects.mak
# level,
#
# If you need to create an object file from some other input file type then
# create another code block like this with the correct object and source suffixes
# and modify the build command as needed.
#
# The rules below rely on the concept of stems - these are the paths in
# front of the base target and dependency names that make uses to figure
# out how to build a file.
#
# For example:
#
# path/to/build/output/foo.o
# some/other/path/to/src/foo.c
#
# We could rewrite this as follows:
#
# TARGET_STEM := path/to/build/output
# PREREQ_STEM := some/other/path/to/src
# 
# $(TARGET_STEM)/foo.o
# $(PREREQ_STEM)/foo.c
#----------------------------------------------------------------------------

TARGET_STEM := $(ROOT_PATH)/$(BUILD_PATH)/$(MODULE_PATH)
# $(info TARGET_STEM is $(TARGET_STEM))

PREREQ_STEM := $(ROOT_PATH)/$(SRC_PATH)/$(MODULE_PATH)
# $(info PREREQ_STEM is $(PREREQ_STEM))

$(TARGET_STEM)/%.o: INCPATH := $($(MODULE)_INCPATH) 
$(TARGET_STEM)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$(TARGET_STEM)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$(TARGET_STEM)/%.o: $(PREREQ_STEM)/%.c
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COVFLAGS) -o $@ $<

$(TARGET_STEM)/%.o: INCPATH := $($(MODULE)_INCPATH) 
$(TARGET_STEM)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$(TARGET_STEM)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$(TARGET_STEM)/%.o: $(PREREQ_STEM)/%.C
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COVFLAGS) -o $@ $<

$(TARGET_STEM)/%.o: INCPATH := $($(MODULE)_INCPATH) 
$(TARGET_STEM)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$(TARGET_STEM)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$(TARGET_STEM)/%.o: $(PREREQ_STEM)/%.s
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COV_FLAGS) -o $@ $<

$(TARGET_STEM)/%.o: INCPATH := $($(MODULE)_INCPATH) 
$(TARGET_STEM)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$(TARGET_STEM)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$(TARGET_STEM)/%.o: $(PREREQ_STEM)/%.S
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COV_FLAGS) -o $@ $<

# Special handling for _OPT3 objects ...

$(TARGET_STEM)/%.o_opt3: INCPATH := $($(MODULE)_INCPATH)
$(TARGET_STEM)/%.o_opt3: CDEFS   := $($(MODULE)_CDEFS)
$(TARGET_STEM)/%.o_opt3: CFLAGS  := $($(MODULE)_CFLAGS)
$(TARGET_STEM)/%.o_opt3: $(PREREQ_STEM)/%.c
	@echo Building $@ from $<
	@$(CC) -c -o3 $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COV_FLAGS) -o $@ $<

# Special support for building test sources with different flags

$($(MODULE)_TEST_BUILDPATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$($(MODULE)_TEST_BUILDPATH)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$($(MODULE)_TEST_BUILDPATH)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$($(MODULE)_TEST_BUILDPATH)/%.o: $($(MODULE)_TEST_SRCPATH)/%.c
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) -o $@ $<

# ----------------------------------------------------------------------------
