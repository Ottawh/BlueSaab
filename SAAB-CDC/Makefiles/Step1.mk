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
# Last update: Jan 26, 2016 release 6.1.2






# Sketch unicity test and extension
# ----------------------------------
#
ifndef SKETCH_EXTENSION
    ifeq ($(words $(wildcard *.pde) $(wildcard *.ino)), 0)
        $(error No pde or ino sketch)
    endif

    ifneq ($(words $(wildcard *.pde) $(wildcard *.ino)), 1)
        $(error More than 1 pde or ino sketch)
    endif

    ifneq ($(wildcard *.pde),)
        SKETCH_EXTENSION := pde
    else ifneq ($(wildcard *.ino),)
        SKETCH_EXTENSION := ino
    else
        $(error Extension error)
    endif
endif

ifneq ($(MULTI_INO),1)
ifneq ($(SKETCH_EXTENSION),__main_cpp_only__)
    ifneq ($(SKETCH_EXTENSION),_main_cpp_only_)
        ifneq ($(SKETCH_EXTENSION),cpp)
            ifeq ($(words $(wildcard *.$(SKETCH_EXTENSION))), 0)
                $(error No $(SKETCH_EXTENSION) sketch)
            endif

            ifneq ($(words $(wildcard *.$(SKETCH_EXTENSION))), 1)
                $(error More than one $(SKETCH_EXTENSION) sketch)
            endif
        endif
    endif
endif
endif


# Board selection
# ----------------------------------
# Board specifics defined in .xconfig file
# BOARD_TAG and AVRDUDE_PORT 
#
ifneq ($(MAKECMDGOALS),boards)
    ifneq ($(MAKECMDGOALS),clean)
        ifndef BOARD_TAG
            $(error BOARD_TAG not defined)
        endif
    endif
endif

ifndef BOARD_PORT
    BOARD_PORT = /dev/tty.usb*
endif


# Path to applications folder
#
# $(HOME) same as $(wildcard ~)
# $(USER_PATH)/Library same as $(USER_LIBRARY_DIR)
#
USER_PATH      := $(HOME)
EMBEDXCODE_APP  = $(USER_LIBRARY_DIR)/embedXcode
PARAMETERS_TXT  = $(EMBEDXCODE_APP)/parameters.txt

# ~
ifeq ($(USER_LIBRARY_DIR),)
    USER_LIBRARY_DIR = /Users/$(shell echo $$USER)/Library
endif

ifndef APPLICATIONS_PATH
    ifneq ($(wildcard $(PARAMETERS_TXT)),)
        ap1 = $(shell grep ^applications.path '$(PARAMETERS_TXT)' | cut -d = -f 2-;)
        ifneq ($(ap1),)
            APPLICATIONS_PATH = $(ap1)
        endif
    endif
endif

ifndef APPLICATIONS_PATH
    APPLICATIONS_PATH = /Applications
endif
# ~~


# APPlications full paths
# ----------------------------------
#
# Welcome unified 1.8.0 release for all Arduino.CC and Genuino, Arduino.ORG boards!
#
ifneq ($(wildcard $(APPLICATIONS_PATH)/Arduino.app),)
    ARDUINO_APP   := $(APPLICATIONS_PATH)/Arduino.app
#else ifneq ($(wildcard $(APPLICATIONS_PATH)/ArduinoCC.app),)
#    ARDUINO_APP   := $(APPLICATIONS_PATH)/ArduinoCC.app
#else ifneq ($(wildcard $(APPLICATIONS_PATH)/ArduinoORG.app),)
#    ARDUINO_APP   := $(APPLICATIONS_PATH)/ArduinoORG.app
endif

# Unified Arduino.app 1.8.1 for all Arduino.CC and Genuino, Arduino.ORG boards
#
ifneq ($(wildcard $(APPLICATIONS_PATH)/Arduino.app),)
    ifneq ($(shell grep -e '$(ARDUINO_IDE_RELEASE)' $(APPLICATIONS_PATH)/Arduino.app/Contents/Java/lib/version.txt),)
        ARDUINO_180_APP = $(APPLICATIONS_PATH)/Arduino.app
    endif
endif

# Unified Arduino.app for Arduino.CC and Genuino, Arduino.ORG boards
#
ARDUINO_PATH        := $(ARDUINO_APP)/Contents/Java
ARDUINO_180_PATH    := $(ARDUINO_180_APP)/Contents/Java
#ARDUINO_ORG_PATH    := $(ARDUINO_ORG_APP)/Contents/Java
#ARDUINO_ORG_AVR_BOARDS  = $(ARDUINO_ORG_PATH)/hardware/arduino/avr/boards.txt
#ARDUINO_ORG_SAM_BOARDS  = $(ARDUINO_ORG_PATH)/hardware/arduino/sam/boards.txt
#ARDUINO_ORG_SAMD_BOARDS = $(ARDUINO_ORG_PATH)/hardware/arduino/samd/boards.txt

# Other IDEs
#
ENERGIA_18_APP       = $(APPLICATIONS_PATH)/Energia.app
# ~
WIRING_APP           = $(APPLICATIONS_PATH)/Wiring.app
MAPLE_APP            = $(APPLICATIONS_PATH)/MapleIDE.app
MBED_APP             = $(EMBEDXCODE_APP)/mbed-$(MBED_SDK_RELEASE)
EDISON_YOCTO_APP     = $(EMBEDXCODE_APP)/EdisonYocto
BEAGKE_DEBIAN_APP    = $(EMBEDXCODE_APP)/BeagleBone
ROBOTIS_APP          = $(APPLICATIONS_PATH)/ROBOTIS_OpenCM.app
# ~~

include $(MAKEFILE_PATH)/About.mk
RELEASE_NOW = $(shell echo $(EMBEDXCODE_RELEASE) | sed 's/\.//g')


# Additional boards for Arduino 1.8.0 Boards Manager
# ----------------------------------
# Unified Arduino.app for Arduino.CC and Genuino, Arduino.ORG boards
# Only if ARDUINO_180_APP exists
#

