#!/bin/sh
# Type './build.sh' to make Android native libraries.
# Type `./build.sh -swig` to re-generate JNI classes too.
#
cd ../thirdparty/Shape/android; ./build.sh; cd ../../../android

cd ../thirdparty/MonkVG/projects/MonkVG-Android/jni; ndk-build; cd ../../../../../android

cd testopenvg/jni; ./build.sh $1; cd ../..
