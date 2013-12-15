// Copyright (c) 2013, https://github.com/rhcad/touchvg

package vgtest.testview.canvas;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import touchvg.core.TestOpenVGCanvas;

import android.app.Activity;
import android.content.Context;
import android.opengl.GLSurfaceView;
import android.view.MotionEvent;
import android.view.View;

public class GLSurfaceView1 extends GLSurfaceView {
    private TestOpenVGCanvas mTester;
    private int mCreateFlags;
    private long mStartTime;
    private float mLastX = 50;
    private float mLastY = 50;

    static {
        System.loadLibrary("touchvg");
    }
    
    public GLSurfaceView1(Context context) {
        super(context);
        setEGLContextClientVersion(2);         // OpenGL ES 2.0
        setRenderer(new TestRenderer());

        mCreateFlags = ((Activity) context).getIntent().getExtras().getInt("flags");
        
        this.setOnTouchListener(new OnTouchListener() {
            public boolean onTouch(View v, MotionEvent event) {
                mLastX = event.getX(0);
                mLastY = event.getY(0);
                return true;
            }
        });
    }
    
    protected void render(TestOpenVGCanvas tester) {
        boolean pathCached = (mCreateFlags & 0x400) == 0;
        mTester.draw(mCreateFlags, 300, pathCached);
        mTester.dyndraw(mLastX, mLastY);
    }

    private class TestRenderer implements GLSurfaceView.Renderer {

        public void onSurfaceCreated(GL10 gl, EGLConfig config) {
        }

        public void onSurfaceChanged(GL10 gl, int width, int height) {
            if (mTester == null) {
                mTester = new TestOpenVGCanvas(width, height, 1);
                mStartTime = System.currentTimeMillis();
            } else {
                mTester.resize(width, height);
            }
            gl.glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
            gl.glViewport(0, 0, width, height);
        }

        public void onDrawFrame(GL10 gl) {
            if (mTester != null) {
                gl.glClear(GL10.GL_COLOR_BUFFER_BIT);
                
                boolean dynzoom = (mCreateFlags & 0x10000) != 0;
                mTester.prepareToDraw(dynzoom, (int)(System.currentTimeMillis() - mStartTime));
                render(mTester);
            }
        }
    }
}
