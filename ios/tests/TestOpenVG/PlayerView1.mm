// PlayerView1.mm
// Created by Zhang Yungui on 13-12-13.
// Copyright (c) 2013, https://github.com/rhcad/touchvg

#import "PlayerView1.h"
#import "ARCMacro.h"
#include "playshapes.h"
#include "mgshapedoc.h"
#include "testvgcanvas.h"

int giGetScreenDpi();

@implementation PlayerView1

- (void)dealloc
{
    [super DEALLOC];
    
    if (_doc) {
        _doc->release();
        _doc = NULL;
    }
    if (_dynShapes) {
        _dynShapes->release();
        _dynShapes = NULL;
    }
    dispatch_release(_semaphore);
    delete _xform;
}

- (id)initWithFrame:(CGRect)frame withFlags:(int)t;
{
    self = [super initWithFrame:frame withFlags:t];
    if (self) {
        _xform = new GiTransform();
        _xform->setResolution(giGetScreenDpi());
        _semaphore = dispatch_semaphore_create(0);
        
        [self performSelector:@selector(startPlayer) withObject:nil afterDelay:0.1];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _xform->setWndSize(self.bounds.size.width, self.bounds.size.height);
}

- (void)startAnimation
{
    // not use CADisplayLink
}

- (void)render
{
    GiGraphics gs(_xform);
    
    gs.beginPaint(_tester->beginPaint(true));
    _doc->draw(gs);
    _tester->endPaint();
    
    gs.beginPaint(_tester->beginPaint(false));
    _dynShapes->draw(gs);
    _tester->endPaint();
    
    gs.endPaint();
}

- (void)play {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self drawFrame];
        dispatch_semaphore_signal(_semaphore);
    });
}

- (void)startPlayer
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                       objectAtIndex:0] stringByAppendingPathComponent:@"rec"];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        MgPlayShapes player([path UTF8String], _xform);
        
        if (player.loadFirstFile()) {
            player.copyXform(_xform);
            _doc = player.pickFrontDoc();
            _dynShapes = player.pickDynShapes();
            [self play];
            
            for (int index = 1; ; index++) {
                int res = player.loadNextFile(index);
                
                if (res & MgPlayShapes::FRAME_CHANGED) {
                    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
                    
                    if (res & MgPlayShapes::STATIC_CHANGED) {
                        if (_doc) _doc->release();
                        _doc = player.pickFrontDoc();
                    }
                    if (res & MgPlayShapes::DYNAMIC_CHANGED) {
                        if (_dynShapes) _dynShapes->release();
                        _dynShapes = player.pickDynShapes();
                    }
                    [self play];
                }
                else {
                    break;
                }
            }
        }
    });
}

@end