ifneq ($(ARDUINO_180_APP),)

ARDUINO_180_PACKAGES_PATH = $(HOME)/Library/Arduino15/packages

# find $(ARDUINO_180_PACKAGES_PATH) -name arm-none-eabi-gcc -type d
# find $(ARDUINO_180_PACKAGES_PATH) -name avr-gcc -type d


# Arduino path for Arduino 1.8.0
#
ARDUINO_AVR_1 = $(ARDUINO_180_PACKAGES_PATH)/arduino

ifneq ($(wildcard $(ARDUINO_AVR_1)/hardware/avr),)
    ARDUINO_AVR_APP     = $(ARDUINO_AVR_1)
    ARDUINO_AVR_PATH    = $(ARDUINO_AVR_APP)
    ARDUINO_180_AVR_BOARDS  = $(ARDUINO_AVR_APP)/hardware/avr/$(ARDUINO_AVR_RELEASE)/boards.txt
endif

ARDUINO_SAM_1 = $(ARDUINO_180_PACKAGES_PATH)/arduino

ifneq ($(wildcard $(ARDUINO_SAM_1)/hardware/sam),)
    ARDUINO_SAM_APP     = $(ARDUINO_SAM_1)
    ARDUINO_SAM_PATH    = $(ARDUINO_SAM_APP)
    ARDUINO_180_SAM_BOARDS  = $(ARDUINO_SAM_APP)/hardware/sam/$(ARDUINO_SAM_RELEASE)/boards.txt
endif

ARDUINO_SAMD_1 = $(ARDUINO_180_PACKAGES_PATH)/arduino

ifneq ($(wildcard $(ARDUINO_SAMD_1)/hardware/samd),)
    ARDUINO_SAMD_APP     = $(ARDUINO_SAMD_1)
    ARDUINO_SAMD_PATH    = $(ARDUINO_SAMD_APP)
    ARDUINO_180_SAMD_BOARDS  = $(ARDUINO_SAMD_APP)/hardware/samd/$(ARDUINO_SAMD_RELEASE)/boards.txt
endif

# ~
# Adafruit path for Arduino 1.8.0
#
ADAFRUIT_AVR_1  = $(ARDUINO_180_PACKAGES_PATH)/adafruit

ifneq ($(wildcard $(ADAFRUIT_AVR_1)/hardware/avr),)
    ADAFRUIT_AVR_APP     = $(ADAFRUIT_AVR_1)
    ADAFRUIT_AVR_PATH    = $(ADAFRUIT_AVR_APP)
    ADAFRUIT_AVR_BOARDS  = $(ADAFRUIT_AVR_APP)/hardware/avr/$(ADAFRUIT_AVR_RELEASE)/boards.txt
endif
# ~~

# ~
ADAFRUIT_SAMD_1  = $(ARDUINO_180_PACKAGES_PATH)/adafruit

ifneq ($(wildcard $(ADAFRUIT_SAMD_1)/hardware/samd),)
    ADAFRUIT_SAMD_APP     = $(ADAFRUIT_SAMD_1)
    ADAFRUIT_SAMD_PATH    = $(ADAFRUIT_SAMD_APP)
    ADAFRUIT_SAMD_BOARDS  = $(ADAFRUIT_SAMD_APP)/hardware/samd/$(ADAFRUIT_SAMD_RELEASE)/boards.txt
endif
# ~~

# ~
# chipKIT path for Arduino 1.8.0
#
CHIPKIT_1     = $(ARDUINO_180_PACKAGES_PATH)/chipKIT
ifneq ($(wildcard $(CHIPKIT_1)),)
    CHIPKIT_APP     = $(CHIPKIT_1)
    CHIPKIT_PATH    = $(CHIPKIT_APP)
    CHIPKIT_BOARDS  = $(CHIPKIT_APP)/hardware/pic32/$(CHIPKIT_RELEASE)/boards.txt
endif
# ~~

# ~
# RFduino path for Arduino 1.8.0
#
RFDUINO_1    = $(ARDUINO_180_PACKAGES_PATH)/RFduino

ifneq ($(wildcard $(RFDUINO_1)),)
    RFDUINO_APP     = $(RFDUINO_1)
    RFDUINO_PATH    = $(RFDUINO_APP)
    RFDUINO_BOARDS  = $(RFDUINO_APP)/hardware/RFduino/$(RFDUINO_RELEASE)/boards.txt
endif
# ~~

# ~
# Simblee path for Arduino 1.8.0
#
SIMBLEE_1    = $(ARDUINO_180_PACKAGES_PATH)/Simblee

ifneq ($(wildcard $(SIMBLEE_1)),)
    SIMBLEE_APP     = $(SIMBLEE_1)
    SIMBLEE_PATH    = $(SIMBLEE_APP)
    SIMBLEE_BOARDS  = $(SIMBLEE_APP)/hardware/Simblee/$(SIMBLEE_RELEASE)/boards.txt
endif
# ~~

# ~
# TinyCircuits path for Arduino 1.8.0
#
TINYCIRCUITS_1    = $(ARDUINO_180_PACKAGES_PATH)/TinyCircuits

ifneq ($(wildcard $(TINYCIRCUITS_1)),)
    TINYCIRCUITS_APP          = $(TINYCIRCUITS_1)
    TINYCIRCUITS_SAMD_PATH    = $(TINYCIRCUITS_APP)
    TINYCIRCUITS_SAMD_BOARDS  = $(TINYCIRCUITS_APP)/hardware/samd/$(TINYCIRCUITS_SAMD_RELEASE)/boards.txt
endif
# ~~

# ~
# ARDUCAM_ESP path for Arduino 1.8.0
#
ARDUCAM_ESP_1    = $(ARDUINO_180_PACKAGES_PATH)/ArduCAM_ESP8266_UNO

ifneq ($(wildcard $(ARDUCAM_ESP_1)),)
    ARDUCAM_ESP_APP     = $(ARDUCAM_ESP_1)
    ARDUCAM_ESP_PATH    = $(ARDUCAM_ESP_APP)
    ARDUCAM_ESP_BOARDS  = $(ARDUCAM_ESP_APP)/hardware/ArduCAM_ESP8266_UNO/$(ARDUCAM_ESP_RELEASE)/boards.txt
