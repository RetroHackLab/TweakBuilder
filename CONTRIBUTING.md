# Contributing to RetroHackLab Projects 🧪

First off, thank you for taking the time to contribute! This laboratory relies on community curiosity to keep legacy iOS development, retro-automation, and system research alive.

By participating in this repository, you agree to abide by our educational guidelines, structural development layout, and code standards.

---

## 📜 Ethical & Educational Policy

> [!CAUTION]
> All projects under the **RetroHackLab** organization are created strictly for **educational purposes, scientific research, and system interaction studies**. 
> We do not accept contributions that target active production security gates, promote software piracy, or attempt to weaponize automation scripts. Keep all contributions educational, research-focused, and safe.

---

## ⚙️ Understanding the 5-Script Ecosystem

To ensure your contributions do not break the production-hardened toolchain pipeline, please make sure you understand the role of each component before modifying code:

1. **`./build.sh`** : The master configuration script. Writes metadata, parses versions, sets up folder maps, and generates the main `Makefile`.
2. **`./SDK_INSTALL.sh`** : Toolchain installer module. Fetches and installs standard iOS SDK structures via Theos.
3. **`./RUN_Permissions.sh`** : Permission lock & core injector. Sets root-level directory profiles on SDK headers and deploys mandatory compiler system files.
4. **`./Clangy.sh`** : The compiler execution engine. Handles Clang calls to generate target `.dylib` binaries and executable bundles.
5. **`./DEBIAN.sh`** : The compression engine. Cleans system junk and invokes `dpkg-deb` to build the installable `.deb` bundle.

---

## 🛠️ How Can I Contribute?

### 1. Reporting Bugs & Issues
If you encounter script validation failures, broken directory permissions, or compilation errors:
* Check if the issue already exists in the tracker.
* Open a new issue with a clear title (e.g., `[Bug] build.sh fails range validation on pre-release 1.0-BETA`).
* Provide your environment specs (Host OS, target device architecture `armv7`/`arm64`, and step execution logs).

### 2. Suggesting Enhancements
Want to add a new layout profile, support a newer deployment range, or optimize script parameters?
* Open an issue outlining your concept.
* Explain the computer science use-case and why it benefits legacy environment research.

### 3. Submitting Code Changes (Pull Requests)
Ready to improve the script parameters? Follow this workflow to ensure a smooth review:

1. **Fork the repository** and create your branch from `main`:
   ```bash
   git checkout -b feature/amazing-optimization
