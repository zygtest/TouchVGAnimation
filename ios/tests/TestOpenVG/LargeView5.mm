// LargeView5.mm
// Copyright (c) 2013, https://github.com/rhcad/touchvg

#import "LargeView5.h"
#import "GraphView5.h"
#import "PlayerView1.h"
#import "ARCMacro.h"

@implementation LargeView5

- (id)initWithFrame:(CGRect)frame withFlags:(int)t
{
    self = [super initWithFrame:frame];
    if (self) {
        float w = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 1024 : 2048;
        
        if (t & 0x40000) {
            _subview = [[PlayerView1 alloc]initWithFrame:CGRectMake(0, 0, w, w) withFlags:t];
        }
        else if (t & 0x400) {   // testDynCurves
            _subview = [[GraphView5 alloc]initWithFrame:CGRectMake(0, 0, w, w) withFlags:t];
        }
        else {
            _subview = [[GraphView5 alloc]initWithFrame:CGRectMake(0, 0, w, w) withFlags:t];
        }
        [self addSubview:_subview];
        [_subview RELEASE];
        
        self.delegate = self;
        self.contentSize = _subview.frame.size;
        self.minimumZoomScale = 0.25f;
        self.maximumZoomScale = 5.f;
    }
    
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _subview;
}

- (void)save
{
    [_subview save];
}

- (void)startAnimation
{
    [_subview startAnimation];
}

- (void)tearDown
{
    [_subview tearDown];
}

@end
