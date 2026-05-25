#!/bin/bash

# ==============================================================================
# TweakBuilder v1.3.0 - Developed by RetroHackLab (2026)
# Production-Hardened Environment Orchestrator & Structural Injector
# ==============================================================================

clear
echo "=================================================================="
echo "          __====__                               "
echo "        _-        -_      TWEAK BUILDER v1.3     "
echo "       /  O    O    \     by RetroHackLab        "
echo "      |    ____      |                           "
echo "       \  \____/    /     Retro-Automation OS    "
echo "        _-________-_                             "
echo "=================================================================="
echo ""

# ------------------------------------------------------------------------------
# STEP 1: PROJECT BASIC INFO
# ------------------------------------------------------------------------------
echo "[-] STEP 1: Project Metadata"
read -p "    👉 Enter Project Name (e.g. MyTweak): " proj_name
if [[ -z "$proj_name" || "$proj_name" =~ [[:space:]] ]]; then
    echo "❌ Error: Project Name cannot be empty or contain spaces! [Unsupported]"
    exit 1
fi

read -p "    👉 Enter Package ID (e.g., com.retro.tweak): " pkg_id
if [[ ! "$pkg_id" =~ ^[a-zA-Z0-9\.\-_]+$ ]]; then
    echo "❌ Error: Invalid Package ID format! [Invalid]"
    exit 1
fi
echo ""

# ------------------------------------------------------------------------------
# STEP 2: CHOOSE SPECIFIC VERSION WITH STRICT RANGE VALIDATION
# ------------------------------------------------------------------------------
echo "[-] STEP 2: Versioning Policy"
echo "    1) Pre-Release (Range: 0.9.0 up to 1.0-BETA)"
echo "    2) Latest      (Range: 0.9.5 up to 3.2.2)"
read -p "    👉 Select Version Type [1-2]: " ver_choice

case $ver_choice in
    1)
        echo "    📝 Requis: Between 0.9.0 and 1.0-BETA"
        read -p "    👉 Enter Pre-Release Version: " version
        if [[ ! "$version" =~ ^(0\.9\.[0-9]+(-[a-zA-Z0-9]+)?|1\.0-BETA)$ ]]; then
            echo "❌ Wrong Answer: Version '$version' is out of range! [Unsupported]"
            exit 1
        fi
        ;;
    2)
        echo "    📝 Requis: Between 0.9.5 and 3.2.2"
        read -p "    👉 Enter Latest Version: " version
        if [[ ! "$version" =~ ^([0-3]\.[0-9]+\.[0-9]+)$ ]]; then
            echo "❌ Wrong Answer: String is not a proper semantic version. [Invalid]"
            exit 1
        fi
        IFS='.' read -r major minor patch <<< "$version"
        if (( major == 0 && (minor < 9 || (minor == 9 && patch < 5)) )) || (( major > 3 || (major == 3 && (minor > 2 || (minor == 2 && patch > 2))) )); then
            echo "❌ Wrong Answer: Version '$version' is out of boundaries! [Unsupported]"
            exit 1
        fi
        ;;
    *)
        echo "❌ Error: Selection choice '$ver_choice' does not exist! [Unsupported]"
        exit 1
        ;;
esac
echo ""

# ------------------------------------------------------------------------------
# STEP 3: CHOOSE TWEAK TYPE & ENVIRONMENT LOGIC
# ------------------------------------------------------------------------------
echo "[-] STEP 3: Tweak Environment Specification"
echo "    1) Native Tweak"
echo "    2) Native Tweak (Prefs)"
echo "    3) Utility Tweak (contains *app)"
echo "    4) System Tweak (contains *app, preferences, or system accessory)"
echo "    5) Custom Tweak"
read -p "    👉 Select Tweak Type [1-5]: " type_choice

# Clean previous build workspaces safely
rm -rf Package
mkdir -p Package/DEBIAN
mkdir -p Package/Library/MobileSubstrate/DynamicLibraries

