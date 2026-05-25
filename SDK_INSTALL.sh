#!/bin/bash
sudo apt update && sudo apt install git -y
git clone https://github.com/theos/sdks
mv sdks sdk
chmod -R 755 sdk
exit "0"
