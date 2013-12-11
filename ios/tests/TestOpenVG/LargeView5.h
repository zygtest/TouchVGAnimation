// LargeView5.h
// Copyright (c) 2013, https://github.com/rhcad/touchvg

#import <UIKit/UIKit.h>

@class GraphView5;

@interface LargeView5 : UIScrollView<UIScrollViewDelegate> {
    GraphView5 *_subview;
}

- (id)initWithFrame:(CGRect)frame withFlags:(int)t;
- (void)save;
- (void)startAnimation;
- (void)tearDown;

@end