endif
# ~~

# ~
# Moteino path for Arduino 1.8.0
#
MOTEINO_1    = $(ARDUINO_180_PACKAGES_PATH)/Moteino

ifneq ($(wildcard $(MOTEINO_1)),)
    MOTEINO_APP     = $(MOTEINO_1)
    MOTEINO_PATH    = $(MOTEINO_APP)
    MOTEINO_BOARDS  = $(MOTEINO_APP)/hardware/avr/$(MOTEINO_AVR_RELEASE)/boards.txt
endif
# ~~

# ~
# UDOO_NEO path for Arduino 1.6.5
#
UDOO_NEO_1    = $(ARDUINO_180_PACKAGES_PATH)/UDOO

ifneq ($(wildcard $(UDOO_NEO_1)),)
    UDOO_NEO_APP     = $(UDOO_NEO_1)
    UDOO_NEO_PATH    = $(UDOO_NEO_APP)
    UDOO_NEO_BOARDS  = $(UDOO_NEO_APP)/hardware/solox/$(UDOO_NEO_RELEASE)/boards.txt
endif
# ~~

# ~
# Intel path for Arduino 1.8.0
#
INTEL_1    = $(ARDUINO_180_PACKAGES_PATH)/Intel

ifneq ($(wildcard $(INTEL_1)),)
    INTEL_APP     = $(INTEL_1)
    INTEL_PATH    = $(INTEL_APP)
    INTEL_GALILEO_BOARDS  = $(INTEL_APP)/hardware/i586/$(INTEL_GALILEO_RELEASE)/boards.txt
    INTEL_EDISON_BOARDS   = $(INTEL_APP)/hardware/i686/$(INTEL_EDISON_RELEASE)/boards.txt
    INTEL_CURIE_BOARDS    = $(INTEL_APP)/hardware/arc32/$(INTEL_CURIE_RELEASE)/boards.txt
endif
# ~~

# ~
# RedBearLab path for Arduino 1.8.0
#
REDBEARLAB_AVR_1    = $(ARDUINO_180_PACKAGES_PATH)/RedBear
REDBEARLAB_NRF51_1    = $(ARDUINO_180_PACKAGES_PATH)/RedBear

ifneq ($(wildcard $(REDBEARLAB_AVR_1)/hardware/avr),)
    REDBEARLAB_AVR_APP     = $(REDBEARLAB_AVR_1)
    REDBEARLAB_AVR_PATH    = $(REDBEARLAB_AVR_APP)
    REDBEARLAB_AVR_BOARDS  = $(REDBEARLAB_AVR_1)/hardware/avr/$(REDBEAR_AVR_RELEASE)/boards.txt
endif

ifneq ($(wildcard $(REDBEARLAB_NRF51_1)/hardware/nRF51822),)
    REDBEARLAB_NRF51_APP     = $(REDBEARLAB_NRF51_1)
    REDBEARLAB_NRF51_PATH    = $(REDBEARLAB_NRF51_APP)
    REDBEARLAB_NRF51_BOARDS  = $(REDBEARLAB_NRF51_1)/hardware/nRF51822/$(REDBEAR_NRF51_RELEASE)/boards.txt
endif
# ~~

# ~
REDBEARLAB_NRF52_1    = $(ARDUINO_180_PACKAGES_PATH)/RedBear

ifneq ($(wildcard $(REDBEARLAB_NRF52_1)/hardware/nRF52832),)
    REDBEARLAB_NRF52_APP     = $(REDBEARLAB_NRF52_1)
    REDBEARLAB_NRF52_PATH    = $(REDBEARLAB_NRF52_APP)
    REDBEARLAB_NRF52_BOARDS  = $(REDBEARLAB_NRF52_1)/hardware/nRF52832/$(REDBEAR_NRF52_RELEASE)/boards.txt
endif
# ~~

# ~
REDBEARLAB_DUO_1    = $(ARDUINO_180_PACKAGES_PATH)/RedBear

ifneq ($(wildcard $(REDBEARLAB_DUO_1)/hardware/STM32F2),)
    REDBEARLAB_DUO_APP     = $(REDBEARLAB_DUO_1)
    REDBEARLAB_DUO_PATH    = $(REDBEARLAB_DUO_APP)
    REDBEARLAB_DUO_BOARDS  = $(REDBEARLAB_DUO_1)/hardware/STM32F2/$(REDBEAR_DUO_RELEASE)/boards.txt
endif
# ~~

# ~
# DigisparkArduino.app path for Arduino 1.8.0
#
DIGISTUMP_AVR_1 = $(ARDUINO_180_PACKAGES_PATH)/digistump
DIGISTUMP_SAM_1 = $(ARDUINO_180_PACKAGES_PATH)/digistump
DIGISTUMP_OAK_1 = $(ARDUINO_180_PACKAGES_PATH)/digistump

ifneq ($(wildcard $(DIGISTUMP_AVR_1)),)
    DIGISTUMP_AVR_APP    = $(DIGISTUMP_AVR_1)
    DIGISTUMP_AVR_PATH   = $(DIGISTUMP_AVR_APP)
    DIGISTUMP_AVR_BOARDS = $(DIGISTUMP_AVR_APP)/hardware/avr/$(DIGISTUMP_AVR_RELEASE)/boards.txt
endif

ifneq ($(wildcard $(DIGISTUMP_SAM_1)),)
    DIGISTUMP_SAM_APP    = $(DIGISTUMP_SAM_1)
    DIGISTUMP_SAM_PATH   = $(DIGISTUMP_SAM_APP)
    DIGISTUMP_SAM_BOARDS = $(DIGISTUMP_SAM_APP)/hardware/sam/$(DIGISTUMP_SAM_RELEASE)/boards.txt
endif

