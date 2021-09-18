//
//  CZImagePreviewerCellVM.swift
//  CZImagePreviewerCellVM
//
//  Created by siuzeontou on 2021/9/10.
//

import UIKit
import Kingfisher

protocol PreviewerCellViewModelDelegate: AnyObject {
    /// 通知代理图片加载进度
    func collectionCellViewModel(_ viewModel: PreviewerCellViewModel, idx: Int, resourceLoadingStateDidChanged state: CZImagePreviewer.ImageLoadingState)
}

// 资源模型
internal struct PreviewerCellItem {
    var resource: ResourceProtocol?
    var idx: Int
}

/// 此类会被 CZImagePreviewerCollectionViewCell 懒加载生成, 专门处理 视图 与 PreviewerCellItem 之间的通讯
public class PreviewerCellViewModel: NSObject {     // 继承自 NSObject 是因为此类需要遵循 ScrollViewDelegate 协议
    
    // 记录当前索引
    public private(set) var idx = 0
    // 弱引用 CZImagePreviewerCollectionViewCell 实例
    unowned var cell: CollectionViewCell
    // delegate
    weak var delegate: PreviewerCellViewModelDelegate?
    
    // 从 dataSource 取得的辅助视图, 在 willSet 时, 加入到 cell.contentView
    public weak var accessoryView: UIView? {
        willSet {
            if newValue === accessoryView { return }
            accessoryView?.removeFromSuperview()
            guard let newView = newValue else { return }
            cell.contentView.addSubview(newView)
            newView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    /// 从 dataSource 取得的视频layer, 在 willSet 时, 加入到 cell.videoContainer.layer
    public weak var videoLayer: CALayer? {
        willSet {
            self.cell.zoomingScrollView.isHidden = newValue != nil
            self.cell.videoContainer.isHidden = newValue == nil
            if newValue === videoLayer { return }
            videoLayer?.removeFromSuperlayer()
            guard let newLayer = newValue else { return }
            self.cell.videoContainer.layer.addSublayer(newLayer)
            self.cell.videoContainer.videoLayer = newLayer
        }
    }
    
    /// 记录视频尺寸, 在闭包 var videoSizeSettingHandler 被调用时赋值
    public private(set) var videoSize: CGSize = .zero {
        didSet {
            self.updateVideoContainerConfiguration()
        }
    }
    
    /// 视频尺寸配置闭包
    public private(set) lazy var videoSizeSettingHandler: ((CGSize?) -> Void)? = { [weak self] size in
        guard let size = size else {
            return
        }
        self?.videoSize = size
    }
    
    /// dismiss动画发生时, 需要判断该由 imageView 或是 videoView 作为动画主角
    var dismissAnimationActor: UIView {
        if self.videoLayer != nil {
            return self.cell.videoContainer
        }
        return self.cell.imageView
    }
    
    var item: PreviewerCellItem? {
        didSet {
            self.idx = item?.idx ?? 0
            self.resource = item?.resource
        }
    }
    
    var resource: ResourceProtocol? {
        didSet {
            resource?.loadImage(progress: self.progress(receivedSize:expectedSize:), completion: self.completion(image:result:))
        }
    }
    
    init(cell: CollectionViewCell) {
        self.cell = cell
        super.init()
    }
    
    func cellDidLayoutSubviews() {
        self.updateScrollViewConfiguration()
        self.updateVideoContainerConfiguration()
        self.keepCentral()
    }
}

// MARK: ScrollViewDelegate
extension PreviewerCellViewModel: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.cell.imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.keepCentral()
    }
}

// MARK: Public function
extension PreviewerCellViewModel {
    func clearZooming(animate: Bool = true) {
        self.cell.zoomingScrollView.setZoomScale(1, animated: animate)
    }
    
