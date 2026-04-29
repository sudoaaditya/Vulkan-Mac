# Vulkan on macOS

A collection of Vulkan code samples and setup notes for macOS using MoltenVK.

---

## Prerequisites

- macOS 10.15 (Catalina) or later
- Xcode Command Line Tools
- [Homebrew](https://brew.sh/)
- A GPU that supports Metal (all Apple Silicon and most modern Intel Macs)

---

## Dependencies

### 1. Vulkan SDK (via LunarG)

Download and install the macOS Vulkan SDK from [LunarG](https://vulkan.lunarg.com/sdk/home#mac).

After installation, add the following to your shell profile (`~/.zshrc` or `~/.bash_profile`):

```bash
export VULKAN_SDK=$HOME/VulkanSDK/<version>/macOS
export PATH=$VULKAN_SDK/bin:$PATH
export DYLD_LIBRARY_PATH=$VULKAN_SDK/lib:$DYLD_LIBRARY_PATH
export VK_ICD_FILENAMES=$VULKAN_SDK/share/vulkan/icd.d/MoltenVK_icd.json
export VK_LAYER_PATH=$VULKAN_SDK/share/vulkan/explicit_layer.d
```

Replace `<version>` with your installed SDK version (e.g., `1.3.280.0`).

### 2. MoltenVK

MoltenVK is included in the LunarG SDK. It translates Vulkan API calls to Apple's Metal API.

Alternatively, install via Homebrew:

```bash
brew install molten-vk
```

### 3. GLFW (windowing)

```bash
brew install glfw
```

### 4. GLM (math library)

```bash
brew install glm
```

### 5. GLSL Shader Compiler

```bash
brew install glslang
```

---

## Building

### With CMake

```bash
mkdir build && cd build
cmake ..
make
```

### Manual Compilation Example

```bash
clang++ -std=c++17 main.cpp \
  -I$VULKAN_SDK/include \
  -L$VULKAN_SDK/lib \
  -lvulkan -lglfw \
  -o VulkanApp
```

### Compiling Shaders

```bash
glslc shader.vert -o vert.spv
glslc shader.frag -o frag.spv
```

---

## Running

```bash
./VulkanApp
```

If you see a validation layer warning about `VK_LAYER_PATH`, ensure your environment variables are sourced correctly.

---

## MoltenVK Notes

- Vulkan on macOS runs via **MoltenVK**, a Vulkan-to-Metal translation layer.
- Not all Vulkan extensions are supported. Check [MoltenVK feature support](https://github.com/KhronosGroup/MoltenVK/blob/main/Docs/MoltenVK_Runtime_UserGuide.md) for details.
- Apple Silicon (M1/M2/M3/M4) is fully supported via Rosetta or native ARM builds.

---

## Useful Links

- [Vulkan Tutorial](https://vulkan-tutorial.com/)
- [LunarG Vulkan SDK](https://vulkan.lunarg.com/sdk/home#mac)
- [MoltenVK GitHub](https://github.com/KhronosGroup/MoltenVK)
- [Vulkan Specification](https://registry.khronos.org/vulkan/)
- [GLFW Documentation](https://www.glfw.org/docs/latest/)

---

## Troubleshooting

| Issue | Fix |
|---|---|
| `vkCreateInstance` fails | Check `VK_ICD_FILENAMES` points to `MoltenVK_icd.json` |
| Validation layers not found | Verify `VK_LAYER_PATH` is set and SDK is installed |
| Black screen / no output | Ensure shaders are compiled to SPIR-V (`.spv`) |
| `dyld` library not found | Re-export `DYLD_LIBRARY_PATH` and restart terminal |
