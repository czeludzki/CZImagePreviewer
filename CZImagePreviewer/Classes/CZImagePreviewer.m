//
//  CZImagePreview.m
//  CZImagePreview
//
//  Created by siu on 12/4/16.
//  Copyright © 2016年 siu. All rights reserved.
//

#import "CZImagePreviewer.h"
#import "CZImagePreviewImageItem.h"
#import "CZImagePreviewCollectionCell.h"
#import "Masonry.h"
#import "CZImagePreviewer_Macro.h"

#define k_ImageViewMargin 10

typedef NS_ENUM(NSInteger,ImagePreviewScrollingStatus){
    ImagePreviewScrollingStatus_Stop = 0,
    ImagePreviewScrollingStatus_Right = 1,
    ImagePreviewScrollingStatus_Left = 2
};

@interface CZImagePreviewer ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, CZImagePreviewCollectionCellDelegate, UIGestureRecognizerDelegate>
@property (copy, nonatomic) SaveImageBlock saveImageBlock;
@property (strong, nonatomic) NSIndexPath *currentIndex;
@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UIPanGestureRecognizer *panOnView;
/**
 *  记录传入的数组中元素的类型是什么
 */
@property (assign, nonatomic) ImagesClassType imagesClassType;
/**
 *  图片数据
 */
@property (nonatomic, strong) NSMutableArray <CZImagePreviewImageItem *>*images;
/**
 *  app本来的statusBar样式,如果 在info.plist 中没设置 UIViewControllerBasedStatusBarAppearance NO ,自动变化statuBarStyle的功能将不会生效
 */
@property (assign, nonatomic) UIStatusBarStyle applicationDefaultStatusBarStyle;
/**
 *  为了在viewWillLayoutSubviews中设置初始滚动到的地方,该只是为了记录他只设置了一次
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
@property (assign, nonatomic) NSInteger indexPathItemBeforeRotate;
/**
 记录show前的屏幕方向
 */
@property (assign, nonatomic) UIInterfaceOrientation enterOrientation;
@end

