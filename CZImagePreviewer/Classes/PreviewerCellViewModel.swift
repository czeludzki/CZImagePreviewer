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
class PreviewerCellViewModel: NSObject {     // 继承自 NSObject 是因为此类需要遵循 ScrollViewDelegate 协议
    
    // 记录当前索引
    private var idx = 0
    // 弱引用 CZImagePreviewerCollectionViewCell 实例
    unowned var cell: CollectionViewCell
    // delegate
    weak var delegate: PreviewerCellViewModelDelegate?
    
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
            
            /// 不知道为什么不能直接调用 imageResource?.loadImage() 方法
            /// 直接调用的结果是, 总会走到 extension ImgSourceNamespaceWrapper: ImageResourceProtocol 的默认实现中去,
            /// 而不是 extension ImgSourceNamespaceWrapper where WrappedValueType == String 指定 String 的实现
            /// 除非像下面做的, 对 imageResource 进行转型, 编译器才会调用到正确的函数, 也就是走 extension ImgSourceNamespaceWrapper where WrappedValueType == String 指定的实现
            
            if let res = resource as? ImgSourceNamespaceWrapper<String> {
                res.loadImage(progress: self.progress(receivedSize:expectedSize:targetURL:), completion: completion(image:data:error:cacheType:finish:targetURL:))
                return
            }
            
            if let res = resource as? ImgSourceNamespaceWrapper<URL> {
                res.loadImage(progress: self.progress(receivedSize:expectedSize:targetURL:), completion: completion(image:data:error:cacheType:finish:targetURL:))
                return
            }
            
            if let res = resource as? ImgSourceNamespaceWrapper<UIImage> {
                res.loadImage(progress: self.progress(receivedSize:expectedSize:targetURL:), completion: completion(image:data:error:cacheType:finish:targetURL:))
                return
            }
            
            resource?.loadImage(progress: self.progress(receivedSize:expectedSize:targetURL:), completion: completion(image:data:error:cacheType:finish:targetURL:))
        }
    }
    
}

// MARK: ScrollViewDelegate
extension PreviewerCellViewModel: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.cell.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.keepCentral()
    }
}

// MARK: Helper
extension PreviewerCellViewModel {
    
    // 图片加载进度闭包
    func progress(receivedSize: Int, expectedSize: Int, targetURL: URL?) {
        self.delegate?.collectionCellViewModel(self, idx: self.idx, resourceLoadingStateDidChanged: .loading(receivedSize: receivedSize, expectedSize: expectedSize))
    }
    
    // 图片加载结果
    func completion(image: UIImage?, data: Data?, error: Error?, cacheType: SDImageCacheType, finish: Bool, targetURL: URL?) {
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
    
    /// 计算图片以 UIViewContentModeScaleAspectFit 显示在 imageView 上的大小
    static func imageFitingSizeOnScreen(imgSize: CGSize) -> CGSize {
        let mainScreenSize = UIScreen.main.bounds.size
        let widthRaito = mainScreenSize.width / imgSize.width
        let heightRaito = mainScreenSize.height / imgSize.height
        let scale = min(widthRaito, heightRaito)
        let fitingWidth = scale * imgSize.width
        let fitingHeight = scale * imgSize.height
        return CGSize.init(width: fitingWidth, height: fitingHeight)
    }
    
    /// 更新 zoomingScroll 的配置
    func updateScrollViewConfiguration() {
        let screenSize = UIScreen.main.bounds.size
        let imgSize = self.cell.imageView.image?.size ?? CGSize.zero
        self.cell.zoomingScrollView.contentSize = imgSize
        
        // 不缩放的情况下, 图片在屏幕上的大小
        let imageFitingSizeInScreen = Self.imageFitingSizeOnScreen(imgSize: imgSize)
        
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
