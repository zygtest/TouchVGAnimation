// ViewFactory.mm
// Copyright (c) 2013, https://github.com/rhcad/touchvg

#import "GraphView5.h"
#import "LargeView5.h"
#import "PlayerView1.h"
#import "ARCMacro.h"

static UIViewController *_tmpController = nil;

@interface GLViewController : UIViewController

@end

@implementation GLViewController

- (void)viewDidAppear:(BOOL)animated
{
    [(EAGLView *)self.view startAnimation];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [(EAGLView *)self.view tearDown];
    [super viewWillDisappear:animated];
}

@end

static void addView(NSMutableArray *arr, NSString* title, UIView* view)
{
    if (arr) {
        [arr addObject:title];
    }
    else if (view) {
        _tmpController = [[GLViewController alloc] init];
        _tmpController.title = title;
        _tmpController.view = view;
    }
}

static void addView5(NSMutableArray *arr, NSUInteger &i, NSUInteger index, 
                     NSString* title, int flags, CGRect frame)
{
    GraphView5 *view = nil;
    
    if (!arr && index == i++) {
        if (flags & 0x40000) {
            view = [[PlayerView1 alloc]initWithFrame:frame withFlags:flags];
        } else {
            view = [[GraphView5 alloc]initWithFrame:frame withFlags:flags];
        }
    }
    addView(arr, title, view);
    [view RELEASE];
}

static void addLargeView5(NSMutableArray *arr, NSUInteger &i, NSUInteger index, 
                         NSString* title, int flags, CGRect frame)
{
    LargeView5 *view = nil;
    
    if (!arr && index == i++) {
        view = [[LargeView5 alloc]initWithFrame:frame withFlags:flags];
    }
    addView(arr, title, view);
    [view RELEASE];
}

static void gatherTestView(NSMutableArray *arr, NSUInteger index, CGRect frame)
{
    NSUInteger i = 0;
    
    addView5(arr, i, index, @"PlayerView1 from ", 0x40000, frame);
    addView5(arr, i, index, @"PlayerView1", 0x40000, frame);
    addLargeView5(arr, i, index, @"PlayerView1 in large view", 0x40000, frame);
    
    addView5(arr, i, index, @"testRect", 0x01, frame);
    addView5(arr, i, index, @"testLine", 0x02, frame);
    addView5(arr, i, index, @"testTextAt", 0x04, frame);
    addView5(arr, i, index, @"testEllipse", 0x08, frame);
    addView5(arr, i, index, @"testQuadBezier", 0x10, frame);
    addView5(arr, i, index, @"testCubicBezier", 0x20, frame);
    addView5(arr, i, index, @"testPolygon", 0x40, frame);
    addView5(arr, i, index, @"testClearRect", 0x80|0x40|0x02, frame);
    addView5(arr, i, index, @"testClipPath", 0x100, frame);
    addView5(arr, i, index, @"testHandle", 0x200, frame);
    addView5(arr, i, index, @"testDynCurves", 0x400, frame);
    
    addView5(arr, i, index, @"testRect dynzoom", 0x01|0x10000, frame);
    addView5(arr, i, index, @"testLine dynzoom", 0x02|0x10000, frame);
    addView5(arr, i, index, @"testTextAt dynzoom", 0x04|0x10000, frame);
    addView5(arr, i, index, @"testEllipse dynzoom", 0x08|0x10000, frame);
    addView5(arr, i, index, @"testQuadBezier dynzoom", 0x10|0x10000, frame);
    addView5(arr, i, index, @"testCubicBezier dynzoom", 0x20|0x10000, frame);
    addView5(arr, i, index, @"testPolygon dynzoom", 0x40|0x10000, frame);
    
    addLargeView5(arr, i, index, @"testTextAt in large view", 0x04|0x20000, frame);
    addLargeView5(arr, i, index, @"testCubicBezier in large view", 0x20|0x20000, frame);
    addLargeView5(arr, i, index, @"testHandle in large view", 0x200|0x20000, frame);
    addLargeView5(arr, i, index, @"testDynCurves in large view", 0x400|0x20000, frame);
    
    addLargeView5(arr, i, index, @"testRect dynzoom in large view", 0x01|0x30000, frame);
    addLargeView5(arr, i, index, @"testCubicBezier dynzoom in large view", 0x20|0x30000, frame);
}

void getTestViewTitles(NSMutableArray *arr)
{
    gatherTestView(arr, 0, CGRectNull);
}

UIViewController *createTestView(NSUInteger index, CGRect frame)
{
    _tmpController = nil;
    gatherTestView(nil, index, frame);
    return _tmpController;
}
