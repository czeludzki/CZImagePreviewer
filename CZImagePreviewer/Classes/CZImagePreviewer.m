//
//  CZImagePreview.m
//  CZImagePreview
//
//  Created by siu on 12/4/16.
//  Copyright © 2016年 siu. All rights reserved.
//

#import "CZImagePreviewer.h"
#import "CZImagePreviewerItem.h"
#import "CZImagePreviewCollectionCell.h"
#import <Masonry/Masonry.h>

/**
 滑动的方向枚举
 */
typedef NS_ENUM(NSInteger,ImagePreviewerDragDirection) {
    ImagePreviewerDragDirection_up = 0,
    ImagePreviewerDragDirection_left = 1,
    ImagePreviewerDragDirection_down = 2,
    ImagePreviewerDragDirection_right = 3,
};

@interface CZImagePreviewer ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, CZImagePreviewCollectionCellDelegate, UIGestureRecognizerDelegate>
@property (copy, nonatomic) SaveImageBlock saveImageBlock;
@property (strong, nonatomic) NSIndexPath *currentIndex;
@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UIPanGestureRecognizer *panOnView;
/**
 *  为了在viewWillLayoutSubviews中设置初始滚动到的地方,该值是为了记录他只设置了一次
 */
@property (assign, nonatomic) BOOL hasSetStartDisplaycell;
/**
 在旋转以后,collectionview的contentOffset可能会出现不准确的情况,尝试过直接在旋转的方法里设置contentOffset,无效
 所以,在viewdidlayoutSubview里设置
 此值为yes,则表示要重设contentOffset
 */
@property (assign, nonatomic) BOOL needResetContentOffsetAfterRotate;
/**
 此值是记录旋转之前的indexPath.item,在旋转之后重设contentOffset时使用
 */
@property (assign, nonatomic) NSIndexPath *indexPathBeforeRotate;
/**
 记录show前的屏幕方向
 */
@property (assign, nonatomic) UIDeviceOrientation enterOrientation;
@end

@implementation CZImagePreviewer
static NSString *CZImagePreviewCollectionCellID = @"CZImagePreviewCollectionCellID";
#pragma mark - Getter && Setter

#pragma mark - LifeCycle
- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillChangeStatusBarOrientationNotification:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    collectionView.pagingEnabled = YES;
    collectionView.prefetchingEnabled = NO;     // 把预加载关掉, 否则可能会遇到旋转后图片不能居中的问题
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[CZImagePreviewCollectionCell class] forCellWithReuseIdentifier:CZImagePreviewCollectionCellID];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    [tap requireGestureRecognizerToFail:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    self.panOnView = pan;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setStartDisplayCell];
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.currentIndex = [NSIndexPath indexPathForItem:((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width) inSection:0];
}

#pragma mark - CollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self numberOfItemInPreviewer];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CZImagePreviewCollectionCell *imageView = [collectionView dequeueReusableCellWithReuseIdentifier:CZImagePreviewCollectionCellID forIndexPath:indexPath];
    imageView.item = [self itemAtIndex:indexPath.item];
    imageView.delegate = self;
    imageView.idx = indexPath.item;
    return imageView;
}

#pragma mark - Action
#pragma GestureRecognizer
- (void)tap:(UITapGestureRecognizer *)sender
{
    [self dismiss];
}

- (void)doubleTap:(UITapGestureRecognizer *)sender
{
    CZImagePreviewCollectionCell *displayImageView = (CZImagePreviewCollectionCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndex];
    if (displayImageView.isZooming) {
        [displayImageView clearScaleWithAnimate:YES];
    }else{
        CGPoint touchLocation = [sender locationInView:sender.view];
        [displayImageView zoomRect:CGRectMake(touchLocation.x, touchLocation.y, 1, 1) animate:YES];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(imagePreviewer:didLongPressWithImageAtIndex:)]) {
            [self.delegate imagePreviewer:self didLongPressWithImageAtIndex:self.currentIndex.item];
        }
    }
}