ifneq ($(wildcard $(DIGISTUMP_OAK_1)/hardware/oak),)
    DIGISTUMP_OAK_APP    = $(DIGISTUMP_OAK_1)
    DIGISTUMP_OAK_PATH   = $(DIGISTUMP_OAK_APP)
    DIGISTUMP_OAK_BOARDS = $(DIGISTUMP_OAK_APP)/hardware/oak/$(DIGISTUMP_OAK_RELEASE)/boards.txt
endif
# ~~

# ESP8266 NodeMCU.app path for Arduino 1.8.0
#
ESP8266_1 = $(ARDUINO_180_PACKAGES_PATH)/esp8266

ifneq ($(wildcard $(ESP8266_1)),)
    ESP8266_APP     = $(ESP8266_1)
    ESP8266_PATH    = $(ESP8266_APP)
    ESP8266_BOARDS  = $(ESP8266_1)/hardware/esp8266/$(ESP8266_RELEASE)/boards.txt
endif

# ~
# LittleRobotFriends.app path for Arduino 1.8.0
#
LITTLEROBOTFRIENDS_1 = $(ARDUINO_180_PACKAGES_PATH)/littlerobotfriends

ifneq ($(wildcard $(LITTLEROBOTFRIENDS_1)),)
    LITTLEROBOTFRIENDS_APP  = $(ARDUINO_APP)
    LITTLEROBOTFRIENDS_PATH = $(ARDUINO_APP)
    LITTLEROBOTFRIENDS_BOARDS = $(LITTLEROBOTFRIENDS_1)/hardware/avr/$(LITTLEROBOTFRIENDS_AVR_RELEASE)/boards.txt
endif
# ~~

# ~
# Cosa.app path for Arduino 1.8.0
#
COSA_AVR_1    = $(ARDUINO_180_PACKAGES_PATH)/Cosa

ifneq ($(wildcard $(COSA_AVR_1)),)
    COSA_AVR_APP     = $(COSA_AVR_1)
    COSA_AVR_PATH    = $(COSA_AVR_APP)
    COSA_AVR_BOARDS  = $(COSA_AVR_APP)/hardware/avr/$(COSA_AVR_RELEASE)/boards.txt
endif
# ~~

# ~
# LinkIt.app path for Arduino 1.8.0
#
LINKIT_ARM_1    = $(ARDUINO_180_PACKAGES_PATH)/LinkIt

ifneq ($(wildcard $(LINKIT_ARM_1)/hardware/arm/$(LINKIT_ONE_RELEASE)),)
    LINKIT_ARM_APP      = $(LINKIT_ARM_1)
    LINKIT_ARM_PATH     = $(LINKIT_ARM_APP)
    LINKIT_ARM_BOARDS   = $(LINKIT_ARM_PATH)/hardware/arm/$(LINKIT_ONE_RELEASE)/boards.txt
endif

LINKIT_AVR_1    = $(ARDUINO_180_PACKAGES_PATH)/LinkIt

ifneq ($(wildcard $(LINKIT_AVR_1)/hardware/avr/$(LINKIT_DUO_RELEASE)),)
    LINKIT_AVR_APP      = $(LINKIT_AVR_1)
    LINKIT_AVR_PATH     = $(LINKIT_AVR_APP)
    LINKIT_AVR_BOARDS   = $(LINKIT_AVR_PATH)/hardware/avr/$(LINKIT_DUO_RELEASE)/boards.txt
endif
# ~~

# ~
# panStamp.app path for Arduino 1.8.0
#
PANSTAMP_AVR_1    = $(ARDUINO_180_PACKAGES_PATH)/panstamp_avr

ifneq ($(wildcard $(PANSTAMP_AVR_1)),)
    PANSTAMP_AVR_APP    = $(PANSTAMP_AVR_1)
    PANSTAMP_AVR_PATH   = $(PANSTAMP_AVR_APP)
    PANSTAMP_AVR_BOARDS = $(PANSTAMP_AVR_APP)/hardware/avr/$(PANSTAMP_AVR_RELEASE)/boards.txt
endif

PANSTAMP_NRG_1    = $(ARDUINO_180_PACKAGES_PATH)/panstamp_nrg

ifneq ($(wildcard $(PANSTAMP_NRG_1)),)
    PANSTAMP_NRG_APP    = $(PANSTAMP_NRG_1)
    PANSTAMP_NRG_PATH   = $(PANSTAMP_NRG_APP)
    PANSTAMP_NRG_BOARDS = $(PANSTAMP_NRG_APP)/hardware/msp430/$(PANSTAMP_MSP_RELEASE)/boards.txt
endif
# ~~

# ~
STM32DUINO_F1_1  = $(ARDUINO_180_PACKAGES_PATH)/stm32duino

ifneq ($(wildcard $(STM32DUINO_F1_1)/hardware/STM32F1),)
    STM32DUINO_F1_APP     = $(STM32DUINO_F1_1)
    STM32DUINO_F1_PATH    = $(STM32DUINO_F1_APP)
    STM32DUINO_F1_BOARDS  = $(STM32DUINO_F1_APP)/hardware/STM32F1/$(STM32DUINO_F1_RELEASE)/boards.txt
endif

STM32DUINO_F3_1  = $(ARDUINO_180_PACKAGES_PATH)/stm32duino

ifneq ($(wildcard $(STM32DUINO_F3_1)/hardware/STM32F3),)
    STM32DUINO_F3_APP     = $(STM32DUINO_F3_1)
    STM32DUINO_F3_PATH    = $(STM32DUINO_F3_APP)
    STM32DUINO_F3_BOARDS  = $(STM32DUINO_F3_APP)/hardware/STM32F1/$(STM32DUINO_F3_RELEASE)/boards.txt
endif

STM32DUINO_F4_1  = $(ARDUINO_180_PACKAGES_PATH)/stm32duino

ifneq ($(wildcard $(STM32DUINO_F4_1)/hardware/STM32F4),)
    STM32DUINO_F4_APP     = $(STM32DUINO_F4_1)
    STM32DUINO_F4_PATH    = $(STM32DUINO_F4_APP)
    STM32DUINO_F4_BOARDS  = $(STM32DUINO_F4_APP)/hardware/STM32F1/$(STM32DUINO_F4_RELEASE)/boards.txt
