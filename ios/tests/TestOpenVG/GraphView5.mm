// GraphView5.mm
// Copyright (c) 2013, https://github.com/rhcad/touchvg

#import "GraphView5.h"
#import "ARCMacro.h"
#include "testvgcanvas.h"

@implementation GraphView5

- (void)dealloc
{
    delete _tester;
    [super DEALLOC];
}

- (id)initWithFrame:(CGRect)frame withFlags:(int)t
{
    self = [super initWithFrame:frame];
    if (self) {
        _flags = t;
        _startTime = CACurrentMediaTime();
        _tester = new TestOpenVGCanvas(self.bounds.size.width, self.bounds.size.height,
                                       self.contentScaleFactor);
        [self addGestureRecognizers];
    }
    
    return self;
}

- (void)tearDown
{
    [super tearDown];
    if (_tester) {
        delete _tester;
        _tester = NULL;
    }
}

- (BOOL)isDrawing
{
    return _lastEndTime > 1.0e10;
}

- (void)drawFrame
{
    BOOL recreated = [self setFramebuffer];
    
    _lastEndTime = 1.0e20;
    if (recreated) {
        _tester->resize(self.framebufferWidth, self.framebufferHeight);
    }
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    bool dynzoom = (_flags & 0x10000) != 0;
    _tester->prepareToDraw(dynzoom, (CACurrentMediaTime() - _startTime) * 1000.0);
    
    [self render];
    [self presentFramebuffer];
    _lastEndTime = CACurrentMediaTime();
}

- (void)render
{
    bool inScrollView = (_flags & 0x20000) != 0;
    bool pathCached = (_flags & 0x400) == 0;        // not save paths when testDynCurves
    _tester->draw(_flags, inScrollView ? 600 : 300, pathCached);
    
    _tester->dyndraw(_lastpt.x, _lastpt.y);
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
}

- (void)save {
    UIImage *image = [self snapshot];
    if (!image) {
        return;
    }
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                          NSUserDomainMask, YES) objectAtIndex:0];
    static int order = 0;
    NSString *fmt = image.scale > 1.5f ? @"%@/page%d@2x.png" : @"%@/page%d.png";
    NSString *filename = [NSString stringWithFormat:fmt, path, order++ % 10];
    
    NSData* imageData = UIImagePNGRepresentation(image);
    BOOL ret = imageData && [imageData writeToFile:filename atomically:NO];
    
    if (ret) {
        NSString *msg = [NSString stringWithFormat:@"%.0f x %.0f\n%@",
                         image.size.width, image.size.height,
                         [filename substringFromIndex:[filename rangeOfString:@"Doc"].location]];
        [[[UIAlertView alloc] initWithTitle:@"Save" message:msg
                                   delegate:nil cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end
