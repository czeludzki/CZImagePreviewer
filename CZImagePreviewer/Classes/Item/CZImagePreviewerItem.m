//
//  CZImagePreviewImageItem.m
//  CZImagePreview
//
//  Created by siu on 16/4/14.
//  Copyright © 2016年 siu. All rights reserved.
//

#import "CZImagePreviewerItem.h"

@implementation CZImagePreviewerItem

- (instancetype)initWithImage:(id)img placeholderImg:(UIImage *)placeholder
{
    if (self = [super init]) {
        if ([img isKindOfClass:NSString.class]) {
            self.imageURL = img;
        }
        if ([img isKindOfClass:NSURL.class]) {
            self.imageURL = [((NSURL *)img) absoluteString];
        }
        if ([img isKindOfClass:UIImage.class]) {
            self.image = img;
        }
        self.placeholderImage = placeholder;
    }
    return self;
}

@end
