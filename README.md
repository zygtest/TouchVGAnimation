# TouchVGAnimation

## Overview

TouchVGAnimation is a vector drawing framework designed for animation using OpenVG 1.1 and OpenGL ES 2.0 for iOS and Android platforms.

It renders shapes animated with [MonkVG](https://github.com/micahpearlman/MonkVG) and [TouchVGShape](https://github.com/rhcad/TouchVGShape), and supports cross-platform canvas and shape interfaces for coding in C++.

This is an open source LGPL 2.1 licensed project that is in active development. Contributors and sponsors welcome.

## Build

* Build for **iOS** platform on Mac OS X.

  > Open ios/TestVG.xcworkspace in Xcode, then run TestOpenVG project.
  >
  > To run on iPhone or iPad device, you may need to change the application's Bundle Identifier like 'com.yourcompany.TestOpenVG', and select your Code Signing Identity.

* Build for **Android** platform on Mac, Linux or Windows.

  > Import the TestOpenVG project in eclipse and run it.
  >
  > You can rebuild the native library: Cd the 'android' folder of this project and type `./build.sh` to build with ndk-build. MinGW and MSYS are recommend on Windows.
  >
  > Type `./build.sh -swig` to re-generate JNI classes, SWIG and Python are needed then.

## TODO

- Implement image and text drawing using OpenVG in the canvas adapter.

## Thanks

Micah Pearlman, the author of MonkVG and MonkSVG.
