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
    
    public private(set) lazy var coverImageView: Kingfisher.AnimatedImageView = Kingfisher.AnimatedImageView.init()
    
    /// 从 dataSource 取得的视频layer, 在 willSet 时, 加入到 cell.videoContainer.layer
    public weak var videoLayer: CALayer? {
        willSet {
            self.videoContainer.isHidden = newValue == nil
            if newValue === videoLayer { return }
            videoLayer?.removeFromSuperlayer()
            guard let newLayer = newValue else { return }
            self.videoContainer.layer.addSublayer(newLayer)
            self.videoContainer.videoLayer = newLayer
        }
    }
    
    /// 记录视频尺寸, 在闭包 var videoSizeSettingHandler 被调用时赋值
    public private(set) var videoSize: CGSize = .zero {
        didSet {
            self.updateVideoContainerConfiguration()
        }
    }
    
    /// 视频尺寸配置闭包
    public private(set) lazy var videoSizeSettingHandler: ((CGSize?) -> Void) = { [weak self] size in
        guard let size = size else { return }
        self?.videoSize = size
    }
    
    private var videoProvider: VideoProvider? {
        guard let videoProvider = self.item?.resource as? VideoProvider else { return nil }
        return videoProvider
    }
    
    /// 拖拽事件发生时, 拖拽动画主角
    override var dragingActor: UIView {
        self.videoContainer
    }
    
    override var item: CellItem? {
        didSet {
            self.videoLayer?.removeFromSuperlayer()
            self.videoProvider?.pause()
            self.coverImageView.image = nil
            guard let resource = self.videoProvider?.cover as? ImageProvider else { return }
            resource.loadImage(options: nil) { [weak self] receivedSize, totalSize in
                self?.progress(receivedSize: receivedSize, expectedSize: totalSize)
            } completion: { [weak self] result in
                self?.completion(result: result)
            }
        }
    }
    
    lazy var videoContainer: AccessoryView = {
        let videoContainer = AccessoryView.init()
        videoContainer.viewType = .videoView
        return videoContainer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.contentView.addSubview(self.coverImageView)
        self.coverImageView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        self.contentView.addSubview(self.videoContainer)
        self.videoContainer.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit { print("Cell销毁了") }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateVideoContainerConfiguration()
    }
        
    // 在 cell 离开屏幕后, 重置其 zoomingScrollView 和 videoView 的隐藏状态. 默认是 图像层 不隐藏, 视频层 隐藏
    override func didEndDisplay() {
        
    }
}

// MARK: Helper
extension VideoResourceCollectionViewCell {
    
    /// 更新 video 视图配置, 配置 videoLayer 以及 videoContainer 的 frame
    func updateVideoContainerConfiguration() {
        if self.videoSize == .zero {
            self.videoContainer.frame = self.contentView.bounds
            return
        }
        // 计算 self.videoSize 展示在屏幕上的大小
        let convertSize = self.videoSize.scaleAspectFiting(toSize: self.contentView.bounds.size)
        self.videoContainer.bounds.size = convertSize
        self.videoContainer.center = CGPoint(x: self.contentView.bounds.maxX * 0.5, y: self.contentView.bounds.maxY * 0.5)
    }
    
    // 图片加载进度闭包
    func progress(receivedSize: Int64, expectedSize: Int64) {
        guard let item = self.item else { return }
        self.delegate?.collectionViewCell(self, resourceLoadingStateDidChanged: .loading(receivedSize: receivedSize, expectedSize: expectedSize), idx: item.idx, accessoryView: self.accessoryView)
    }
    
    // 图片加载结果
    func completion(result: Result<UIImage, KingfisherError>) {
        guard let item = self.item else { return }
        self.coverImageView.image = result.image
        if case .success = result {
            self.delegate?.collectionViewCell(self, resourceLoadingStateDidChanged: .default, idx: item.idx, accessoryView: self.accessoryView)
        }else{
            self.delegate?.collectionViewCell(self, resourceLoadingStateDidChanged: .loadingFaiure, idx: item.idx, accessoryView: self.accessoryView)
        }
    }

}
