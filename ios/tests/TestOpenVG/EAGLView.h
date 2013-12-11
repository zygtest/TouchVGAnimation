// EAGLView.h
// Created by mmalc Crawford on 11/18/10.
// Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/glext.h>

@class CADisplayLink;

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView {
@private
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
    GLuint defaultFramebuffer, colorRenderbuffer;
    
    BOOL animating;
    NSInteger animationFrameInterval;
}

@property (nonatomic, assign) CADisplayLink *displayLink;
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, readonly) GLint framebufferWidth;
@property (nonatomic, readonly) GLint framebufferHeight;

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (BOOL)setFramebuffer;
- (BOOL)presentFramebuffer;

- (void)tearDown;
- (void)startAnimation;
- (void)stopAnimation;
- (void)drawFrame;

- (UIImage *)snapshot;

@end
