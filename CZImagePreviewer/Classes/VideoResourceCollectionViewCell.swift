//
//  VideoResourceCollectionViewCell.swift
//  CZImagePreviewer
//
//  Created by siu on 2023/6/1.
//

import Foundation
import Kingfisher

class VideoResourceCollectionViewCell: CollectionViewCell {
        
    // 从 dataSource 取得的辅助视图, 在 willSet 时, 加入到 cell.contentView
    public override weak var accessoryView: AccessoryView? {
        willSet {
            if newValue === accessoryView { return }
            accessoryView?.removeFromSuperview()
            guard let newView = newValue else { return }
            self.contentView.addSubview(newView)
            newView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    // 快速获取 VideoProvider
    private var videoProvider: VideoProvider? {
        guard let videoProvider = self.item?.resource as? VideoProvider else { return nil }
        return videoProvider
    }
    
    /// 记录视频尺寸, 在闭包 var videoSizeSettingHandler 被调用时赋值
    public private(set) var videoSize: CGSize = .zero {
        didSet {
            self.updateVideoContainerFrame()
        }
    }
    
    /// 从 dataSource 取得的视频layer, 在 willSet 时, 加入到 cell.videoContainer.layer
    public weak var videoView: VideoView? {
        willSet {
            if newValue === videoView { return }
            guard let newView = newValue else { return }
            self.contentView.addSubview(newView)
            self.updateVideoContainerFrame()
        }
    }
            
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateVideoContainerFrame()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    /// 拖拽事件发生时, 拖拽动画主角
    override var dragingActor: UIView? { self.videoView }

    /// 加载内容
    override func willDisplay() {
        super.willDisplay()
        // 获取视频尺寸 及 监听其变化
        self.videoProvider?.videoSizeProvider = { [weak self] size in
            self?.videoSize = size
        }
        // 获取视频内容视图
        self.videoView = self.videoProvider?.videoView
    }
    
    // 在 cell 离开屏幕后调用
    override func didEndDisplay() {
        super.didEndDisplay()
        self.videoProvider?.pause()
    }
}

// MARK: Helper
extension VideoResourceCollectionViewCell {
    
    /// 更新 video 视图配置, 配置 videoLayer 以及 videoContainer 的 frame
    func updateVideoContainerFrame() {
        if self.videoSize == .zero {
            self.videoView?.frame = self.contentView.bounds
            return
        }
        // 计算 self.videoSize 展示在屏幕上的大小
        let convertSize = self.videoSize.scaleAspectFiting(toSize: self.contentView.bounds.size)
        let center = CGPoint(x: self.contentView.bounds.maxX * 0.5, y: self.contentView.bounds.maxY * 0.5)
        self.videoView?.center = center
        self.videoView?.bounds = .init(origin: .zero, size: convertSize)
    }

}
