// Copyright (c) 2012-2013, https://github.com/rhcad/touchvg

package vgtest.testopenvg;

import java.lang.reflect.Constructor;

import android.app.Activity;
import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.view.View;

public class DummyActivity extends Activity {
    private View mView;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        Bundle bundle = getIntent().getExtras();
        View view = null;
        
        try {
            Class<?> c = Class.forName(bundle.getString("className"));
            Constructor<?> c1 = c.getDeclaredConstructor(new Class[]{ Context.class });
            c1.setAccessible(true);
            view = (View)c1.newInstance(new Object[]{this});
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        this.setContentView(view);
        this.setTitle(bundle.getString("title"));
        mView = view;
    }
    
    @Override
    public void onDestroy() {
        mView = null;
        super.onDestroy();
    }
    
    @Override protected void onPause() {
        super.onPause();
        if (mView instanceof GLSurfaceView) {
            ((GLSurfaceView)mView).onPause();
        }
    }

    @Override protected void onResume() {
        super.onResume();
        if (mView instanceof GLSurfaceView) {
            ((GLSurfaceView)mView).onResume();
        }
    }
}
