//
//  CZImagePreviewerTableViewController.m
//  CZImagePreviewer_Example
//
//  Created by siu on 16/01/2018.
//  Copyright © 2018 czeludzki. All rights reserved.
//

#import "CZImagePreviewerTableViewController.h"
#import "CZImagePreviewerTableViewCell.h"
#import <UIImageView+WebCache.h>

@interface CZImagePreviewerTableViewController ()
@property (nonatomic, strong) NSMutableArray *dataSources;
@property (strong, nonatomic) NSArray *imagePaths;

@end

@implementation CZImagePreviewerTableViewController

- (NSArray *)imagePaths
{
    if (!_imagePaths) {
        _imagePaths = @[
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
    }
    return _imagePaths;
}

- (NSMutableArray *)dataSources
{
    if (!_dataSources) {
        _dataSources = [NSMutableArray array];
    }
    return _dataSources;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

#pragma mark - Action
- (void)timerAction:(NSTimer *)timer
{
    [self.dataSources addObjectsFromArray:self.imagePaths];
    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"self.tableView.contentSize.height = %.2f",self.tableView.contentSize.height);
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSources.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    });
}

#pragma mark - Table view data source
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 200;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CZImagePreviewerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TESTID" forIndexPath:indexPath];
    [cell.testImageView sd_setImageWithURL:[NSURL URLWithString:self.dataSources[indexPath.row]]];
    return cell;
}

@end
