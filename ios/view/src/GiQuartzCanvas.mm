//! \file GiQuartzCanvas.mm
//! \brief Implement GiCanvas adapter class: GiQuartzCanvas.
// Copyright (c) 2012-2013, https://github.com/rhcad/touchvg

#import "ARCMacro.h"
#include "GiQuartzCanvas.h"

static const float patDash[]      = { 4, 2, 0 };
static const float patDot[]       = { 1, 2, 0 };
static const float patDashDot[]   = { 10, 2, 2, 2, 0 };
static const float dashDotdot[]   = { 20, 2, 2, 2, 2, 2, 0 };
const float* const GiQuartzCanvas::LINEDASH[] = { NULL, patDash, patDot, patDashDot, dashDotdot };

GiQuartzCanvas::GiQuartzCanvas() : _ctx(NULL)
{
}

GiQuartzCanvas::~GiQuartzCanvas()
{
}

CGContextRef GiQuartzCanvas::context()
{
    return _ctx;
}

bool GiQuartzCanvas::beginPaint(CGContextRef context)
{
    if (_ctx || !context) {
        return false;
    }
    
    _ctx = context;
    _fill = false;
    
    CGContextSetShouldAntialias(_ctx, true);
    CGContextSetAllowsAntialiasing(_ctx, true);
    CGContextSetFlatness(_ctx, 3);
    CGContextSetLineCap(_ctx, kCGLineCapRound);
    CGContextSetLineJoin(_ctx, kCGLineJoinRound);
    CGContextSetRGBFillColor(_ctx, 0, 0, 0, 0);
    
    return true;
}

void GiQuartzCanvas::endPaint()
{
    _ctx = NULL;
}

float GiQuartzCanvas::colorPart(int argb, int byteOrder)
{
    return (float)((argb >> (byteOrder * 8)) & 0xFF) / 255.f;
}

void GiQuartzCanvas::setPen(int argb, float width, int style, float phase)
{
    if (argb != 0) {
        CGContextSetRGBStrokeColor(_ctx, colorPart(argb, 2), colorPart(argb, 1),
                                   colorPart(argb, 0), colorPart(argb, 3));
    }
    if (width > 0) {
        CGContextSetLineWidth(_ctx, width);
    }
    
    if (style > 0 && style < 5) {
        CGFloat pattern[6];
        int n = 0;
        for (; LINEDASH[style][n] > 0.1f; n++) {
            pattern[n] = LINEDASH[style][n] * (width < 1.f ? 1.f : width);
        }
        CGContextSetLineDash(_ctx, phase, pattern, n);
        CGContextSetLineCap(_ctx, kCGLineCapButt);
    }
    else if (0 == style) {
        CGContextSetLineDash(_ctx, 0, NULL, 0);
        CGContextSetLineCap(_ctx, kCGLineCapRound);
    }
}

void GiQuartzCanvas::setBrush(int argb, int style)
{
    if (0 == style) {
        float alpha = colorPart(argb, 3);
        _fill = alpha > 1e-2f;
        CGContextSetRGBFillColor(_ctx, colorPart(argb, 2), colorPart(argb, 1),
                                 colorPart(argb, 0), alpha);
    }
}

void GiQuartzCanvas::saveClip()
{
    CGContextSaveGState(_ctx);
}

void GiQuartzCanvas::restoreClip()
{
    CGContextRestoreGState(_ctx);
}

void GiQuartzCanvas::clearRect(float x, float y, float w, float h)
{
    CGContextClearRect(_ctx, CGRectMake(x, y, w, h));
}

void GiQuartzCanvas::drawRect(float x, float y, float w, float h, bool stroke, bool fill)
{
    if (fill && _fill) {
        CGContextFillRect(_ctx, CGRectMake(x, y, w, h));
    }
    if (stroke) {
        CGContextStrokeRect(_ctx, CGRectMake(x, y, w, h));
    }
}

bool GiQuartzCanvas::clipRect(float x, float y, float w, float h)
{
    CGContextClipToRect(_ctx, CGRectMake(x, y, w, h));
    CGRect rect = CGContextGetClipBoundingBox(_ctx);
    return !CGRectIsEmpty(rect);
}

void GiQuartzCanvas::drawLine(float x1, float y1, float x2, float y2)
{
    CGContextBeginPath(_ctx);
    CGContextMoveToPoint(_ctx, x1, y1);
    CGContextAddLineToPoint(_ctx, x2, y2);
    CGContextStrokePath(_ctx);
}

