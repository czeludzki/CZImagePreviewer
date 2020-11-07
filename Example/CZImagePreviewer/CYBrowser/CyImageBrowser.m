//
//  CyImageBrowser.m
//  manager
//
//  Created by ios2 on 2020/8/27.
//  Copyright © 2020 CY. All rights reserved.
//

#import "CYBrowerMacro.h"
#import "CyImageBrowser.h"
#import "CyBrowerCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+CyShowRect.h"

static NSString *_browImgViewCellIdentifier = @"browImgViewCell";

static float info_defaultHeight = 120.0;                             // 详情的默认高度 可以 在外部进行单独修改 infoView.frame

@interface CyImageBrowser ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIView *contentView;                   //内容的View
@property (nonatomic, strong) UICollectionView *browerCollectionView;  //浏览器
@property (nonatomic, strong) UILabel *pageLable;                    //页码标签
@property (nonatomic, strong) NSMutableArray *dataSource;            //数据源
@property (nonatomic, strong) UIImageView *animationImgView;         //动画执行文件
@property (nonatomic, weak) UIView *pageOriginalView;                //原始的View
@property (nonatomic, assign) NSInteger currentPage;                 //当前页码数
@property (nonatomic, assign) CGPoint begain_center;                 //启动时候的中心点坐标
@property (nonatomic, strong) UIView *infoView;                      //主要用于图片信息加载的View

@end

@implementation CyImageBrowser

#pragma mark - struct method - 构造方法
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configerUI];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPanGusture:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

#pragma mark - init UI
- (void)configerUI {
    self.contentView.frame = self.bounds;
    self.browerCollectionView.frame = self.bounds;
    self.pageLable.text = @"-/-";
}

#pragma mark - panGusture target method
- (void)onPanGusture:(UIPanGestureRecognizer *)pan {
    CGPoint p = [pan translationInView:self.superview];
    CGPoint targetPoint = CGPointMake(self.begain_center.x + p.x, self.begain_center.y + p.y);
    CGFloat changeY =  MAX(0, (targetPoint.y - self.begain_center.y) / targetPoint.y);

	if (changeY >1) {
	 //解决存在的缩放bug
	  changeY = 0;
	}
    CGFloat scale = 1 - changeY;
    scale = MAX(0.4, scale);
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.begain_center = self.contentView.center;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
		//手势拖动起来的时候进行处理
		self.pageLable.hidden = YES;
		self.infoView.hidden = YES;
        self.contentView.center = targetPoint;
        self.contentView.transform = CGAffineTransformMakeScale(scale, scale);
		//颜色 透明度 使用 立方  来降低 透明度 0 - 1 阶段 效果比较显著
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:scale*scale*scale];
    } else {
        if (scale < 0.75) {
            [self siglTapDismiss];              //消失----
        } else {
			CyBrowerInfo *info = (CyBrowerInfo *)self.dataSource[_currentPage];
			BOOL isHiddenInfoView = (info.imgInfo != nil)?NO:YES;
			[UIView animateWithDuration:0.2 animations:^{
				self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                self.contentView.center = self.begain_center;
                self.backgroundColor = [UIColor blackColor];
			} completion:^(BOOL finished) {
				self.infoView.hidden = isHiddenInfoView;
				self.pageLable.hidden = NO;
			}];
        }
    }
}

#pragma mark - override method
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        !_makePageLable ? : _makePageLable(self.pageLable);
        !_makeInfoView ? : _makeInfoView(self.infoView);
        //只修改一次 保证 无论 block 使用 strong 还是weak  防止循环引用问题
        _makePageLable = nil;
        _makeInfoView = nil;
    }
}

#pragma mark - protocol method   协议方法

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CyBrowerCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:_browImgViewCellIdentifier forIndexPath:indexPath];
    item.backgroundColor = [UIColor clearColor];
    [item configerModel:self.dataSource[indexPath.row]];
    __weak typeof(self) weakSelf = self;

    [item setSingleGustureTap:^{
        [weakSelf siglTapDismiss];         //单击手势
    }];

    [item setLongGustureAction:^(id _Nonnull sender) {
        NSLog(@"用户正在长按-> 如果想继续使用请在下面位置处理   longGestureAction 代码块处理！");
        !weakSelf.longGestureAction ? : weakSelf.longGestureAction(weakSelf.dataSource[weakSelf.currentPage], weakSelf.currentPage);
    }];

    return item;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint p = CGPointMake(scrollView.contentOffset.x + CGRectGetWidth(scrollView.frame) / 2.0, CGRectGetHeight(scrollView.frame) / 2.0);
    NSIndexPath *indexPath =  [self.browerCollectionView indexPathForItemAtPoint:p];
    if (indexPath) {
        self.currentPage = indexPath.row;
    }
}

