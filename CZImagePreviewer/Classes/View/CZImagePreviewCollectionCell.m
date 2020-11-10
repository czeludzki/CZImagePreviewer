//
//  CZPreviewImageView.m
//  CZImagePreview
//
//  Created by siu on 16/4/15.
//  Copyright © 2016年 siu. All rights reserved.
//

#import "CZImagePreviewCollectionCell.h"
#import "UIImageView+WebCache.h"
#import <Masonry/Masonry.h>

@interface CZImagePreviewCollectionCell ()<UIScrollViewDelegate>
/**
 *  在网络加载失败时提醒
 */
@property (weak, nonatomic) UILabel *noImageWaring;
/**
 *  菊花
 */
@property (weak, nonatomic) UIActivityIndicatorView *assFlower;
@end

@implementation CZImagePreviewCollectionCell
@synthesize zooming = _zooming;
#pragma mark - Getter && Setter
- (CGFloat)defatulScale
{
    // 以 Screen.width 或者 Screen.height 最大的那个为基准
    return MIN(self.bounds.size.width / self.zoomingImageView.image.size.width, self.bounds.size.height / self.zoomingImageView.image.size.height);
}

- (BOOL)isZooming
{
    _zooming = self.defatulScale != self.zoomingScrollView.zoomScale;
    return _zooming;
}

- (void)setItem:(CZImagePreviewerItem *)item
{
    _item = item;
    __weak __typeof (self) weakSelf = self;
    self.zoomingScrollView.zoomScale = 1;
    if (_item.image) {
        [self.assFlower removeFromSuperview];
        [self.noImageWaring removeFromSuperview];
        [self.zoomingImageView setImage:item.image];
        [self updateScrollViewConfig];
        return;
    }
    if(_item.imageURL){
        [self showAssFlower];
        [self.zoomingImageView sd_setImageWithURL:[NSURL URLWithString:_item.imageURL] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                [weakSelf.assFlower removeFromSuperview];
                [weakSelf showWarningLabel];
            }else{
                weakSelf.zoomingImageView.image = image;
                [weakSelf.assFlower removeFromSuperview];
                [weakSelf.noImageWaring removeFromSuperview];
                [weakSelf updateScrollViewConfig];
            }
        }];
        return;
    }
}

#pragma mark - LifeCycle
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        [self initSetup];
    }
    return self;
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize scaledSize = (CGSize){floorf(self.zoomingImageView.image.size.width * scrollView.zoomScale), floorf(self.zoomingImageView.image.size.height * scrollView.zoomScale)};
    //调整位置 使其居中
    CGFloat top_bottom_Margin = MAX(0, floorf((CGRectGetHeight(self.zoomingScrollView.frame) - scaledSize.height) * 0.5f));
    CGFloat left_right_Margin = MAX(0, floorf((CGRectGetWidth(self.zoomingScrollView.frame) - scaledSize.width) * 0.5f));
    self.zoomingScrollView.contentInset = (UIEdgeInsets){top_bottom_Margin,left_right_Margin,top_bottom_Margin,left_right_Margin};
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomingImageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(imagePreviewCollectionCell:scrollViewDidScroll:)]) {
        [self.delegate imagePreviewCollectionCell:self scrollViewDidScroll:scrollView];
    }
}

#pragma mark - Helper
/**
 *  部署内容的scrollView
 */
- (void)initSetup
{
    UIScrollView *zoomingScrollView = [[UIScrollView alloc] init];
    if (@available(iOS 11.0, *)) {
        zoomingScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    zoomingScrollView.showsVerticalScrollIndicator = NO;
    zoomingScrollView.showsHorizontalScrollIndicator = NO;
    zoomingScrollView.bounces = YES;
    zoomingScrollView.clipsToBounds = NO;
    zoomingScrollView.delegate = self;
    zoomingScrollView.backgroundColor = [UIColor clearColor];
    zoomingScrollView.alwaysBounceVertical = NO;
    zoomingScrollView.alwaysBounceHorizontal = NO;
    [self.contentView addSubview:zoomingScrollView];
    self.zoomingScrollView = zoomingScrollView;
    zoomingScrollView.frame = self.contentView.bounds;
    [zoomingScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    UIImageView *zoomingImageView = [[UIImageView alloc] init];
    zoomingImageView.backgroundColor = [UIColor clearColor];
    zoomingImageView.clipsToBounds = YES;   // 为了返回到容器的时候,动画更好看
    zoomingImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.zoomingScrollView addSubview:zoomingImageView];
    self.zoomingImageView = zoomingImageView;
    [self.zoomingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)zoom2Max
{
    [self.zoomingScrollView setZoomScale:self.zoomingScrollView.maximumZoomScale animated:YES];
}

- (void)zoomRect:(CGRect)rect animate:(BOOL)animate
{
    CGRect translationRect = CGRectZero;
    translationRect.origin.x = rect.origin.x / self.zoomingScrollView.zoomScale - self.zoomingScrollView.contentInset.left / self.zoomingScrollView.zoomScale;
    translationRect.origin.y = rect.origin.y / self.zoomingScrollView.zoomScale - self.zoomingScrollView.contentInset.top / self.zoomingScrollView.zoomScale;
    translationRect.size.height = 1;
    translationRect.size.width = 1;
    [self.zoomingScrollView zoomToRect:translationRect animated:YES];
}

- (void)showAssFlower
{
    if (self.assFlower) {
        return;
    }
    UIActivityIndicatorView *ass = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:ass];
    [ass startAnimating];
    self.assFlower = ass;
    ass.center = self.center;
}

- (void)showWarningLabel
{
    if (self.noImageWaring) {
        return;
    }
    UILabel *warning = [[UILabel alloc] init];
    warning.font = [UIFont boldSystemFontOfSize:13];
    warning.textColor = [UIColor whiteColor];
    warning.text = @"加载失败,请检查网络状态";
    [self addSubview:warning];
    self.noImageWaring = warning;
    warning.center = self.center;
}

- (void)updateScrollViewConfig
{
    CGSize imgSize = self.zoomingImageView.image.size;
//    self.zoomingImageView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
//    self.zoomingScrollView.contentSize = imgSize;

    // 配置scrollview minZoomScale || maxZoomScale
    self.zoomingScrollView.minimumZoomScale = self.defatulScale;
    
    CGFloat maxZoomScale = (imgSize.height * imgSize.width) / ([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].bounds.size.height);
    self.zoomingScrollView.maximumZoomScale = maxZoomScale > 1 ? maxZoomScale : 2;
    
    //按照比例算出初次展示的尺寸
    CGSize scaledSize = (CGSize){floorf(imgSize.width * self.zoomingScrollView.zoomScale), floorf(imgSize.height * self.zoomingScrollView.zoomScale)};

    //调整位置 使其居中
    CGFloat top_bottom_Margin = MAX(0, floorf((CGRectGetHeight(self.zoomingScrollView.frame) - scaledSize.height) * 0.5f));
    CGFloat left_right_Margin = MAX(0, floorf((CGRectGetWidth(self.zoomingScrollView.frame) - scaledSize.width) * 0.5f));
    self.zoomingScrollView.contentInset = (UIEdgeInsets){top_bottom_Margin, left_right_Margin, top_bottom_Margin, left_right_Margin};
    
    // 初始缩放系数
    [self.zoomingScrollView setZoomScale:self.defatulScale animated:NO];
    [self layoutIfNeeded];
}

/**
 *  清除缩放效果
 */
- (void)clearScaleWithAnimate:(BOOL)animate
{
    [self.zoomingScrollView setZoomScale:self.defatulScale animated:animate];
}

@end
