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

#pragma mark - Getter && Setter
- (BOOL)isZooming
{
    return self.zoomingScrollView.zoomScale != 1;
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self keepCentered];
//    NSLog(@"collectionViewCell = %p, %ld, image = %p", self, self.idx, self.zoomingImageView.image);
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self keepCentered];
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
    zoomingScrollView.backgroundColor = UIColor.clearColor;
    zoomingScrollView.alwaysBounceVertical = NO;
    zoomingScrollView.alwaysBounceHorizontal = NO;
    [self.contentView addSubview:zoomingScrollView];
    self.zoomingScrollView = zoomingScrollView;
    [zoomingScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    UIImageView *zoomingImageView = [[UIImageView alloc] init];
    zoomingImageView.backgroundColor = UIColor.clearColor;
    zoomingImageView.clipsToBounds = YES;
    zoomingImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.zoomingScrollView addSubview:zoomingImageView];
    self.zoomingImageView = zoomingImageView;
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
    [ass startAnimating];
    [self.contentView addSubview:ass];
    self.assFlower = ass;
    [self.assFlower mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
    }];
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
    [self.noImageWaring mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
    }];
}

- (void)updateScrollViewConfig
{
    CGSize mainScreenSize = UIScreen.mainScreen.bounds.size;
    CGSize imgSize = self.zoomingImageView.image.size;
    // 计算实际显示的大小
    CGSize imageFitingSizeInScreen = [self imageFitingSizeInScreen:imgSize];
    self.zoomingScrollView.contentSize = imgSize;
    
    self.zoomingImageView.frame = CGRectMake(0, 0, imageFitingSizeInScreen.width, imageFitingSizeInScreen.height);
    self.zoomingImageView.center = CGPointMake(mainScreenSize.width * 0.5, mainScreenSize.height * 0.5);

    // 配置scrollview minZoomScale || maxZoomScale
    self.zoomingScrollView.minimumZoomScale = 1;
    
    CGFloat maxZoomScale = (imgSize.height * imgSize.width) / (imageFitingSizeInScreen.width * imageFitingSizeInScreen.height);
    self.zoomingScrollView.maximumZoomScale = maxZoomScale > 1 ? maxZoomScale : 2;
    
    // 初始缩放系数
    [self.zoomingScrollView setZoomScale:1 animated:NO];
    [self layoutIfNeeded];
}

/// 计算当图片以 UIViewContentModeScaleAspectFit 显示在 imageView 上时的大小
- (CGSize)imageFitingSizeInScreen:(CGSize)imgSize
{
    CGSize mainScreenSize = UIScreen.mainScreen.bounds.size;
    CGFloat widthRatio = mainScreenSize.width / imgSize.width;
    CGFloat heightRatio = mainScreenSize.height / imgSize.height;
    CGFloat scale = MIN(widthRatio, heightRatio);
    CGFloat imageWidth = scale * imgSize.width;
    CGFloat imageHeight = scale * imgSize.height;
    return CGSizeMake(imageWidth, imageHeight);
}

// 通过设置 scrollView.contentInset 使 imageView 保持居中
- (void)keepCentered
{
    CGFloat scrollW = UIScreen.mainScreen.bounds.size.width;
    CGFloat scrollH = UIScreen.mainScreen.bounds.size.height;

    CGSize contentSize = self.zoomingScrollView.contentSize;
    CGFloat offsetX = scrollW > contentSize.width ? (scrollW - contentSize.width) * 0.5 : 0;
    CGFloat offsetY = scrollH > contentSize.height ? (scrollH - contentSize.height) * 0.5 : 0;

    CGFloat centerX = contentSize.width * 0.5 + offsetX;
    CGFloat centerY = contentSize.height * 0.5 + offsetY;

    self.zoomingImageView.center = CGPointMake(centerX, centerY);
}

/**
 *  清除缩放效果
 */
- (void)clearScaleWithAnimate:(BOOL)animate
{
    [self.zoomingScrollView setZoomScale:1 animated:animate];
}

@end
