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
    
    /// 图片加载状态改变
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, imageLoadingStateDidChanged state: CZImagePreviewer.ImageLoadingState, with viewModel: PreviewerCellViewModel)
    
    /// 为图片浏览器提供自定义操作视图, 该视图会平铺在图片浏览器子视图集顶部, 不参与缩放, 不受滑动交互影响
    /// 调用时机:
    ///     Previewer.currentIdx 发生改变时发起
    /// 添加视图到 Previewer 的时机:
    ///     在View实例被添加到图片浏览器后, 只要View实例是和已在展示的View实例是同一个, 则不重复做 addSubView 操作
    /// 此视图一般放置一些共有控件例如下载按钮等
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int) -> CZImagePreviewer.AccessoryView?
    
    /// 为每一个 Cell 提供自定义操作视图, 这个视图会覆盖在每个Cell的顶部
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, accessoryViewForCellWith viewModel: PreviewerCellViewModel) -> CZImagePreviewer.AccessoryView?
    
    /// 为每一个 Cell 提供视频播放容器, 你可以将你的视频播放器 Layer, 添加到 参数: videoView.layer 中
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoLayerForCellWith viewModel: PreviewerCellViewModel) -> CALayer?
    
    typealias VideoSizeSettingHandler = (CGSize?) -> Void
    /// 告知 Previewer 视频尺寸
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoSizeForCellWith viewModel: PreviewerCellViewModel, videoSizeSettingHandler: VideoSizeSettingHandler)
}

public protocol PreviewerDelegate: AnyObject {
    /// 当 imagePreviewer 即将要退出显示时调用
    /// - Returns: 根据返回值决定返回动画: 退回到某个UIView视图的动画
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithCellViewModel viewModel: PreviewerCellViewModel) -> UIView?
    
    /// 接收到长按事件
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didLongPressAtIndex index: Int)
}

public extension PreviewerDelegate {
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithCellViewModel viewModel: PreviewerCellViewModel) -> UIView? { nil }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didLongPressAtIndex index: Int) {}
}

public extension PreviewerDataSource {
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int) -> CZImagePreviewer.AccessoryView? { nil }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, accessoryViewForCellWith viewModel: PreviewerCellViewModel) -> CZImagePreviewer.AccessoryView? { nil }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoLayerForCellWith viewModel: PreviewerCellViewModel) -> CALayer? { nil }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, imageLoadingStateDidChanged state: CZImagePreviewer.ImageLoadingState, with viewModel: PreviewerCellViewModel) {}
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoSizeForCellWith viewModel: PreviewerCellViewModel, videoSizeSettingHandler: VideoSizeSettingHandler) {}
}
