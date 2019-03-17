//
//  CZImagePreviewImageItem.h
//  CZImagePreview
//
//  Created by siu on 16/4/14.
//  Copyright © 2016年 siu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CZImagePreviewerItem : NSObject
@property (copy, nonatomic) NSString *imageURL;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *placeholderImage;
- (instancetype)initWithImage:(id)img placeholderImg:(UIImage *)placeholder;
@end
