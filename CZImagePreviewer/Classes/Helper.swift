//
//  CZImagePreviewNamespace.swift
//  CZImagePreviewNamespace
//
//  Created by siuzeontou on 2021/9/8.
//

import Foundation
import Kingfisher

extension CGSize {
    /// 计算图片以 UIViewContentModeScaleAspectFit mode 显示在某个 size 上的实际大小
    func scaleAspectFiting(toSize: CGSize) -> CGSize {
        let originalSize = self
        let widthRaito = toSize.width / originalSize.width
        let heightRaito = toSize.height / originalSize.height
        let scale = min(widthRaito, heightRaito)
        let fitingWidth = scale * originalSize.width
        let fitingHeight = scale * originalSize.height
        return CGSize.init(width: fitingWidth, height: fitingHeight)
    }
}

public extension Result where Success == RetrieveImageResult, Failure == KingfisherError {
    var image: UIImage? {
        if case let .success(result) = self {
            return result.image
        }
        return nil
    }
}

public extension Result where Success == UIImage, Failure == KingfisherError {
    var image: UIImage? {
        if case let .success(result) = self {
            return result
        }
        return nil
    }
}

public extension UIImage {
    
    var isAnimatedImage: Bool {
        guard let imageFrameCount = self.kf.imageFrameCount else { return false }
        return imageFrameCount > 0
    }
    
    /// 是否将 图片当作 large image 来处理
    /// 判断标准是 图片面积 是否大于 屏幕面积 * 4
    var isLargeImage: Bool {
        self.size.width * self.size.height > UIScreen.main.bounds.width * UIScreen.main.bounds.height * 4
    }
    
}
