// GraphView3.mm
// Copyright (c) 2012-2013, https://github.com/rhcad/touchvg

#import "GraphView3.h"
#import <QuartzCore/QuartzCore.h>  // renderInContext
#import "ARCMacro.h"
#include "GiQuartzCanvas.h"
#include "testcanvas.h"
#include <mach/mach_time.h>

static int machToMs(uint64_t start)
{
    uint64_t elapsedTime = mach_absolute_time() - start;
    static double ticksToNanoseconds = -1.0;
    
    if (ticksToNanoseconds < 0) {
        mach_timebase_info_data_t timebase;
        mach_timebase_info(&timebase);
        ticksToNanoseconds = (double)timebase.numer / timebase.denom * 1e-6;
    }
    
    return (int)(elapsedTime * ticksToNanoseconds);
}

@interface DynGraphView3 : UIView
@end

@implementation DynGraphView3

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    GraphView3 *parent = (GraphView3 *)self.superview;
    CGContextRef context = UIGraphicsGetCurrentContext();
    GiQuartzCanvas canvas;
    
    if (canvas.beginPaint(context)) {
        [parent dynDraw:&canvas];
        canvas.endPaint();
    }
}

@end

@implementation GraphView3

- (void)dealloc
{
    if (_dynview && _dynview != self) {
        [_dynview RELEASE];
        _dynview = nil;
    }
    delete _canvas;
    [super DEALLOC];
}

- (id)initWithFrame:(CGRect)frame withFlags:(int)t
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        self.opaque = NO;
        
        _flags = t;
        _canvas = new GiQuartzCanvas();
        _dynview = self;
        if (_flags & 0x10000) {         // with embeded dynview
            _dynview = [[DynGraphView3 alloc]initWithFrame:self.bounds];
            [self addSubview:_dynview];
        }
        [self addGestureRecognizers];
        
        _lineWidth = 3;
        _lineStyle = 0;
        _useFill = false;
        _antiAlias = true;
        _flatness = 3;
    }
    return self;
}

- (void)dynDraw:(GiQuartzCanvas*)canvas
{
    static float phase = 0;
    phase += 1;
    canvas->setPen(0, 0, 1, phase);
    canvas->setBrush(0x88005500, 0);
    canvas->drawEllipse(_lastpt.x - 50, _lastpt.y - 50, 100, 100, true, true);
}

- (void)draw:(GiQuartzCanvas*)canvas
{
    CGContextRef c = canvas->context();
    
    CGContextSetFlatness(c, _flatness);
    CGContextSetAllowsAntialiasing(c, _antiAlias);
    canvas->setPen(0, _lineWidth, _lineStyle, 0);
    canvas->setBrush(_useFill ? 0x4400ff00 : 0, 0);
    
    if (_flags & 0x20000) {     // in scroll view
        TestCanvas::test(canvas, _flags, 600);
    }
    else {
        TestCanvas::test(canvas, _flags, 300);
    }
}

- (void)drawRect:(CGRect)rect
{
    uint64_t start = mach_absolute_time();
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (_canvas->beginPaint(context)) {
        [self draw:_canvas];
        if (_dynview == self)
            [self dynDraw:_canvas];
        _canvas->endPaint();
    }
    
    int drawTime = machToMs(start);
    bool inthread = ((_flags & 0x40000) != 0);
    
    [self showDrawnTime:drawTime logging:!inthread];
    if (_drawTimes > 0) {
        _drawTimes++;
    }
    if (inthread && _testOrder >= 0 && (_flags & 0x400) == 0) {
        if (_testOrder == 0) {
            NSLog(@"\torder\tantiAlias\tfill\tstyle\tflatness\twidth\ttime(ms)");
        }
        else {
            NSLog(@"\t%d\t%d\t%d\t%d\t%.1f\t%.0f\t%d", 
                  _testOrder, _antiAlias, _useFill, _lineStyle, _flatness, _lineWidth, drawTime);
        }
        
        ++_testOrder;
        int i = 0;
        
        for (int j = 0; j < 4; j++) {
            _antiAlias = (j % 4 < 2);
            _useFill = (j % 2 == 0);
            for (_lineStyle = 0; _lineStyle <= 1; _lineStyle++) {
                for (_flatness = 1.f; _flatness <= 5.f; _flatness += 1.f) {
                    for (_lineWidth = 1; _lineWidth <= 50; _lineWidth += 10) {
                        if (++i == _testOrder)
                            return;
                    }
                }
            }
        }
        _testOrder = -1;
    }
}

