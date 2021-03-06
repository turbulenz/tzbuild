# Copyright (c) 2012 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

############################################################

MACOSX_XCODE_BIN_PATH := $(wildcard /Developer/usr/bin/)

# Language to compile all .cpp files as
MACOSX_CXX_DEFAULTLANG ?= objective-c++

XCODE_SDK_VER ?= 10.6

# Create a variable holding the xcode configuration
ifeq ($(CONFIG),debug)
  XCODE_CONFIG := Debug
else
  XCODE_CONFIG := Release
endif

# Mark non-10.6 builds

ifneq ($(XCODE_SDK_VER),10.6)
  VARIANT:=$(strip $(VARIANT)-$(XCODE_SDK_VER))
endif

# Check the known SDK install locations

XCODE_SDK_ROOT:=/Developer/SDKs/MacOSX$(XCODE_SDK_VER).sdk
ifeq (,$(wildcard $(XCODE_SDK_ROOT)))
  XCODE_SDK_ROOT:=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform$(XCODE_SDK_ROOT)
endif

############################################################

$(call log,MACOSX BUILD CONFIGURATION)

#
# CXX / CMM FLAGS
#

CXX := $(MACOSX_XCODE_BIN_PATH)llvm-g++-4.2
CMM := $(CXX)

CXXFLAGSPRE := -x $(MACOSX_CXX_DEFAULTLANG) \
    -arch i386 -fmessage-length=0 -pipe -fexceptions \
    -fpascal-strings -fasm-blocks \
    -Wall -Wno-unknown-pragmas \
    -Wno-reorder -Wno-trigraphs -Wno-unused-parameter \
    -isysroot $(XCODE_SDK_ROOT) \
    -ftree-vectorize -msse3 -mssse3 \
    -mmacosx-version-min=$(XCODE_SDK_VER) \
    -fvisibility-inlines-hidden \
    -fvisibility=hidden \
    -DXP_MACOSX=1 -DMACOSX

# -fno-rtti
# -fno-exceptions
# -fvisibility=hidden

CMMFLAGSPRE := -x objective-c++ \
    -arch i386 -fmessage-length=0 -pipe \
    -fpascal-strings -fasm-blocks -fPIC \
    -Wall -Wno-unknown-pragmas \
    -Wno-reorder -Wno-trigraphs -Wno-unused-parameter \
    -Wno-undeclared-selector \
    -isysroot $(XCODE_SDK_ROOT) \
    -ftree-vectorize -msse3 -mssse3 \
    -mmacosx-version-min=$(XCODE_SDK_VER) \
    -fvisibility-inlines-hidden \
    -fvisibility=hidden \
    -DXP_MACOSX=1

# -fno-exceptions
# -fno-rtti

CXXFLAGSPOST := \
    -c

CMMFLAGSPOST := \
    -c

# DEBUG / RELEASE

ifeq ($(CONFIG),debug)
  CXXFLAGSPRE += -g -O0 -D_DEBUG -DDEBUG
  CMMFLAGSPRE += -g -O0 -D_DEBUG -DDEBUG
else
  CXXFLAGSPRE += -g -O3 -DNDEBUG
  CMMFLAGSPRE += -g -O3 -DNDEBUG
endif

#
# LIBS
#

# ARFLAGSPOST := \
#     -Xlinker \
#     --no-demangle \
#     -framework CoreFoundation \
#     -framework OpenGL \
#     -framework Carbon \
#     -framework AGL \
#     -framework QuartzCore \
#     -framework AppKit \
#     -framework IOKit \
#     -framework System

AR := MACOSX_DEPLOYMENT_TARGET=$(XCODE_SDK_VER) $(MACOSX_XCODE_BIN_PATH)libtool
ARFLAGSPRE := -static -arch_only i386 -g
arout := -o
ARFLAGSPOST := \
  -framework CoreFoundation \
  -framework OpenGL \
  -framework Carbon \
  -framework AGL \
  -framework QuartzCore \
  -framework AppKit \
  -framework IOKit \
  -framework System

libprefix := lib
libsuffix := .a

#
# DLL
#

DLL := MACOSX_DEPLOYMENT_TARGET=$(XCODE_SDK_VER) $(MACOSX_XCODE_BIN_PATH)llvm-g++-4.2
DLLFLAGSPRE := -isysroot $(XCODE_SDK_ROOT) -dynamiclib -arch i386 -g
DLLFLAGSPOST := \
  -framework CoreFoundation \
  -framework OpenGL \
  -framework Carbon \
  -framework AGL \
  -framework QuartzCore \
  -framework AppKit \
  -framework IOKit \
  -framework System

DLLFLAGS_LIBDIR := -L
DLLFLAGS_LIB := -l

dllprefix :=
dllsuffix := .dylib

dll-post = \
  $(CMDPREFIX) for d in $($(1)_ext_dlls) ; do \
    in=`$(MACOSX_XCODE_BIN_PATH)otool -D $$$$d | grep -v :`; \
    bn=`basename $$$$d`; \
    $(MACOSX_XCODE_BIN_PATH)install_name_tool -change $$$$in @loader_path/$$$$bn $$@ ; \
  done

#
# APPS
#

LDFLAGS_LIBDIR := -L
LDFLAGS_LIB := -l

LD := $(MACOSX_XCODE_BIN_PATH)llvm-g++-4.2
LDFLAGSPRE := \
    -arch i386 \
    -g \
    -isysroot $(XCODE_SDK_ROOT)

LDFLAGSPOST := \
    -mmacosx-version-min=$(XCODE_SDK_VER) \
    -dead_strip \
    -Wl,-search_paths_first \
    -framework CoreFoundation \
    -framework OpenGL \
    -framework Carbon \
    -framework QuartzCore \
    -framework AppKit \
    -framework IOKit \
    -licucore

#    -Xlinker \
#    --no-demangle \

app-post = \
  $(CMDPREFIX) for d in $($(1)_ext_dlls) ; do \
    in=`$(MACOSX_XCODE_BIN_PATH)otool -D $$$$d | grep -v :`; \
    bn=`basename $$$$d`; \
    $(MACOSX_XCODE_BIN_PATH)install_name_tool -change $$$$in @loader_path/$$$$bn $$@ ; \
  done

############################################################
