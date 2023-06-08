//
//  TiledImageViewWrapper.swift
//  CZImagePreviewer
//
//  Created by siu on 2023/6/4.
//

import Foundation
import Kingfisher

/// 此视图封装了 UIImageView + TiledImageView.
/// 为了避免 TiledImageView 在初始化时出现空白方格的尴尬, UIImageView 加载一个低质量的视图覆盖在 TiledImageView 下方
public class TiledImageViewWrapper: UIView {
    
    private(set) var image: UIImage?
    
    private(set) var imageProvider: ImageProvider?
        
    // 此 View 在 tiledImageView 之下,渲染 tiledImageView 前, 会先对 self.image 进行 resize 操作, 缩小视图, 然后显示在此 View 上, 再对 tiledImageView.image 进行赋值
    lazy var backImageView: UIImageView = .init()
    
    var tiledImageView: TiledImageView?
    
    public init() {
        super.init(frame: .zero)
        self.initSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initSetup()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.backImageView.frame = .init(origin: .zero, size: self.bounds.size)
        self.tiledImageView?.frame = .init(origin: .zero, size: self.bounds.size)
    }
    
    func display(imageProvider: ImageProvider?, image: UIImage) {
        
        self.clearImage()
        
        self.image = image
        self.imageProvider = imageProvider
        
        /// 判断是否是大图, 是就需要用到 tiledImage 来显示图片
        if !image.isLargeImage {
            self.backImageView.image = image
            return
        }
        
        // IS LARGE IMAGE
        self.createNewTiledImageView()
        
        // 尝试从 provider 中取缩略图
        imageProvider?.loadImage(options: [.processor(ResizingImageProcessor(referenceSize: UIScreen.main.bounds.size, mode: .aspectFit))], progress: nil, completion: { [weak self] result in
            if imageProvider?.cacheKey == self?.imageProvider?.cacheKey {
                self?.backImageView.image = result.image
            }
        })
        self.tiledImageView?.image = self.image
    }
    
    func clearImage() {
        self.image = nil
        self.backImageView.image = nil
        // 因为 tiledLayer 不能手动停止渲染, 所以每次设置新的 image, 都将 tiledImageView 移除
        self.tiledImageView?.removeFromSuperview()
        self.tiledImageView = nil
    }
    
    func initSetup() {
        self.addSubview(self.backImageView)
        self.backImageView.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin, .flexibleHeight, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth]
    }
    
    func createNewTiledImageView() {
        let tiledImageView: TiledImageView = .init()
        self.addSubview(tiledImageView)
        tiledImageView.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin, .flexibleHeight, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth]
        self.tiledImageView = tiledImageView
    }
    
    // MARK: ImageZoomingViewTarget
    public func imageZoomingViewDidZoom(_ view: ImageZoomingView) {
        self.tiledImageView?.imageZoomingViewDidZoom(view)
    }
    
}
