#!/bin/bash

# 1. Clean up old workspace manifests if they exist
rm -rf .repo/local_manifests

# 2. Initialize Matrixx A16 Source
repo init -u https://github.com/ProjectMatrixx/android.git -b 16.2 --git-lfs

# 3. Pull your custom m14x / Exynos manifests
git clone https://github.com/MrPankaj24/local_manifests -b lineage-23.2 .repo/local_manifests

# 4. Sync the complete source tree
/opt/crave/resync.sh

# 5. Set your custom identity signatures
export BUILD_USERNAME="MrPankaj24"
export BUILD_HOSTNAME="MrPankaj24"

# 6. Initialize build environment
source build/envsetup.sh
lunch matrixx_m14x-userdebug

# 7. Clean and compile
make installclean
m bacon

# 8. Verify the build and list output folder contents
echo "=========================================================="
echo "Build command finished. Verifying output..."
echo "=========================================================="

# Search for the compiled Matrixx zip file
ZIP_FILE=$(ls out/target/product/m14x/Matrixx-*.zip 2>/dev/null | head -n 1)

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
    # This will print every file, image, and log sitting in the target folder
    ls -lh out/target/product/m14x/
else
    echo "Directory does not exist. The build failed before generating the device folder."
fi
echo "----------------------------------------------------------"
