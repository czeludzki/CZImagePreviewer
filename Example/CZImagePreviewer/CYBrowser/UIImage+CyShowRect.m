//
//  UIImage+CyShowRect.m
//  JXPagingView
//
//  Created by ios2 on 2020/9/7.
//

#import "UIImage+CyShowRect.h"
#import "CYBrowerMacro.h"

@implementation UIImage (CyShowRect)

- (CGRect)showRect {
    CGFloat img_w = self.size.width;
    CGFloat img_h = self.size.height;
    CGFloat new_w = CY_BROWER_W * 0.9;
    CGFloat new_h = new_w * img_h / img_w;
    if (new_h >= CY_BROWER_H*0.9) {
        new_h = CY_BROWER_H * 0.9;
        new_w = new_h * img_w / img_h;
    }
    //结束的位置
    CGRect endFrame = CGRectMake((CY_BROWER_W - new_w) / 2.0, (CY_BROWER_H - new_h) / 2.0, new_w, new_h);
    return endFrame;
}


@end
