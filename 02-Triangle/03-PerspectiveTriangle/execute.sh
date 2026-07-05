
VULKAN_MAC_SDK=$HOME/VulkanSDK/Vulkan/macOS

export VULKAN_ICD_FILENAMES=$VULKAN_MAC_SDK/macOS/share/vulkan/icd.d/MoltenVK_icd.json
export VULKAN_LAYER_PATH=$VULKAN_MAC_SDK/macOS/share/vulkan/explicit_layer.d

./vk.app/Contents/MacOS/vk