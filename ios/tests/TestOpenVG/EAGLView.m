// EAGLView.m
// Created by mmalc Crawford on 11/18/10.
// Copyright 2010 Apple Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EAGLView.h"
#import "ARCMacro.h"

@interface EAGLView ()
- (void)initView;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end

@implementation EAGLView

@synthesize context = _context;
@synthesize framebufferWidth;
@synthesize framebufferHeight;
@synthesize animating, animationFrameInterval, displayLink;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
	if (self) {
        [self initView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	if (self) {
        [self initView];
    }
    
    return self;
}

- (void)initView
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking : @FALSE,
                                      kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8 };
    eaglLayer.contentsScale = [UIScreen mainScreen].scale;  // support for Retina screen
    
    animationFrameInterval = 1;
    [self setupContext];
}

- (void)dealloc
{
    [self tearDown];
    [super DEALLOC];
}

- (void)setContext:(EAGLContext *)newContext
{
    if (_context != newContext) {
        [self deleteFramebuffer];
        
        [_context RELEASE];
        _context = [newContext RETAIN];
        
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)createFramebuffer
{
    if (_context && !defaultFramebuffer) {
        [EAGLContext setCurrentContext:_context];
        
        // Create default framebuffer object.
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        
        GLint status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (status != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"Failed to make complete framebuffer object %x", status);
    }
}

- (void)deleteFramebuffer
{
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
    }
}

- (BOOL)setFramebuffer
{
    BOOL recreated = FALSE;
    
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        
        if (!defaultFramebuffer) {
            [self createFramebuffer];
            recreated = TRUE;
        }
        
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        glViewport(0, 0, framebufferWidth, framebufferHeight);
    }
    
    return recreated;
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        success = [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}

- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
}

#pragma mark - Animation

/*
 Frame interval defines how many display frames must pass between each time the display link fires.
 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
 */
- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating) {
        self.displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(drawFrame)];
        [self.displayLink setFrameInterval:animationFrameInterval];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

- (void)drawFrame
{
}

- (void)tearDown
{
    [self stopAnimation];
    [self deleteFramebuffer];
    if (_context) {
        if ([EAGLContext currentContext] == _context)
            [EAGLContext setCurrentContext:nil];
        [_context RELEASE];
        _context = nil;
    }
}

- (BOOL)setupContext {
    self.contentScaleFactor = [UIScreen mainScreen].scale;  // support for Retina screen
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context || ![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        return NO;
    }
    
    return [self setFramebuffer];
}

// See https://developer.apple.com/library/ios/qa/qa1704/_index.html
- (UIImage *)snapshot {
    GLint width = 0, height = 0;
    
    // Get the size of the backing CAEAGLLayer
    [EAGLContext setCurrentContext:_context];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    NSInteger dataLength = width * height * 4;
    GLubyte *data = dataLength ? (GLubyte*)malloc(dataLength * sizeof(GLubyte)) : NULL;
    
    if (!data) {
        NSLog(dataLength ? @"Out of memory to snapshot" : @"No backing layer to snapshot");
        return nil;
    }
    
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    BOOL opaque = self.layer.opaque;
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace,
                                    kCGBitmapByteOrder32Big | (opaque ? kCGImageAlphaNoneSkipLast
                                                               : kCGImageAlphaPremultipliedLast),
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    
    CGFloat scale = self.contentScaleFactor;
    CGSize sizeInPt = CGSizeMake(width / scale, height / scale);
    
    UIGraphicsBeginImageContextWithOptions(sizeInPt, opaque, scale);
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.f, 0.f, sizeInPt.width, sizeInPt.height), iref);
    
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    return image;
}

@end
