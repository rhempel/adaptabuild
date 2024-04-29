# ----------------------------------------------------------------------------
# objects.mak - support for building the objects infor a module
#
# Note that objects.mak may be included multiple times - for example
# when creating objects with code coverage support we will need certain
# CFLAGS to be defined.
# ----------------------------------------------------------------------------
# Add the $(MODULE)_ prefix to create unique compiler flags for this module
# at build time

$(call log_debug,$(MODULE)_INCPATH is $($(MODULE)_INCPATH))
$(call log_debug,LIBC_INCPATH is $(LIBC_INCPATH))
$(MODULE)_INCPATH := $(addprefix -I $(SRC_PATH)/,$($(MODULE)_INCPATH) $(LIBC_INCPATH))
$(call log_debug,$(MODULE)_INCPATH is $($(MODULE)_INCPATH))

$(MODULE)_CDEFS := $(addprefix -D ,$($(MODULE)_CDEFS) $(CDEFS))
$(call log_debug,$(MODULE)_CDEFS is $($(MODULE)_CDEFS))

$(MODULE)_CFLAGS := $($(MODULE)_CFLAGS) $(CFLAGS)
$(call log_debug,$(MODULE)_CFLAGS is $($(MODULE)_CFLAGS))

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

TARGET_STEM := $(BUILD_PATH)/$(MODULE_PATH)
# $(info TARGET_STEM is $(TARGET_STEM))

PREREQ_STEM := $(SRC_PATH)/$(MODULE_PATH)
# $(info PREREQ_STEM is $(PREREQ_STEM))

# These are the target specific variables, and when the same target can
# be built from multiple dependencies, only the LAST set of target specific
# variables is used. Therefore we define the target specific build variables
# here in the same block.
#
# Note that the target stem is ALWAYS the same: $(TARGET_STEM)/%.o

$(TARGET_STEM)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(TARGET_STEM)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$(TARGET_STEM)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)

# And now we can define the recipies for the different suffixes [cCsS]

$(TARGET_STEM)/%.o: $(PREREQ_STEM)/%.c
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COVFLAGS) -o $@ $<

$(TARGET_STEM)/%.o: $(PREREQ_STEM)/%.cpp
	@echo Building $@ from $<
	@$(CXX) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COVFLAGS) -o $@ $<

$(TARGET_STEM)/%.o: $(PREREQ_STEM)/%.C
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COVFLAGS) -o $@ $<

$(TARGET_STEM)/%.o: $(PREREQ_STEM)/%.s
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COVFLAGS) -o $@ $<

$(TARGET_STEM)/%.o: $(PREREQ_STEM)/%.S
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COVFLAGS) -o $@ $<

# Special handling for _OPT3 objects ... the target stem is different than
# the previous set so it can have its own target specific variables.

# $(TARGET_STEM)/%.o_opt3: INCPATH := $($(MODULE)_INCPATH)
$(TARGET_STEM)/%.o_opt3: CDEFS   := $($(MODULE)_CDEFS)
$(TARGET_STEM)/%.o_opt3: CFLAGS  := $($(MODULE)_CFLAGS)
$(TARGET_STEM)/%.o_opt3: $(PREREQ_STEM)/%.c
	@echo Building $@ from $<
	@$(CC) -c -o3 $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) $(COVFLAGS) -o $@ $<

# ----------------------------------------------------------------------------
