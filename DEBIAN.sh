#!/bin/bash

# ==============================================================================
# DEBIAN.sh v1.0.0 - Developed by RetroHackLab (2026)
# Standardized Gzip DEB Packager Engine
# ==============================================================================

clear
echo "=================================================================="
echo "          __====__                               "
echo "        _-        -_      DEBIAN PACKAGER        "
echo "       /  O    O    \     by RetroHackLab        "
echo "      |    ____      |                           "
echo "       \  \____/    /     Retro-Automation OS    "
echo "        _-________-_                             "
echo "=================================================================="
echo ""

# 1. Vérification de la structure de base
if [ ! -d "Package" ] || [ ! -d "Package/DEBIAN" ] || [ ! -f "Package/DEBIAN/control" ]; then
    echo "❌ Error: 'Package/DEBIAN/control' tree structure not found!"
    echo "👉 Please execute 'build.sh' first to set up your workspace environment."
    exit 1
fi

# 2. Demande du nom personnalisé pour le fichier de sortie .deb
echo "[-] STEP 1: Package Configuration Output"
read -p "    👉 Enter output .deb file name (e.g., mytweak_v1.0): " deb_name

if [[ -z "$deb_name" || "$deb_name" =~ [[:space:]] ]]; then
    echo "❌ Wrong Answer: File name cannot be empty or contain spaces! [Unsupported]"
    exit 1
fi

# S'assurer que l'extension .deb est présente sans la dupliquer
if [[ ! "$deb_name" =~ \.deb$ ]]; then
    deb_name="${deb_name}.deb"
fi

# 3. Nettoyage des permissions système sensibles (Crucial pour éviter les erreurs d'installation sur iOS)
echo "[-] STEP 2: Standardizing file system execution permissions..."
find Package -type d -exec chmod 755 {} \;
find Package -type f -not -path "Package/DEBIAN/*" -exec chmod 644 {} \;

# S'assurer que les scripts de maintenance DEBIAN gardent leurs droits d'exécution
if [ -f "Package/DEBIAN/preinst" ]; then chmod 755 Package/DEBIAN/preinst; fi
if [ -f "Package/DEBIAN/postinst" ]; then chmod 755 Package/DEBIAN/postinst; fi
if [ -f "Package/DEBIAN/prerm" ]; then chmod 755 Package/DEBIAN/prerm; fi
if [ -f "Package/DEBIAN/postrm" ]; then chmod 755 Package/DEBIAN/postrm; fi

echo "    ✅ Permissions tree standardized successfully."
echo ""

# 4. Phase de compilation du paquet binaire via dpkg-deb avec compression gzip obligatoirement
echo "[-] STEP 3: Compiling environment..."
echo "    📦 Invoking: dpkg-deb -Zgzip -b Package $deb_name"
echo "------------------------------------------------------------------"

# Exécution de la commande de packaging
dpkg-deb -Zgzip -b Package "$deb_name"

# Vérification du code de retour de la commande dpkg
if [ $? -eq 0 ]; then
    echo "------------------------------------------------------------------"
    echo "🎉 SUCCESS: Package created seamlessly!"
    echo "📦 Target Binary: $(pwd)/$deb_name"
    echo "=================================================================="
else
    echo "------------------------------------------------------------------"
    echo "❌ Error: Critical packaging pipeline failure encountered during dpkg-deb routing."
    exit 1
fi
