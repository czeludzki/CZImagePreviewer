//
//  ImageCollectionViewCell.m
//  封装套件使用deom
//
//  Created by siu on 2017/5/16.
//  Copyright © 2017年 siu. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation ImageCollectionViewCell
- (void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:_imageURL]];
}
@end
