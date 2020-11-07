//
//  CyBrowerInfos.m
//  manager
//
//  Created by ios2 on 2020/8/27.
//  Copyright © 2020 CY. All rights reserved.
//

#import "CyBrowerInfos.h"

@implementation CyBrowerInfo

- (BOOL)isWeb
{
    if ([_image isKindOfClass:[NSString class]]) {
        if (_image != nil && ([_image hasPrefix:@"http://"] || [_image hasPrefix:@"https://"])) return YES;
    }
    return NO;
}
+(CyBrowerInfo*(^)( id image, UIView   * _Nullable showView, id _Nullable imgInfo))make;
{
	return ^(id aImg,UIView * _Nullable showV,id _Nullable imgInfo){
		CyBrowerInfo*info = [CyBrowerInfo new];
		info.image = aImg;
		info.showView = showV;
		info.imgInfo = imgInfo;
		return info;
	};
}
@end

@implementation CyBrowerInfos {
	NSInteger _max_num;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentIndex = 0;
    }
    return self;
}

-(void)setItems:(NSArray<CyBrowerInfo *> *)items
{
	_items = items;
	if (_items&&_items.count > 0) {
		_max_num  = _items.count;
	}
}
-(NSInteger)currentIndex {
	return  _currentIndex % _max_num; // 让页码数不超过当前数字
}

+(CyBrowerInfos*(^)(NSArray *(^itemInfos)(NSMutableArray <CyBrowerInfo *>*temp),NSInteger currentIndex))make {
	return ^(NSArray *(^items)(NSMutableArray *temp),NSInteger index){
		CyBrowerInfos*info = [CyBrowerInfos new];
		NSMutableArray *tempArray = [NSMutableArray array];
		info.items = items(tempArray); //外部钩取数组内的数据
		info.currentIndex = index;
		return info;
	};
}

@end