endif
# ~~

endif # end Arduino 1.8.0


# Additional boards for Energia 18 Boards Manager
# ----------------------------------
# Energia.app
#
ENERGIA_PACKAGES_PATH = $(HOME)/Library/Energia15/packages/energia

ENERGIA_18_PATH    = $(ENERGIA_18_APP)/Contents/Java
ENERGIA_18_MSP430_BOARDS       = $(ENERGIA_18_PATH)/hardware/energia/msp430/boards.txt
#ENERGIA_18_C2000_BOARDS        = $(ENERGIA_18_PATH)/hardware/c2000/boards.txt

ENERGIA_TIVAC_1    = $(ENERGIA_PACKAGES_PATH)/hardware/tivac/$(ENERGIA_TIVAC_RELEASE)
ifneq ($(wildcard $(ENERGIA_TIVAC_1)),)
    ENERGIA_TIVAC_APP    = $(ENERGIA_TIVAC_1)
    ENERGIA_TIVAC_PATH   = $(ENERGIA_PACKAGES_PATH)
    ENERGIA_18_TIVAC_BOARDS = $(ENERGIA_TIVAC_1)/boards.txt
endif

ENERGIA_MSP430_1    = $(ENERGIA_PACKAGES_PATH)/hardware/msp430/$(ENERGIA_IDE_MSP430_RELEASE)
ifneq ($(wildcard $(ENERGIA_MSP430_1)),)
    ENERGIA_MSP430_APP    = $(ENERGIA_MSP430_1)
    ENERGIA_MSP430_PATH   = $(ENERGIA_PACKAGES_PATH)
    ENERGIA_19_MSP430_BOARDS = $(ENERGIA_MSP430_1)/boards.txt
endif

ENERGIA_CC3200_1    = $(ENERGIA_PACKAGES_PATH)/hardware/cc3200/$(ENERGIA_CC3200_RELEASE)
ifneq ($(wildcard $(ENERGIA_CC3200_1)),)
    ENERGIA_CC3200_APP    = $(ENERGIA_CC3200_1)
    ENERGIA_CC3200_PATH   = $(ENERGIA_PACKAGES_PATH)
    ENERGIA_18_CC3200_BOARDS = $(ENERGIA_CC3200_1)/boards.txt
endif

ENERGIA_CC3200_EMT_1    = $(ENERGIA_PACKAGES_PATH)/hardware/cc3200emt/$(ENERGIA_CC3200_EMT_RELEASE)
ifneq ($(wildcard $(ENERGIA_CC3200_EMT_1)),)
    ENERGIA_CC3200_EMT_APP    = $(ENERGIA_CC3200_EMT_1)
    ENERGIA_CC3200_EMT_PATH   = $(ENERGIA_PACKAGES_PATH)
    ENERGIA_18_CC3200_EMT_BOARDS = $(ENERGIA_CC3200_EMT_1)/boards.txt
endif

# ~
ENERGIA_CC1310_EMT_1    = $(ENERGIA_PACKAGES_PATH)/hardware/cc13xx/$(ENERGIA_CC1310_EMT_RELEASE)
ifneq ($(wildcard $(ENERGIA_CC1310_EMT_1)),)
    ENERGIA_CC1310_EMT_APP    = $(ENERGIA_CC1310_EMT_1)
    ENERGIA_CC1310_EMT_PATH   = $(ENERGIA_CC1310_EMT_APP)
    ENERGIA_18_CC1310_EMT_BOARDS = $(ENERGIA_CC1310_EMT_1)/boards.txt
endif

ENERGIA_CC2600_EMT_1    = $(ENERGIA_PACKAGES_PATH)/hardware/cc26xx/$(ENERGIA_CC2600_EMT_RELEASE)
ifneq ($(wildcard $(ENERGIA_CC2600_EMT_1)),)
    ENERGIA_CC2600_EMT_APP    = $(ENERGIA_CC2600_EMT_1)
    ENERGIA_CC2600_EMT_PATH   = $(ENERGIA_CC2600_EMT_APP)
    ENERGIA_18_CC2600_EMT_BOARDS = $(ENERGIA_CC2600_EMT_1)/boards.txt
endif

ENERGIA_C2000_1         = $(ENERGIA_PACKAGES_PATH)/hardware/c2000/$(ENERGIA_C2000_RELEASE)
ifneq ($(wildcard $(ENERGIA_C2000_1)),)
    ENERGIA_C2000_APP    = $(ENERGIA_C2000_1)
    ENERGIA_C2000_PATH   = $(ENERGIA_C2000_APP)
    ENERGIA_18_C2000_BOARDS = $(ENERGIA_C2000_1)/boards.txt
endif
# ~~

ENERGIA_MSP432_EMT_1    = $(ENERGIA_PACKAGES_PATH)/hardware/msp432/$(ENERGIA_MSP432_EMT_RELEASE)
ifneq ($(wildcard $(ENERGIA_MSP432_EMT_1)),)
    ENERGIA_MSP432_EMT_APP    = $(ENERGIA_MSP432_EMT_1)
    ENERGIA_MSP432_EMT_PATH   = $(ENERGIA_PACKAGES_PATH)
    ENERGIA_18_MSP432_EMT_BOARDS = $(ENERGIA_MSP432_EMT_1)/boards.txt
endif


