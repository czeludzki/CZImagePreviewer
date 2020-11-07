//
//  CyImageBrowser.h
//  manager
//
//  Created by ios2 on 2020/8/27.
//  Copyright © 2020 CY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CyBrowerInfos.h"

NS_ASSUME_NONNULL_BEGIN

@interface CyImageBrowser : UIView

//设置
@property (nonatomic, assign) BOOL isShowInformation;

#warning  以下代码块会在 clear 或者 执行完一次后被清理 如果 strong 引用该控件  重复使用时 请重新设置

@property (nonatomic, copy) void (^ makeInfoView)(UIView *infoView);

/** 修改 pageLable 的样式
 *  当被添加到 父控件时候会调用
 *  可在此自定义 页码的各种属性以及位置
 */
@property (nonatomic, copy) void (^ makePageLable)(UILabel *pageLable);

/**  格式化页码
 * block 中自定义显示格式
 * pageLable   页码标签
 * page        当前页数   从 0 开始
 *totalCount   总页数
 */
@property (nonatomic, strong) void (^ changePageFormart)(UILabel *pageLable,
                                                         NSInteger page,
                                                         NSInteger totalCount);
/** 详细信息设置
* block 中根据 CyBrowerInfo 参数设置详细信息
* infoView    详细信息的承载页
* info        CyBrowerInfo 承载图片信息页
*/
@property (nonatomic, copy) void (^ changePageInfo)(UIView *infoView, CyBrowerInfo *info); // 详细信息 修改

/** 长按
 * 用户长按响应事件外部处理
 *  info  CyBrowerInfo
 */
@property (nonatomic, strong) void (^ longGestureAction)(CyBrowerInfo *info,
                                                         NSInteger page);
/**
 * CyImageBrowser  构造方法
 * return CyImageBrowser 对象
 */
+ (instancetype)cyImageBrower;

/**
 *  显示到 window 上
 *  CyBrowerInfos 携带图片数组数据
 */
- (void)showBrowerInfos:(CyBrowerInfos *)browerInfos; //显示浏览详情

/** 禁用的构造方法 */
-(instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
