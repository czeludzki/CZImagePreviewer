//
//  CZImagePreviewerCellVM.swift
//  CZImagePreviewerCellVM
//
//  Created by siuzeontou on 2021/9/10.
//

import UIKit
import SDWebImage

protocol PreviewerCellViewModelDelegate: AnyObject {
    /// 通知代理图片加载进度
    func collectionCellViewModel(_ viewModel: PreviewerCellViewModel, idx: Int, resourceLoadingStateDidChanged state: CZImagePreviewer.ImageLoadingState)
}

// 资源模型
struct PreviewerCellItem {
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
    
    // 从 dataSource 取得的辅助视图, 在 didset 后, 加入到 cell.contentView 
    public weak var accessoryView: UIView? {
        willSet {
            accessoryView?.removeFromSuperview()
            guard let newView = newValue else { return }
            cell.contentView.addSubview(newView)
            newView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    /// 从 dataSource 取得的视频layer, 在 willset 后, 加入到 cell.videoContainer.layer
    public weak var videoLayer: CALayer? {
        willSet {
            videoLayer?.removeFromSuperlayer()
            guard let newLayer = newValue else { return }
            self.cell.videoContainer.layer.addSublayer(newLayer)
            newLayer.frame = self.cell.videoContainer.bounds
        }
    }
    
    /// dismiss动画发生时, 需要判断该由 imageView 或是 videoView 作为动画主角
    var dismissAnimationActor: UIView {
        if self.videoLayer != nil {
            return self.cell.videoContainer
        }
        return self.cell.imageView
    }
    
    init(cell: CollectionViewCell) {
        self.cell = cell
        super.init()
    }
    
    var item: PreviewerCellItem? {
        didSet {
            self.idx = item?.idx ?? 0
            self.resource = item?.resource
        }
    }
    
    var resource: ResourceProtocol? {
        didSet {
            resource?.loadImage(progress: self.progress(receivedSize:expectedSize:targetURL:), completion: completion(image:data:error:cacheType:finish:targetURL:))
        }
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
    func progress(receivedSize: Int, expectedSize: Int, targetURL: URL?) {
        DispatchQueue.main.async {
            self.delegate?.collectionCellViewModel(self, idx: self.idx, resourceLoadingStateDidChanged: .loading(receivedSize: receivedSize, expectedSize: expectedSize))
        }
    }
    
    // 图片加载结果
    func completion(image: UIImage?, data: Data?, error: Error?, cacheType: SDImageCacheType, finish: Bool, targetURL: URL?) {
        DispatchQueue.main.async {
            self.cell.imageView.image = image
            self.updateScrollViewConfiguration()
            if let _ = error {
                self.delegate?.collectionCellViewModel(self, idx: self.idx, resourceLoadingStateDidChanged: .loadingFaiure)
                return
            }
            if !finish {
                self.delegate?.collectionCellViewModel(self, idx: self.idx, resourceLoadingStateDidChanged: .processing)
                return
            }
            self.delegate?.collectionCellViewModel(self, idx: self.idx, resourceLoadingStateDidChanged: .default)
        }
    }
    
    /// 更新 zoomingScroll 的配置
    func updateScrollViewConfiguration() {
        let screenSize = UIScreen.main.bounds.size
        let imgSize = self.cell.imageView.image?.size ?? screenSize
        self.cell.zoomingScrollView.contentSize = imgSize
        
        // 不缩放的情况下, 图片在屏幕上的大小
        let imageFitingSizeInScreen: CGSize = self.cell.imageView.image?.asImgRes.scaleAspectFiting(toSize: screenSize) ?? screenSize
        
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
    
    func keepCentral() {
        let scrollW = UIScreen.main.bounds.width
        let scrollH = UIScreen.main.bounds.height
        
        let contentSize = self.cell.zoomingScrollView.contentSize
        let offsetX = scrollW > contentSize.width ? (scrollW - contentSize.width) * 0.5 : 0
        let offsetY = scrollH > contentSize.height ? (scrollH - contentSize.height) * 0.5 : 0
        
        let centerX = contentSize.width * 0.5 + offsetX
        let centerY = contentSize.height * 0.5 + offsetY
        
        self.cell.imageView.center = CGPoint.init(x: centerX, y: centerY)
    }
}