# Other boards
# ----------------------------------
#
# ~
# Particle is the new name for Spark
#
SPARK_APP     = $(EMBEDXCODE_APP)/Particle
ifeq ($(wildcard $(SPARK_APP)/*),) # */
    SPARK_APP = $(EMBEDXCODE_APP)/Spark
endif
# ~~

# Teensyduino.app path
#
TEENSY_0    = $(APPLICATIONS_PATH)/Teensyduino.app
ifneq ($(wildcard $(TEENSY_0)),)
    TEENSY_APP    = $(TEENSY_0)
else
    TEENSY_APP    = $(ARDUINO_APP)
endif

# ~
# Glowduino.app path
#
GLOWDECK_0  = $(APPLICATIONS_PATH)/Glowduino.app
ifneq ($(wildcard $(GLOWDECK_0)),)
    GLOWDECK_APP    = $(GLOWDECK_0)
else
    GLOWDECK_APP    = $(ARDUINO_APP)
endif
# ~~

# ~
# Microduino.app path
#
MICRODUINO_0 = $(APPLICATIONS_PATH)/Microduino.app

ifneq ($(wildcard $(MICRODUINO_0)),)
    MICRODUINO_APP = $(MICRODUINO_0)
else
    MICRODUINO_APP = $(ARDUINO_APP)
endif
# ~~

# ~
# LightBlueIDE.app path
#
LIGHTBLUE_0 = $(APPLICATIONS_PATH)/LightBlueIDE.app

ifneq ($(wildcard $(LIGHTBLUE_0)),)
    LIGHTBLUE_APP = $(LIGHTBLUE_0)
else
    LIGHTBLUE_APP = $(ARDUINO_APP)
endif
# ~~


# Check at least one IDE installed
#
ifeq ($(wildcard $(ARDUINO_180_APP)),)
ifeq ($(wildcard $(ESP8266_APP)),)
    ifeq ($(wildcard $(LINKIT_ARM_APP)),)
    ifeq ($(wildcard $(WIRING_APP)),)
    ifeq ($(wildcard $(ENERGIA_18_APP)),)
    ifeq ($(wildcard $(MAPLE_APP)),)
        ifeq ($(wildcard $(TEENSY_APP)),)
        ifeq ($(wildcard $(GLOWDECK_APP)),)
        ifeq ($(wildcard $(DIGISTUMP_APP)),)
        ifeq ($(wildcard $(MICRODUINO_APP)),)
        ifeq ($(wildcard $(LIGHTBLUE_APP)),)
            ifeq ($(wildcard $(INTEL_APP)),)
            ifeq ($(wildcard $(ROBOTIS_APP)),)
            ifeq ($(wildcard $(RFDUINO_APP)),)
            ifeq ($(wildcard $(REDBEARLAB_APP)),)
                ifeq ($(wildcard $(LITTLEROBOTFRIENDS_APP)),)
                ifeq ($(wildcard $(PANSTAMP_AVR_APP)),)
                ifeq ($(wildcard $(MBED_APP)/*),) # */
                ifeq ($(wildcard $(EDISON_YOCTO_APP)/*),) # */
                    ifeq ($(wildcard $(SPARK_APP)/*),) # */
                    ifeq ($(wildcard $(ADAFRUIT_AVR_APP)),)
                        $(error Error: no application found)
                    endif
                    endif
                endif
                endif
                endif
                endif
            endif
            endif
            endif
            endif
        endif
        endif
        endif
        endif
        endif
    endif
    endif
    endif
    endif
endif
endif


# Arduino-related nightmares
# ----------------------------------
#
# Get Arduino release
# Gone Arduino 1.0, 1.5 Java 6 and 1.5 Java 7 triple release nightmare
#
ifneq ($(wildcard $(ARDUINO_APP)),) # */
#    s102 = $(ARDUINO_APP)/Contents/Resources/Java/lib/version.txt
    s103 = $(ARDUINO_APP)/Contents/Java/lib/version.txt
#    ifneq ($(wildcard $(s102)),)
#        ARDUINO_RELEASE := $(shell cat $(s102) | sed -e "s/\.//g")
#    else
        ARDUINO_RELEASE := $(shell cat $(s103) | sed -e "s/\.//g")
#    endif
    ARDUINO_MAJOR := $(shell echo $(ARDUINO_RELEASE) | cut -d. -f 1-2)
else
    ARDUINO_RELEASE := 0
    ARDUINO_MAJOR   := 0
endif


# Paths list for other genuine IDEs
#
# ~
MICRODUINO_PATH = $(MICRODUINO_APP)/Contents/Java
MICRODUINO_AVR_BOARDS       = $(MICRODUINO_PATH)/hardware/Microduino/avr/boards.txt
# ~~

TEENSY_PATH     = $(TEENSY_APP)/Contents/Java
TEENSY_BOARDS   = $(TEENSY_PATH)/hardware/teensy/avr/boards.txt

# ~
GLOWDECK_PATH   = $(GLOWDECK_APP)/Contents/Java
GLOWDECK_BOARDS = $(GLOWDECK_PATH)/hardware/teensy/avr/boards.txt
# ~~

# ~
MAPLE_PATH      = $(MAPLE_APP)/Contents/Resources/Java
MAPLE_BOARDS    = $(MAPLE_PATH)/hardware/leaflabs/boards.txt
WIRING_PATH     = $(WIRING_APP)/Contents/Java
WIRING_BOARDS   = $(WIRING_PATH)/hardware/Wiring/boards.txt
# ~~

# ~
# Paths list for other genuine IDEs
#
ROBOTIS_PATH    = $(ROBOTIS_APP)/Contents/Resources/Java
ROBOTIS_BOARDS  = $(ROBOTIS_PATH)/hardware/robotis/boards.txt
# ~~

# ~
# Paths list for other plug-ins
#
LIGHTBLUE_PATH   = $(LIGHTBLUE_APP)/Contents/Java
LIGHTBLUE_BOARDS = $(LIGHTBLUE_PATH)/hardware/LightBlue-Bean/avr/boards.txt
# ~~

# ~
# Paths list for IDE-less platforms
#
MBED_PATH           = $(MBED_APP)
SPARK_PATH          = $(SPARK_APP)
EDISON_YOCTO_PATH   = $(EMBEDXCODE_APP)/EdisonYocto
EDISON_YOCTO_BOARDS = $(EDISON_YOCTO_PATH)/boards.txt
EDISON_MCU_PATH     = $(EMBEDXCODE_APP)/EdisonMCU
EDISON_MCU_BOARDS   = $(EDISON_MCU_PATH)/boards.txt
BEAGLE_DEBIAN_PATH  = $(BEAGKE_DEBIAN_APP)
# ~~


# Miscellaneous
# ----------------------------------
# Variables
#
TARGET      := embeddedcomputing
USER_FLAG   := true

# Builds directory
#
OBJDIR  = Builds

# Function PARSE_BOARD data retrieval from boards.txt
# result = $(call PARSE_BOARD 'boardname','parameter')
#
PARSE_BOARD = $(shell if [ -f $(BOARDS_TXT) ]; then grep ^$(1).$(2)= $(BOARDS_TXT) | cut -d = -f 2-; fi; )

# Function PARSE_FILE data retrieval from specified file
# result = $(call PARSE_FILE 'boardname','parameter','filename')
#
PARSE_FILE = $(shell if [ -f $(3) ]; then grep ^$(1).$(2) $(3) | cut -d = -f 2-; fi; )

# ~
# Warnings flags
#
ifeq ($(WARNING_OPTIONS),)
    WARNING_FLAGS = -Wall
else
    ifeq ($(WARNING_OPTIONS),0)
        WARNING_FLAGS = -w
    else
        WARNING_FLAGS = $(addprefix -W, $(WARNING_OPTIONS))
    endif
endif
# ~~


# Identification and switch
# ----------------------------------
# Look if BOARD_TAG is listed as a Arduino/Arduino board
# Look if BOARD_TAG is listed as a Arduino/arduino/avr board *1.5
# Look if BOARD_TAG is listed as a Arduino/arduino/sam board *1.5
# Look if BOARD_TAG is listed as a chipKIT/PIC32 board
# Look if BOARD_TAG is listed as a Wiring/Wiring board
# Look if BOARD_TAG is listed as a Energia/MPS430 board
# Look if BOARD_TAG is listed as a MapleIDE/LeafLabs board
# Look if BOARD_TAG is listed as a Teensy/Teensy board
# Look if BOARD_TAG is listed as a Microduino/Microduino board
# Look if BOARD_TAG is listed as a Digistump/Digistump board
# Look if BOARD_TAG is listed as a IntelGalileo/arduino/x86 board
# Look if BOARD_TAG is listed as a Adafruit/Arduino board
# Look if BOARD_TAG is listed as a LittleRobotFriends board
# Look if BOARD_TAG is listed as a mbed board
# Look if BOARD_TAG is listed as a RedBearLab/arduino/RBL_nRF51822 board
# Look if BOARD_TAG is listed as a Spark board
# ~
# Look if BOARD_TAG is listed as a LightBlueIDE/LightBlue-Bean board
# Look if BOARD_TAG is listed as a Robotis/robotis board
# Look if BOARD_TAG is listed as a RFduino/RFduino board
# ~~
#
# Order matters!
#
ifneq ($(MAKECMDGOALS),boards)
    ifneq ($(MAKECMDGOALS),clean)
# ~
        ifneq ($(findstring COSA,$(GCC_PREPROCESSOR_DEFINITIONS)),)

            ifeq ($(COSA_BOARD_TAG),)
                COSA_BOARD_TAG = $(BOARD_TAG)
            endif
            ifneq ($(call PARSE_FILE,$(COSA_BOARD_TAG),name,$(COSA_AVR_BOARDS)),)
                MAKEFILE_NAME = Cosa_165
            else
                $(error Cosa board $(BOARD_TAG) is unknown)
            endif

    else
# ~~
        # Arduino
        ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(ARDUINO_180_AVR_BOARDS)),)
            MAKEFILE_NAME = ArduinoAVR_166
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG1),name,$(ARDUINO_180_AVR_BOARDS)),)
			MAKEFILE_NAME = ArduinoAVR_166

        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(ARDUINO_180_PATH)/hardware/arduino/avr/boards.txt),)
            MAKEFILE_NAME = ArduinoAVR_165
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG1),name,$(ARDUINO_180_PATH)/hardware/arduino/avr/boards.txt),)
            MAKEFILE_NAME = ArduinoAVR_165

        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(ARDUINO_180_SAM_BOARDS)),)
            MAKEFILE_NAME = ArduinoSAM_165
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(ARDUINO_180_SAMD_BOARDS)),)
            MAKEFILE_NAME = ArduinoSAMD_180

