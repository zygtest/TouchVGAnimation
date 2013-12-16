// Copyright (c) 2013, https://github.com/rhcad/touchvg

package vgtest.testview.play;

import android.content.Context;
import android.util.DisplayMetrics;
import android.util.Log;
import touchvg.core.GiGraphics;
import touchvg.core.GiTransform;
import touchvg.core.MgPlayShapes;
import touchvg.core.MgShapeDoc;
import touchvg.core.MgShapes;
import touchvg.core.TestOpenVGCanvas;
import vgtest.testview.canvas.GLSurfaceView1;

public class PlayView1 extends GLSurfaceView1 {
    private static final String RECORD_PATH = "mnt/sdcard/TouchVG/rec";
    private static final String TAG = "PlayView1";
    private GiTransform mXf = new GiTransform();
    private GiGraphics mGs = new GiGraphics(mXf);
    private MgShapeDoc mDoc;
    private MgShapes mDynShapes;
    private Thread mThread;
    

    public PlayView1(Context context) {
        super(context);
        
        final DisplayMetrics dm = context.getApplicationContext().getResources().getDisplayMetrics();
        mXf.setResolution(dm.densityDpi);
        
        setRenderMode(RENDERMODE_WHEN_DIRTY);
    }
    
    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        mXf.setWndSize(w, h);
    }
    
    @Override
    public void onPause() {
        mGs.stopDrawing();
        synchronized(mXf) {}
        mThread = null;
        super.onPause();
    }

    @Override
    protected void render(TestOpenVGCanvas tester) {
        if (mThread == null) {
            mThread = new Thread(new LoadingThread());
            mThread.start();
        }
        if (mDoc == null) {
            return;
        }
        int n1 = 0, n2 = 0;
        synchronized(mXf) {
            if (!mGs.isStopping() && mGs.beginPaint(tester.beginPaint(true))) {
                n1 = mDoc.draw(mGs);
                mGs.endPaint();
            }
            if (!mGs.isStopping() && mGs.beginPaint(tester.beginPaint(false))) {
                n2 = mDynShapes.draw(mGs);
                mGs.endPaint();
            }
        }
        Log.d(TAG, "render draw:" + n1 + ", dyndraw:" + n2);
    }
    
    class LoadingThread implements Runnable {
        public void run() {
            MgPlayShapes player = new MgPlayShapes(RECORD_PATH, mXf);
            
            if (player.loadFirstFile()) {
                player.copyXformTo(mXf);
                mDoc = player.pickFrontDoc();
                mDynShapes = player.pickDynShapes();
                requestRender();
                
                for (int index = 1; !mGs.isStopping(); index++) {
                    int res = player.loadNextFile(index);
                    
                    if ((res & MgPlayShapes.FRAME_CHANGED) != 0) {
                        synchronized(mXf) {
                            if (mGs.isStopping())
                                break;
                            if ((res & MgPlayShapes.STATIC_CHANGED) != 0) {
                                mDoc.release();
                                mDoc = player.pickFrontDoc();
                            }
                            if ((res & MgPlayShapes.DYNAMIC_CHANGED) != 0) {
                                mDynShapes.release();
                                mDynShapes = player.pickDynShapes();
                            }
                        }
                        requestRender();
                    }
                    else {
                        break;
                    }
                }
            }
        }
    }
}
