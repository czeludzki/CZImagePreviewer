//
//  CZPreviewImageView.h
//  CZImagePreview
//
//  Created by siu on 16/4/15.
//  Copyright © 2016年 siu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZImagePreviewerItem.h"

@class CZImagePreviewCollectionCell;
@protocol CZImagePreviewCollectionCellDelegate <NSObject>
- (void)imagePreviewCollectionCell:(CZImagePreviewCollectionCell *)cell scrollViewDidScroll:(UIScrollView *)scrollView;
@end

@interface CZImagePreviewCollectionCell : UICollectionViewCell
@property (nonatomic, assign) NSInteger idx;
@property (nonatomic, assign, readonly, getter=isZooming) BOOL zooming;
@property (weak, nonatomic) UIScrollView *zoomingScrollView;
@property (weak, nonatomic) UIImageView *zoomingImageView;
@property (strong, nonatomic) CZImagePreviewerItem *item;
@property (weak, nonatomic) id<CZImagePreviewCollectionCellDelegate>delegate;
/**
 *  清除缩放效果
 */
- (void)clearScaleWithAnimate:(BOOL)animate;
- (void)zoom2Max;
- (void)zoomRect:(CGRect)rect animate:(BOOL)animate;
@end