- (void)showDrawnTime:(int)ms logging:(BOOL)log
{
    UIViewController *detailc = (UIViewController *)self.superview.nextResponder;
    if (![detailc respondsToSelector:@selector(saveDetailPage:)]) {
        detailc = (UIViewController *)self.superview.superview.nextResponder;
    }
    NSString *title = detailc.title;
    NSRange range = [title rangeOfString:@" ms - "];
    if (range.length > 0) {
        title = [title substringFromIndex:range.location + 6];
    }
    if (_testOrder > 0) {
        detailc.title = [[NSString stringWithFormat:@"%d:%d ms - ", _testOrder, ms]
                         stringByAppendingString:title];
    }
    else if (_drawTimes > 0) {
        detailc.title = [[NSString stringWithFormat:@"%d:%d ms - ", _drawTimes, ms]
                         stringByAppendingString:title];
    }
    else {
        detailc.title = [[NSString stringWithFormat:@"%d ms - ", ms]
                         stringByAppendingString:title];
    }
    if (log) {
        NSLog(@"drawRect: %@", detailc.title);
    }
}

- (UIImage *)snapshot
{
    uint64_t start = mach_absolute_time();
    CGSize size = self.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(size, self.opaque, 0);
    
    int drawTime = machToMs(start);
    NSLog(@"UIGraphicsBeginImageContext: %d ms", drawTime);
    
#if 1   // no HW
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    GiQuartzCanvas canvas;
    
    if (canvas.beginPaint(ctx)) {
        [self draw:&canvas];
        canvas.endPaint();
    }
    
    int drawTime2 = machToMs(start);
    NSLog(@"draw: %d ms", drawTime2 - drawTime);
    
#else   // fastest with internal cache
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
#endif
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)shotCG
{
    uint64_t start = mach_absolute_time();
    float scale = [UIScreen mainScreen].scale;
    CGSize size = self.bounds.size;
    
    size.width *= scale;
    size.height *= scale;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width * 4,
                                             colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    int drawTime = machToMs(start);
    NSLog(@"CGBitmapContextCreate: %d ms", drawTime);
    
    CGContextClearRect(ctx, CGRectMake(0, 0, size.width, size.height));
    
    int drawTime2 = machToMs(start);
    NSLog(@"CGContextClearRect: %d ms", drawTime2 - drawTime);
    
    // Make coord system same as UIView
    CGContextTranslateCTM(ctx, 0, size.height);
    CGContextScaleCTM(ctx, scale, - scale);
    
#if 1
    GiQuartzCanvas canvas;
    
    if (canvas.beginPaint(ctx)) {
        [self draw:&canvas];
        canvas.endPaint();
    }
#else   // slower about 10 ms
    [self.layer drawInContext:ctx];
#endif
    
    int drawTime3 = machToMs(start);
    NSLog(@"draw: %d ms", drawTime3 - drawTime2);
    
#if 1
    CGImageRef cgimage = CGBitmapContextCreateImage(ctx);
    UIImage *image = [[[UIImage alloc]initWithCGImage:cgimage scale:scale
                                          orientation:UIImageOrientationUp] AUTORELEASE];
    CGImageRelease(cgimage);
    CGContextRelease(ctx);
#else   // will fail as following
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(ctx);
    
    int drawTime4 = machToMs(start);
    NSLog(@"GetImage: %d ms", drawTime4 - drawTime3);
#endif
    
    return image;
}

- (void)saveImage:(UIImage *)image start:(uint64_t)start
{
    int drawTime = machToMs(start);
    NSLog(@"saveAsPng: %d ms", drawTime);
    
    if (!image) {
        return;
    }
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                          NSUserDomainMask, YES) objectAtIndex:0];
    static int order = 0;
    NSString *filename = [NSString stringWithFormat:@"%@/page%d.png", path, order++ % 10];
    
    NSData* imageData = UIImagePNGRepresentation(image);
    if (imageData) {
        [imageData writeToFile:filename atomically:NO];                 
    }
    
    int savedTime = machToMs(start) - drawTime;
    NSString *msg = [NSString stringWithFormat:@"%d ms, %d ms, %d x %d\n%@", 
                     drawTime, savedTime, 
                     (int)image.size.width, (int)image.size.height,
                     [filename substringFromIndex:[filename length] - 22]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save" message:msg
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert RELEASE];
}

- (void)save
{
    uint64_t start = mach_absolute_time();
#if 0
    [self saveImage:[self snapshot] start:start];   // faster
#else
    [self saveImage:[self shotCG] start:start];
#endif
}

- (void)addGestureRecognizers {
    UIPanGestureRecognizer *oneFingerPan =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerPan:)];
    oneFingerPan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:oneFingerPan];
    [oneFingerPan RELEASE];
}

- (void)oneFingerPan:(UIPanGestureRecognizer *) recognizer {
    _lastpt = [recognizer locationInView:self];
    [self setNeedsDisplay];
}

@end

@interface GraphView4() {
    BOOL _canceled;
}
@end

@implementation GraphView4

- (void)removeFromSuperview
{
    _canceled = YES;
    [super removeFromSuperview];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    _drawTimes++;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (!_canceled) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setNeedsDisplay];
            });
        }
    });
}

@end
