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
