#!/bin/bash

echo "=========================================================="
echo " 1. NUKING OLD CACHE (Fixing Repo/Hook Clashes) "
echo "=========================================================="
# This forcefully deletes the old LineageOS cache so Matrixx can sync cleanly
rm -rf * .repo*

echo "=========================================================="
echo " 2. INITIALIZING PROJECT MATRIXX (Android 16.2) "
echo "=========================================================="
repo init -u https://github.com/ProjectMatrixx/android.git -b 16.2 --git-lfs

echo "=========================================================="
echo " 3. CLONING DEVICE TREES "
echo "=========================================================="
git clone https://github.com/MrPankaj24/local_manifests -b lineage-23.2 .repo/local_manifests

echo "=========================================================="
echo " 4. SYNCING SOURCE CODE "
echo "=========================================================="
# This will take a while since it's downloading a fresh tree
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

echo "=========================================================="
echo " 7. VERIFYING OUTPUT "
echo "=========================================================="
# Search for the compiled Matrixx zip file
ZIP_FILE=$(ls out/target/product/m14x/*Matrixx*.zip 2>/dev/null | head -n 1)

if [ -f "$ZIP_FILE" ]; then
    echo "🎉 SUCCESS: Project Matrixx compiled perfectly!"
    echo "ROM zip found at: $ZIP_FILE"
else
    echo "❌ ERROR: No Matrixx zip file found. The build likely failed or crashed."
    echo "Check the terminal logs above to find out where the compiler tripped up."
fi

echo ""
echo "📂 Contents of the output directory (out/target/product/m14x/):"
echo "----------------------------------------------------------"
if [ -d "out/target/product/m14x" ]; then
    ls -lh out/target/product/m14x/
else
    echo "Directory does not exist. The build failed before generating the device folder."
fi
echo "----------------------------------------------------------"
