//! \file testvgcanvas.h
//! \brief Define the testing class: TestOpenVGCanvas.
// Copyright (c) 2013, https://github.com/rhcad/touchvg

#ifndef TOUCHVG_TEST_OPENVGCANVAS_H
#define TOUCHVG_TEST_OPENVGCANVAS_H

class GiCanvas;

//! The testing class for GiOpenVGCanvas.
/*! \ingroup GRAPH_INTERFACE
 */
class TestOpenVGCanvas
{
public:
    TestOpenVGCanvas(int width, int height, int scale);
    ~TestOpenVGCanvas();
    
    void resize(int width, int height);
    int getWidth();
    int getHeight();
    void prepareToDraw(bool dynzoom, int mstime);
    
    void draw(int bits, int n, bool pathCached = true);
    void dyndraw(float x, float y);
    
    GiCanvas* beginPaint(bool pathCached) const;
    void endPaint();
    
private:
    struct Impl;
    Impl* _impl;
};

#endif // TOUCHVG_TEST_OPENVGCANVAS_H
