//
//  ImageResourceCollectionViewCell.swift
//  CZImagePreviewer
//
//  Created by siu on 2023/6/1.
//

import Foundation
import Kingfisher

public class ImageResourceCollectionViewCell: CollectionViewCell {
    
    // 记录当前索引
    public private(set) var idx = 0
    
    // delegate
    weak var delegate: CollectionViewCellDelegate?
    
    // 从 dataSource 取得的辅助视图, 在 willSet 时, 加入到 cell.contentView
    public weak var accessoryView: AccessoryView? {
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
    
    /// 从 dataSource 取得的视频layer, 在 willSet 时, 加入到 cell.videoContainer.layer
    public weak var videoLayer: CALayer? {
        willSet {
            self.zoomingScrollView.isHidden = newValue != nil
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
    
    /// 拖拽事件发生时, 需要判断该由 imageView 或是 videoView 作为拖拽主角
    var draginglyActor: UIView {
        if self.videoLayer != nil {
            return self.videoContainer
        }
        return self.imageView
    }
    
    var item: PreviewerCellItem? {
        didSet {
            self.idx = item?.idx ?? 0
            self.resource = item?.resource
        }
    }
    
    var resource: ImageProvider? {
        didSet {
            self.imageView.image = nil
            guard let resource = resource else { return }
            resource.loadImage { [weak self] receivedSize, totalSize in
                self?.progress(receivedSize: receivedSize, expectedSize: totalSize)
            } completion: { [weak self] result in
                self?.completion(result: result)
            }
        }
    }
    
    lazy var animatedImageView: Kingfisher.AnimatedImageView = {
        let ret = Kingfisher.AnimatedImageView.init(frame: CGRect.zero)
        ret.backgroundColor = .clear
        ret.clipsToBounds = true
        ret.contentMode = .scaleAspectFill
        return ret
    }()
    
    lazy var animatedImageZoomingView: ImageZoomingView = {
        let zoomingScrollView = ImageZoomingView.init(self.animatedImageView)
        return zoomingScrollView
    }()
    
    lazy var tiledImageView: TiledImageView = TiledImageView.init()
    
    lazy var tiledImageZoomingView: ImageZoomingView = {
        let zoomingScrollView = ImageZoomingView.init(self.tiledImageView)
        return zoomingScrollView
    }()
    
    lazy var videoContainer: AccessoryView = {
        let videoContainer = AccessoryView.init()
        videoContainer.viewType = .videoView
        return videoContainer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.contentView.addSubview(self.animatedImageZoomingView)
        self.animatedImageZoomingView.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.tiledImageZoomingView.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.contentView.addSubview(self.videoContainer)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit { print("Cell销毁了") }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateVideoContainerConfiguration()
        self.keepCentral()
    }
    
    public func clearZooming(animate: Bool = true) {
        self.animatedImageZoomingView.clearZooming(animate: animate)
        self.tiledImageZoomingView.clearZooming(animate: animate)
    }
    
    public func zoom(rect: CGRect, animate: Bool = true) {
        var translationRect: CGRect = .zero
        translationRect.origin.x = rect.origin.x / self.zoomingScrollView.zoomScale - self.zoomingScrollView.contentInset.left / self.zoomingScrollView.zoomScale
        translationRect.origin.y = rect.origin.y / self.zoomingScrollView.zoomScale - self.zoomingScrollView.contentInset.top / self.zoomingScrollView.zoomScale
        translationRect.size.height = 10
        translationRect.size.width = 10
        self.zoomingScrollView.zoom(to: translationRect, animated: true)
    }
}

// MARK: Helper
extension ImageResourceCollectionViewCell {
    
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
        self.delegate?.collectionViewCell(self, resourceLoadingStateDidChanged: .loading(receivedSize: receivedSize, expectedSize: expectedSize), idx: self.idx, accessoryView: self.accessoryView)
    }
    
    // 图片加载结果
    func completion(result: Result<UIImage, KingfisherError>) {
        if case let .success(img) = result {
            img.kf.imageFrameCount
            
            self.delegate?.collectionViewCell(self, resourceLoadingStateDidChanged: .default, idx: self.idx, accessoryView: self.accessoryView)
        }else{
            self.delegate?.collectionViewCell(self, resourceLoadingStateDidChanged: .loadingFaiure, idx: self.idx, accessoryView: self.accessoryView)
        }
    }
}