    func zoom(rect: CGRect, animate: Bool = true) {
        var translationRect: CGRect = .zero
        translationRect.origin.x = rect.origin.x / self.cell.zoomingScrollView.zoomScale - self.cell.zoomingScrollView.contentInset.left / self.cell.zoomingScrollView.zoomScale
        translationRect.origin.y = rect.origin.y / self.cell.zoomingScrollView.zoomScale - self.cell.zoomingScrollView.contentInset.top / self.cell.zoomingScrollView.zoomScale
        translationRect.size.height = 10
        translationRect.size.width = 10
        self.cell.zoomingScrollView.zoom(to: translationRect, animated: true)
    }
}

// MARK: Helper
extension PreviewerCellViewModel {
    
    // 图片加载进度闭包
    func progress(receivedSize: Int64, expectedSize: Int64) {
        self.delegate?.collectionCellViewModel(self, idx: self.idx, resourceLoadingStateDidChanged: .loading(receivedSize: receivedSize, expectedSize: expectedSize))
    }
    
    // 图片加载结果
    func completion(image: UIImage?, result: Result<RetrieveImageResult, KingfisherError>?) {
        self.cell.imageView.image = image
        self.updateScrollViewConfiguration()
        if case .failure(_) = result {
            self.delegate?.collectionCellViewModel(self, idx: self.idx, resourceLoadingStateDidChanged: .loadingFaiure)
            return
        }
        self.delegate?.collectionCellViewModel(self, idx: self.idx, resourceLoadingStateDidChanged: .default)
    }
    
    /// 更新 zoomingScroll 的配置
    func updateScrollViewConfiguration() {
        let screenSize = UIScreen.main.bounds.size
        let imgSize = self.cell.imageView.image?.size ?? screenSize
        self.cell.zoomingScrollView.contentSize = imgSize
        
        // 不缩放的情况下, 图片在屏幕上的大小
        let imageFitingSizeInScreen: CGSize = self.cell.imageView.image?.size.asImgRes.scaleAspectFiting(toSize: screenSize) ?? screenSize
        
        self.cell.imageView.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: imageFitingSizeInScreen.width, height: imageFitingSizeInScreen.height))
        self.cell.imageView.center = CGPoint.init(x: screenSize.width * 0.5, y: screenSize.height * 0.5)
        
        // 计算最大/最小缩放
        self.cell.zoomingScrollView.minimumZoomScale = 1
        let maxZoomScale = (imgSize.height * imgSize.width) / (imageFitingSizeInScreen.width * imageFitingSizeInScreen.height)
        self.cell.zoomingScrollView.maximumZoomScale = maxZoomScale > 1 ? maxZoomScale : 2
        
        // 初始缩放系数
        self.cell.zoomingScrollView.setZoomScale(1, animated: false)
        self.cell.layoutIfNeeded()
    }
    
    /// 更新 video 视图配置, 配置 videoLayer 以及 videoContainer 的 frame
    func updateVideoContainerConfiguration() {
        if self.videoSize == .zero {
            self.cell.videoContainer.frame = self.cell.contentView.bounds
            return
        }
        // 计算 self.videoSize 展示在屏幕上的大小
        let convertSize = self.videoSize.asImgRes.scaleAspectFiting(toSize: self.cell.contentView.bounds.size)
        self.cell.videoContainer.bounds.size = convertSize
        self.cell.videoContainer.center = CGPoint(x: self.cell.contentView.bounds.maxX * 0.5, y: self.cell.contentView.bounds.maxY * 0.5)
    }
    
    func keepCentral() {
        let scrollW = UIScreen.main.bounds.width
        let scrollH = UIScreen.main.bounds.height
        
        let contentSize = self.cell.zoomingScrollView.contentSize
        let offsetX = scrollW > contentSize.width ? (scrollW - contentSize.width) * 0.5 : 0
        let offsetY = scrollH > contentSize.height ? (scrollH - contentSize.height) * 0.5 : 0
        
        let centerX = contentSize.width * 0.5 + offsetX
        let centerY = contentSize.height * 0.5 + offsetY
        
        self.cell.imageView.center = CGPoint(x: centerX, y: centerY)
    }
}
