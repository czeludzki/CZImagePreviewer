//
//  CZImageSourceProtocol.swift
//  CZImageSourceProtocol
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import Kingfisher
import CoreMedia

// 定义协议, 规定 CZImagePreviewerDataSource 数据源代理方法返回的泛型支持此协议
public protocol ResourceProtocol {
    /// 加载进度
    typealias LoadImageProgress = Kingfisher.DownloadProgressBlock
    /// 完成
    typealias LoadImageCompletion = (_ image: UIImage?, _ result: Result<RetrieveImageResult, KingfisherError>?) -> Void
    
    /// 加载图片的方法.
    /// 使用者只需遵循此协议, 在此方法参数两个闭包中提供内容, 即可作为数据源返回值
    func loadImage(progress: Kingfisher.DownloadProgressBlock?, completion: LoadImageCompletion?)
}

/// 使 结构体ImgSourceNamespaceWrapper 遵循 ResourceProtocol 协议, 以便 下面的 String, URL, UIImage 的实例可以通过 .szt 命名空间(属性) 调用 ResourceProtocol 协议的方法
extension ImgSourceNamespaceWrapper: ResourceProtocol {
    
    // 默认实现中不做操作
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        
        /// 不知道为什么在类型不明确的情况下(仅知道当前是 ResourceProtocols 类型, 不是 ImgSourceNamespaceWrapper<String> 类型), 不能直接调用 imageResource?.loadImage() 方法
        /// 直接调用的结果是, 总会走到这个默认实现,
        /// 而不是 extension ImgSourceNamespaceWrapper where WrappedValueType == String 指定 String 的实现
        /// 除非像下面做的, 对 ResourceProtocol 进行转型, 编译器才会调用到正确的函数, 也就是走 extension ImgSourceNamespaceWrapper where WrappedValueType == String 指定的实现
        
        if let res = self as? ImgSourceNamespaceWrapper<String> {
            res.loadImage(progress: progress, completion: completion)
            return
        }
        
        if let res = self as? ImgSourceNamespaceWrapper<URL> {
            res.loadImage(progress: progress, completion: completion)
            return
        }
        
        if let res = self as? ImgSourceNamespaceWrapper<UIImage> {
            res.loadImage(progress: progress, completion: completion)
            return
        }
        
        fatalError("错误的类型调用了 loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) 函数, 请检查")
    }
    
}

/*
 使 UIImage, String, URL 三种类型遵循 ImgSourceNamespaceWrappable 协议
 使它们都可以访问 .szt 结构体实例, 从而可以通过 .szt 访问 ImageResourceProtocol协议 的方法
*/

extension String: ImgSourceNamespaceWrappable {}
/// 约束结构体 ImgSourceNamespaceWrapper 的 泛型WrappedValueType 为 String, 指定当 泛型WrappedValueType 为 String 时调用的方法
extension ImgSourceNamespaceWrapper where WrappedValueType == String {
    
    public func toURL() -> URL? {
        return URL(string: self.wrappedValue)
    }
    
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        guard let url = self.toURL() else { return }
        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: progress, downloadTaskUpdated: nil) { result in
            completion?(result.image, result)
        }
    }
}

extension URL: ImgSourceNamespaceWrappable {}
extension ImgSourceNamespaceWrapper where WrappedValueType == URL {
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        KingfisherManager.shared.retrieveImage(with: self.wrappedValue, options: nil, progressBlock: progress, downloadTaskUpdated: nil) { result in
            completion?(result.image, result)
        }
    }
}

extension UIImage: ImgSourceNamespaceWrappable {}
extension ImgSourceNamespaceWrapper where WrappedValueType : UIImage {
    
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        let imgSize: Int = Int(self.wrappedValue.size.height * self.wrappedValue.size.width)
        if let progress = progress {
            progress(Int64(imgSize), Int64(imgSize))
        }
        if let completion = completion {
            completion(self.wrappedValue, nil)
        }
    }
    
}

extension CGSize: ImgSourceNamespaceWrappable {}
extension ImgSourceNamespaceWrapper where WrappedValueType == CGSize {
    /// 计算图片以 UIViewContentModeScaleAspectFit mode 显示在某个 size 上的实际大小
    func scaleAspectFiting(toSize: CGSize) -> CGSize {
        let originalSize = self.wrappedValue
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
