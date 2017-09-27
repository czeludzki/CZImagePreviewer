//
//  CZPreviewImageView.m
//  CZImagePreview
//
//  Created by siu on 16/4/15.
//  Copyright © 2016年 siu. All rights reserved.
//

#import "CZImagePreviewCollectionCell.h"
#import "CZImagePreviewer_Macro.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

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
@synthesize defatulScale = _defatulScale;
#pragma mark - Getter && Setter
- (CGFloat)defatulScale
{
    //以 Screen.width 或者 Screen.height 最大的那个为基准
    _defatulScale = MIN(UIWindowWidth / self.item.image.size.width, UIWindowHeight / self.item.image.size.height);
    return _defatulScale;
}

- (BOOL)isZooming
{
    _zooming = self.defatulScale != self.zoomingScrollView.zoomScale;
    return _zooming;
}

- (void)setItem:(CZImagePreviewImageItem *)item
{
    _item = item;
    
    __weak __typeof (self) weakSelf = self;
    self.zoomingImageView.image = _item.placeholderImage ? _item.placeholderImage : nil;
    if (_item.image) {
        [self.assFlower removeFromSuperview];
        [self.noImageWaring removeFromSuperview];
        [self.zoomingImageView setImage:item.image];
        [self updateScrollViewConfig];
        return;
    }
    if(_item.imageUrlStr){
        [self showAssFlower];
        [self.zoomingImageView sd_setImageWithURL:[NSURL URLWithString:_item.imageUrlStr] placeholderImage:_item.placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                _item.image = image;
                [weakSelf.assFlower removeFromSuperview];
                [weakSelf.noImageWaring removeFromSuperview];
                [weakSelf updateScrollViewConfig];
            }else{
                [weakSelf.assFlower removeFromSuperview];
                [weakSelf showWarningLabel];
            }
        }];
        return;
    }
    if(_item.imageURL){
        [self showAssFlower];
        [self.zoomingImageView sd_setImageWithURL:_item.imageURL placeholderImage:_item.placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                [weakSelf.assFlower removeFromSuperview];
                item.image = image;
                [weakSelf updateScrollViewConfig];
            }else{
                [weakSelf.assFlower removeFromSuperview];
                [weakSelf showWarningLabel];
            }
        }];
        return;
    }
}

#pragma mark - LifeCycle
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateScrollViewConfig];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        [self layoutScrollView];
    }
    return self;
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize scaledSize = (CGSize){floorf(self.item.image.size.width * scrollView.zoomScale), floorf(self.item.image.size.height * scrollView.zoomScale)};
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
    CGPoint velocityInView = [scrollView.panGestureRecognizer velocityInView:scrollView];
    if ([self.delegate respondsToSelector:@selector(imagePreviewCollectionCell:scrollViewDidScrollWithVelocity:)]) {
        [self.delegate imagePreviewCollectionCell:self scrollViewDidScrollWithVelocity:velocityInView];
    }
}

#pragma mark - Helper
/**
 *  部署内容的scrollView
 */
- (void)layoutScrollView
{
    UIScrollView *zoomingScrollView = [[UIScrollView alloc] init];
    zoomingScrollView.showsVerticalScrollIndicator = NO;
    zoomingScrollView.showsHorizontalScrollIndicator = NO;
    zoomingScrollView.bounces = YES;
    zoomingScrollView.clipsToBounds = NO;
    zoomingScrollView.delegate = self;
    zoomingScrollView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:zoomingScrollView];
    self.zoomingScrollView = zoomingScrollView;
    [zoomingScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    UIImageView *zoomingImageView = [[UIImageView alloc] init];
    zoomingImageView.userInteractionEnabled = YES;
    zoomingImageView.backgroundColor = [UIColor clearColor];
    zoomingImageView.clipsToBounds = YES;   // 为了返回到容器的时候,动画更好看
    zoomingImageView.contentMode = UIViewContentModeScaleAspectFill;
    [zoomingScrollView addSubview:zoomingImageView];
    self.zoomingImageView = zoomingImageView;
    [zoomingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
        make.height.mas_equalTo(UIWindowHeight);
        make.width.mas_equalTo(UIWindowWidth);
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
    __weak __typeof (self) weakSelf = self;
    UIActivityIndicatorView *ass = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:ass];
    [ass startAnimating];
    self.assFlower = ass;
    [ass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf);
    }];
}

- (void)showWarningLabel
{
    if (self.noImageWaring) {
        return;
    }
    __weak __typeof (self) weakSelf = self;
    UILabel *warning = [[UILabel alloc] init];
    warning.font = [UIFont boldSystemFontOfSize:13];
    warning.textColor = [UIColor whiteColor];
    warning.text = @"加载失败,请检查网络状态";
    [self addSubview:warning];
    self.noImageWaring = warning;
    [warning mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf);
    }];
}

- (void)updateScrollViewConfig
{
    CGSize imgSize = self.item.image.size;
    [self.zoomingImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(imgSize.width);
        make.height.mas_equalTo(imgSize.height);
    }];
    [self layoutIfNeeded];
    
    //配置scrollview minZoomScale || maxZoomScale
    self.zoomingScrollView.minimumZoomScale = self.defatulScale;
    CGFloat maxZoomScale = (imgSize.height * imgSize.width) / (UIWindowWidth * UIWindowHeight * UIScreen.mainScreen.scale * UIScreen.mainScreen.scale);
    self.zoomingScrollView.maximumZoomScale = maxZoomScale > 1 ? maxZoomScale : 2;
    
    //初始缩放系数
    self.zoomingScrollView.zoomScale = self.defatulScale;
    
    //按照比例算出初次展示的尺寸
    CGSize scaledSize = (CGSize){floorf(imgSize.width * self.zoomingScrollView.zoomScale), floorf(imgSize.height * self.zoomingScrollView.zoomScale)};
    self.zoomingScrollView.contentSize = scaledSize;
    
    //调整位置 使其居中
    CGFloat top_bottom_Margin = MAX(0, floorf((CGRectGetHeight(self.zoomingScrollView.frame) - scaledSize.height) * 0.5f));
    CGFloat left_right_Margin = MAX(0, floorf((CGRectGetWidth(self.zoomingScrollView.frame) - scaledSize.width) * 0.5f));
    self.zoomingScrollView.contentInset = (UIEdgeInsets){top_bottom_Margin, left_right_Margin, top_bottom_Margin, left_right_Margin};
}

/**
 *  清除缩放效果
 */
- (void)clearScaleWithAnimate:(BOOL)animate
{
    [self.zoomingScrollView setZoomScale:self.defatulScale animated:animate];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
