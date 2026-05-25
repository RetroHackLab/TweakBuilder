#!/bin/bash

# ==============================================================================
# Clangy.sh v1.1.0 - Developed by RetroHackLab (2026)
# Dynamic Source-Naming Cross-Compiler Engine
# ==============================================================================

clear
echo "=================================================================="
echo "          __====__                               "
echo "        _-        -_      CLANGY COMPILER        "
echo "       /  O    O    \     by RetroHackLab        "
echo "      |    ____      |                           "
echo "       \  \____/    /     Retro-Automation OS    "
echo "        _-________-_                             "
echo "=================================================================="
echo ""


if [ ! -d "Package" ] || [ ! -f "Package/DEBIAN/control" ]; then
    echo "❌ Error: 'Package/DEBIAN/control' tree structure not found!"
    echo "👉 Please run 'build.sh' first to initialize project parameters."
    exit 1
fi

PROJ_NAME=$(grep '^Name:' Package/DEBIAN/control | cut -d' ' -f2)
ARCH_TAG=$(grep '^Architecture:' Package/DEBIAN/control | cut -d' ' -f2)

if [[ -z "$PROJ_NAME" || -z "$ARCH_TAG" ]]; then
    echo "❌ Error: Could not parse Project Name or Architecture from control profile!"
    exit 1
fi


if [ "$ARCH_TAG" == "iphoneos-arm" ]; then
    CLANG_ARCH="armv7"
    MIN_IOS="-miphoneos-version-min=5.0"
else
    CLANG_ARCH="arm64"
    MIN_IOS="-miphoneos-version-min=7.0"
fi


AVAILABLE_SDKS=($(ls ./sdk 2>/dev/null))
if [ ${#AVAILABLE_SDKS[@]} -eq 0 ]; then
    echo "❌ Error: No SDK structures discovered inside './sdk/' execution folder!"
    exit 1
fi
SDK_PATH="./sdk/${AVAILABLE_SDKS[0]}"

echo "    ✅ Target Framework Binding: $SDK_PATH"
echo "    ✅ Target Architecture Base: $CLANG_ARCH"
echo ""

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------
echo "[-] STEP 2: Compiling Dynamic Substrate Library Layer..."
TARGET_DYLIB="Package/Library/MobileSubstrate/DynamicLibraries/${PROJ_NAME}.dylib"
TWEAK_SRC="${PROJ_NAME}.mm"


if [ ! -f "$TWEAK_SRC" ]; then
    echo "    ⚠️ Source file '$TWEAK_SRC' not found. Creating standard RetroHackLab template..."
    cat <<EOF > "$TWEAK_SRC"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%ctor {
    NSLog(@"*** [RetroHackLab] Tweak ${PROJ_NAME} Injection Vector Loaded ***");
}
EOF
fi

clang++ -dynamiclib \
    -isysroot "$SDK_PATH" \
    -arch "$CLANG_ARCH" \
    "$MIN_IOS" \
    -fobjc-arc \
    -framework UIKit \
    -framework Foundation \
    -o "$TARGET_DYLIB" \
    "$TWEAK_SRC"

if [ $? -eq 0 ]; then
    echo "    ✅ Successfully compiled target library: ${PROJ_NAME}.dylib"
else
    echo "❌ Critical Error: Clang++ compilation routine rejected '$TWEAK_SRC' execution code."
    exit 1
fi
echo ""

# ------------------------------------------------------------------------------
# PHASE 3: COMPILATION DES PRÉFÉRENCES (*TweakName*Controller.mm)
# ------------------------------------------------------------------------------
BUNDLE_DIR="Package/Library/PreferenceBundles/${PROJ_NAME}.bundle"
if [ -d "$BUNDLE_DIR" ]; then
    echo "[-] STEP 3: Compiling Preference Bundle Controller Binary..."
    TARGET_BIN="$BUNDLE_DIR/${PROJ_NAME}"
    PREFS_SRC="${PROJ_NAME}Controller.mm"
    
    rm -f "$TARGET_BIN"

    
    if [ ! -f "$PREFS_SRC" ]; then
        echo "    ⚠️ Source file '$PREFS_SRC' not found. Crafting controller class template..."
        cat <<EOF > "$PREFS_SRC"
#import <Preferences/PSListController.h>

@interface ${PROJ_NAME}Controller : PSListController
@end

@implementation ${PROJ_NAME}Controller
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }
    return _specifiers;
}
@end
EOF
    fi

    clang++ -dynamiclib \
        -isysroot "$SDK_PATH" \
        -arch "$CLANG_ARCH" \
        "$MIN_IOS" \
        -fobjc-arc \
        -framework UIKit \
        -framework Foundation \
        -framework Preferences \
        -o "$TARGET_BIN" \
        "$PREFS_SRC"

    if [ $? -eq 0 ]; then
        echo "    ✅ Successfully compiled binary executable: ${PROJ_NAME} (No Extension)"
    else
        echo "❌ Critical Error: Preference cross-compilation pipeline failed for '$PREFS_SRC'."
        exit 1
    fi
fi

echo ""
echo "=================================================================="
echo "🎉 COMPLICATION PIPELINE COMPLETE!"
echo "👉 Run './DEBIAN.sh' to pack your standardized .deb distribution file."
echo "=================================================================="
