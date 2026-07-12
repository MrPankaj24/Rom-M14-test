#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "=========================================================="
echo " 1. CLEANING PREVIOUS BUILD ARTIFACTS AND LOCAL MANIFESTS "
echo "=========================================================="
# DO NOT kill .repo. Instead, cleanly wipe the staging areas.
rm -rf out/
rm -rf .repo/local_manifests/
rm -rf .repo/local_manifest.xml

echo "=========================================================="
echo " 2. SWITCHING MANIFEST TO PROJECT MATRIXX (Android 16.2) "
echo "=========================================================="
# Force a manifest switch without breaking the underlying git objects cache
repo init -u https://github.com/ProjectMatrixx/android.git -b 16.2 --git-lfs --depth=1

echo "=========================================================="
echo " 3. CLONING DEVICE LOCAL MANIFESTS "
echo "=========================================================="
# Clones your custom device trees manifest repository directly into place
git clone https://github.com/MrPankaj24/local_manifests -b lineage-23.2 .repo/local_manifests

echo "=========================================================="
echo " 4. SYNCING SOURCE CODE VIA CRAVE CLIENT "
echo "=========================================================="
# Using Crave's internal optimized script to pull changes over the cache safely
/opt/crave/resync.sh

echo "=========================================================="
echo " 5. SETTING UP ENVIRONMENT & MAINTAINER INFO "
echo "=========================================================="
export BUILD_USERNAME="MrPankaj24"
export BUILD_HOSTNAME="MrPankaj24"
export TZ="Asia/Kolkata"

# Load build commands
source build/envsetup.sh

# Select target combo
lunch matrixx_m14x-userdebug

echo "=========================================================="
echo " 6. STARTING COMPILATION "
echo "=========================================================="
# 'make installclean' keeps the core compiled files but wipes old packaging outputs safely
make installclean

# Trigger compilation
m bacon

echo "=========================================================="
echo " 7. VERIFYING OUTPUT "
echo "=========================================================="
ZIP_FILE=$(ls out/target/product/m14x/*Matrixx*.zip 2>/dev/null | head -n 1)

if [ -f "$ZIP_FILE" ]; then
    echo "🎉 SUCCESS: Project Matrixx compiled perfectly!"
    echo "ROM zip found at: $ZIP_FILE"
else
    echo "❌ ERROR: No Matrixx zip file found. The build likely failed or crashed."
fi

echo ""
echo "📂 Contents of the output directory:"
echo "----------------------------------------------------------"
if [ -d "out/target/product/m14x" ]; then
    ls -lh out/target/product/m14x/
else
    echo "Directory out/target/product/m14x does not exist."
fi
echo "----------------------------------------------------------"