- (void)pan:(UIPanGestureRecognizer *)sender
{
    __weak __typeof (self) weakSelf = self;
    CZImagePreviewCollectionCell *visibleImageView = (CZImagePreviewCollectionCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndex];
    CGPoint translationInView = [sender translationInView:self.view];
    CGPoint velocityInView = [sender velocityInView:self.view];
    float progress = (fabs(translationInView.y) / self.view.bounds.size.height);
    
    static CGFloat defaultZoomScale;
    static CGPoint normalCenter;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            defaultZoomScale = visibleImageView.zoomingScrollView.zoomScale;
            normalCenter = visibleImageView.zoomingImageView.center;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale((1 - progress) * defaultZoomScale, (1 - progress) * defaultZoomScale);
            visibleImageView.zoomingImageView.transform = scaleTransform;
            visibleImageView.zoomingImageView.center = CGPointMake(normalCenter.x + translationInView.x, normalCenter.y + translationInView.y);
            self.collectionView.backgroundColor = [UIColor colorWithRed:1/255 green:1/255 blue:1/255 alpha:(1 - progress)];
        }
            break;
        case UIGestureRecognizerStateEnded: case UIGestureRecognizerStateFailed: case UIGestureRecognizerStateCancelled:{
            visibleImageView.zoomingScrollView.scrollEnabled = YES;
            if (fabs(velocityInView.y) > 1200 || progress > .3f) {
                [self dismiss];
            }else{
                [UIView animateWithDuration:.3f animations:^{
                    visibleImageView.zoomingScrollView.zoomScale = defaultZoomScale;
                    visibleImageView.zoomingImageView.center = normalCenter;
                    weakSelf.collectionView.backgroundColor = [UIColor colorWithRed:1/255 green:1/255 blue:1/255 alpha:1];
                }];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - CZImagePreviewCollectionCellDelegate
- (void)imagePreviewCollectionCell:(CZImagePreviewCollectionCell *)cell scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panOnView){
        CZImagePreviewCollectionCell *cell = (CZImagePreviewCollectionCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndex];
        // 判断滑动的方向
        ImagePreviewerDragDirection direction = [self dragDirectionWithPanGesture:gestureRecognizer];
        // 如果是向上滑动, 判断 cell.scrollView 是否已经滑动到底部, 如果是, 使 self.panOnView 手势有效, 且 使 ScrollView.scrollEnabled 失效
        CGFloat maxOffsetY = floor(cell.zoomingScrollView.contentSize.height - cell.zoomingScrollView.bounds.size.height);
        if (direction == ImagePreviewerDragDirection_up && cell.zoomingScrollView.contentOffset.y >= maxOffsetY) {
            cell.zoomingScrollView.scrollEnabled = NO;
            return YES;
        }
        // 如果是向下滑动, 判断 cell.scrollView 是否已经滑动到顶部, 如果是, 使 self.panOnView 手势有效, 且 使 ScrollView.scrollEnabled 失效
        if (direction == ImagePreviewerDragDirection_down && cell.zoomingScrollView.contentOffset.y <= 0) {
            cell.zoomingScrollView.scrollEnabled = NO;
            return YES;
        }
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

#pragma mark - Show && Dismiss
- (void)showWithImageContainer:(UIView *)container currentIndex:(NSInteger)currentIndex presentedController:(UIViewController *)presentedController
{
    __weak __typeof (self) weakSelf = self;
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.currentIndex = [NSIndexPath indexPathForItem:currentIndex inSection:0];
    // 进入时, 记录当前 statusBar 方向
    self.enterOrientation = UIDevice.currentDevice.orientation;
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *presentVC = presentedController ? presentedController : rootViewController;
    // 遇到了比较奇葩的问题, 如果 modalPresentationStyle = UIModalPresentationOverFullScreen 且presentVC.shouldAutorotate 返回NO 会导致此控制器不能旋转, 但是不这么设置会导致 self.view.background 设置为透明都不能看到上一级控制器
    // 如果是 UIModalPresentationCustom, 怎不会出现上述两种情况, 可以保持透明且能够旋转, 但是旋转会使上一级控制器跟着转, 这是系统bug
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.alpha = 0;
    
    [presentVC presentViewController:self animated:NO completion:^{
        CZImagePreviewCollectionCell *currentImageView = (CZImagePreviewCollectionCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndex];
        CGRect imageViewOldFrame = currentImageView.zoomingImageView.frame;
        weakSelf.view.alpha = 1;
        if (container) {    // 如果有容器
            CGRect containerRectOnKeyWindow = [container convertRect:container.bounds toView:[[UIApplication sharedApplication].delegate window]];
            currentImageView.zoomingImageView.frame = CGRectMake(containerRectOnKeyWindow.origin.x - currentImageView.zoomingScrollView.contentInset.left, containerRectOnKeyWindow.origin.y - currentImageView.zoomingScrollView.contentInset.top, containerRectOnKeyWindow.size.width, containerRectOnKeyWindow.size.height);
            [UIView animateWithDuration:.3f delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.collectionView.backgroundColor = [UIColor blackColor];
                currentImageView.zoomingImageView.frame = imageViewOldFrame;
            } completion:^(BOOL finished) {
                
            }];
        }else{
            currentImageView.zoomingImageView.transform = CGAffineTransformMakeScale(0, 0);
            [UIView animateWithDuration:.3f delay:0 usingSpringWithDamping:.8f initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
                weakSelf.collectionView.backgroundColor = [UIColor blackColor];
                currentImageView.zoomingImageView.transform = CGAffineTransformIdentity;
                currentImageView.zoomingImageView.frame = imageViewOldFrame;
            } completion:^(BOOL finished) {
                
            }];
        }
    }];
}