case $type_choice in
    1) tweak_type="Native Tweak" ;;
    2) tweak_type="Native Tweak (Prefs)" ;;
    3)
        tweak_type="Utility Tweak"
        read -p "    ❓ Does this utility contain an App [y/n]? " has_app
        if [[ "$has_app" != "y" && "$has_app" != "n" && "$has_app" != "Y" && "$has_app" != "N" ]]; then
            echo "❌ Wrong Answer: Expected y/n. [Unsupported]"
            exit 1
        fi
        if [[ "$has_app" == "y" || "$has_app" == "Y" ]]; then mkdir -p Package/Applications; fi
        ;;
    4)
        tweak_type="System Tweak"
        read -p "    ❓ Does this system environment contain an App [y/n]? " has_app
        if [[ "$has_app" != "y" && "$has_app" != "n" && "$has_app" != "Y" && "$has_app" != "N" ]]; then
            echo "❌ Wrong Answer: Expected y/n. [Unsupported]"
            exit 1
        fi
        if [[ "$has_app" == "y" || "$has_app" == "Y" ]]; then mkdir -p Package/Applications; fi
        mkdir -p Package/usr/bin
        mkdir -p Package/usr/lib
        ;;
    5)
        read -p "    👉 Enter Custom Package Type Name (e.g., Untether): " custom_name
        if [[ -z "$custom_name" ]]; then echo "❌ Error: Field empty! [Invalid]"; exit 1; fi
        tweak_type="Custom ($custom_name)"
        ;;
    *)
        echo "❌ Error: Type option '$type_choice' does not map to a profile! [Unsupported]"
        exit 1
        ;;
esac
echo ""

# ------------------------------------------------------------------------------
# STEP 4: PREFERENCE BUNDLE LOADER LOGIC (IF PREFS OR SYSTEM TWEAK)
# ------------------------------------------------------------------------------
if [[ "$type_choice" == "2" || "$type_choice" == "4" ]]; then
    echo "[-] STEP 4: Preference Configuration Builder"
    echo "    1) Simple Prefs (Settings pane shows ON/OFF Switch Only)"
    echo "    2) Pro Prefs     (Links directly and accesses your custom Root.plist Layout)"
    read -p "    👉 Select Preference Profile [1-2]: " pref_style

    if [[ "$pref_style" != "1" && "$pref_style" != "2" ]]; then
        echo "❌ Wrong Answer: Choice out of scope! [Unsupported]"
        exit 1
    fi

    # Initialize Directory Trees
    BUNDLE_DIR="Package/Library/PreferenceBundles/${proj_name}.bundle"
    LOADER_DIR="Package/Library/PreferenceLoader/Preferences"
    mkdir -p "$BUNDLE_DIR"
    mkdir -p "$LOADER_DIR"

    # 1. Info.plist Setup
    cat <<EOF > "$BUNDLE_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>${pkg_id}.preference</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>English</string>
    <key>CFBundleExecutable</key>
    <string>${proj_name}</string>
    <key>CFBundleName</key>
    <string>${proj_name}</string>
    <key>NSPrincipalClass</key>
    <string>${proj_name}Controller</string>
</dict>
</plist>
EOF

    # 2. Executable Placeholder Creation
    echo "NOTICE: This is a placeholder structure generated by RetroHackLab TweakBuilder." > "$BUNDLE_DIR/${proj_name}"
    echo "CRITICAL STEPS REQUIRED: Replace this structural text file bundle container with your compiled executable binary." >> "$BUNDLE_DIR/${proj_name}"

    # 3. PreferenceLoader Target (.plist) & Root.plist Generator Mapping
    if [ "$pref_style" == "1" ]; then
        cat <<EOF > "$LOADER_DIR/${proj_name}.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>entry</key>
    <dict>
        <key>cell</key>
        <string>PSSwitchCell</string>
        <key>default</key>
        <false/>
        <key>defaults</key>
        <string>${pkg_id}</string>
        <key>key</key>
        <string>Enabled</string>
        <key>label</key>
        <string>${proj_name} Status</string>
    </dict>
