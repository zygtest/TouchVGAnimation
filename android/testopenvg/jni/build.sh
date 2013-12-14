#!/bin/sh
# Type './build.sh' to make Android native libraries.
# Type `./build.sh -swig` to re-generate JNI classes too.
#
if [ "$1"x = "-swig"x ] || [ ! -f touchvg_java_wrap.cpp ] ; then # Make JNI classes
    mkdir -p ../src/touchvg/core
    rm -rf ../src/touchvg/core/*.*
    
    swig -c++ -java -D__ANDROID__ \
        -module touchvg -package touchvg.core \
        -outdir ../src/touchvg/core \
        -o touchvg_java_wrap.cpp \
        -I../../../core/include/glcanvas \
        -I../../../core/include/record \
        -I../../../thirdparty/TouchVGShape/core/include/geom \
        -I../../../thirdparty/TouchVGShape/core/include/canvas \
        -I../../../thirdparty/TouchVGShape/core/include/graph \
        -I../../../thirdparty/TouchVGShape/core/include/shape \
        -I../../../thirdparty/TouchVGShape/core/include/shapedoc \
        -I../../../thirdparty/TouchVGShape/core/include/storage \
        ../../../core/src/glcanvas/glcanvas.i
    python replacejstr.py
fi
ndk-build
