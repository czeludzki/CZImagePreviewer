//
//  TiledImageView.swift
//  CZImagePreviewer_Example
//
//  Created by siu on 2023/5/31.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class TiledLayer: CATiledLayer {
//    override class func fadeDuration() -> CFTimeInterval { 0.1 }
}

public class TiledImageView: UIView {
    
    public override class var layerClass: AnyClass { TiledLayer.self }

    private var imageSizeScale: CGSize = .zero
    public var image: UIImage? {
        didSet {
            self.caculateImageScale()
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
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.caculateImageScale()
    }
    
    func caculateImageScale() {
        guard let image = self.image else { return }
        self.imageSizeScale = .init(width: self.bounds.width / image.size.width, height: self.bounds.height / image.size.height)
    }
    
    public override func draw(_ rect: CGRect) {
        guard let img = self.image else { return }
        let _ = autoreleasepool {
            let scale = max(self.imageSizeScale.height, self.imageSizeScale.width)
            let tiledRect = CGRect.init(x: rect.origin.x / scale, y: rect.origin.y / scale, width: rect.width / scale, height: rect.height / scale)
            guard let cgImgRef = img.cgImage?.cropping(to: tiledRect) else { return }
            let tiledImage = UIImage.init(cgImage: cgImgRef)
            tiledImage.draw(in: rect)
        }
    }
    
}
