//
//  CyZoomScrollView.m
//  manager
//
//  Created by ios2 on 2020/8/28.
//  Copyright © 2020 CY. All rights reserved.
//

#import "CyZoomScrollView.h"
#import "CYBrowerMacro.h"

@implementation CyZoomScrollView
{
    BOOL _isSingleTap;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.bouncesZoom = YES;
        self.maximumZoomScale = 3.0;
        self.minimumZoomScale = 0.5;
        [self addSubview:self.showImgView];
        if (@available(iOS 13.0,*)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGRect rect = self.showImgView.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    CGFloat rect_w = CGRectGetWidth(rect);
    CGFloat rect_h = CGRectGetHeight(rect);

    if (rect_w  < CY_BROWER_W) {
        rect.origin.x = floorf((CY_BROWER_W - rect.size.width) / 2.0);
    }

    if (rect_h  < CY_BROWER_H) {
        rect.origin.y = floorf((CY_BROWER_H - rect.size.height) / 2.0);
    }

    self.showImgView.frame = rect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.showImgView;
}

- (UIImageView *)showImgView {
    if (!_showImgView) {
        _showImgView = [[UIImageView alloc]init];
    }
    return _showImgView;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    if (touch.tapCount == 1) {
        if (!_isSingleTap) {
            [self performSelector:@selector(singleTapClick) withObject:nil afterDelay:0.2];
        }
    } else {
        // cancelPreviousPerformRequestsWithTarget  执行双击的时候取消掉 "上一个"  单击点击的方法

        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        CGPoint touchPoint = [touch locationInView:self.showImgView];
        if (touch.tapCount == 2) {
            [self zoomDoubleTapWithPoint:touchPoint];
            _isSingleTap = NO;
        }
    }
}

//双击缩放
- (void)zoomDoubleTapWithPoint:(CGPoint)point {
    if (self.zoomScale <= 1.0) {
        CGFloat width = self.frame.size.width / self.maximumZoomScale;
        CGFloat height = self.frame.size.height / self.maximumZoomScale;
        [self zoomToRect:CGRectMake(point.x - width / 2, point.y - height / 2, width, height) animated:YES];
    } else {
        [self setZoomScale:0.99 animated:YES];
    }
}

- (void)singleTapClick {
    _isSingleTap = YES;
    !_singleTapBlock ? : _singleTapBlock();
}

@end