# ~
        # Additional boards for Arduino 1.8.0
        # Intel
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(INTEL_GALILEO_BOARDS)),)
            MAKEFILE_NAME = IntelGalileo_165
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(INTEL_EDISON_BOARDS)),)
            MAKEFILE_NAME = IntelEdison_165
		else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(INTEL_CURIE_BOARDS)),)
			MAKEFILE_NAME = IntelCurie_165

        # panStamp
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(PANSTAMP_AVR_BOARDS)),)
            MAKEFILE_NAME = panStampAVR_165
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(PANSTAMP_NRG_BOARDS)),)
            MAKEFILE_NAME = panStampNRG_165

        # chipKIT
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(CHIPKIT_BOARDS)),)
            MAKEFILE_NAME = chipKIT_165
# ~~

        # Energia 18
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG_18),name,$(ENERGIA_19_MSP430_BOARDS)),)
            MAKEFILE_NAME = EnergiaMSP430_19
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG_18),name,$(ENERGIA_18_MSP430_BOARDS)),)
            MAKEFILE_NAME = EnergiaMSP430_18
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG_18),name,$(ENERGIA_18_TIVAC_BOARDS)),)
            MAKEFILE_NAME = EnergiaTIVAC_18
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG_18),name,$(ENERGIA_18_CC3200_BOARDS)),)
            MAKEFILE_NAME = EnergiaCC3200_18
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG_18),name,$(ENERGIA_18_CC1310_EMT_BOARDS)),)
            MAKEFILE_NAME = EnergiaCC1300EMT_18
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG_18),name,$(ENERGIA_18_MSP432_EMT_BOARDS)),)
            MAKEFILE_NAME = EnergiaMSP432EMT_18
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG_18),name,$(ENERGIA_18_CC3200_EMT_BOARDS)),)
            MAKEFILE_NAME = EnergiaCC3200EMT_18
