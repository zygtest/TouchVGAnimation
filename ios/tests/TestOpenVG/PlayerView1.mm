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
    dispatch_release(_semaphore);
    delete _gs;
    delete _xform;
    [super DEALLOC];
}

- (id)initWithFrame:(CGRect)frame withFlags:(int)t;
{
    self = [super initWithFrame:frame withFlags:t];
    if (self) {
        _xform = new GiTransform();
        _xform->setResolution(giGetScreenDpi());
        _gs = new GiGraphics(_xform);
    }
    return self;
}

- (void)layoutSubviews
{
    if (![self isDrawing]) {
        [super layoutSubviews];
        _xform->setWndSize(self.bounds.size.width, self.bounds.size.height);
    }
}

- (void)tearDown
{
    _gs->stopDrawing();
    if (_semaphore) {
        dispatch_semaphore_wait(_semaphore,  10 * NSEC_PER_SEC);
        if (CACurrentMediaTime() - _lastEndTime < 1000.0)
            giSleep(500);
    }
    [super tearDown];
    MgObject::release_pointer(_doc);
    MgObject::release_pointer(_dynShapes);
}

- (void)startAnimation
{
    _semaphore = dispatch_semaphore_create(0);
    [self startPlayer];
}

- (void)render
{
    if (!_gs->isStopping() && _gs->beginPaint(_tester->beginPaint(true))) {
        _doc->draw(*_gs);
        _gs->endPaint();
    }
    if (!_gs->isStopping() && _gs->beginPaint(_tester->beginPaint(false))) {
        _dynShapes->draw(*_gs);
        _gs->endPaint();
    }
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
            player.copyXformTo(_xform);
            _doc = player.pickFrontDoc();
            _dynShapes = player.pickDynShapes();
            [self play];
            
            for (int index = 1; !_gs->isStopping(); index++) {
                int res = player.loadNextFile(index);
                
                if (res & MgPlayShapes::FRAME_CHANGED) {
                    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
                    if (_gs->isStopping())
                        break;
                    if (res & MgPlayShapes::STATIC_CHANGED) {
                        MgObject::release_pointer(_doc);
                        _doc = player.pickFrontDoc();
                    }
                    if (res & MgPlayShapes::DYNAMIC_CHANGED) {
                        MgObject::release_pointer(_dynShapes);
                        _dynShapes = player.pickDynShapes();
                    }
                    [self play];
                }
                else {
                    break;
                }
            }
        }
        player.close();
        dispatch_semaphore_signal(_semaphore);
    });
}

@end
