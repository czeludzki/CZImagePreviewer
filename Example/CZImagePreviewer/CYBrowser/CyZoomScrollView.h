//
//  CyZoomScrollView.h
//  manager
//
//  Created by ios2 on 2020/8/28.
//  Copyright © 2020 CY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CyZoomScrollView : UIScrollView<UIScrollViewDelegate>

//显示图片的View
@property (nonatomic, strong) UIImageView *showImgView;

//单点回调
@property (nonatomic, copy) void (^ singleTapBlock)(void);


@end

NS_ASSUME_NONNULL_END
