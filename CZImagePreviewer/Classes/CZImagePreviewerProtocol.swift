//
//  CZImagePreviewerProtocol.swift
//  CZImagePreviewerProtocol
//
//  Created by siuzeontou on 2021/9/8.
//

import Foundation
import UIKit

public protocol CZImagePreviewerDelegate {
    /// 当 imagePreviewer 即将要退出显示时调用
    /// - Returns: 根据返回值决定返回动画: 退回到某个UIView视图的动画
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithIndex index: Int) -> UIView?
    
    /// 接收到长按事件
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didLongPressAtIndex index: Int)
}

public protocol CZImagePreviewerDataSource {
    /// 向 dataSource 获取数据量
    func numberOfItems(in imagePreviewer: CZImagePreviewer) -> Int
    
    /// 数据源方法
    /// 返回值类型默认可以是 String, URL, UIImage, 或者是任何自定义遵循了 ImageResourceProtocol 协议的类型, 具体操作见 CZImageSourceProtocol.swift
    func imagePreviewer<ImageResource: ImageResourceProtocol>(_ imagePreviewer: CZImagePreviewer, atIndex index: Int) -> ImageResource?
}

public extension CZImagePreviewerDelegate {
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithIndex index: Int) -> UIView? { nil }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didLongPressAtIndex index: Int) {}
}
