//
//  CZImagePreviewImageItem.h
//  CZImagePreview
//
//  Created by siu on 16/4/14.
//  Copyright © 2016年 siu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ImagesClassType){
    ImagesClassType_UIImage = 0,
    ImagesClassType_NSString = 1,
    ImagesClassType_NSURL = 2,
    /**
     *  如果是非法的,则在show的时候不响应show事件,打印错误
     */
    ImagesClassType_Illegal = 3
};


@interface CZImagePreviewImageItem : NSObject
@property (copy, nonatomic) NSString *imageUrlStr;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) UIImage *image;

@property (assign, nonatomic) ImagesClassType type;
@property (strong, nonatomic) UIImage *placeholderImage;

+ (instancetype)imageItemWithImage:(UIImage *)image orURL:(NSURL *)URL orImageUrlStr:(NSString *)imageUrlStr andType:(ImagesClassType)type andPlaceholderImage:(UIImage *)placeholderImage;
- (instancetype)initWithImage:(UIImage *)image orURL:(NSURL *)URL orImageUrlStr:(NSString *)imageUrlStr andType:(ImagesClassType)type andPlaceholderImage:(UIImage *)placeholderImage;
@end
