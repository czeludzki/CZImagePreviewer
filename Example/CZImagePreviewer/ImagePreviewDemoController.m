//
//  ImagePreviewDemoController.m
//  封装套件使用deom
//
//  Created by siu on 2017/5/16.
//  Copyright © 2017年 siu. All rights reserved.
//

#import "ImagePreviewDemoController.h"
#import "ImageCollectionViewCell.h"
#import "CZImagePreviewer.h"

@interface ImagePreviewDemoController () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource, CZImagePreviewDelegate, CZImagePreviewDataSource>
@property (strong, nonatomic) NSMutableArray *imagePaths;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation ImagePreviewDemoController

- (NSMutableArray *)imagePaths
{
    if (!_imagePaths) {
        NSArray *a = @[
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951072412&di=a4f0333c47f236cf2fc43eda23ac188b&imgtype=0&src=http%3A%2F%2Fwww.tupianzj.com%2Fuploads%2FBizhi%2Fqc126_19201.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951121134&di=c7316d9e304be9ab6723a4e412d506ee&imgtype=0&src=http%3A%2F%2Fn.sinaimg.cn%2Fsinacn%2F20161229%2Fb5d9-fxzencv2120554.jpeg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951141310&di=16e1b5be6eb0e000c92aae6da144cfad&imgtype=0&src=http%3A%2F%2Fcar0.autoimg.cn%2Fupload%2F2014%2F6%2F13%2F201406132124130794322.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951155680&di=7ec1c26c5b5c9290f4106750a1b10e43&imgtype=0&src=http%3A%2F%2Fimg.pconline.com.cn%2Fimages%2Fupload%2Fupc%2Ftx%2Fwallpaper%2F1212%2F06%2Fc2%2F16397554_1354787416906_800x600.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951167278&di=9ee4e5b520a359855c1df2479ec61df8&imgtype=0&src=http%3A%2F%2Fb.zol-img.com.cn%2Fdesk%2Fbizhi%2Fimage%2F6%2F720x360%2F1426561861511.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951183795&di=52c6e463b923dd14bb2e17d233fc2a85&imgtype=0&src=http%3A%2F%2Fattach.bbs.letv.com%2Fforum%2F201606%2F25%2F162403ipzartlyzqht3q2t.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951199349&di=c908322c95435feb41d9338c04c9acea&imgtype=0&src=http%3A%2F%2Fpic.t139.com%2Fpicture%2F201510%2Fb_561ccc4ca81d8.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495545938&di=ea90ab5d075889f335180d9984956851&imgtype=jpg&er=1&src=http%3A%2F%2Fimg15.3lian.com%2F2015%2Ff3%2F01%2F111.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495545968&di=19e21e46be73f3e7d1dc754a0a955d61&imgtype=jpg&er=1&src=http%3A%2F%2Fy2.ifengimg.com%2Fifengimcp%2Fpic%2F20140917%2F208572cc2ebbd01d8729_size505_w1044_h1600.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951280389&di=dc76722718257e9b63f239d55d642c9a&imgtype=0&src=http%3A%2F%2Fpic29.nipic.com%2F20130512%2F8952533_135542382000_2.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951121134&di=c7316d9e304be9ab6723a4e412d506ee&imgtype=0&src=http%3A%2F%2Fn.sinaimg.cn%2Fsinacn%2F20161229%2Fb5d9-fxzencv2120554.jpeg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951141310&di=16e1b5be6eb0e000c92aae6da144cfad&imgtype=0&src=http%3A%2F%2Fcar0.autoimg.cn%2Fupload%2F2014%2F6%2F13%2F201406132124130794322.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951155680&di=7ec1c26c5b5c9290f4106750a1b10e43&imgtype=0&src=http%3A%2F%2Fimg.pconline.com.cn%2Fimages%2Fupload%2Fupc%2Ftx%2Fwallpaper%2F1212%2F06%2Fc2%2F16397554_1354787416906_800x600.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951167278&di=9ee4e5b520a359855c1df2479ec61df8&imgtype=0&src=http%3A%2F%2Fb.zol-img.com.cn%2Fdesk%2Fbizhi%2Fimage%2F6%2F720x360%2F1426561861511.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951183795&di=52c6e463b923dd14bb2e17d233fc2a85&imgtype=0&src=http%3A%2F%2Fattach.bbs.letv.com%2Fforum%2F201606%2F25%2F162403ipzartlyzqht3q2t.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951199349&di=c908322c95435feb41d9338c04c9acea&imgtype=0&src=http%3A%2F%2Fpic.t139.com%2Fpicture%2F201510%2Fb_561ccc4ca81d8.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495545938&di=ea90ab5d075889f335180d9984956851&imgtype=jpg&er=1&src=http%3A%2F%2Fimg15.3lian.com%2F2015%2Ff3%2F01%2F111.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495545968&di=19e21e46be73f3e7d1dc754a0a955d61&imgtype=jpg&er=1&src=http%3A%2F%2Fy2.ifengimg.com%2Fifengimcp%2Fpic%2F20140917%2F208572cc2ebbd01d8729_size505_w1044_h1600.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951280389&di=dc76722718257e9b63f239d55d642c9a&imgtype=0&src=http%3A%2F%2Fpic29.nipic.com%2F20130512%2F8952533_135542382000_2.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951292383&di=f31a808921c373e651c68b6eb689fb82&imgtype=0&src=http%3A%2F%2Fimg3.3lian.com%2F2013%2Fs4%2F8%2Fd%2F59.jpg",
                        @"http://s9.sinaimg.cn/orignal/5244a93cg9914e513e468&690",
                        @"http://ww1.sinaimg.cn/bmiddle/63c9e579ly1fjix6vwv91j21d57b7qv5.jpg",
                        ];
        _imagePaths = [NSMutableArray arrayWithArray:a];
    }
    return _imagePaths;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - CollectionViewDelegate && DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagePaths.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellID" forIndexPath:indexPath];
    cell.imageURL = self.imagePaths[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CZImagePreviewer *imagePreview = [[CZImagePreviewer alloc] init];
    imagePreview.delegate = self;
    imagePreview.dataSource = self;
    [imagePreview showWithImageContainer:[collectionView cellForItemAtIndexPath:indexPath] currentIndex:indexPath.item presentedController:self];
}

#pragma mark - CZImagePreviewDataSource
- (NSInteger)numberOfItemInImagePreviewer:(CZImagePreviewer *)previewer
{
    return self.imagePaths.count;
}

- (id)imagePreviewer:(CZImagePreviewer *)previewer imageAtIndex:(NSInteger)index
{
    return self.imagePaths[index];
}

#pragma mark - CZImagePreviewDelegate
- (UIView *)imagePreviewer:(CZImagePreviewer *)previewer willDismissWithDisplayingImageAtIndex:(NSInteger)index
{
    return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (void)imagePreviewer:(CZImagePreviewer *)imagePreview didLongPressWithImageAtIndex:(NSInteger)index
{
    __weak __typeof (self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *a0 = [UIAlertAction actionWithTitle:@"删除图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.imagePaths removeObjectAtIndex:index];
        [weakSelf.collectionView reloadData];
        [imagePreview deleImageAtIndex:index];
    }];
    [alertController addAction:a0];
    UIAlertAction *a1 = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:a1];
    [imagePreview presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Override
- (BOOL)shouldAutorotate
{
    return NO;
}

@end
