//
//  CyBrowerCell.h
//  manager
//
//  Created by ios2 on 2020/8/27.
//  Copyright © 2020 CY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CyZoomScrollView.h"
#import "CyBrowerInfos.h"

NS_ASSUME_NONNULL_BEGIN

@interface CyBrowerCell : UICollectionViewCell
@property (nonatomic, strong) CyZoomScrollView *scaleScrollView;       //缩放的视图
//单点响应
@property (nonatomic, copy) void (^ singleGustureTap)(void);
//长按手势响应
@property (nonatomic, copy) void (^ longGustureAction)(id sender);

- (void)configerModel:(CyBrowerInfo *)info;

@end

NS_ASSUME_NONNULL_END
