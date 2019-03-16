//
//  CZImagePreviewer.h
//  CZImagePreviewer
//
//  Created by siu on 12/4/16.
//  Copyright © 2016年 siu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZImagePreviewImageItem.h"

typedef void(^SaveImageBlock)(BOOL successed,NSError *error);

@class CZImagePreviewer;

@protocol CZImagePreviewDelegate <NSObject>
@optional
// 在imagePreview将要消失的时候,告诉delegate当前正在显示的图片是哪一张,而delegate返回装载该图片的容器给imagePreview,imagePreview负责动画返回效果 传出的 参数 image 类型 和 init方法中传入的image类型一致
/**
 *  在imagePreview将要消失的时候,imagePreView告诉代理当前显示的图片是哪一张
 *  @return 如delegate给imagePreview返回装载当前显示的图片的容器.
    imagePreview会自动判断该容器当前是否显示在屏幕范围内.
    if YES :会有将当前显示的图片返回到该容器的动画效果
    if NO :则采用默认的动画效果dismiss
 */
- (UIView *)imagePreviewWillDismissWithDisplayingImage:(CZImagePreviewImageItem *)imageItem andDisplayIndex:(NSInteger)index;
/**
 *  长按以后的操作,注意,如要呼出 UIAlertController 推荐使用 [imagePreview presentViewController:alertViewController]
 */
- (void)imagePreview:(CZImagePreviewer *)imagePreview didLongPressWithImageItem:(CZImagePreviewImageItem *)imageItem andDisplayIndex:(NSInteger)index;
@end


@interface CZImagePreviewer : UIViewController
@property (weak,nonatomic) id<CZImagePreviewDelegate>delegate;
/**
 *  placeholderImage
 */
@property (strong, nonatomic) UIImage *placeholderImage;
// images 里面装的可以是UIImage NSString(图片地址) NSURL
// 重点:数组中的类型要和参数 image 类型一致
- (instancetype)initWithImages:(NSArray <CZImagePreviewImageItem *>*)images displayingIndex:(NSInteger)index;
+ (instancetype)imagePreViewWithImages:(NSArray <CZImagePreviewImageItem *>*)images displayingIndex:(NSInteger)index;
/**
 *  显示
 *
 *  @param container 所点击的图片容器 : 如果为空,就不会有返回到该容器的动画效果
 */
- (void)showWithImageContainer:(UIView *)container andPresentedController:(UIViewController *)presentedController;
- (void)dismiss;

- (void)saveImage:(UIImage *)image successed:(SaveImageBlock)block;
- (void)deleImageAtIndex:(NSInteger)index;
@end
