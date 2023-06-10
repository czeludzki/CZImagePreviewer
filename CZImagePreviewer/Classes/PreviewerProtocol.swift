//
//  CZImagePreviewerProtocol.swift
//  CZImagePreviewerProtocol
//
//  Created by siuzeontou on 2021/9/8.
//

import Foundation
import UIKit

public protocol DataSource: AnyObject {
    
    /// 向 dataSource 获取数据量
    func numberOfItems(in imagePreviewer: Previewer) -> Int
    
    /// 数据源方法
    /// 返回值类型默认可以是 String, URL, UIImage, 或者是任何自定义遵循了 ImageResourceProtocol 协议的类型, 具体操作见 CZImageSourceProtocol.swift
    func imagePreviewer(_ imagePreviewer: Previewer, resourceForItemAtIndex index: Int) -> ResourceProvider?
    
    /// 图片加载状态改变
    func imagePreviewer(_ imagePreviewer: Previewer, imageLoadingStateDidChanged state: Previewer.ImageLoadingState, at index: Int, accessoryView: AccessoryView?)
    
    /// 为图片浏览器提供自定义操作视图, 该视图会平铺在图片浏览器子视图集顶部, 不参与缩放, 不受滑动交互影响
    /// 调用时机:
    ///     Previewer.currentIdx 发生改变时发起
    /// 添加视图到 Previewer 的时机:
    ///     在View实例被添加到图片浏览器后, 只要View实例是和已在展示的View实例是同一个, 则不重复做 addSubView 操作
    /// 此视图一般放置一些共有控件例如下载按钮等
    func imagePreviewer(_ imagePreviewer: Previewer, consoleForItemAtIndex index: Int) -> AccessoryView?
    
    /// 为每一个 Cell 提供自定义操作视图, 这个视图会覆盖在每个Cell的顶部
    func imagePreviewer(_ imagePreviewer: Previewer, accessoryViewForCell cell: CollectionViewCell, at index: Int) -> AccessoryView?
    
}

public extension DataSource {

    func imagePreviewer(_ imagePreviewer: Previewer, imageLoadingStateDidChanged state: Previewer.ImageLoadingState, at index: Int, accessoryView: AccessoryView?) {}

    func imagePreviewer(_ imagePreviewer: Previewer, consoleForItemAtIndex index: Int) -> AccessoryView? { nil }
    
    func imagePreviewer(_ imagePreviewer: Previewer, accessoryViewForCell cell: CollectionViewCell, at index: Int) -> AccessoryView? { nil }
    
}

public protocol Delegate: AnyObject {
    
    /// 将要显示 imagePreviewer
    /// 返回值 fromContainer 决定展示动画从哪里弹出, resource 是图片资源
    /// 展示动画出现前, 会创建 UIImageView 展示 resource 图片, 该 UIImageView 会作为展示动画的主角, 从 fromContrainer 中弹出
    func imagePreviewer(_ imagePreviewer: Previewer, willDisplayAtIndex index: Int)
    
    func imagePreviewer(_ imagePreviewer: Previewer, didDisplayAtIndex index: Int)
    
    /// index 发生改变
    func imagePreviewer(_ imagePreviewer: Previewer, indexDidChangedTo newIndex: Int, fromOldIndex oldIndex: Int)
    
    /// contentOffset 发生改变
    func imagePreviewer(_ imagePreviewer: Previewer, contentOffsetDidChanged: CGPoint)
    
    /// 当 imagePreviewer 即将要退出显示时调用
    /// - Returns: 根据返回值决定返回动画: 退回到某个UIView视图的动画
    func imagePreviewer(_ imagePreviewer: Previewer, willDismissWithCell cell: CollectionViewCell, at index: Int) -> UIView?
    
    /// call when previewer dismiss
    func imagePreviewerDidDismiss(_ imagePreviewer: Previewer)
    
    /// 接收到长按事件
    func imagePreviewer(_ imagePreviewer: Previewer, didLongPressAtIndex index: Int)
    
    /// 接收到 点击 或 拖拽企图导致dismiss 的手势, 此返回值决定是否执行 dismiss 操作
    /// 此方法也可用作单击事件的监听. 通过判断 gestureType 的类型是否为 UITapGestureRecognizer 类型来决定是否为点击事件
    func imagePreviewer(_ imagePreviewer: Previewer, shouldDismissWithGesture gesture: UIGestureRecognizer, at index: Int) -> Bool
    
    /// deleteItems(at indexs: [Int])  调用后, 删除操作结束后, 会触发此方法
    func imagePreviewer(_ imagePreviewer: Previewer, didFinishDeletedItems indexs: [Int])
    
}

public extension Delegate {
    
    func imagePreviewer(_ imagePreviewer: Previewer, willDisplayAtIndex index: Int) {}
    
    func imagePreviewer(_ imagePreviewer: Previewer, didDisplayAtIndex index: Int) {}
    
    func imagePreviewer(_ imagePreviewer: Previewer, indexDidChangedTo newIndex: Int, fromOldIndex oldIndex: Int) {}
    
    func imagePreviewer(_ imagePreviewer: Previewer, contentOffsetDidChanged: CGPoint) {}

    func imagePreviewer(_ imagePreviewer: Previewer, willDismissWithCell cell: CollectionViewCell, at index: Int) -> UIView? { nil }
    
    func imagePreviewerDidDismiss(_ imagePreviewer: Previewer) {}
    
    func imagePreviewer(_ imagePreviewer: Previewer, didLongPressAtIndex index: Int) {}
    
    func imagePreviewer(_ imagePreviewer: Previewer, shouldDismissWithGesture gesture: UIGestureRecognizer, at index: Int) -> Bool { true }
    
    func imagePreviewer(_ imagePreviewer: Previewer, didFinishDeletedItems indexs: [Int]) {}
    
}