</dict>
</plist>
EOF
    else
        cat <<EOF > "$LOADER_DIR/${proj_name}.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>entry</key>
    <dict>
        <key>bundle</key>
        <string>${proj_name}</string>
        <key>cell</key>
        <string>PSLinkCell</string>
        <key>isController</key>
        <true/>
        <key>label</key>
        <string>${proj_name}</string>
    </dict>
</dict>
</plist>
EOF

        cat <<EOF > "$BUNDLE_DIR/Root.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>cell</key>
            <string>PSGroupCell</string>
            <key>label</key>
            <string>${proj_name} Settings</string>
        </dict>
        <dict>
            <key>cell</key>
            <string>PSSwitchCell</string>
            <key>default</key>
            <true/>
            <key>defaults</key>
            <string>${pkg_id}</string>
            <key>key</key>
            <string>Enabled</string>
            <key>label</key>
            <string>Enable Tweak Engine</string>
        </dict>
    </array>
    <key>title</key>
    <string>${proj_name}</string>
</dict>
</plist>
EOF
    fi
fi

# ------------------------------------------------------------------------------
# STEP 5: DEPENDENCIES & MAINTENANCE TARGETS
# ------------------------------------------------------------------------------
echo "[-] STEP 5: System Dependencies"
echo "    1) iOS 5.0 - 9.3.4"
echo "    2) iOS 7.0 - 11.0"
read -p "    👉 Choose Dependency Version [1-2]: " dep_choice

if [ "$dep_choice" == "1" ]; then
    dependencies="mobilesubstrate, firmware (>= 5.0), firmware (<= 9.3.4)"
elif [ "$dep_choice" == "2" ]; then
    dependencies="mobilesubstrate, firmware (>= 7.0), firmware (<= 11.0)"
else
    echo "❌ Wrong Answer: Selected dependency option index out of bounds! [Invalid]"
    exit 1
fi

read -p "    ❓ Do you want to add postinst module [y/n]? " add_post
if [[ "$add_post" != "y" && "$add_post" != "n" && "$add_post" != "Y" && "$add_post" != "N" ]]; then
    echo "❌ Wrong Answer: Expecting boolean evaluation. [Unsupported]"
    exit 1
fi

if [[ "$add_post" == "y" || "$add_post" == "Y" ]]; then
    read -p "    👉 Enter product module device identifier (e.g., iPhone8,1): " prod_module
    if [[ -z "$prod_module" ]]; then echo "❌ Error: Code blank! [Invalid]"; exit 1; fi
    echo "#!/bin/sh" > Package/DEBIAN/postinst
    echo "echo 'Configuring module for $prod_module...'" >> Package/DEBIAN/postinst
fi

echo "    [-] Choose Pre-inst Type:"
echo "        A) System Reboot"
echo "        B) Respring Only"
read -p "    👉 Selection [A/B]: " pre_type

if [[ "$pre_type" != "A" && "$pre_type" != "B" && "$pre_type" != "a" && "$pre_type" != "b" ]]; then
    echo "❌ Wrong Answer: Invalid operations command token. [Unsupported]"
    exit 1
fi

echo "#!/bin/sh" > Package/DEBIAN/preinst
if [[ "$pre_type" == "A" || "$pre_type" == "a" ]]; then
    echo "echo 'System reboot scheduled by installation profile...'" >> Package/DEBIAN/preinst
else
    echo "echo 'Respring engine triggering...'" >> Package/DEBIAN/preinst
fi

chmod 755 Package/DEBIAN/preinst
if [ -f Package/DEBIAN/postinst ]; then chmod 755 Package/DEBIAN/postinst; fi
echo ""

# ------------------------------------------------------------------------------
# STEP 6: HARDWARE ARCHITECTURE & AUTOMATED SUBSTRATE FILTER SETUP
# ------------------------------------------------------------------------------
echo "[-] STEP 6: Target Hardware Layer"
echo "    1) 32-bit Architecture"
echo "    2) 64-bit Architecture"
read -p "    👉 Selection [1-2]: " arch_choice

