# ----------------------------------------------------------------------------
# module_objects.mak - support for building the objects for a module
#
# This file is included at the end of every module level adaptabuild.mak
# file, like this:
#
#   include adaptabuild/make/module_objects.mak
#   include adaptabuild/make/module_library.mak
#
# ----------------------------------------------------------------------------
# Add the $(MODULE)_ prefix to create a unique INCPATH for this module
# at build time

$(MODULE)_INCPATH := $(addprefix -I $(SRC_PATH)/,$($(MODULE)_INCPATH))

# This is the rule to build an object file from a .c file - we take advantage
# of make's ability to create variables for each object file at build time to
# set up the INCPATH and CDEFS, the CFLAGS are set at the library_obkects.mak
# level,
#
# If you need to create an object file from some other input file type then
# create another code block like this with the correct object and source suffixes
# and modufy the build command as needed.

$(OBJ_PATH)/$(MODULE_PATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: CDEFS   := $(CDEFS) $($(MODULE)_CDEFS) $(local_cdefs)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: $(SRC_PATH)/$(MODULE_PATH)/%.c
	@echo Building $@ from $<
	@$(CC) $(CDEFS) -c $(INCPATH) $(CFLAGS) $< -o $@

# For example, here we are compiling the files in $(SRC_C_OPT3) with
# a special flag ... see module_library.mak for more details.

$(OBJ_PATH)/$(MODULE_PATH)/%.o.opt3: INCPATH := $($(MODULE)_INCPATH)
$(OBJ_PATH)/$(MODULE_PATH)/%.o.opt3: CDEFS   := $(CDEFS) $($(MODULE)_CDEFS) $(local_cdefs)
$(OBJ_PATH)/$(MODULE_PATH)/%.o.opt3: CFLAGS  := $(CFLAGS) -o3
$(OBJ_PATH)/$(MODULE_PATH)/%.o.opt3: $(SRC_PATH)/$(MODULE_PATH)/%.c
	@echo Building $@ from $<
	@$(CC) $(CDEFS) -c $(INCPATH) $(CFLAGS) $< -o $@

# And here we build objects from assembler source

$(OBJ_PATH)/$(MODULE_PATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: CDEFS   := $(CDEFS) $(local_cdefs)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: $(SRC_PATH)/$(MODULE_PATH)/%.s
	@echo Building $@ from $<
	$(CC) $(CDEFS) -D __ASSEMBLY__ -c $(INCPATH) $(CFLAGS) $< -o $@

# ----------------------------------------------------------------------------	
