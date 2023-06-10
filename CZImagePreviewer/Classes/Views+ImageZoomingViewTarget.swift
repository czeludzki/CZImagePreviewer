//
//  View+ImageZoomingViewTarget.swift
//  CZImagePreviewer
//
//  Created by siu on 2023/6/1.
//

import Foundation
import Kingfisher

extension Kingfisher.AnimatedImageView: ImageZoomingViewTarget {
    public var contentSize: CGSize? {
        guard let imgSize = self.image?.size, let imgScale = self.image?.scale else { return nil }
        return .init(width: imgSize.width * imgScale, height: imgSize.height * imgScale)
    }
}

extension TiledImageView: ImageZoomingViewTarget {
    
    public var contentSize: CGSize? {
        guard let imgSize = self.image?.size, let imgScale = self.image?.scale else { return nil }
        return .init(width: imgSize.width * imgScale, height: imgSize.height * imgScale)
    }
    
    public func imageZoomingView(_ view: ImageZoomingView, maximumZoomScaleDidUpdate scale: CGFloat) {
        let screenScale = UIScreen.main.scale
        // 设置 tiledLayer 的 levelsOfDetailBias.
        // 在 scrollView 缩放过程中, tiledLayer 会执行多次重绘. 该值决定scrollView在缩放过程中, tiledLayer 可执行多少层的重绘操作, 层数越高, 大图可显示的内容越细致
        self.levelsOfDetailBias = Int(floor(log2(scale / (screenScale * screenScale))))
    }
}

extension TiledImageViewWrapper: ImageZoomingViewTarget {
    public var contentSize: CGSize? {
        guard let imgSize = self.image?.size, let imgScale = self.image?.scale else { return nil }
        return .init(width: imgSize.width * imgScale, height: imgSize.height * imgScale)
    }
    
    public func imageZoomingView(_ view: ImageZoomingView, maximumZoomScaleDidUpdate scale: CGFloat) {
        let screenScale = UIScreen.main.scale
        // 设置 tiledLayer 的 levelsOfDetailBias.
        // 在 scrollView 缩放过程中, tiledLayer 会执行多次重绘. levelsOfDetailBias 决定scrollView在缩放过程中, tiledLayer 可执行多少层的重绘操作, 层数越高, 大图可显示的内容越细致
        self.tiledImageView?.levelsOfDetailBias = Int(floor(log2(scale / (screenScale * screenScale))))
        self.tiledImageView?.levelsOfDetail = 1
    }

}