if [ "$arch_choice" == "1" ]; then
    arch_tag="iphoneos-arm"
elif [ "$arch_choice" == "2" ]; then
    arch_tag="iphoneos-arm64"
else
    echo "❌ Wrong Answer: Target layout profile completely [Unsupported]."
    exit 1
fi

# SMART FILTER DETECTION PAYLOAD
if [[ "$type_choice" == "1" ]]; then
    FILTER_BUNDLE="com.apple.UIKit"
elif [[ "$type_choice" == "2" || "$pref_style" == "2" ]]; then
    FILTER_BUNDLE="com.apple.Preferences"
else
    FILTER_BUNDLE="com.apple.springboard"
fi

cat <<EOF > "Package/Library/MobileSubstrate/DynamicLibraries/${proj_name}.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Filter</key>
    <dict>
        <key>Bundles</key>
        <array>
            <string>${FILTER_BUNDLE}</string>
        </array>
    </dict>
</dict>
</plist>
EOF

echo "NOTICE: Deployment requires copying your compiled target executable '.dylib' file directly here." > "Package/Library/MobileSubstrate/DynamicLibraries/COPY_DYLIB_HERE.txt"
echo ""

# ------------------------------------------------------------------------------
# STEP 7: TOOLCHAIN SDK SELECTOR
# ------------------------------------------------------------------------------
echo "[-] STEP 7: Toolchain SDK Linker mapping"
if [ -d "./sdk" ] && [ "$(ls -A ./sdk)" ]; then
    echo "    Available iOS SDK bundles discovered inside /sdk/:"
    select sdk_folder in $(ls ./sdk); do
        if [ -n "$sdk_folder" ]; then
            SDK_PATH="./sdk/$sdk_folder"
            echo "    ✅ Selected Toolchain SDK: $SDK_PATH"
            break
        else
            echo "❌ Wrong Answer: Index item matching lookup failed! [Invalid]"
            exit 1
        fi
    done
else
    echo "    ⚠️ Warning: No local /sdk/ repository directory discovered. Creating default folder."
    mkdir -p ./sdk
    SDK_PATH="./sdk/iPhoneOS9.3.sdk"
fi
echo ""

# ------------------------------------------------------------------------------
# STEP 8: AUTOMATIC CONTROL GENERATOR (Auto AI Engine)
# ------------------------------------------------------------------------------
cat <<EOF > Package/DEBIAN/control
Package: $pkg_id
Name: $proj_name
Version: $version
Architecture: $arch_tag
Description: Architecture-optimized $tweak_type built by TweakBuilder.
Section: Tweaks
Depends: $dependencies
Author: Git Repo's Developper
EOF

# ------------------------------------------------------------------------------
# BUILD PIPELINE RESULTS INDEX
# ------------------------------------------------------------------------------
echo "=================================================================="
echo "🎉 DEPLOYMENT WORKSPACE DESIGNED & VERIFIED"
echo "=================================================================="
echo "📦 Package ID  : $pkg_id"
echo "🚀 Target Name : $proj_name ($version)"
echo "⚙️ Architecture: $arch_tag"
echo "🎯 Injection Filter Target: $FILTER_BUNDLE"
echo "📁 Structure Manifest Status:"
echo "------------------------------------------------------------------"
echo " -> [✓] Package/DEBIAN/control generated."
echo " -> [✓] MobileSubstrate filter mapping file written successfully."
if [ -d "$BUNDLE_DIR" ]; then 
    echo " -> [✓] Bundle created at: $BUNDLE_DIR"
    echo " -> [⚠️] NOTICE: Remember to replace placeholder '$proj_name' file with actual binary!"
fi
if [ -f "$LOADER_DIR/${proj_name}.plist" ]; then 
    echo " -> [✓] PreferenceLoader mapping implemented (.plist file initialized)."
fi
echo "=================================================================="
echo "Workspace parameters generated. Ready for Clangy.sh compilation layer."
