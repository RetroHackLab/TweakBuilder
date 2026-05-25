#!/bin/bash
sudo apt update && sudo apt install git -y
git clone https://github.com/theos/sdks
mv sdks sdk
chmod -R 755 sdk
mkdir include
mkdir toolchain && mkdir templates
mkdir toolchain/linux/iphone
tar --lzma -xf toolchain.tar.lzma -C "toolchain/linux/iphone/"
source ~/.bashrc
ln -s "toolchain/linux/iphone/bin/arm64-apple-darwin14-ld" /usr/bin/ld
ln -s "$/toolchain/linux/iphone/bin/ld" /usr/bin/ld
CAT <<EOF > include/.keep
fix -c http://iphone.apple.com
run -bsxc.plist
EOF
chmod +x .keep