- (void)dismiss
{
    __weak __typeof (self) weakSelf = self;
    [UIApplication sharedApplication].statusBarHidden = NO;
    // 获得当前显示的imageView
    __block CZImagePreviewCollectionCell *visibleImageView = (CZImagePreviewCollectionCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndex];
    UIView *container = nil;
    if ([self.delegate respondsToSelector:@selector(imagePreviewer:willDismissWithDisplayingImageAtIndex:)]) {
        container = [self.delegate imagePreviewer:self willDismissWithDisplayingImageAtIndex:self.currentIndex.item];
    }
    CGRect containerRectOnKeyWindow = [container convertRect:container.bounds toView:[[UIApplication sharedApplication].delegate window]];
    CGRect intersectionRect = CGRectIntersection([UIScreen mainScreen].bounds, containerRectOnKeyWindow);  // 容器与window的交汇Rect
    
    UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;
    if (container && !container.hidden && container.superview && !(CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) && orientation == self.enterOrientation) {   // 有容器且容器显示在屏幕上
        // 计算偏移量
        CGFloat final_X = 0;
        CGFloat final_Y = 0;
        
        if (visibleImageView.zoomingImageView.frame.size.width >= self.view.frame.size.width || visibleImageView.zoomingScrollView.contentOffset.x > 0) {
            final_X = containerRectOnKeyWindow.origin.x - visibleImageView.zoomingScrollView.contentInset.left + visibleImageView.zoomingScrollView.contentOffset.x;
        }else{
            final_X = containerRectOnKeyWindow.origin.x - visibleImageView.zoomingScrollView.contentInset.left;
        }
        
        if (visibleImageView.zoomingImageView.frame.size.height >= self.view.frame.size.height || visibleImageView.zoomingScrollView.contentOffset.y > 0) {
            final_Y = containerRectOnKeyWindow.origin.y - visibleImageView.zoomingScrollView.contentInset.top + visibleImageView.zoomingScrollView.contentOffset.y;
        }else{
            final_Y = containerRectOnKeyWindow.origin.y - visibleImageView.zoomingScrollView.contentInset.top;
        }
        
        CGRect finalRect = CGRectMake(final_X, final_Y, containerRectOnKeyWindow.size.width, containerRectOnKeyWindow.size.height);
        
        [UIView animateWithDuration:.3f animations:^{
            weakSelf.collectionView.backgroundColor = [UIColor clearColor];
            visibleImageView.zoomingImageView.frame = finalRect;
        } completion:^(BOOL finished) {
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
        }];
        
    }else{
        
        [UIView animateWithDuration:.3f delay:0 usingSpringWithDamping:.8f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            visibleImageView.transform = CGAffineTransformMakeScale(1.3, 1.3);
            weakSelf.view.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
        }];
    }
}

