//
//  CZImagePreviewerAccessoryView.swift
//  CZImagePreviewer
//
//  Created by siu on 2021/9/28.
//

import UIKit

/// 辅助视图类型
public enum ViewType {
    /// 放在 VideoCollectionCell 顶部的控制面板
    case console
    /// 放在 Cell 上的辅助视图
    case accessoryView
    /// Cell 上的视频容器视图
    case videoView
}

/// DateSource 方法要求返回的辅助视图类
open class AccessoryView: UIView {
    
    public var viewType: ViewType = .console
    
    /// 对 hitTest 方法进行处理,
    /// 防止 AccessoryView 自身参与事件处理
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 当找到的响应者是自己, 就返回 nil, 不参与事件响应
        if !self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01 { return nil }
        if self.point(inside: point, with: event) {
            for sub in self.subviews.reversed() {
                let convertPoint = sub.convert(point, from: self)
                if let target = sub.hitTest(convertPoint, with: event) {
                    return target
                }
            }
            // 即使在子视图中找不到目标也不 return self
        }
        return nil
    }
    
}

open class VideoView: AccessoryView {
    
    weak var videoLayer: CALayer?
    
    public required init(playerLayer: CALayer) {
        super.init(frame: .zero)
        self.viewType = .videoView
        self.videoLayer = playerLayer
        self.layer.addSublayer(playerLayer)
    }
    
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
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
