// Copyright (c) 2013, https://github.com/rhcad/touchvg

package vgtest.testview.canvas;

import android.content.Context;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ScrollView;

public class LargeView1 extends ScrollView {

    public LargeView1(Context context) {
        super(context);

        View view = new GLSurfaceView1(context);
        if (view != null) {
            final FrameLayout layout = new FrameLayout(context);
            layout.addView(view, new LayoutParams(LayoutParams.MATCH_PARENT, 2048));
            this.addView(layout);
        }
    }
}