#pragma mark target method -
- (void)siglTapDismiss {
    CyBrowerInfo *info = (CyBrowerInfo *)self.dataSource[_currentPage];
    UIImageView *imgV = [self currentShowImageView];
    CGRect rect = [self getRectFromWindow:imgV];
    CGRect endRect = info.showView == nil ? CGRectMake((CY_BROWER_W - rect.size.width)/2.0, (CY_BROWER_H - rect.size.height)/2.0, rect.size.width, rect.size.height) : [self getRectFromWindow:info.showView];
    self.animationImgView.alpha = 1;
    self.animationImgView.frame = rect;
    self.animationImgView.image = imgV.image;
    self.browerCollectionView.hidden = YES;
    self.pageLable.hidden = YES;
    self.infoView.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:_animationImgView];
	CGFloat cX0 = CGRectGetMidX(rect);
	CGFloat cY0 = CGRectGetMidY(rect);
	CGFloat cX1 = CGRectGetMidX(endRect);
	CGFloat cY1 = CGRectGetMidY(endRect);
	CGFloat chageX = cX0 - cX1;
	CGFloat changeY = cY0 - cY1;
	float duration = sqrt(pow(chageX, 2) + pow(changeY, 2)) /(CY_BROWER_H /2.5) * 0.5;
	if (info.showView == nil &&duration <= 0.2)
	{
	   [self showOrgView];
	   [self dismiss];
	}else{
		duration  = MIN(duration, 0.5);//最大不能超过 0.5
		[UIView animateWithDuration:duration animations:^{
			self.animationImgView.frame = endRect;
			if (!info.showView) {
				self.animationImgView.alpha = 0;
			}
		} completion:^(BOOL finished) {
			[self showOrgView];
			[self dismiss];
		}];
	}
}
//显示原始的图片
-(void)showOrgView
{
	for (CyBrowerInfo * aInfo in self.dataSource) {
		if (aInfo.showView) {
			aInfo.showView.hidden = NO;
		}
	}
}

#pragma mark - public method
#pragma mark  ----  构造方法
+ (instancetype)cyImageBrower {
    CyImageBrowser *brower = [[CyImageBrowser alloc]initWithFrame:CGRectMake(0, 0, CY_BROWER_W, CY_BROWER_H)];
    return brower;
}

#pragma mark - 显示到 window 上
- (void)showBrowerInfos:(CyBrowerInfos *)browerInfos {
    NSArray *windows = [UIApplication sharedApplication].windows;
    UIWindow *window = nil;
    for (UIWindow *aWidow in windows) {
        if (aWidow.windowLevel == UIWindowLevelNormal &&
			[[NSString stringWithFormat:@"%@",aWidow.class] isEqualToString:@"UIWindow"]) {
            window = aWidow;
        }
    }
    [window addSubview:self];
    [self.dataSource removeAllObjects];
    if (browerInfos.items) {
        [self.dataSource addObjectsFromArray:browerInfos.items];
    }
    __weak typeof(self) weakSelf = self;
    NSInteger currentPage = browerInfos.currentIndex;
    UIView *showView = [self.dataSource[currentPage] showView];
    self.browerCollectionView.alpha = 0;
	CyBrowerInfo *info =  browerInfos.items[browerInfos.currentIndex];
    if (showView) {
       UIImageView *animationImgView = [UIImageView new];
		if ([info isWeb]) {
			[animationImgView sd_setImageWithURL:[NSURL URLWithString:info.image]];
		}else if ([info.image isKindOfClass:[NSData class]]){
			animationImgView.image = [UIImage imageWithData:info.image];
		}else if ([info.image isKindOfClass:[NSString class]]){
			animationImgView.image = [UIImage imageNamed:info.image];
		}else if ([info.image isKindOfClass:[UIImage class]]){
			animationImgView.image = info.image;
		}
		if (!animationImgView.image) {
			animationImgView.image =  [self imageFromView:showView]; //以上方法都无法得到图片执行截图操作
		}
        animationImgView.contentMode = showView.contentMode;
        animationImgView.frame = [self getRectFromWindow:showView];        //读取到位置
		if (info.isHiddenOgView) {
			showView.hidden = YES;
		}
        //结束的位置
		CGRect endFrame = [animationImgView.image showRect];
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:animationImgView];
        self.animationImgView = animationImgView;
        [UIView animateWithDuration:0.5 animations:^{
            animationImgView.frame = endFrame;
            self.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
			self.browerCollectionView.alpha = 1;
			[UIView animateWithDuration:0.3 animations:^{
				animationImgView.alpha = 0;
			}];
		}];

    } else {
        [UIView animateWithDuration:0.4 animations:^{
            self.browerCollectionView.alpha = 1.0;
			self.browerCollectionView.alpha = 1;
			self.backgroundColor = [UIColor blackColor];
        }];
    }

    [self.browerCollectionView performBatchUpdates:^{
    } completion:^(BOOL finished) {
        if (weakSelf.dataSource.count > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentPage inSection:0];
            [weakSelf.browerCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
            weakSelf.currentPage = indexPath.row;
            weakSelf.infoView.hidden = weakSelf.isShowInformation ? NO : YES;         //是否显示 ——> 详情
        }
    }];
}

