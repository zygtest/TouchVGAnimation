//! \file GiQuartzCanvas.h
//! \brief Define GiCanvas adapter class: GiQuartzCanvas.
// Copyright (c) 2012-2013, https://github.com/rhcad/touchvg

#ifndef TOUCHVG_IOS_QUARTZCANVAS_H
#define TOUCHVG_IOS_QUARTZCANVAS_H

#include "gicanvas.h"
#include <CoreGraphics/CoreGraphics.h>

//! GiCanvas adapter using Quartz 2D.
/*! \ingroup GROUP_IOS
 */
class GiQuartzCanvas : public GiCanvas
{
public:
    GiQuartzCanvas();
    virtual ~GiQuartzCanvas();
    
    bool beginPaint(CGContextRef context);
    void endPaint();
    CGContextRef context();
    
    static int getScreenDpi();
    
    static const float* const LINEDASH[];     //!< Dash pattern, 0..4
    static float colorPart(int argb, int byteOrder);
    
public:
    void setPen(int argb, float width, int style, float phase);
    void setBrush(int argb, int style);
    void clearRect(float x, float y, float w, float h);
    void drawRect(float x, float y, float w, float h, bool stroke, bool fill);
    void drawLine(float x1, float y1, float x2, float y2);
    void drawEllipse(float x, float y, float w, float h, bool stroke, bool fill);
    void beginPath();
    void moveTo(float x, float y);
    void lineTo(float x, float y);
    void bezierTo(float c1x, float c1y, float c2x, float c2y, float x, float y);
    void quadTo(float cpx, float cpy, float x, float y);
    void closePath();
    void drawPath(bool stroke, bool fill);
    void saveClip();
    void restoreClip();
    bool clipRect(float x, float y, float w, float h);
    bool clipPath();
    void drawHandle(float x, float y, int type);
    void drawBitmap(const char* name, float xc, float yc, float w, float h, float angle);
    float drawTextAt(const char* text, float x, float y, float h, int align);
    
private:
    CGContextRef    _ctx;
    bool            _fill;
};

#endif // TOUCHVG_IOS_QUARTZCANVAS_H