@implementation CZImagePreviewer
static NSString *CZImagePreviewCollectionCellID = @"CZImagePreviewCollectionCellID";
#pragma mark - Getter && Setter
- (NSMutableArray *)images
{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

+ (instancetype)imagePreViewWithImages:(NSArray *)images displayingIndex:(NSInteger)index
{
    CZImagePreviewer *preview = [[CZImagePreviewer alloc] initWithImages:images displayingIndex:index];
    return preview;
}

- (instancetype)initWithImages:(NSArray *)images displayingIndex:(NSInteger)index
{
    if (self = [super init]) {
        self.applicationDefaultStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        self.currentIndex = [NSIndexPath indexPathForItem:index inSection:0];
        if ([images.firstObject isKindOfClass:[UIImage class]]) {
            self.imagesClassType = ImagesClassType_UIImage;
        }else if ([images.firstObject isKindOfClass:[NSString class]]){
            self.imagesClassType = ImagesClassType_NSString;
        }else if ([images.firstObject isKindOfClass:[NSURL class]]){
            self.imagesClassType = ImagesClassType_NSURL;
        }else{
            self.imagesClassType = ImagesClassType_Illegal;
        }
        
        NSAssert(self.imagesClassType != ImagesClassType_Illegal, @"CZImagePreview在init方法中传入了非法的类型,只支持 UIImage NSString NSURL 类型");
        
        for (id imageData in images) {
            CZImagePreviewImageItem *item;
            switch (self.imagesClassType) {
                case ImagesClassType_UIImage:{
                    item = [CZImagePreviewImageItem imageItemWithImage:imageData orURL:nil orImageUrlStr:nil andType:ImagesClassType_UIImage andPlaceholderImage:self.placeholderImage ? self.placeholderImage : nil];
                }
                    break;
                case ImagesClassType_NSURL:{
                    item = [CZImagePreviewImageItem imageItemWithImage:nil orURL:imageData orImageUrlStr:nil andType:ImagesClassType_NSURL andPlaceholderImage:self.placeholderImage ? self.placeholderImage : nil];
                }
                    break;
                case ImagesClassType_NSString:{
                    item = [CZImagePreviewImageItem imageItemWithImage:nil orURL:nil orImageUrlStr:imageData andType:ImagesClassType_NSString andPlaceholderImage:self.placeholderImage ? self.placeholderImage : nil];
                }
                    break;
                default:
                    break;
            }
            [self.images addObject:item];
        }
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark - LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSAssert(self.images.count != 0, @"CZImagePreview init] images参数不能为空");
    self.view.backgroundColor = [UIColor clearColor];
    [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelStatusBar + 1;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    collectionView.pagingEnabled = YES;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[CZImagePreviewCollectionCell class] forCellWithReuseIdentifier:CZImagePreviewCollectionCellID];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
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
    [self resetContentOffsetAfterRotate];
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.currentIndex = [NSIndexPath indexPathForItem:(scrollView.contentOffset.x + self.collectionView.bounds.size.width * 0.5) / self.collectionView.bounds.size.width inSection:0];
}

#pragma mark - CollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
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
    return CGSizeMake(UIWindowWidth, UIWindowHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CZImagePreviewCollectionCell *imageView = [collectionView dequeueReusableCellWithReuseIdentifier:CZImagePreviewCollectionCellID forIndexPath:indexPath];
    imageView.item = self.images[indexPath.item];
    imageView.delegate = self;
    return imageView;
}

#pragma mark - CZImagePreviewCollectionCell
- (void)imagePreviewCollectionCell:(CZImagePreviewCollectionCell *)cell scrollViewDidScrollWithProgress:(double)progress
{
    
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
    if (displayImageView.zooming) {
        [displayImageView clearScaleWithAnimate:YES];
    }else{
        CGPoint touchLocation = [sender locationInView:sender.view];
        [displayImageView zoomRect:CGRectMake(touchLocation.x, touchLocation.y, 1, 1) animate:YES];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        CZImagePreviewImageItem *currentItem = self.images[self.currentIndex.item];
        if (currentItem.image == nil) return;
        if ([self.delegate respondsToSelector:@selector(imagePreview:didLongPressWithImageItem:andDisplayIndex:)]) {
            [self.delegate imagePreview:self didLongPressWithImageItem:currentItem andDisplayIndex:self.currentIndex.item];
        }
    }
}

- (void)pan:(UIPanGestureRecognizer *)sender
{
    __weak __typeof (self) weakSelf = self;
    CZImagePreviewCollectionCell *visibleImageView = (CZImagePreviewCollectionCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndex];
    CGPoint translationInView = [sender translationInView:self.view];
    static CGFloat defaultZoomScale;
    static CGPoint normalCenter;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            defaultZoomScale = visibleImageView.zoomingScrollView.zoomScale;
            normalCenter = visibleImageView.zoomingImageView.center;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            float progress = (1 - (fabs(translationInView.y) / UIWindowHeight));
            NSLog(@"translationInView = %@",NSStringFromCGPoint(translationInView));
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(progress * defaultZoomScale, progress * defaultZoomScale);
            visibleImageView.zoomingImageView.transform = scaleTransform;
            visibleImageView.zoomingImageView.center = CGPointMake(normalCenter.x + translationInView.x, normalCenter.y + translationInView.y);
            self.collectionView.backgroundColor = RMColorRGBA(1, 1, 1, progress);
        }
            break;
        case UIGestureRecognizerStateEnded: case UIGestureRecognizerStateFailed: case UIGestureRecognizerStateCancelled:{
            CGPoint velocity = [sender velocityInView:self.view];
            if (fabs(velocity.y) > 1500) {
                [self dismiss];
            }else{
                [UIView animateWithDuration:.3f animations:^{
                    visibleImageView.zoomingScrollView.zoomScale = defaultZoomScale;
                    visibleImageView.zoomingImageView.center = normalCenter;
                    weakSelf.collectionView.backgroundColor = RMColorRGBA(1, 1, 1, 1);
                }];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - CZImagePreviewCollectionCellDelegate
- (void)imagePreviewCollectionCell:(CZImagePreviewCollectionCell *)cell scrollViewDidScrollWithVelocity:(CGPoint)velocity
{
    
}

#pragma mark - UIGestureRecognizerDelegate


#pragma mark - Show && Dismiss
- (void)showWithImageContainer:(UIView *)container andPresentedController:(UIViewController *)presentedController
{
    __weak __typeof (self) weakSelf = self;
    // 进入时, 记录当前 statusBar 方向
    self.enterOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *presentVC = presentedController ? presentedController : rootViewController;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
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
    BOOL needRotateBack = NO;
    
    [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
    // 获得当前显示的imageView
    __block CZImagePreviewCollectionCell *visibleImageView = (CZImagePreviewCollectionCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndex];
    UIView *container = nil;
    if ([self.delegate respondsToSelector:@selector(imagePreviewWillDismissWithDisplayingImage:andDisplayIndex:)]) {
        if (self.images.count != 0) {
            container = [self.delegate imagePreviewWillDismissWithDisplayingImage:self.images[self.currentIndex.item] andDisplayIndex:self.currentIndex.item];
        }
    }
    CGRect containerRectOnKeyWindow = [container convertRect:container.bounds toView:[[UIApplication sharedApplication].delegate window]];
    CGRect intersectionRect = CGRectIntersection([UIScreen mainScreen].bounds, containerRectOnKeyWindow);  // 容器与window的交汇Rect
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation != self.enterOrientation) {
        [self rotate2Orientation:self.enterOrientation];
        needRotateBack = YES;
    }
    
    if (!needRotateBack && container && !container.hidden && container.superview && !(CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect))) {   // 有容器且容器显示在屏幕上
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
    return NO;
}

- (void)deviceOrientationDidChange:(NSNotification *)sender
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait ||
        interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        [self rotate2Orientation:interfaceOrientation];
    }
}

- (void)rotate2Orientation:(UIInterfaceOrientation)orientation
{
    __weak __typeof (self) weakSelf = self;
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    //判断如果当前方向和要旋转的方向一致,那么不做任何操作
    if (currentOrientation == orientation) {
        return;
    }
    // 保存当前indexPath
    NSIndexPath *currentIndexPath = self.currentIndex;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:case UIInterfaceOrientationLandscapeRight:{
            if (currentOrientation != UIInterfaceOrientationPortrait) break;
            [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(CGPointZero);
                make.width.mas_equalTo(UIWindowHeight);
                make.height.mas_equalTo(UIWindowWidth);
            }];
        }
            break;
        case UIInterfaceOrientationPortrait:{
            [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsZero);
            }];
        }
            break;
        default:
            break;
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
    CGAffineTransform transform = [self getTranformWithOrientation:orientation];
    [UIView animateWithDuration:.3f animations:^{
        weakSelf.collectionView.transform = transform;
    }];
    [self.collectionView reloadData];
    self.needResetContentOffsetAfterRotate = YES;
    self.indexPathItemBeforeRotate = currentIndexPath.item;
}

- (void)resetContentOffsetAfterRotate
{
    if (!self.needResetContentOffsetAfterRotate) return;
    [self.collectionView setContentOffset:CGPointMake(UIWindowWidth * self.indexPathItemBeforeRotate, 0) animated:NO];
    self.needResetContentOffsetAfterRotate = NO;
}

- (CGAffineTransform)getTranformWithOrientation:(UIInterfaceOrientation)orientation
{
    //根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

- (void)setStartDisplayCell
{
    if (self.hasSetStartDisplaycell == YES) return;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex.item inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    self.hasSetStartDisplaycell = YES;
}

- (void)dealloc
{
    NSLog(@"ImagePreview dealloc");
}

- (void)saveImage:(UIImage *)image successed:(SaveImageBlock)block
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
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
    [self.images removeObjectAtIndex:index];
    [self.collectionView deleteItemsAtIndexPaths:@[self.currentIndex]];
    CZImagePreviewCollectionCell *cell = self.collectionView.visibleCells.firstObject;
    self.currentIndex = [self.collectionView indexPathForCell:cell];
    if (self.images.count == 0) {
        [self dismiss];
    }
}

@end

