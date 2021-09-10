//
//  CZImagePreviewerProtocol.swift
//  CZImagePreviewerProtocol
//
//  Created by siuzeontou on 2021/9/8.
//

import Foundation
import UIKit

public protocol PreviewerDelegate: AnyObject {
    /// 当 imagePreviewer 即将要退出显示时调用
    /// - Returns: 根据返回值决定返回动画: 退回到某个UIView视图的动画
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithIndex index: Int) -> UIView?
    
    /// 接收到长按事件
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didLongPressAtIndex index: Int)
}

public protocol PreviewerDataSource: AnyObject {
    /// 向 dataSource 获取数据量
    func numberOfItems(in imagePreviewer: CZImagePreviewer) -> Int
    
    /// 数据源方法
    /// 返回值类型默认可以是 String, URL, UIImage, 或者是任何自定义遵循了 ImageResourceProtocol 协议的类型, 具体操作见 CZImageSourceProtocol.swift
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, imageResourceForItemAtIndex index: Int) -> ResourceProtocol?
    
    /// 为图片浏览器提供自定义操作视图, 该视图会平铺在图片浏览器子视图集顶部, 不参与缩放
    /// 此方法会在图片浏览器展示时发起, 展示到图片浏览器
    /// 在View实例被添加到图片浏览器后, 只要View实例是和已在展示的View实例是同一个, 则不重复做 addSubView 操作
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int, resourceLoadingState: CZImagePreviewer.ImageLoadingState) -> UIView?
}

public extension PreviewerDelegate {
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithIndex index: Int) -> UIView? { nil }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didLongPressAtIndex index: Int) {}
}

public extension PreviewerDataSource {
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int, resourceLoadingState: CZImagePreviewer.ImageLoadingState) -> UIView? { nil }
}
