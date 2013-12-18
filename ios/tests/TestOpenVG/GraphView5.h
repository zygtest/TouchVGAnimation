// GraphView5.h
// Copyright (c) 2013, https://github.com/rhcad/touchvg

#import "EAGLView.h"

class TestOpenVGCanvas;

@interface GraphView5 : EAGLView {
    TestOpenVGCanvas  *_tester;
    __block CGPoint _lastpt;
    int             _flags;
    CFTimeInterval  _startTime;
    CFTimeInterval  _lastEndTime;
}

- (id)initWithFrame:(CGRect)frame withFlags:(int)t;
- (void)save;
- (void)render;
- (BOOL)isDrawing;

@end