#pragma Rotate
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)applicationWillChangeStatusBarOrientationNotification:(NSNotification *)sender
{
    self.indexPathBeforeRotate = [NSIndexPath indexPathForItem:self.currentIndex.item inSection:0];
}

- (void)applicationDidChangeStatusBarOrientationNotification:(NSNotification *)sender
{
    NSLog(@"applicationDidChangeStatusBarOrientationNotification");
    [self.collectionView reloadData];
    [self.collectionView performBatchUpdates:^{
    } completion:^(BOOL finished) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.indexPathBeforeRotate.item inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }];
}

- (void)setStartDisplayCell
{
    if (self.hasSetStartDisplaycell == YES) return;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex.item inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    self.hasSetStartDisplaycell = YES;
}

#pragma mark - Helper
// 获取手势的移动方向
- (ImagePreviewerDragDirection)dragDirectionWithPanGesture:(UIPanGestureRecognizer *)panGes
{
    CGPoint velocityInView = [panGes velocityInView:nil];
//    NSLog(@"    velocityInView = %@\n    translationInView = %@", [NSValue valueWithCGPoint:velocityInView], [NSValue valueWithCGPoint:[panGes translationInView:nil]]);
    ImagePreviewerDragDirection direction_vertical = velocityInView.y > 0 ? ImagePreviewerDragDirection_down : ImagePreviewerDragDirection_up;
    ImagePreviewerDragDirection direction_horizontal = velocityInView.x > 0 ? ImagePreviewerDragDirection_left : ImagePreviewerDragDirection_right;
    ImagePreviewerDragDirection primary_direction = fabs(velocityInView.x) > fabs(velocityInView.y) ? direction_horizontal : direction_vertical;
    return primary_direction;
}

- (NSInteger)numberOfItemInPreviewer
{
    if ([self.dataSource respondsToSelector:@selector(numberOfItemInImagePreviewer:)]) {
        return [self.dataSource numberOfItemInImagePreviewer:self];
    }
    return 0;
}

- (CZImagePreviewerItem *)itemAtIndex:(NSInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(imagePreviewer:imageAtIndex:)]) {
        id img = [self.dataSource imagePreviewer:self imageAtIndex:index];
        CZImagePreviewerItem *item = [[CZImagePreviewerItem alloc] initWithImage:img placeholderImg:self.placeholderImage];
        return item;
    }else{
        return nil;
    }
}

- (void)saveImageAtIndex:(NSInteger)index successed:(SaveImageBlock)block
{
    CZImagePreviewCollectionCell *cell = (CZImagePreviewCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    UIImageWriteToSavedPhotosAlbum(cell.zoomingImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    self.saveImageBlock = block;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        self.saveImageBlock(YES,error);
    }else{
        self.saveImageBlock(NO,error);
    }
}

- (void)deleImageAtIndex:(NSInteger)index
{
    [self.collectionView deleteItemsAtIndexPaths:@[self.currentIndex]];
    CZImagePreviewCollectionCell *cell = self.collectionView.visibleCells.firstObject;
    self.currentIndex = [self.collectionView indexPathForCell:cell];
    if ([self numberOfItemInPreviewer] == 0) {
        [self dismiss];
    }
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

@end
