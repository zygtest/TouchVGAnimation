// LargeView3.h
// Copyright (c) 2012-2013, https://github.com/rhcad/touchvg

#import <UIKit/UIKit.h>

@class GraphView3;

@interface LargeView3 : UIScrollView<UIScrollViewDelegate> {
    GraphView3 *_subview;
}

- (id)initWithFrame:(CGRect)frame withFlags:(int)t;
- (void)save;

@end
