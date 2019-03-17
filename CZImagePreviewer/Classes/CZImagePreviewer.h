//
//  CZImagePreviewer.h
//  CZImagePreviewer
//
//  Created by siu on 12/4/16.
//  Copyright © 2016年 siu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SaveImageBlock)(BOOL successed,NSError *error);

@class CZImagePreviewer, CZImagePreviewerItem;

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
- (UIView *)imagePreviewer:(CZImagePreviewer *)previewer willDismissWithDisplayingImageAtIndex:(NSInteger)index;
/**
 *  长按以后的操作,注意,如要呼出 UIAlertController 推荐使用 [imagePreview presentViewController:alertViewController]
 */
- (void)imagePreviewer:(CZImagePreviewer *)imagePreview didLongPressWithImageAtIndex:(NSInteger)index;
@end

@protocol CZImagePreviewDataSource <NSObject>
- (NSInteger)numberOfItemInImagePreviewer:(CZImagePreviewer *)previewer;
/**
 previewer 向DataSource请求图片
 @param index index of image
 @return UIImage, NSString, NSURL
 */
- (id)imagePreviewer:(CZImagePreviewer *)previewer imageAtIndex:(NSInteger)index;
@end


@interface CZImagePreviewer : UIViewController
@property (weak, nonatomic) id<CZImagePreviewDelegate>delegate;
@property (weak, nonatomic) id<CZImagePreviewDataSource>dataSource;
/**
 *  placeholderImage
 */
@property (strong, nonatomic) UIImage *placeholderImage;
/**
 *  显示
 *  @param currentIndex 当previewer要显示时, 应该要显示第几张图片
 *  @param container 所点击的图片容器 : if nil, 就不会有返回到该容器的动画效果
 *  @param presentedController 负责 present previewer 的 controller, if nil, will let the keyWindow.rootViewContoller do this
 */
- (void)showWithImageContainer:(UIView *)container currentIndex:(NSInteger)currentIndex presentedController:(UIViewController *)presentedController;
- (void)dismiss;

- (void)saveImage:(UIImage *)image successed:(SaveImageBlock)block;
- (void)deleImageAtIndex:(NSInteger)index;
@end
