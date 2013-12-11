// GraphView3.h
// Copyright (c) 2012-2013, https://github.com/rhcad/touchvg

#import <UIKit/UIKit.h>

class GiQuartzCanvas;

@interface GraphView3 : UIView {
    GiQuartzCanvas  *_canvas;
    CGPoint         _lastpt;
    UIView          *_dynview;
    int             _flags;
    int             _drawTimes;
    
    float           _lineWidth;
    int             _lineStyle;
    bool            _useFill;
    bool            _antiAlias;
    float           _flatness;
    int             _testOrder;
}

- (id)initWithFrame:(CGRect)frame withFlags:(int)t;
- (void)save;
- (void)draw:(GiQuartzCanvas*)canvas;
- (void)dynDraw:(GiQuartzCanvas*)canvas;
- (void)showDrawnTime:(int)ms logging:(BOOL)log;

@end

@interface GraphView4 : GraphView3
@end
