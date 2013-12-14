// PlayerView1.h
// Created by Zhang Yungui on 13-12-13.
// Copyright (c) 2013, https://github.com/rhcad/touchvg

#import "GraphView5.h"

class GiTransform;
class MgShapeDoc;
class MgShapes;

@interface PlayerView1 : GraphView5 {
    __block GiTransform *_xform;
    __block MgShapeDoc  *_doc;
    __block MgShapes    *_dynShapes;
    dispatch_semaphore_t    _semaphore;
}
@end
