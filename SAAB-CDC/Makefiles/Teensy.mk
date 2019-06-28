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
# Last update: Nov 20, 2016 release 5.3.9






# Teensy specifics
# ----------------------------------
#
ifeq ($(BOARD_TAG),glowdeck)
    PLATFORM         := Glowdeck
    APPLICATION_PATH := $(GLOWDECK_PATH)
else
    PLATFORM         := Teensy
    APPLICATION_PATH := $(TEENSY_PATH)
endif
PLATFORM_TAG      = ARDUINO=10801 TEENSY_CORE EMBEDXCODE=$(RELEASE_NOW)

t001 = $(APPLICATION_PATH)/lib/teensyduino.txt
t002 = $(APPLICATION_PATH)/lib/version.txt
TEENSY_VERSION = $(shell if [ -f $(t001) ] ; then cat $(t001) ; fi)
MODIFIED_ARDUINO_VERSION =  $(shell if [ -f $(t002) ] ; then cat $(t002) ; fi)
ifneq ($(TEENSY_VERSION),1.25)
    INFORMATION_MESSAGE = Teensyduino release 1.25 required.
endif
PLATFORM_VERSION := $(TEENSY_VERSION) for Arduino $(MODIFIED_ARDUINO_VERSION)

# Automatic Teensy2 or Teensy 3 selection based on build.core
#
BOARDS_TXT      := $(APPLICATION_PATH)/hardware/teensy/avr/boards.txt
BUILD_SUBCORE    = $(call PARSE_BOARD,$(BOARD_TAG),build.core)
#$(info BUILD_SUBCORE $(BUILD_SUBCORE))

DFLAGS = $(call PARSE_BOARD,$(BOARD_TAG),build.flags.defs)

ifeq ($(BUILD_SUBCORE),teensy)
    include $(MAKEFILE_PATH)/Teensy2.mk
else ifeq ($(BUILD_SUBCORE),teensy3)
    include $(MAKEFILE_PATH)/Teensy3.mk
else ifeq ($(BUILD_SUBCORE),glowdeck)
    include $(MAKEFILE_PATH)/Teensy3.mk
else
    $(error $(BUILD_SUBCORE) unknown) 
endif

# One single location for Teensyduino application libraries
# $(APPLICATION_PATH)/libraries aren't compatible
#
#APP_LIB_PATH = $(APPLICATION_PATH)/hardware/teensy/avr/libraries
APP_LIB_PATH     := $(APPLICATION_PATH)/hardware/teensy/avr/libraries

a1000    = $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%,$(APP_LIBS_LIST)))
a1000   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/utility,$(APP_LIBS_LIST)))
a1000   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src,$(APP_LIBS_LIST)))
a1000   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src/utility,$(APP_LIBS_LIST)))
a1000   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src/arch/$(BUILD_SUBCORE),$(APP_LIBS_LIST)))
a1000   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src/$(BUILD_SUBCORE),$(APP_LIBS_LIST)))

APP_LIB_CPP_SRC = $(foreach dir,$(a1000),$(wildcard $(dir)/*.cpp)) # */
APP_LIB_C_SRC   = $(foreach dir,$(a1000),$(wildcard $(dir)/*.c)) # */
APP_LIB_H_SRC   = $(foreach dir,$(a1000),$(wildcard $(dir)/*.h)) # */

APP_LIB_OBJS     = $(patsubst $(APPLICATION_PATH)/%.cpp,$(OBJDIR)/%.cpp.o,$(APP_LIB_CPP_SRC))
APP_LIB_OBJS    += $(patsubst $(APPLICATION_PATH)/%.c,$(OBJDIR)/%.c.o,$(APP_LIB_C_SRC))

BUILD_APP_LIBS_LIST = $(subst $(BUILD_APP_LIB_PATH)/, ,$(APP_LIB_CPP_SRC))

# ~
# Teensy USB kind, layout, PID and VID
#
ifndef TEENSY_USB
    TEENSY_USB    = USB_SERIAL
endif
ifndef TEENSY_LAYOUT
    TEENSY_LAYOUT = LAYOUT_US_ENGLISH
endif
# ~~

USB_VID   := $(call PARSE_BOARD,$(BOARD_TAG),build.vid)
USB_PID   := $(call PARSE_BOARD,$(BOARD_TAG),build.pid)

ifneq ($(USB_PID),)
ifneq ($(USB_VID),)
    USB_FLAGS  = -DUSB_VID=$(USB_VID)
    USB_FLAGS += -DUSB_PID=$(USB_PID)
endif
endif

ifeq ($(USB_FLAGS),)
    USB_FLAGS = -DUSB_VID=null -DUSB_PID=null
endif

# ~
USB_FLAGS += $(addprefix -D,$(TEENSY_USB) $(TEENSY_LAYOUT))
# ~~

MAX_RAM_SIZE = $(call PARSE_BOARD,$(BOARD_TAG),upload.maximum_ram_size)

# Specific OBJCOPYFLAGS for objcopy only
# objcopy uses OBJCOPYFLAGS only
#
OBJCOPYFLAGS  = -R .eeprom -Oihex

# Target
#
TARGET_HEXBIN    = $(TARGET_HEX)
#TARGET_EEP    = $(OBJDIR)/$(TARGET).eep
TARGET_EEP       = $(TARGET_BIN)
COMMAND_COPY     = $(OBJCOPY) -O binary -R .eeprom $< $@


# Link command
#
COMMAND_LINK     = $(QUIET)$(CXX) $(OUT_PREPOSITION)$@ $(LOCAL_OBJS) $(LOCAL_ARCHIVES) $(TARGET_A) $(LDFLAGS)


