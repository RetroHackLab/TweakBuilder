#!/bin/bash

# ==============================================================================
# TweakBuilder v1.3.0 - Developed by RetroHackLab (2026)
# Production-Hardened Environment Orchestrator & Structural Injector
# ==============================================================================

clear
echo "=================================================================="
echo "          __====__                               "
echo "        _-        -_      TWEAK BUILDER v1.3.0   "
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
        echo "    📝 Required: Between 0.9.0 and 1.0-BETA"
        read -p "    👉 Enter Pre-Release Version: " version
        if [[ ! "$version" =~ ^(0\.9\.[0-9]+(-[a-zA-Z0-9]+)?|1\.0-BETA)$ ]]; then
            echo "❌ Wrong Answer: Version '$version' is out of range! [Unsupported]"
            exit 1
        fi
        ;;
    2)
        echo "    📝 Required: Between 0.9.5 and 3.2.2"
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
echo "    1) 100% Native Tweak (Hidden Pack / Scripts & Binaries)"
echo "    2) Native Tweak (Contains Settings/Preferences Only)"
echo "    3) Utility Tweak (100% Application - Optional /var access)"
echo "    4) System Tweak (Contains *app, Substrate Hooks, or /usr accessor)"
echo "    5) Custom Tweak"
read -p "    👉 Select Tweak Type [1-5]: " type_choice

# Clean previous build workspaces safely
rm -rf Package
mkdir -p Package/DEBIAN

case $type_choice in
    1) 
        tweak_type="Native Tweak (100% Pack)" 
        ;;
    2) 
        tweak_type="Native Tweak (Prefs)" 
        ;;
    3)
        tweak_type="Utility Tweak"
        read -p "    ❓ Does this utility contain an App bundle [y/n]? " has_app
        if [[ "$has_app" != "y" && "$has_app" != "n" && "$has_app" != "Y" && "$has_app" != "N" ]]; then
            echo "❌ Wrong Answer: Expected y/n. [Unsupported]"
            exit 1
        fi
        if [[ "$has_app" == "y" || "$has_app" == "Y" ]]; then mkdir -p Package/Applications; fi
        ;;
    4)
        tweak_type="System Tweak"
        read -p "    ❓ Does this system environment contain an App bundle [y/n]? " has_app
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

read -p "    ❓ Do you want to add preinst module [y/n]? " add_post
if [[ "$add_post" != "y" && "$add_post" != "n" && "$add_post" != "Y" && "$add_post" != "N" ]]; then
    echo "❌ Wrong Answer: Expecting boolean evaluation. [Unsupported]"
    exit 1
fi

# Setup preinst script if required
if [[ "$add_post" == "y" || "$add_post" == "Y" ]]; then
    read -p "    👉 Enter product module device identifier (e.g., iPhone8,1): " prod_module
    if [[ -z "$prod_module" ]]; then echo "❌ Error: Code blank! [Invalid]"; exit 1; fi
    
    cat << 'EOF' > Package/DEBIAN/preinst
#!/bin/sh
MODEL=$(sysctl -n hw.machine)
EOF
    echo "TARGET_MODEL=\"$prod_module\"" >> Package/DEBIAN/preinst
    cat << 'EOF' >> Package/DEBIAN/preinst

if
