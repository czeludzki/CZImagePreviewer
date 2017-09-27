//
//  CZPreviewImageView.h
//  CZImagePreview
//
//  Created by siu on 16/4/15.
//  Copyright © 2016年 siu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZImagePreviewImageItem.h"

@class CZImagePreviewCollectionCell;
@protocol CZImagePreviewCollectionCellDelegate <NSObject>
- (void)imagePreviewCollectionCell:(CZImagePreviewCollectionCell *)cell scrollViewDidScrollWithVelocity:(CGPoint)velocity;
@end

@interface CZImagePreviewCollectionCell : UICollectionViewCell
@property (nonatomic, assign, readonly, getter=isZooming) BOOL zooming;
@property (weak, nonatomic) UIScrollView *zoomingScrollView;
@property (weak, nonatomic) UIImageView *zoomingImageView;
@property (strong, nonatomic) CZImagePreviewImageItem *item;
@property (weak, nonatomic) id delegate;
/**
 正常状态的scale
 */
@property (assign, nonatomic, readonly) CGFloat defatulScale;
/**
 *  清除缩放效果
 */
- (void)clearScaleWithAnimate:(BOOL)animate;
- (void)zoom2Max;
- (void)zoomRect:(CGRect)rect animate:(BOOL)animate;
@end
