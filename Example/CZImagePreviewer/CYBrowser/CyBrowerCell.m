//
//  CyBrowerCell.m
//  manager
//
//  Created by ios2 on 2020/8/27.
//  Copyright © 2020 CY. All rights reserved.
//

#import "CyBrowerCell.h"

#import "CYBrowerMacro.h"

#import "UIImageView+WebCache.h"
#import "UIImage+CyShowRect.h"

@interface CyBrowerCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *failLable;                     //图片加载失败提示
@property (nonatomic, strong) UIActivityIndicatorView *animationView; //菊花转子 loading ……
@end

@implementation CyBrowerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _animationView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _animationView.color = [UIColor whiteColor];
        [self.contentView addSubview:_animationView];
        [self.contentView addSubview:self.scaleScrollView];
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGesture:)];
        [self addGestureRecognizer:longGesture];
    }
    return self;
}

#pragma mark - 长按手势 ---
- (void)longGesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        !_longGustureAction ? : _longGustureAction(self);
    }
}

- (void)configerModel:(CyBrowerInfo *)info {
    self.scaleScrollView.zoomScale = 1.0; //需要重新赋值 到原始比例
    self.scaleScrollView.contentSize = CGSizeMake(CY_BROWER_W, CY_BROWER_H);     // contentSize  重置
    if (info.showView) {
        self.scaleScrollView.showImgView.contentMode = info.showView.contentMode;
        self.scaleScrollView.showImgView.clipsToBounds = info.showView.clipsToBounds;
    }
    if (info.isWeb) {     // web 图片  以及本地图片
        __weak typeof(self) weakSelf = self;
        [self.animationView startAnimating];
//		[self.scaleScrollView.showImgView sd_cancelCurrentImageLoad];//取消当前加载
        if ([self.scaleScrollView respondsToSelector:@selector(sd_cancelCurrentImageLoad)]) {
            //如果能够响应 sd 不同版本取消了一下方法
            [self.scaleScrollView performSelector:@selector(sd_cancelCurrentImageLoad)];
        }

        [self.scaleScrollView.showImgView sd_setImageWithURL:[NSURL URLWithString:info.image] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [weakSelf.animationView stopAnimating];
            [weakSelf showImage:image];
            weakSelf.failLable.hidden = (image == nil) ? NO : YES;
        }];
    } else {
        if ([info.image isKindOfClass:[NSString class]]) {
            self.scaleScrollView.showImgView.image = [UIImage imageNamed:info.image];
        } else if ([info.image isKindOfClass:[UIImage class]]) {
            self.scaleScrollView.showImgView.image = info.image;
        } else if ([info.image isKindOfClass:[NSData class]]) {
            self.scaleScrollView.showImgView.image = [UIImage imageWithData:info.image];
        }
        [self showImage:self.scaleScrollView.showImgView.image];
    }
}

- (void)showImage:(UIImage *)image {
    CGFloat img_w = image ? image.size.width : 0.1;
    CGFloat img_h = image ? image.size.height : 0.1;
    CGFloat img_scale = img_w / img_h;
    CGRect rect = self.scaleScrollView.showImgView.frame;
    CGFloat max_w = CY_BROWER_W * 0.9;
    CGFloat max_h = CY_BROWER_H * 0.9;
    if (max_w / img_scale < max_h) {
        rect.size = CGSizeMake(max_w, max_w / img_scale);
    } else if (max_h * img_scale < max_w) {
        rect.size = CGSizeMake(max_h * img_scale, max_h);
    }
    self.scaleScrollView.showImgView.frame = [image showRect];
    self.scaleScrollView.zoomScale = 0.99;
    [self.scaleScrollView setZoomScale:1.0 animated:YES];
}

- (CyZoomScrollView *)scaleScrollView {
    if (!_scaleScrollView) {
        _scaleScrollView = [[CyZoomScrollView alloc]init];
        _scaleScrollView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        _scaleScrollView.contentSize = CGSizeMake(CY_BROWER_W, CY_BROWER_H);
        __weak typeof(self) weakSelf = self;
        [_scaleScrollView setSingleTapBlock:^{
            !weakSelf.singleGustureTap ? : weakSelf.singleGustureTap();
        }];
    }
    return _scaleScrollView;
}

#pragma mark - getter
- (UILabel *)failLable
{
    if (!_failLable) {
        _failLable = [[UILabel alloc]init];
        _failLable.textColor = [UIColor whiteColor];
        _failLable.textAlignment = NSTextAlignmentCenter;
        _failLable.font = [UIFont systemFontOfSize:15.0];
        _failLable.text = @"图片加载失败……";
        _failLable.userInteractionEnabled = NO;
        [self.contentView addSubview:_failLable];
        _failLable.hidden = YES;
    }
    return _failLable;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat self_w = CGRectGetWidth(self.bounds);
    CGFloat self_h = CGRectGetHeight(self.bounds);
    self.failLable.center = (CGPoint) { self_w / 2.0, self_h / 2.0 };
    self.failLable.bounds = CGRectMake(0, 0, self_w, 30.0f);
    self.animationView.center = CGPointMake(self_w / 2.0, self_h / 2.0);
}

@end
