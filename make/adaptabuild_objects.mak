# ----------------------------------------------------------------------------
# module_objects.mak - support for building the objects infor a module
#
# ----------------------------------------------------------------------------
# Add the $(MODULE)_ prefix to create a unique INCPATH for this module
# at build time

$(MODULE)_INCPATH := $(addprefix -I $(SRC_PATH)/,$($(MODULE)_INCPATH))

# This is a rule to build an object file from a .c file - we take advantage
# of make's ability to create variables for each object file at build time to
# set up the INCPATH and CDEFS, the CFLAGS are set at the library_objects.mak
# level,
#
# If you need to create an object file from some other input file type then
# create another code block like this with the correct object and source suffixes
# and modufy the build command as needed.

####### NOTE: The -MD and -MP flags should be system level defined - just here for testing!
# See https://www.cmcrossroads.com/article/tips-and-tricks-automatic-dependency-generation-masters
# for the thinking behind this!

$(OBJ_PATH)/$(MODULE_PATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: CDEFS   := $(CDEFS) $($(MODULE)_CDEFS) $(local_cdefs)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: $(SRC_PATH)/$(MODULE_PATH)/%.c
	@echo Building $@ from $(SRC_PATH)/$(MODULE_PATH)/$*.c
	$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) -MP -MD -o $(@D)/$(*F).o $<

$(OBJ_PATH)/$(MODULE_PATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: CDEFS   := $(CDEFS) $($(MODULE)_CDEFS) $(local_cdefs)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: $(SRC_PATH)/$(MODULE_PATH)/%.s
	@echo Building $@ from $(SRC_PATH)/$(MODULE_PATH)/$*.s
	$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) -MP -MD -o $(@D)/$(*F).o $<

$(OBJ_PATH)/$(MODULE_PATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: CDEFS   := $(CDEFS) $($(MODULE)_CDEFS) $(local_cdefs)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: $(SRC_PATH)/$(MODULE_PATH)/%.S
	@echo Building $@ from $<
	$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) -MP -MD -o $(@D)/$(*F).o $<

# Special handling for _OPT3 objects ...

$(OBJ_PATH)/$(MODULE_PATH)/%.o_opt3: INCPATH := $($(MODULE)_INCPATH)
$(OBJ_PATH)/$(MODULE_PATH)/%.o_opt3: CDEFS   := $(CDEFS) $($(MODULE)_CDEFS) $(local_cdefs)
$(OBJ_PATH)/$(MODULE_PATH)/%.o_opt3: $(SRC_PATH)/$(MODULE_PATH)/%.c
	@echo Building $@ from $(SRC_PATH)/$(MODULE_PATH)/$*.c
	$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) -MP -MD -o $(@D)/$(*F).o_opt3 $<

# ----------------------------------------------------------------------------	
