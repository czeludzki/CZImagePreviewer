//
//  TiledImageView.swift
//  CZImagePreviewer_Example
//
//  Created by siu on 2023/5/31.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Kingfisher

// https://www.jianshu.com/p/2d9e58d67d87
class TiledLayer: CATiledLayer {
    override class func fadeDuration() -> CFTimeInterval { 0.2 }
}

public class TiledImageView: UIView {
    
    public override class var layerClass: AnyClass { TiledLayer.self }
    
    private var imageSizeScale: CGSize = .zero
    public var image: UIImage? {
        didSet {
            if image == nil {
                self.layer.contents = nil
                return
            }
            self.caculateImageScale()
            self.setNeedsDisplay()
        }
    }
    
    var tiledLayer: TiledLayer {
        return self.layer as! TiledLayer
    }
    
    public var levelsOfDetail: Int = 1 {
        didSet {
            self.tiledLayer.levelsOfDetail = levelsOfDetail
        }
    }
    
    public var levelsOfDetailBias: Int = 0 {
        didSet {
            self.tiledLayer.levelsOfDetailBias = levelsOfDetailBias
        }
    }

    public init(_ image: UIImage? = nil) {
        super.init(frame: .zero)
        self.initSetup()
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initSetup()
    }
        
    func initSetup() {
        self.backgroundColor = .clear
        self.tiledLayer.contentsScale = 1.0
        self.tiledLayer.tileSize = .init(width: 512, height: 512)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.caculateImageScale()
    }
    
    public override var isHidden: Bool {
        didSet {
            if self.isHidden { return }
            self.setNeedsDisplay()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        guard let img = self.image, let cgImage = img.cgImage else { return }
        let _ = autoreleasepool {
            let scale = max(self.imageSizeScale.height, self.imageSizeScale.width)
            let tiledRect = CGRect.init(x: rect.origin.x / scale, y: rect.origin.y / scale, width: rect.width / scale, height: rect.height / scale)
            guard let cgImgTiled = cgImage.cropping(to: tiledRect) else { return }
            let tiledImage = UIImage.init(cgImage: cgImgTiled)
            tiledImage.draw(in: rect)
        }
    }
    
    // MARK: Helper
    func caculateImageScale() {
        guard let image = self.image else { return }
        self.imageSizeScale = .init(width: self.bounds.width / image.size.width, height: self.bounds.height / image.size.height)
    }
    
    // MARK: CALayerDelegate
    public override func draw(_ layer: CALayer, in ctx: CGContext) {
        // super == nil || contentSize == nil || self.isHidden 就不需要浪费算力去渲染了
        if self.superview == nil { return }
        if self.contentSize == .zero { return }
        if self.isHidden { return }
//        if self.zoomScale < 1 { return }
        super.draw(layer, in: ctx)
    }
        
    var zoomScale: CGFloat = 1
    // MARK: ImageZoomingViewTarget
    public func imageZoomingViewDidZoom(_ view: ImageZoomingView) {
        self.zoomScale = view.scrollView.zoomScale
    }
    
}
