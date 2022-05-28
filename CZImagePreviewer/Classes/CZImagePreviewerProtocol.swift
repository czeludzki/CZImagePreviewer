//
//  CZImagePreviewerProtocol.swift
//  CZImagePreviewerProtocol
//
//  Created by siuzeontou on 2021/9/8.
//

import Foundation
import UIKit

public protocol CZImagePreviewerDataSource: AnyObject {
    
    /// 向 dataSource 获取数据量
    func numberOfItems(in imagePreviewer: CZImagePreviewer) -> Int
    
    /// 数据源方法
    /// 返回值类型默认可以是 String, URL, UIImage, 或者是任何自定义遵循了 ImageResourceProtocol 协议的类型, 具体操作见 CZImageSourceProtocol.swift
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, imageResourceForItemAtIndex index: Int) -> CZImagePreviewerResourceProtocol?
    
    /// 图片加载状态改变
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, imageLoadingStateDidChanged state: CZImagePreviewer.ImageLoadingState, at index: Int, accessoryView: CZImagePreviewerAccessoryView?)
    
    /// 为图片浏览器提供自定义操作视图, 该视图会平铺在图片浏览器子视图集顶部, 不参与缩放, 不受滑动交互影响
    /// 调用时机:
    ///     Previewer.currentIdx 发生改变时发起
    /// 添加视图到 Previewer 的时机:
    ///     在View实例被添加到图片浏览器后, 只要View实例是和已在展示的View实例是同一个, 则不重复做 addSubView 操作
    /// 此视图一般放置一些共有控件例如下载按钮等
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int) -> CZImagePreviewerAccessoryView?
    
    /// 为每一个 Cell 提供自定义操作视图, 这个视图会覆盖在每个Cell的顶部
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, accessoryViewForCell cell: CZImagePreviewerCollectionViewCell, at index: Int) -> CZImagePreviewerAccessoryView?
    
    /// 为每一个 Cell 提供视频播放容器, 你可以将你的视频播放器 Layer, 添加到 videoView.layer 中
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoLayerForCell cell: CZImagePreviewerCollectionViewCell, at index: Int) -> CALayer?
    
    typealias VideoSizeSettingHandler = (CGSize?) -> Void
    /// 通过此代理方法告知 Previewer 视频尺寸
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoSizeForCell cell: CZImagePreviewerCollectionViewCell, at index: Int, videoSizeSettingHandler: VideoSizeSettingHandler)
}

public extension CZImagePreviewerDataSource {

    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, imageLoadingStateDidChanged state: CZImagePreviewer.ImageLoadingState, at index: Int, accessoryView: CZImagePreviewerAccessoryView?) {}

    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int) -> CZImagePreviewerAccessoryView? { nil }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, accessoryViewForCell cell: CZImagePreviewerCollectionViewCell, at index: Int) -> CZImagePreviewerAccessoryView? { nil }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoLayerForCell cell: CZImagePreviewerCollectionViewCell, at index: Int) -> CALayer? { nil }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoSizeForCell cell: CZImagePreviewerCollectionViewCell, at index: Int, videoSizeSettingHandler: VideoSizeSettingHandler) {}
    
}

public protocol CZImagePreviewerDelegate: AnyObject {
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDisplayAtIndex index: Int)
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didDisplayAtIndex index: Int)
    
    /// index 发生改变
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, index oldIndex: Int, didChangedTo newIndex: Int)
    
    /// contentOffset 发生改变
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, contentOffsetDidChanged: CGPoint)
    
    /// 当 imagePreviewer 即将要退出显示时调用
    /// - Returns: 根据返回值决定返回动画: 退回到某个UIView视图的动画
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithCell cell: CZImagePreviewerCollectionViewCell, at index: Int) -> UIView?
    
    /// call when previewer dismiss
    func imagePreviewerDidDismiss(_ imagePreviewer: CZImagePreviewer)
    
    /// 接收到长按事件
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didLongPressAtIndex index: Int)
    
    /// 接收到 点击 或 拖拽企图导致dismiss 的手势, 此返回值决定是否执行 dismiss 操作
    /// 此方法也可用作单击事件的监听. 通过判断 gestureType 的类型是否为 UITapGestureRecognizer 类型来决定是否为点击事件
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, shouldDismissWithGesture gesture: UIGestureRecognizer, at index: Int) -> Bool
}

public extension CZImagePreviewerDelegate {
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDisplayAtIndex index: Int) {}
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didDisplayAtIndex index: Int) {}
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, index oldIndex: Int, didChangedTo newIndex: Int) {}
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, contentOffsetDidChanged: CGPoint) {}

    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithCell cell: CZImagePreviewerCollectionViewCell, at index: Int) -> UIView? { nil }
    
    func imagePreviewerDidDismiss(_ imagePreviewer: CZImagePreviewer) {}
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didLongPressAtIndex index: Int) {}
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, shouldDismissWithGesture gesture: UIGestureRecognizer, at index: Int) -> Bool { true }
}
