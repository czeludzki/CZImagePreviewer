//
//  CZImagePreviewerAccessoryView.swift
//  CZImagePreviewer
//
//  Created by siu on 2021/9/28.
//

import UIKit

/// 辅助视图类型
public enum ViewType {
    /// 放在 Previewer 顶部的控制面板
    case console
    /// 放在 Cell 上的辅助视图
    case accessoryView
    /// Cell 上的视频容器视图
    case videoView
}

/// DateSource 方法要求返回的辅助视图类
open class AccessoryView: UIView {
    
    public var viewType: ViewType = .console
    
    /// 对 hitTest 方法进行处理, 防止 AccessoryView 参与事件处理
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let ret = super.hitTest(point, with: event) else {
            return nil
        }
        // 当找到的响应者是自己, 就返回 nil, 不参与事件响应
        if ret == self {
            return nil
        }
        return ret
    }
    
    var videoLayer: CALayer?
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.viewType == .videoView {
            // 参考 https://stackoverflow.com/questions/24670269/how-do-you-animate-the-sublayers-of-the-layer-of-a-uiview-during-a-uiview-animat?r=SearchResults#
            CATransaction.begin()
            if let anim = self.layer.animation(forKey: "bounds.size") {
                // 使 videoLayer 跟随 superLayer 的动画. UIView.animate() 动画返回时会走这里
                CATransaction.setAnimationDuration(anim.duration)
                CATransaction.setAnimationTimingFunction(anim.timingFunction)
            }else{
                // 让 videoLayer 跟随 self.frame.size, 并且取消隐式动画. 手动拖拽时会走这里
                CATransaction.setDisableActions(true)
            }
            self.videoLayer?.frame = CGRect(origin: .zero, size: self.bounds.size)
            CATransaction.commit()
        }
    }
    
}