- (void)dismiss
{
	[self clearBlock];  //清理掉所有的代码块避免出现强引用问题 如果 strong 引用此view 控件 需要重新设置代码块
    [self removeFromSuperview];     //临时的一个 消失方法
}

#pragma mark - getter ---
- (UICollectionView *)browerCollectionView {
    if (!_browerCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = CGFLOAT_MIN;
        layout.minimumInteritemSpacing = CGFLOAT_MIN;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(CY_BROWER_W, CY_BROWER_H);
        _browerCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _browerCollectionView.backgroundColor = [UIColor clearColor];
        [_browerCollectionView registerClass:[CyBrowerCell class] forCellWithReuseIdentifier:_browImgViewCellIdentifier];
        _browerCollectionView.delegate = self;
        _browerCollectionView.dataSource = self;
        _browerCollectionView.pagingEnabled = YES;
        [self.contentView addSubview:_browerCollectionView];        //添加到 View 上
    }
    return _browerCollectionView;
}

//页码标签
- (UILabel *)pageLable {
    if (!_pageLable) {
        _pageLable = [[UILabel alloc]init];
        _pageLable.textColor = [UIColor whiteColor];
        _pageLable.font = [UIFont systemFontOfSize:14.0];
        _pageLable.textAlignment = NSTextAlignmentCenter;
        CGFloat y = 0;
        if (@available(iOS 13.0,*)) {
            UIWindow *window = (UIWindow *)[UIApplication sharedApplication].windows.firstObject;
            y = CGRectGetHeight(window.windowScene.statusBarManager.statusBarFrame);
        } else {
            y =  CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        }
        _pageLable.frame = CGRectMake(0, y, CY_BROWER_W, 25);
        [self.contentView addSubview:_pageLable];
    }
    return _pageLable;
}

//数据源--
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}

//描绘图片内容的View
- (UIView *)infoView {
    if (!_infoView) {
        _infoView = [[UIView alloc]init];
        _infoView.hidden = self.isShowInformation ? NO : YES;
        [self.contentView addSubview:_infoView];
        _infoView.userInteractionEnabled = NO;         //只是显示 不做任何的 交互
        _infoView.frame = (CGRect) {
            0, CY_BROWER_H - info_defaultHeight,       /*   x   ,   y  */
            CY_BROWER_W, info_defaultHeight            /* width , height  */
        };
    }
    return _infoView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
    }
    return _contentView;
}

#pragma mark - setter

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    NSInteger totalCount = self.dataSource.count;
    if (_changePageFormart) {
        _changePageFormart(self.pageLable, _currentPage, totalCount);       //用户在外部自行格式化 ----
    } else {
		self.pageLable.text = [NSString stringWithFormat:@"%d/%ld", currentPage + 1, (long)totalCount];
    }
    [self bringSubviewToFront:self.infoView];     //放到最顶层
    !_changePageInfo ? : _changePageInfo(self.infoView, self.dataSource[_currentPage]);  //修改页码底部的信息
}

- (void)setIsShowInformation:(BOOL)isShowInformation {
    _isShowInformation = isShowInformation;
    //是否显示详细信息
    self.infoView.hidden = _isShowInformation ? NO : YES;
}

#pragma mark - private method

-(UIImageView *)currentShowImageView
{
	CyBrowerCell *browerCell = (CyBrowerCell *)[self.browerCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage inSection:0]];
	if (browerCell) {
		return browerCell.scaleScrollView.showImgView;
	}
	return nil;
}

-(void)clearBlock
{
	_makeInfoView = nil; //内部释放 block  代码块！
	_makePageLable = nil;
	_changePageFormart = nil;
	_longGestureAction = nil;
	_changePageInfo = nil;
}
- (UIImage *)imageFromView:(UIView *)theView {
    // 开启一个绘图的上下文
    CGFloat scale =  [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(theView.frame.size.width * scale, theView.frame.size.height * scale), NO, 0.0);
    // 作用于CALayer层的方法。将view的layer渲染到当前的绘制的上下文中。
    [theView drawViewHierarchyInRect:CGRectMake(0, 0, theView.frame.size.width * scale, theView.frame.size.height * scale) afterScreenUpdates:YES];
    // 获取图片
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束绘图上下文
    UIGraphicsEndImageContext();
    return viewImage;
}

//获取 一个View 相对 window 的位置
- (CGRect)getRectFromWindow:(UIView *)view {
    NSArray *windows = [UIApplication sharedApplication].windows;
    UIWindow *window = windows.firstObject;
    return [view convertRect:view.bounds toView:window];
}

@end
