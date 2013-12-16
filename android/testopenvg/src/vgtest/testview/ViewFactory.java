// Copyright (c) 2012-2013, https://github.com/rhcad/touchvg

package vgtest.testview;

import java.util.ArrayList;
import java.util.List;

public class ViewFactory {
    
    public static class DummyItem {
        
        public String id;
        public int flags;
        public String title;
        
        public DummyItem(String id, int flags, String title) {
            this.id = id;
            this.flags = flags;
            this.title = title;
        }
        
        @Override
        public String toString() {
            return title;
        }
    }
    
    public static List<DummyItem> ITEMS = new ArrayList<DummyItem>();
    
    static {
        addItem("vgtest.testview.play.PlayView1", 0, "PlayView1 from sdcard");
        addItem("vgtest.testview.play.PlayView1", 1, "PlayView1 from zip in assets");
        
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x01, "testRect");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x02, "testLine");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x04, "testTextAt");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x08, "testEllipse");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x10, "testQuadBezier");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x20, "testCubicBezier");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x40, "testPolygon");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x80|0x40|0x02, "testClearRect");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x100, "testClipPath");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x200, "testHandle");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x400, "testDynCurves");
        
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x01|0x10000, "testRect dynzoom");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x02|0x10000, "testLine dynzoom");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x04|0x10000, "testTextAt dynzoom");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x08|0x10000, "testEllipse dynzoom");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x10|0x10000, "testQuadBezier dynzoom");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x20|0x10000, "testCubicBezier dynzoom");
        addItem("vgtest.testview.canvas.GLSurfaceView1", 0x40|0x10000, "testPolygon dynzoom");
        
        addItem("vgtest.testview.canvas.LargeView1", 0x04|0x20000, "testTextAt in large view");
        addItem("vgtest.testview.canvas.LargeView1", 0x20|0x20000, "testCubicBezier in large view");
        addItem("vgtest.testview.canvas.LargeView1", 0x200|0x20000, "testHandle in large view");
        addItem("vgtest.testview.canvas.LargeView1", 0x400|0x20000, "testDynCurves in large view");
        
        addItem("vgtest.testview.canvas.LargeView1", 0x01|0x30000, "testRect dynzoom in large view");
        addItem("vgtest.testview.canvas.LargeView1", 0x20|0x30000, "testCubicBezier dynzoom in large view");
    }
    
    private static void addItem(String id, int flags, String title) {
        ITEMS.add(new DummyItem(id, flags, title));
    }
}
