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
export TZ="Asia/Kolkata"

# 6. Initialize build environment
source build/envsetup.sh
lunch matrixx_m14x-userdebug

# 7. Clean and compile
make installclean
m bacon

# 8. Automated Post-Build Pixeldrain Upload
echo "Checking for compiled flashable zip..."
for file in out/target/product/m14x/ProjectMatrixx*.zip; do
    if [ -f "$file" ]; then
        echo "Uploading build to Pixeldrain: $file"
        # Swap out the dummy token below with your actual Pixeldrain API key
        curl -T "$file" -u :YOUR_PIXELDRAIN_API_KEY https://pixeldrain.com/api/file/
        echo -e "\nUpload completed successfully."
    else
        echo "Compilation file not found. Check build logs above for compilation crashes."
    fi
done
