#!/bin/bash
set -e

echo "=========================================================="
echo " 1. CLEANING PREVIOUS ARTIFACTS AND CONFLICTING HOOKS "
echo "=========================================================="
rm -rf out/
rm -rf .repo/local_manifests/
rm -rf .repo/local_manifest.xml

echo "Set github account.."
git config --global user.name "MrPankaj24"
git config --global user.email "surendersingh54275@gmail.com"


# Safely delete leftover git hooks from ID 72 so repo init won't crash on signature checks
find .repo/ -name "hooks" -type d -exec rm -rf {} + 2>/dev/null || true

echo "=========================================================="
echo " 2. SWITCHING MANIFEST TO PROJECT MATRIXX (Android 16.2) "
echo "=========================================================="
# Removed the illegal --ignore-hooks flag that caused the returned 2 error
repo init -u https://github.com/ProjectMatrixx/android.git -b 16.2 --git-lfs --depth=1

echo "=========================================================="
echo " 3. CLONING DEVICE LOCAL MANIFESTS "
echo "=========================================================="
git clone https://github.com/MrPankaj24/local_manifests -b lineage-23.2 .repo/local_manifests

echo "=========================================================="
echo " 4. SYNCING SOURCE CODE VIA CRAVE RESYNC "
echo "=========================================================="
# Use Crave's internal resync script to rapidly pull changes over the cloud cache
if [ -f /opt/crave/resync.sh ]; then
    /opt/crave/resync.sh
else
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
fi

echo "=========================================================="
echo " 5. SETTING UP ENVIRONMENT & MAINTAINER INFO "
echo "=========================================================="
export BUILD_USERNAME="MrPankaj24"
export BUILD_HOSTNAME="MrPankaj24"
export TZ="Asia/Kolkata"

source build/envsetup.sh
lunch matrixx_m14x-userdebug

echo "=========================================================="
echo " 6. STARTING COMPILATION "
echo "=========================================================="
make installclean
mka bacon -j$(nproc --all)
