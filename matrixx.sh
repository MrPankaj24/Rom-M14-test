#!/bin/bash
set -e

echo "=========================================================="
echo " 1. CLEANING PREVIOUS BUILD ARTIFACTS AND LOCAL MANIFESTS "
echo "=========================================================="
rm -rf out/
rm -rf .repo/local_manifests/
rm -rf .repo/local_manifest.xml

echo "=========================================================="
echo " 2. SWITCHING MANIFEST TO PROJECT MATRIXX (Android 16.2) "
echo "=========================================================="
# Added --ignore-hooks to allow switching manifest without validation crashes
repo init -u https://github.com/ProjectMatrixx/android.git -b 16.2 --git-lfs --depth=1 --ignore-hooks

echo "=========================================================="
echo " 3. CLONING DEVICE LOCAL MANIFESTS "
echo "=========================================================="
git clone https://github.com/MrPankaj24/local_manifests -b lineage-23.2 .repo/local_manifests

echo "=========================================================="
echo " 4. SYNCING SOURCE CODE AND FIXING HOOKS INTERNALLY "
echo "=========================================================="
# Force repo to override conflicting hook paths before running the main sync script
repo sync -d --force-sync --ignore-hooks || true

# Now call the optimized Crave resync utility to pull remaining components over the cache
/opt/crave/resync.sh

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
m bacon
