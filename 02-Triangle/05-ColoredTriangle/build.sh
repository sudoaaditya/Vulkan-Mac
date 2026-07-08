
rm -rf vk.app
rm -rf _VulkanWindowLog.txt

mkdir -p vk.app/Contents/MacOS

clang++ -Wno-deprecated-declarations -arch arm64 -o vk.app/Contents/MacOS/vk -I $HOME/VulkanSDK/Vulkan/macOS/include -L $HOME/VulkanSDK/Vulkan/macOS/lib -F $HOME/VulkanSDK/Vulkan/macOS/Frameworks -rpath $HOME/VulkanSDK/Vulkan/macOS/Frameworks vk.mm -framework Foundation -framework Cocoa -framework QuartzCore -framework vulkan

./vk.app/Contents/MacOS/vk