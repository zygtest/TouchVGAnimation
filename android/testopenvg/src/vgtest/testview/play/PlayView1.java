// Copyright (c) 2013, https://github.com/rhcad/touchvg

package vgtest.testview.play;

import android.content.Context;
import android.util.DisplayMetrics;
import touchvg.core.GiGraphics;
import touchvg.core.GiTransform;
import touchvg.core.MgPlayShapes;
import touchvg.core.MgShapeDoc;
import touchvg.core.MgShapes;
import touchvg.core.TestOpenVGCanvas;
import vgtest.testview.canvas.GLSurfaceView1;

public class PlayView1 extends GLSurfaceView1 {
    private static final String RECORD_PATH = "mnt/sdcard/TouchVG/rec";
    private GiTransform mXf = new GiTransform();
    private GiGraphics mGs = new GiGraphics(mXf);
    private MgShapeDoc mDoc;
    private MgShapes mDynShapes;
    

    public PlayView1(Context context) {
        super(context);
        
        final DisplayMetrics dm = context.getApplicationContext().getResources().getDisplayMetrics();
        mXf.setResolution(dm.densityDpi);
        
        setRenderMode(RENDERMODE_WHEN_DIRTY);
        new Thread(new LoadingThread()).start();
    }
    
    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        mXf.setWndSize(w, h);
    }
    
    @Override
    public void onPause() {
        super.onPause();
        mGs.stopDrawing();
    }

    @Override
    protected void render(TestOpenVGCanvas tester) {
        synchronized(mDoc) {
            mGs.beginPaint(tester.beginPaint(true));
            mDoc.draw(mGs);
            mGs.endPaint();
            
            mGs.beginPaint(tester.beginPaint(false));
            mDynShapes.draw(mGs);
            mGs.endPaint();
        }
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
                        synchronized(mDoc) {
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
