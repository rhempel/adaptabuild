# ----------------------------------------------------------------------------
# objects.mak - support for building the objects infor a module
#
# ----------------------------------------------------------------------------
# Add the $(MODULE)_ prefix to create unique compiler flags for this module
# at build time

$(info  MODULE_INCPATH is $($(MODULE)_INCPATH))

$(MODULE)_INCPATH := $(addprefix -I ,$($(MODULE)_INCPATH))

$(info  MODULE_INCPATH is $($(MODULE)_INCPATH))

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

$(info  27 src_path/module_path is $(SRC_PATH)/$(MODULE_PATH))
$(info  28 obj_path/module_path is $(OBJ_PATH)/$(MODULE_PATH))

$(OBJ_PATH)/$(MODULE_PATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: $(SRC_PATH)/$(MODULE_PATH)/%.c
	@echo Building $@ from $<
	$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) -o $@ $<

$(OBJ_PATH)/$(MODULE_PATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: $(SRC_PATH)/$(MODULE_PATH)/%.s
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) -o $@ $<

$(OBJ_PATH)/$(MODULE_PATH)/%.o: INCPATH := $($(MODULE)_INCPATH)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: CDEFS   := $($(MODULE)_CDEFS)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: CFLAGS  := $($(MODULE)_CFLAGS)
$(OBJ_PATH)/$(MODULE_PATH)/%.o: $(SRC_PATH)/$(MODULE_PATH)/%.S
	@echo Building $@ from $<
	@$(CC) -c $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) -o $@ $<

# Special handling for _OPT3 objects ...

$(OBJ_PATH)/$(MODULE_PATH)/%.o_opt3: INCPATH := $($(MODULE)_INCPATH)
$(OBJ_PATH)/$(MODULE_PATH)/%.o_opt3: CDEFS   := $($(MODULE)_CDEFS)
$(OBJ_PATH)/$(MODULE_PATH)/%.o_opt3: CFLAGS  := $($(MODULE)_CFLAGS)
$(OBJ_PATH)/$(MODULE_PATH)/%.o_opt3: $(SRC_PATH)/$(MODULE_PATH)/%.c
	@echo Building $@ from $<
	@$(CC) -c -o3 $(CDEFS) $(INCPATH) $(CFLAGS) $(DEPFLAGS) -o $@ $<

# ----------------------------------------------------------------------------	
