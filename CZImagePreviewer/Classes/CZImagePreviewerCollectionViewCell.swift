//
//  CZImagePreviewerCollectionViewCell.swift
//  CZImagePreviewerCollectionViewCell
//
//  Created by siuzeontou on 2021/9/9.
//

import UIKit
import Kingfisher

// 资源模型
internal struct PreviewerCellItem {
    var resource: CZImagePreviewerResource?
    var idx: Int
}

internal protocol CollectionViewCellDelegate: AnyObject {
    /// 通知代理图片加载进度
    func collectionViewCell(_ cell: CZImagePreviewerCollectionViewCell, resourceLoadingStateDidChanged state: CZImagePreviewer.ImageLoadingState, idx: Int, accessoryView: CZImagePreviewerAccessoryView?)
}

public class CZImagePreviewerCollectionViewCell: UICollectionViewCell {
    
    static let CollectionViewCellReuseID = NSStringFromClass(CZImagePreviewerCollectionViewCell.self) + "ReuseID"
    
    // 记录当前索引
    public private(set) var idx = 0
    
    // delegate
    weak var delegate: CollectionViewCellDelegate?
    
    // 从 dataSource 取得的辅助视图, 在 willSet 时, 加入到 cell.contentView
    public weak var accessoryView: CZImagePreviewerAccessoryView? {
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
    
    var resource: CZImagePreviewerResource? {
        didSet {
            self.imageView.image = nil
            guard let resource = resource else { return }
            resource.loadImage(progress: self.progress(receivedSize:expectedSize:), completion: self.completion(result:))
        }
    }
    
    lazy var imageView: Kingfisher.AnimatedImageView = {
        let ret = Kingfisher.AnimatedImageView.init(frame: CGRect.zero)
        ret.backgroundColor = .clear
        ret.clipsToBounds = true
        ret.contentMode = .scaleAspectFill
        return ret
    }()
    
    lazy var zoomingScrollView: UIScrollView = {
        let zoomingScrollView = UIScrollView.init(frame: CGRect.zero)
        zoomingScrollView.delegate = self
        zoomingScrollView.showsVerticalScrollIndicator = false
        zoomingScrollView.showsHorizontalScrollIndicator = false
        zoomingScrollView.bounces = true
        zoomingScrollView.clipsToBounds = false
        zoomingScrollView.backgroundColor = UIColor.clear
        zoomingScrollView.alwaysBounceVertical = false
        zoomingScrollView.alwaysBounceHorizontal = false
        zoomingScrollView.contentInsetAdjustmentBehavior = .never
        return zoomingScrollView
    }()
    
    lazy var videoContainer: CZImagePreviewerAccessoryView = {
        let videoContainer = CZImagePreviewerAccessoryView.init()
        videoContainer.viewType = .videoView
        return videoContainer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.contentView.addSubview(self.zoomingScrollView)
        self.zoomingScrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.zoomingScrollView.addSubview(self.imageView)
        self.contentView.addSubview(self.videoContainer)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
//    deinit { print("Cell销毁了") }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateScrollViewConfiguration()
        self.updateVideoContainerConfiguration()
        self.keepCentral()
    }
    
    public func clearZooming(animate: Bool = true) {
        self.zoomingScrollView.setZoomScale(1, animated: animate)
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
extension CZImagePreviewerCollectionViewCell {
    
    /// 更新 zoomingScroll 的配置
    func updateScrollViewConfiguration() {
        let screenSize = UIScreen.main.bounds.size
        let imgSize = self.imageView.image?.size ?? screenSize
        self.zoomingScrollView.contentSize = imgSize
        
        // 不缩放的情况下, 图片在屏幕上的大小
        let imageFitingSizeInScreen: CGSize = self.imageView.image?.size.scaleAspectFiting(toSize: screenSize) ?? screenSize
        
        self.imageView.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: imageFitingSizeInScreen.width, height: imageFitingSizeInScreen.height))
        self.imageView.center = CGPoint.init(x: screenSize.width * 0.5, y: screenSize.height * 0.5)
        
        // 计算最大/最小缩放
        self.zoomingScrollView.minimumZoomScale = 1
        let maxZoomScale = (imgSize.height * imgSize.width) / (imageFitingSizeInScreen.width * imageFitingSizeInScreen.height)
        self.zoomingScrollView.maximumZoomScale = maxZoomScale > 1 ? maxZoomScale : 2
        
        // 初始缩放系数
        self.zoomingScrollView.setZoomScale(1, animated: false)
        self.layoutIfNeeded()
    }
    
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
    
    func keepCentral() {
        let scrollW = UIScreen.main.bounds.width
        let scrollH = UIScreen.main.bounds.height
        
        let contentSize = self.zoomingScrollView.contentSize
        let offsetX = scrollW > contentSize.width ? (scrollW - contentSize.width) * 0.5 : 0
        let offsetY = scrollH > contentSize.height ? (scrollH - contentSize.height) * 0.5 : 0
        
        let centerX = contentSize.width * 0.5 + offsetX
        let centerY = contentSize.height * 0.5 + offsetY
        
        self.imageView.center = CGPoint(x: centerX, y: centerY)
    }
    
    // 图片加载进度闭包
    func progress(receivedSize: Int64, expectedSize: Int64) {
        self.delegate?.collectionViewCell(self, resourceLoadingStateDidChanged: .loading(receivedSize: receivedSize, expectedSize: expectedSize), idx: self.idx, accessoryView: self.accessoryView)
    }
    
    // 图片加载结果
    func completion(result: Result<UIImage, KingfisherError>) {
        if case let .success(img) = result {
            self.imageView.image = img
            self.delegate?.collectionViewCell(self, resourceLoadingStateDidChanged: .default, idx: self.idx, accessoryView: self.accessoryView)
        }else{
            self.delegate?.collectionViewCell(self, resourceLoadingStateDidChanged: .loadingFaiure, idx: self.idx, accessoryView: self.accessoryView)
        }
        self.updateScrollViewConfiguration()
    }
}

// MARK: ScrollViewDelegate
extension CZImagePreviewerCollectionViewCell: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.keepCentral()
    }
}
