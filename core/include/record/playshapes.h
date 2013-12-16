// playshapes.h
// Copyright (c) 2013, Zhang Yungui
// License: LGPL, https://github.com/rhcad/touchvg

#ifndef TOUCHVG_PLAY_SHAPES_H_
#define TOUCHVG_PLAY_SHAPES_H_

class GiTransform;
class MgShapeDoc;
class MgShapes;

class MgPlayShapes
{
public:
    enum { ADD = 1, EDIT = 2, DEL = 4,
        STATIC_CHANGED = 0x1000000,
        DYNAMIC_CHANGED = 0x2000000,
        FRAME_CHANGED = STATIC_CHANGED | DYNAMIC_CHANGED,
        TICKMASK = 0xFFFFFF,    // 4 hours limit
    };
    MgPlayShapes(const char* path, GiTransform* xform);
    ~MgPlayShapes();
    
    void close();
    bool loadFirstFile();
    int loadNextFile(int index);
    
    void copyXformTo(GiTransform* xform);
    MgShapeDoc* pickFrontDoc();
    MgShapes* pickDynShapes();
    
private:
    struct Impl;
    Impl* _im;
};

#endif // TOUCHVG_PLAY_SHAPES_H_