void GiQuartzCanvas::drawEllipse(float x, float y, float w, float h, bool stroke, bool fill)
{
    if (fill && _fill) {
        CGContextFillEllipseInRect(_ctx, CGRectMake(x, y, w, h));
    }
    if (stroke) {
        CGContextStrokeEllipseInRect(_ctx, CGRectMake(x, y, w, h));
    }
}

void GiQuartzCanvas::beginPath()
{
    CGContextBeginPath(_ctx);
}

void GiQuartzCanvas::moveTo(float x, float y)
{
    CGContextMoveToPoint(_ctx, x, y);
}

void GiQuartzCanvas::lineTo(float x, float y)
{
    CGContextAddLineToPoint(_ctx, x, y);
}

void GiQuartzCanvas::bezierTo(float c1x, float c1y, float c2x, float c2y, float x, float y)
{
    CGContextAddCurveToPoint(_ctx, c1x, c1y, c2x, c2y, x, y);
}

void GiQuartzCanvas::quadTo(float cpx, float cpy, float x, float y)
{
    CGContextAddQuadCurveToPoint(_ctx, cpx, cpy, x, y);
}

void GiQuartzCanvas::closePath()
{
    CGContextClosePath(_ctx);
}

void GiQuartzCanvas::drawPath(bool stroke, bool fill)
{
    fill = fill && _fill;
    CGContextDrawPath(_ctx, (stroke && fill) ? kCGPathEOFillStroke
                      : (fill ? kCGPathEOFill : kCGPathStroke));  // will clear the path
}

bool GiQuartzCanvas::clipPath()
{
    CGContextClip(_ctx);
    CGRect rect = CGContextGetClipBoundingBox(_ctx);
    return !CGRectIsEmpty(rect);
}

void GiQuartzCanvas::drawHandle(float x, float y, int type)
{
    if (type >= 0 && type < 6) {
        NSString *names[] = { @"vgdot1.png", @"vgdot2.png", @"vgdot3.png", 
            @"vg_lock.png", @"vg_unlock.png", @"vg_back.png", @"vg_endedit.png" };
        NSString *name = [@"TouchVG.bundle/" stringByAppendingString:names[type]];
        UIImage *image = [UIImage imageNamed:name];
        
        if (image) {
            CGImageRef img = [image CGImage];
            float w = CGImageGetWidth(img) / image.scale;
            float h = CGImageGetHeight(img) / image.scale;
            
            CGAffineTransform af = CGAffineTransformMake(1, 0, 0, -1, x - w * 0.5f, y + h * 0.5f);
            CGContextConcatCTM(_ctx, af);
            CGContextDrawImage(_ctx, CGRectMake(0, 0, w, h), img);
            CGContextConcatCTM(_ctx, CGAffineTransformInvert(af));
            
            // Upside down: CGContextDrawImage(_ctx, CGRectMake(x - w * 0.5f, y - h * 0.5f, w, h), img);
        }
    }
}

void GiQuartzCanvas::drawBitmap(const char* name, float xc, float yc,
                                  float w, float h, float angle)
{
    UIImage *image = [UIImage imageNamed:@"app57.png"];
    if (image) {
        CGImageRef img = [image CGImage];
        CGAffineTransform af = CGAffineTransformMake(1, 0, 0, -1, xc, yc);
        af = CGAffineTransformRotate(af, angle);
        CGContextConcatCTM(_ctx, af);
        CGContextDrawImage(_ctx, CGRectMake(-w/2, -h/2, w, h), img);
        CGContextConcatCTM(_ctx, CGAffineTransformInvert(af));
    }
}

float GiQuartzCanvas::drawTextAt(const char* text, float x, float y, float h, int align)
{
    UIGraphicsPushContext(_ctx);
    
    NSString *str = [[NSString alloc] initWithUTF8String:text];
    
    // The actual font size = target height * temporary font size / temporary font line height (actsize.height)
    UIFont *font = [UIFont systemFontOfSize:h]; // Temporary font size: h
    CGSize actsize = [str sizeWithFont:font     // Use temporary font
                     constrainedToSize:CGSizeMake(1e4f, h)];    // For one line
    font = [UIFont systemFontOfSize: h * h / actsize.height];
    actsize = [str sizeWithFont:font];          // The actual font size
    
    x -= (align == 2) ? actsize.width : ((align == 1) ? actsize.width / 2 : 0);
    [str drawAtPoint:CGPointMake(x, y) withFont:font];
    [str RELEASE];
    
    UIGraphicsPopContext();
    
    return actsize.width;
}
