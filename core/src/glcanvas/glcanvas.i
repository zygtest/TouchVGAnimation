// Copyright (c) 2013, Zhang Yungui, https://github.com/rhcad/touchvg

#ifdef SWIGJAVA
%insert("runtime") %{
#ifdef __ANDROID__
#define SWIG_JAVA_NO_DETACH_CURRENT_THREAD
#define SWIG_JAVA_ATTACH_CURRENT_THREAD_AS_DAEMON
#endif
%}
#endif

%module glcanvas

%{
#include "testvgcanvas.h"
#include "mgshapedoc.h"
#include "mglayer.h"
#include "mgstorage.h"
#include "gicanvas.h"
#include "mgbasicspreg.h"
#include "mgspfactory.h"
#include "playshapes.h"
%}

%include "testvgcanvas.h"

%include "mgtol.h"
%include "mgvec.h"
%include "mgpnt.h"
%include "mgmat.h"
%include "mgbox.h"

%include "gixform.h"
%include "gipath.h"
%include "gicolor.h"
%include "gicontxt.h"
%include "gigraph.h"
%include "gicanvas.h"
%include "mgobject.h"
%include "mgshape.h"
%include "mgshapes.h"
%include "mgshapedoc.h"
%include "mgspfactory.h"
%include "mglayer.h"
%include "mgstorage.h"
%include "mgbasicspreg.h"

%include "playshapes.h"

#ifdef SWIGJAVA
%{
struct TmpJOBJ {
    JNIEnv* env;
    jobject* jo;
    template <class T>
    TmpJOBJ(JNIEnv* e, T* v) : env(e), jo((jobject*)v) {}
    TmpJOBJ(JNIEnv* e, jobject& v) : env(e), jo(&v) { }
    ~TmpJOBJ() { if (*jo) { env->DeleteLocalRef(*jo); *jo = 0; } }
};
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* /*ajvm*/, void* /*reserved*/) {
    return JNI_VERSION_1_6;
}
%}
#endif