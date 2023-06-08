//
//  ImageResourceCollectionViewCell.swift
//  CZImagePreviewer
//
//  Created by siu on 2023/6/1.
//

import Foundation
import Kingfisher

public class ImageResourceCollectionViewCell: CollectionViewCell {
    
    // 从 dataSource 取得的辅助视图, 在 willSet 时, 加入到 cell.contentView
    weak override var accessoryView: AccessoryView? {
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
    
    private var isAnimatedResource: Bool = true
    
    // dismiss 手势发生时, 隐藏 tiledImageView
    override var isDismissGustureDraging: Bool {
        didSet {
            self.tiledImageView.tiledImageView?.isHidden = self.isDismissGustureDraging
        }
    }
    
    /// 拖拽事件发生时, 需要判断该由 animatedImageZoomingView 或是 tiledImageZoomingView 作为拖拽主角
    override var dragingActor: UIView? {
        return self.isAnimatedResource ? self.animatedImageView : self.tiledImageView
    }
    
    /// 让外部快速获取当前的 zoomingView
    var zoomingView: ImageZoomingView {
        return self.isAnimatedResource ? self.animatedImageZoomingView : self.tiledImageZoomingView
    }
    
    private var imageProvider: ImageProvider? {
        guard let imageProvider = self.item?.resource as? ImageProvider else { return nil }
        return imageProvider
    }
    
    // Subviews
    lazy var animatedImageView: Kingfisher.AnimatedImageView = {
        let ret = Kingfisher.AnimatedImageView.init(frame: CGRect.zero)
        ret.backgroundColor = .clear
        ret.clipsToBounds = true
        ret.contentMode = .scaleAspectFill
        return ret
    }()
    
    private lazy var animatedImageZoomingView: ImageZoomingView = {
        let zoomingScrollView = ImageZoomingView.init(self.animatedImageView)
        return zoomingScrollView
    }()
    
    lazy var tiledImageView: TiledImageViewWrapper = TiledImageViewWrapper.init()
    
    private lazy var tiledImageZoomingView: ImageZoomingView = {
        let zoomingScrollView = ImageZoomingView.init(self.tiledImageView)
        return zoomingScrollView
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.contentView.addSubview(self.animatedImageZoomingView)
        self.animatedImageZoomingView.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.contentView.addSubview(self.tiledImageZoomingView)
        self.tiledImageZoomingView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
    public func clearZooming(animate: Bool = true) {
        self.animatedImageZoomingView.clearZooming(animate: animate)
        self.tiledImageZoomingView.clearZooming(animate: animate)
    }
    
    public func zoom(rect: CGRect, animate: Bool = true) {
        self.animatedImageZoomingView.zoom(to: rect, animated: animate)
        self.tiledImageZoomingView.zoom(to: rect, animated: animate)
    }
    
    /// 加载内容
    override func willDisplay() {
        super.willDisplay()
        guard let resource = self.item?.resource as? ImageProvider else { return }
        resource.loadImage(options: nil) { [weak self] receivedSize, totalSize in
            self?.progress(receivedSize: receivedSize, expectedSize: totalSize)
        } completion: { [weak self] result in
            self?.completion(result: result)
        }
    }
    
    override func didEndDisplay() {
        super.didEndDisplay()
        self.tiledImageView.clearImage()
        self.animatedImageView.image = nil
        self.tiledImageZoomingView.clearZooming(animate: false)
        self.animatedImageZoomingView.clearZooming(animate: false)
        self.imageProvider?.downloadCancel()
    }
}

// MARK: Helper
extension ImageResourceCollectionViewCell {
    
    // 图片加载进度闭包
    func progress(receivedSize: Int64, expectedSize: Int64) {
        guard let item = self.item else { return }
        self.delegate?.collectionViewCell(self, resourceLoadingStateDidChanged: .loading(receivedSize: receivedSize, expectedSize: expectedSize), idx: item.idx, accessoryView: self.accessoryView)
    }
    
    // 图片加载结果
    func completion(result: Result<UIImage, KingfisherError>) {
        guard let item = self.item else { return }
        self.display(image: result.image)
        if case .success = result {
            self.delegate?.collectionViewCell(self, resourceLoadingStateDidChanged: .default, idx: item.idx, accessoryView: self.accessoryView)
        }else{
            self.delegate?.collectionViewCell(self, resourceLoadingStateDidChanged: .loadingFaiure, idx: item.idx, accessoryView: self.accessoryView)
        }
    }
    
    // 更新显示
    func display(image: UIImage?) {
        guard let image = image else { return }
        self.isAnimatedResource = image.isAnimatedImage
        self.tiledImageZoomingView.isHidden = self.isAnimatedResource
        self.animatedImageZoomingView.isHidden = !self.isAnimatedResource
        if self.isAnimatedResource {
            self.animatedImageView.image = image
            self.animatedImageZoomingView.updateScrollViewConfiguration()
        }else{
            self.tiledImageView.display(imageProvider: self.imageProvider, image: image)
            self.tiledImageZoomingView.updateScrollViewConfiguration()
        }
    }
}
