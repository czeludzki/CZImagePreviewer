//
//  CZImagePreviewerProtocol.swift
//  CZImagePreviewerProtocol
//
//  Created by siuzeontou on 2021/9/8.
//

import Foundation
import UIKit

public protocol PreviewerDataSource: AnyObject {
    /// 向 dataSource 获取数据量
    func numberOfItems(in imagePreviewer: CZImagePreviewer) -> Int
    
    /// 数据源方法
    /// 返回值类型默认可以是 String, URL, UIImage, 或者是任何自定义遵循了 ImageResourceProtocol 协议的类型, 具体操作见 CZImageSourceProtocol.swift
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, imageResourceForItemAtIndex index: Int) -> ResourceProtocol?
    
    /// 为图片浏览器提供自定义操作视图, 该视图会平铺在图片浏览器子视图集顶部, 不参与缩放, 不受滑动交互影响
    /// 调用时机:
    ///     1.图片浏览器展示时发起;
    ///     2.Previewer.currentIdx 发生改变时发起
    /// 添加视图到Previewer的时机:
    ///     在View实例被添加到图片浏览器后, 只要View实例是和已在展示的View实例是同一个, 则不重复做 addSubView 操作
    /// 此视图一般放置一些共有控件例如下载按钮等
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int) -> UIView?
    
    /// 为每一个图片Cell提供自定义操作视图, 这个视图会覆盖在每个图片Cell的顶部
    /// 
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, accessoryViewForCellAtIndex index: Int, resourceLoadingState: CZImagePreviewer.ImageLoadingState) -> UIView?
}

public protocol PreviewerDelegate: AnyObject {
    /// 当 imagePreviewer 即将要退出显示时调用
    /// - Returns: 根据返回值决定返回动画: 退回到某个UIView视图的动画
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithIndex index: Int) -> UIView?
    
    /// 接收到长按事件
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didLongPressAtIndex index: Int)
}

public extension PreviewerDelegate {
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithIndex index: Int) -> UIView? { nil }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didLongPressAtIndex index: Int) {}
}

public extension PreviewerDataSource {
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int) -> UIView? { nil }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, accessoryViewForCellAtIndex index: Int, resourceLoadingState: CZImagePreviewer.ImageLoadingState) -> UIView? { nil }
}
