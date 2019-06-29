#
# embedXcode
# ----------------------------------
# Embedded Computing on Xcode
#
# Copyright © Rei VILO, 2010-2017
# http://embedxcode.weebly.com
# All rights reserved
#
#
# Last update: Jan 06, 2016 release 6.0.2






# Teensy 3.x and Glowdeck specifics
# ----------------------------------
#
BUILD_CORE      := arm

t400             = $(call PARSE_BOARD,$(BOARD_TAG),upload.tool)
# upload.tool gives teensyloader or GlowdeckUp instead of teensy_flash or glowdeck_flash
ifeq ($(t400),teensyloader)
    UPLOADER            = teensy_flash
    TEENSY_FLASH_PATH   = $(APPLICATION_PATH)/hardware/tools
    TEENSY_POST_COMPILE = $(TEENSY_FLASH_PATH)/teensy_post_compile
    TEENSY_REBOOT       = $(TEENSY_FLASH_PATH)/teensy_reboot

else ifeq ($(t400),GlowdeckUp)
    ifeq ($(UPLOADER),glowdeck_bluetooth)
        UPLOADER            = glowdeck_bluetooth
        UPLOADER_PATH       = $(APPLICATIONS_PATH)
        UPLOADER_EXEC       = $(UPLOADER_PATH)/Glowdeck.app
        UPLOADER_PORT       =
        UPLOADER_OPTS       =
        COMMAND_UPLOAD      = open $(UPLOADER_EXEC) --args $(CURRENT_DIR)/$(TARGET_BIN)

    else ifeq ($(UPLOADER),jlink)
        UPLOADER         = jlink
        UPLOADER_PATH    = $(APPLICATIONS_PATH)/SEGGER/JLink
        UPLOADER_EXEC    = $(UPLOADER_PATH)/JLinkExe
        SHARED_OPTS      = -device mk20dx256xxx7 -speed 100 -if jtag -jtagconf -1,-1
        UPLOADER_OPTS    = $(SHARED_OPTS) -commanderscript Utilities/upload.jlink
        COMMAND_UPLOAD   = $(UPLOADER_EXEC) $(UPLOADER_OPTS)
        COMMAND_PREPARE  = printf '\nhalt\nr\nunlock kinetis\nerase\nloadfile Builds/embeddedcomputing.bin,0x4000\ng\nexit\n' > Utilities/upload.jlink ;
        DEBUG_SERVER_PATH = $(APPLICATIONS_PATH)/SEGGER/JLink
        DEBUG_SERVER_EXEC = $(DEBUG_SERVER_PATH)/JLinkGDBServer
        DEBUG_SERVER_OPTS = $(SHARED_OPTS)

    else
        UPLOADER            = glowdeck_usb
        UPLOADER_PATH       = $(APPLICATION_PATH)/hardware/tools
        UPLOADER_EXEC       = $(UPLOADER_PATH)/Glowdeck.sh
        UPLOADER_PORT       =
        UPLOADER_OPTS       =
#        COMMAND_UPLOAD      = $(UPLOADER_EXEC) $(TARGET_BIN)
 		COMMAND_UPLOAD      = osascript -e 'tell application "Terminal" to do script "$(UPLOADER_EXEC) $(TARGET_BIN)"' -e 'tell application "Terminal" to activate'

    endif

# Adding required EEPROM library for dfu_mode()
# Not the cleanest implementation
    ifeq ($(APP_LIBS_LIST),)

    else ifeq ($(APP_LIBS_LIST),0)
        APP_LIBS_LIST = EEPROM
    else
        APP_LIBS_LIST += EEPROM
    endif
endif

APP_TOOLS_PATH   := $(APPLICATION_PATH)/hardware/tools/arm/bin
CORE_LIB_PATH    := $(APPLICATION_PATH)/hardware/teensy/avr/cores/$(BUILD_SUBCORE)
#APP_LIB_PATH     := $(APPLICATION_PATH)/hardware/teensy/avr/libraries

