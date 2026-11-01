# Makefile for compiling Phantom Laya/Conch iOS arm64 Dylib
# Target: libPhantomLayaMod.dylib

CXX = xcrun --sdk iphoneos clang++
LD = xcrun --sdk iphoneos clang++

ARCH = arm64
SYSROOT = $(shell xcrun --sdk iphoneos --show-sdk-path)

CFLAGS = -arch $(ARCH) -isysroot $(SYSROOT) -std=c++20 -O3 -fobjc-arc -dynamiclib
LDFLAGS = -arch $(ARCH) -isysroot $(SYSROOT) -dynamiclib \
          -framework Foundation \
          -framework UIKit \
          -framework JavaScriptCore \
          -framework Metal \
          -framework MetalKit

TARGET = libPhantomLayaMod.dylib
SRC = PhantomLayaMod.mm

all: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CFLAGS) $(LDFLAGS) $(SRC) -o $(TARGET)

clean:
	rm -f $(TARGET)
