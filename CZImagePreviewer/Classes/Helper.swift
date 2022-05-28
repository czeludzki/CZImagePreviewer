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

/// 定义一个命名空间结构体, 该结构体有名为 wrappedValue 的属性, 该属性指向被包装对象
public struct NamespaceWrapper<WrappedValueType> {
    public let wrappedValue: WrappedValueType
    public init(wrappedValue: WrappedValueType) {
        self.wrappedValue = wrappedValue
    }
}

public protocol NamespaceWrappable {
    associatedtype WrappedValueType
    var czi: NamespaceWrapper<WrappedValueType> { get }
}

extension NamespaceWrappable {
    public var czi: NamespaceWrapper<Self> {
        return NamespaceWrapper<Self>.init(wrappedValue: self)
    }
}



/*
 使 UIImage, String, URL 三种类型遵循 ImgSourceNamespaceWrappable 协议
 使它们都可以访问 .czi 结构体实例, 从而可以通过 .czi 访问 ImageResourceProtocol协议 的方法
*/

extension String: NamespaceWrappable {}
/// 约束结构体 ImgSourceNamespaceWrapper 的 泛型WrappedValueType 为 String, 指定当 泛型WrappedValueType 为 String 时调用的方法
extension NamespaceWrapper where WrappedValueType == String {
    
    public func toURL() -> URL? {
        return URL(string: self.wrappedValue)
    }
    
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        guard let url = self.toURL() else { return }
        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: progress, downloadTaskUpdated: nil) {
            if case .success(_) = $0 {
                completion?(true, $0.image)
            }else{
                completion?(false, nil)
            }
        }
    }
}

extension URL: NamespaceWrappable {}
extension NamespaceWrapper where WrappedValueType == URL {
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        KingfisherManager.shared.retrieveImage(with: self.wrappedValue, options: nil, progressBlock: progress, downloadTaskUpdated: nil) {
            if case .success(_) = $0 {
                completion?(true, $0.image)
            }else{
                completion?(false, nil)
            }
        }
    }
}

extension UIImage: NamespaceWrappable {}
extension NamespaceWrapper where WrappedValueType : UIImage {
    
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        let imgSize: Int = Int(self.wrappedValue.size.height * self.wrappedValue.size.width)
        if let progress = progress {
            progress(Int64(imgSize), Int64(imgSize))
        }
        if let completion = completion {
            completion(true, self.wrappedValue)
        }
    }
    
}

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

extension Result where Success == RetrieveImageResult, Failure == KingfisherError {
    var image: UIImage? {
        if case let .success(result) = self {
            return result.image
        }
        return nil
    }
}

/*
 除了 String, URL, UIImage 三种类型可作为数据源返回之外, 你也可以定义自己的数据源类型:
 
 // 直接将自定义的类型遵循 ImageResourceProtocol 协议
 struct Your_Resource: ImageResourceProtocol {
    // 在此实现 ImageResourceProtocol协议 所需的方法
 }
 
 */
