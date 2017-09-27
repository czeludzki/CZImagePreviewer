//
//  ImageCollectionViewCell.h
//  封装套件使用deom
//
//  Created by siu on 2017/5/16.
//  Copyright © 2017年 siu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSString *imageURL;
@end
