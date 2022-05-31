//
//  CZImagePreviewNamespace.swift
//  CZImagePreviewNamespace
//
//  Created by siuzeontou on 2021/9/8.
//

/*
 为了使 String, URL, UIImage 可以快速访问到 数据源协议ImageResourceProtocol 的方法, 但又不想直接通过 extension String: ImageResourceProtocol 实现, 避免污染到命名空间, 影响开发中方法命名冲突
 所以设计以下 ImgSourceNamespaceWrapper 结构体, ImgSourceNamespaceWrappable 协议, 让 String, URL, UIImage 遵循 ImgSourceNamespaceWrappable 协议, 通过 String, URL, UIImage 的实例的 .szt 属性 直接访问到 ImageResourceProtocol协议的方法
 */

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
