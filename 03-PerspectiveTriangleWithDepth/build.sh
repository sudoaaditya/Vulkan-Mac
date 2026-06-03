
rm -rf vk.app
rm -rf _VulkanWindowLog.txt

mkdir -p vk.app/Contents/MacOS

clang++ -Wno-deprecated-declarations -arch arm64 -o vk.app/Contents/MacOS/vk vk.mm -framework Foundation -framework Cocoa -framework QuartzCore 