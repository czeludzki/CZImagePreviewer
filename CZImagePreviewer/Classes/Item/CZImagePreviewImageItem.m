//
//  CZImagePreviewImageItem.m
//  CZImagePreview
//
//  Created by siu on 16/4/14.
//  Copyright © 2016年 siu. All rights reserved.
//

#import "CZImagePreviewImageItem.h"

@implementation CZImagePreviewImageItem

- (instancetype)initWithImage:(UIImage *)image orURL:(NSURL *)URL orImageUrlStr:(NSString *)imageUrlStr andType:(ImagesClassType)type andPlaceholderImage:(UIImage *)placeholderImage
{
    if (self = [super init]) {
        self.image = image;
        self.imageURL = URL;
        self.imageUrlStr = imageUrlStr;
        self.type = type;
        self.placeholderImage = placeholderImage;
    }
    return self;
}

+ (instancetype)imageItemWithImage:(UIImage *)image orURL:(NSURL *)URL orImageUrlStr:(NSString *)imageUrlStr andType:(ImagesClassType)type andPlaceholderImage:(UIImage *)placeholderImage
{
    CZImagePreviewImageItem *item = [[CZImagePreviewImageItem alloc] initWithImage:image orURL:URL orImageUrlStr:imageUrlStr andType:type andPlaceholderImage:placeholderImage];
    return item;
}

@end
