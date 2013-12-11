//! \file testvgcanvas.cpp
//! \brief Implement the testing class: TestOpenVGCanvas.
// Copyright (c) 2013, https://github.com/rhcad/touchvg

#include "testvgcanvas.h"
#include "testcanvas.h"
#include "GiOpenVGCanvas.h"
#include "vgext.h"
#include <math.h>

struct TestOpenVGCanvas::Impl
{
    GiOpenVGCanvas  canvas;
    int             width;
    int             height;
    float           scale;
};

TestOpenVGCanvas::TestOpenVGCanvas(int width, int height, int scale)
{
    _impl = new Impl();
    _impl->width = width * scale;
    _impl->height = height * scale;
    _impl->scale = scale;
    
    vgCreateContextMNK(_impl->width, _impl->height, VG_RENDERING_BACKEND_TYPE_OPENGLES20);
}

TestOpenVGCanvas::~TestOpenVGCanvas()
{
    delete _impl;
    vgDestroyContextMNK();
}

void TestOpenVGCanvas::resize(int width, int height)
{
    _impl->width = width;
    _impl->height = height;
    vgResizeSurfaceMNK(width, height);
}

int TestOpenVGCanvas::getWidth()
{
    return _impl->width;
}

int TestOpenVGCanvas::getHeight()
{
    return _impl->height;
}

void TestOpenVGCanvas::prepareToDraw(bool dynzoom, int mstime)
{
	VGfloat clearColor[] = {1,1,1,1};
	vgSetfv(VG_CLEAR_COLOR, 4, clearColor);
	
	vgSeti(VG_MATRIX_MODE, VG_MATRIX_PATH_USER_TO_SURFACE);
	vgLoadIdentity();
    vgScale(_impl->scale, -_impl->scale);
    vgTranslate(0, _impl->height);
    
    if (dynzoom) {
        float seconds = 1e-3f * (float)mstime;
        float scale = 0.1f + 5 * fabsf(sinf(seconds));
        vgScale(scale, scale);
        vgTranslate(500 * sinf(2 * seconds) - 200, 500 * cosf(2 * seconds) - 200);
    }
}

void TestOpenVGCanvas::draw(int bits, int n, bool pathCached)
{
    _impl->canvas.beginPaint(pathCached);
    _impl->canvas.setPen(0, 3, 0, 0);
    TestCanvas::test(&_impl->canvas, bits, n);
    _impl->canvas.endPaint();
}

void TestOpenVGCanvas::dyndraw(float x, float y)
{
    static float phase = 0;
    phase += 1;
    
    _impl->canvas.beginPaint(false);
    _impl->canvas.setPen(0, 0, 1, phase);
    _impl->canvas.setBrush(0x88005500, 0);
    _impl->canvas.drawEllipse(x - 50, y - 50, 100, 100, true, true);
    _impl->canvas.endPaint();
}
