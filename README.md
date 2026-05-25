# RetroHackLab TweakBuilder Suite v1.3.0 🚀

A production-hardened development environment and automation toolchain designed by **RetroHackLab (2026)**. This workflow automates the generation of control structures, directory layouts, Substrate filters, PreferenceBundles, and production Makefiles for legacy iOS architecture research.

---

## ⚠️ Important Disclaimer (Educational Purposes)

> [!IMPORTANT]
> **This suite is strictly developed for educational, scientific research, and computer science learning purposes.**
> It was built to study system interactions, iOS Substrate hooking mechanics, and compilation toolchains on legacy Apple hardware. The author (**RetroHackLab**) does not condone, promote, or support any malicious usage or unauthorized modification of production devices. Use responsibly within safe, isolated laboratory environments.

---

## 🛠️ Complete Script Ecosystem

The workspace relies on 5 specialized modules:

1. **`./build.sh`** : The master orchestrator. Configures metadata, ranges, environments, and builds all project compilation scripts and the `Makefile`.
2. **`./SDK_INSTALL.sh`** : Toolchain installer. Fetches and sets up the required iOS SDKs via Theos dependencies.
3. **`./RUN_Permissions.sh`** : Environment lock. Configures root-level permissions for the SDKs and deploys mandatory compiler system files.
4. **`./Clangy.sh`** : The compiler core. Compiles your custom source codes directly into target `.dylib` binaries and executable bundles.
5. **`./DEBIAN.sh`** : The packager. Compresses the structural workspace layout into the final installable `.deb` package.

---

## 🚀 How to Use (Step-by-Step)

### 1️⃣ Step 1: Initialize the SDK Toolchain
First, download and extract the required iOS SDK components:
```bash
chmod +x SDK_INSTALL.sh
./SDK_INSTALL.sh

### 2️⃣ Step 2: Lock Permissions & Deploy Core Files
Run the mandatory permission mapping script to secure the SDK directory and inject required development payloads:
```bash
chmod +x RUN_Permissions.sh
./RUN_Permissions.sh

### 3️⃣ Step 3: Configure Project Architecture
Launch the builder to set up your project name, package identity, architecture types, and automatically compile your build structures:
```bash
chmod +x build.sh
./build.sh

### 4️⃣ Step 4: Compile and Package Your Tweak
Once build.sh has successfully written your workspace parameters, you can use the automated Makefile instructions:
To clean, compile, stage, and package your tweak:
```bash
./DEBIAN.sh