# Add .S files required by Teensyduino 1.21
#
CORE_AS_SRCS    = $(filter-out %main.cpp, $(wildcard $(CORE_LIB_PATH)/*.S)) # */
t001            = $(patsubst %.S,%.S.o,$(filter %S, $(CORE_AS_SRCS)))
FIRST_O_IN_A    = $(patsubst $(APPLICATION_PATH)/%,$(OBJDIR)/%,$(t001))

BUILD_CORE_LIB_PATH  = $(APPLICATION_PATH)/hardware/teensy/avr/cores/$(BUILD_SUBCORE)
BUILD_CORE_LIBS_LIST = $(subst .h,,$(subst $(BUILD_CORE_LIB_PATH)/,,$(wildcard $(BUILD_CORE_LIB_PATH)/*/*.h))) # */
BUILD_CORE_C_SRCS    = $(wildcard $(BUILD_CORE_LIB_PATH)/*.c) # */

BUILD_CORE_CPP_SRCS  = $(filter-out %program.cpp %main.cpp,$(wildcard $(BUILD_CORE_LIB_PATH)/*.cpp)) # */

BUILD_CORE_OBJ_FILES = $(BUILD_CORE_C_SRCS:.c=.c.o) $(BUILD_CORE_CPP_SRCS:.cpp=.cpp.o)
BUILD_CORE_OBJS      = $(patsubst $(APPLICATION_PATH)/%,$(OBJDIR)/%,$(BUILD_CORE_OBJ_FILES))


# Sketchbook/Libraries path
# wildcard required for ~ management
# ?ibraries required for libraries and Libraries
#
ifeq ($(USER_LIBRARY_DIR)/Arduino15/preferences.txt,)
    $(error Error: run Teensy once and define the sketchbook path)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    SKETCHBOOK_DIR = $(shell grep sketchbook.path $(wildcard ~/Library/Arduino15/preferences.txt) | cut -d = -f 2)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    $(error Error: sketchbook path not found)
endif

USER_LIB_PATH  = $(wildcard $(SKETCHBOOK_DIR)/?ibraries)


# Rules for making a c++ file from the main sketch (.pde)
#
PDEHEADER      = \\\#include \"WProgram.h\"  


# Tool-chain names
#
CC      = $(APP_TOOLS_PATH)/arm-none-eabi-gcc
CXX     = $(APP_TOOLS_PATH)/arm-none-eabi-g++
AR      = $(APP_TOOLS_PATH)/arm-none-eabi-ar
OBJDUMP = $(APP_TOOLS_PATH)/arm-none-eabi-objdump
OBJCOPY = $(APP_TOOLS_PATH)/arm-none-eabi-objcopy
SIZE    = $(APP_TOOLS_PATH)/arm-none-eabi-size
NM      = $(APP_TOOLS_PATH)/arm-none-eabi-nm


LDSCRIPT        = $(call PARSE_BOARD,$(BOARD_TAG),build.linkscript)
MCU_FLAG_NAME   = mpcu
MCU             = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)

ifndef TEENSY_F_CPU
    ifeq ($(BOARD_TAG),teensyLC)
        TEENSY_F_CPU = 48000000
    else ifeq ($(BOARD_TAG),teensy36)
        TEENSY_F_CPU = 180000000
    else ifeq ($(BOARD_TAG),teensy35)
        TEENSY_F_CPU = 120000000
    else
        TEENSY_F_CPU = 96000000
    endif
endif
F_CPU           = $(TEENSY_F_CPU)

ifndef TEENSY_OPTIMISATION
    TEENSY_OPTIMISATION = $(call PARSE_BOARD,$(BOARD_TAG),build.flags.optimize)
endif
OPTIMISATION    = $(TEENSY_OPTIMISATION)


# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = $(OPTIMISATION) $(WARNING_FLAGS)
CPPFLAGS    += $(call PARSE_BOARD,$(BOARD_TAG),build.flags.cpu) -DF_CPU=$(F_CPU)
CPPFLAGS    += $(call PARSE_BOARD,$(BOARD_TAG),build.flags.defs)
CPPFLAGS    += $(call PARSE_BOARD,$(BOARD_TAG),build.flags.common)
CPPFLAGS    += $(addprefix -D, $(PLATFORM_TAG)) $(DFLAGS)
CPPFLAGS    += -I$(CORE_LIB_PATH) -I$(VARIANT_PATH) -I$(OBJDIR)

# Specific CFLAGS for gcc only
# gcc uses CPPFLAGS and CFLAGS
#
CFLAGS       = $(call PARSE_BOARD,$(BOARD_TAG),build.flags.c)

# Specific CXXFLAGS for g++ only
# g++ uses CPPFLAGS and CXXFLAGS
#
CXXFLAGS     = $(call PARSE_BOARD,$(BOARD_TAG),build.flags.cpp)

# Specific ASFLAGS for gcc assembler only
# gcc assembler uses CPPFLAGS and ASFLAGS
#
ASFLAGS      = $(call PARSE_BOARD,$(BOARD_TAG),build.flags.S)

# Specific LDFLAGS for linker only
# linker uses CPPFLAGS and LDFLAGS
#
t401         = $(call PARSE_BOARD,$(BOARD_TAG),build.flags.ld)
t402         = $(subst {build.core.path},$(CORE_LIB_PATH),$(t401))
t403         = $(subst {extra.time.local},$(shell date +%s),$(t402))
LDFLAGS      = $(subst ", ,$(t403))
LDFLAGS     += $(call PARSE_BOARD,$(BOARD_TAG),build.flags.cpu)
#LDFLAGS     += $(OPTIMISATION) $(call PARSE_BOARD,$(BOARD_TAG),build.flags.ldspecs)
LDFLAGS     += $(OPTIMISATION) --specs=nano.specs
LDFLAGS     += $(call PARSE_BOARD,$(BOARD_TAG),build.flags.libs)