# ~
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(ENERGIA_18_CC2600_EMT_BOARDS)),)
            MAKEFILE_NAME = EnergiaCC2600EMT_18
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(ENERGIA_18_C2000_BOARDS)),)
            MAKEFILE_NAME = EnergiaC2000_18
# ~~

        # Others boards for Arduino 1.8.0
# ~
        # Adafruit
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(ADAFRUIT_AVR_BOARDS)),)
            MAKEFILE_NAME = AdafruitAVR_165
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(ADAFRUIT_SAMD_BOARDS)),)
            MAKEFILE_NAME = AdafruitSAMD_165
# ~~

        # ESP8266
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(ESP8266_BOARDS)),)
            MAKEFILE_NAME = ESP8266_165

# ~
        # LittleRobotFriends
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(LITTLEROBOTFRIENDS_BOARDS)),)
            MAKEFILE_NAME = LittleRobotFriends_165
# ~~

# ~
        # Digistump
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(DIGISTUMP_AVR_BOARDS)),)
            MAKEFILE_NAME = DigistumpAVR_165
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(DIGISTUMP_SAM_BOARDS)),)
            MAKEFILE_NAME = DigistumpSAM_165
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(DIGISTUMP_OAK_BOARDS)),)
            MAKEFILE_NAME = DigistumpOAK_165
# ~~

# ~
        # RedBearLab
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(REDBEARLAB_AVR_BOARDS)),)
            MAKEFILE_NAME = RedBearLabAVR_165
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(REDBEARLAB_NRF51_BOARDS)),)
            MAKEFILE_NAME = RedBearLabNRF51_165
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(REDBEARLAB_NRF52_BOARDS)),)
            MAKEFILE_NAME = RedBearLabNRF52_165
# ~~

# ~
        # UDOO Neo
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(UDOO_NEO_BOARDS)),)
            MAKEFILE_NAME = UdooNeo_165
# ~~

# ~
        # More boards for Arduino 1.8.0
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(GLOWDECK_BOARDS)),)
            MAKEFILE_NAME = Teensy
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(STM32DUINO_F1_BOARDS)),)
            MAKEFILE_NAME = STM32_F1_165
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(STM32DUINO_F3_BOARDS)),)
            MAKEFILE_NAME = STM32_F3_165
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(STM32DUINO_F4_BOARDS)),)
            MAKEFILE_NAME = STM32_F4_165
# ~~

        # Other IDEs
# ~
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(MAPLE_BOARDS)),)
            MAKEFILE_NAME = MapleIDE
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(WIRING_BOARDS)),)
            MAKEFILE_NAME = Wiring
# ~~
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(TEENSY_BOARDS)),)
            MAKEFILE_NAME = Teensy
# ~
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(GLOWDECK_BOARDS)),)
            MAKEFILE_NAME = Teensy
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG1),name,$(MICRODUINO_AVR_BOARDS)),)
            MAKEFILE_NAME = Microduino_168
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(MICRODUINO_AVR_BOARDS)),)
            MAKEFILE_NAME = Microduino_168
# ~~

# ~
        # Other frameworks
        else ifeq ($(filter MBED,$(GCC_PREPROCESSOR_DEFINITIONS)),MBED)
            MAKEFILE_NAME = mbed

        else ifeq ($(filter SPARK,$(GCC_PREPROCESSOR_DEFINITIONS)),SPARK)
            MAKEFILE_NAME = Particle

        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(TINYCIRCUITS_SAMD_BOARDS)),)
            MAKEFILE_NAME = TinyCircuits_165
# ~~

# ~
# More IDEs
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(ARDUCAM_ESP_BOARDS)),)
            MAKEFILE_NAME = ArducamESP_165

        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(REDBEARLAB_DUO_BOARDS)),)
            MAKEFILE_NAME = RedBearLabDUO_165

        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(MOTEINO_BOARDS)),)
            MAKEFILE_NAME = Moteino_165

        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(LINKIT_ARM_BOARDS)),)
            MAKEFILE_NAME = LinkItOne_165

        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(LINKIT_AVR_BOARDS)),)
            MAKEFILE_NAME = LinkItDuo_165

        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(LIGHTBLUE_BOARDS)),)
            MAKEFILE_NAME = LightBlue

        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(ROBOTIS_BOARDS)),)
            MAKEFILE_NAME = Robotis

        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(RFDUINO_BOARDS)),)
            MAKEFILE_NAME = RFduino_165
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(SIMBLEE_BOARDS)),)
            MAKEFILE_NAME = Simblee_165

        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(EDISON_YOCTO_BOARDS)),)
            MAKEFILE_NAME = IntelEdisonYocto
        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(EDISON_MCU_BOARDS)),)
            MAKEFILE_NAME = IntelEdisonMCU

        else ifneq ($(call PARSE_FILE,$(BOARD_TAG),name,$(BEAGLE_DEBIAN_PATH)/boards.txt),)
            MAKEFILE_NAME = BeagleBoneDebianL
# Alternatives for tool-chain
#            MAKEFILE_NAME = BeagleBoneDebianGCC
#            MAKEFILE_NAME = BeagleBoneDebianCM
# ~~

        else
            UNKNOWN_BOARD = 1
#            $(error $(BOARD_TAG) board is unknown)
        endif
# ~
      endif
# ~~
    endif
endif

# Information on makefile
#
include $(MAKEFILE_PATH)/$(MAKEFILE_NAME).mk
$(eval MAKEFILE_RELEASE = $(shell grep $(MAKEFILE_PATH)/$(MAKEFILE_NAME).mk -e '^# Last update' | rev | cut -d\  -f1-2 | rev ))

# List of sub-paths to be excluded
#
EXCLUDE_NAMES  = Example example Examples examples Archive archive Archives archives Documentation documentation Reference reference
EXCLUDE_NAMES += ArduinoTestSuite tests test
EXCLUDE_NAMES += $(EXCLUDE_LIBS)
EXCLUDE_LIST   = $(addprefix %,$(EXCLUDE_NAMES))

# Step 2
#
include $(MAKEFILE_PATH)/Step2.mk

