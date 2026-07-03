
rm -rf window.app

mkdir -p window.app/Contents/MacOS

clang -Wno-deprecated-declarations -arch arm64 -o window.app/Contents/MacOS/window window.m -framework Foundation -framework Cocoa -framework QuartzCore