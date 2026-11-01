TARGET = PhantomLayaMod.dylib
ARCH = arm64
SDK = iphoneos
CC = xcrun -sdk $(SDK) clang
CXX = xcrun -sdk $(SDK) clang++
CFLAGS = -arch $(ARCH) -isysroot (shell xcrun -sdk(SDK) --show-sdk-path) -O3 -std=c++20
CXXFLAGS = $(CFLAGS) -fobjc-arc
LDFLAGS = -arch $(ARCH) -isysroot (shell xcrun -sdk(SDK) --show-sdk-path) 
-dynamiclib -undefined dynamic_lookup 
-framework Foundation -framework UIKit -framework JavaScriptCore -framework Metal -framework MetalKit
SOURCES = PhantomLayaMod.mm
all: $(TARGET)
$(TARGET): (SOURCES)(CXX) (CXXFLAGS)(LDFLAGS) (SOURCES) -o(TARGET)
clean:
rm -f $(TARGET)
