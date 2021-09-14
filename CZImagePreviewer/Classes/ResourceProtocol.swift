//
//  CZImageSourceProtocol.swift
//  CZImageSourceProtocol
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import SDWebImage

// 定义协议, 规定 CZImagePreviewerDataSource 数据源代理方法返回的泛型支持此协议
public protocol ResourceProtocol {
    /// 加载进度
    typealias LoadImageProgress = (Int, Int, URL?) -> ()
    /// 完成
    typealias LoadImageCompletion = (UIImage?, Data?, Error?, SDImageCacheType, Bool, URL?) -> ()
    
    /// 加载图片的方法.
    /// 使用者只需遵循此协议, 在此方法参数两个闭包中提供内容, 即可作为数据源返回值
    func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?)
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
        let completion = completion ?? {(_: UIImage?, _: Data?, _: Error?, SDImageCacheType, Bool, _: URL?) -> () in }
        SDWebImageManager.shared.loadImage(with: self.toURL(), options: .retryFailed, progress: progress, completed: completion)
    }
}

extension URL: ImgSourceNamespaceWrappable {}
extension ImgSourceNamespaceWrapper where WrappedValueType == URL {
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        let completion = completion ?? {(_: UIImage?, _: Data?, _: Error?, SDImageCacheType, Bool, _: URL?) -> () in }
        SDWebImageManager.shared.loadImage(with: self.wrappedValue, options: .retryFailed, progress: progress, completed: completion)
    }
}

extension UIImage: ImgSourceNamespaceWrappable {}
extension ImgSourceNamespaceWrapper where WrappedValueType : UIImage {
    
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        let imgSize: Int = Int(self.wrappedValue.size.height * self.wrappedValue.size.width)
        if let progress = progress {
            progress(imgSize, imgSize, nil)
        }
        if let completion = completion {
            completion(self.wrappedValue, self.wrappedValue.sd_imageData(), nil, .none, true, nil)
        }
    }
    
    /// 计算图片以 UIViewContentModeScaleAspectFit mode 显示在某个 size 上的实际大小
    func scaleAspectFiting(toSize: CGSize) -> CGSize {
        let imgSize = self.wrappedValue.size
        let widthRaito = toSize.width / imgSize.width
        let heightRaito = toSize.height / imgSize.height
        let scale = min(widthRaito, heightRaito)
        let fitingWidth = scale * imgSize.width
        let fitingHeight = scale * imgSize.height
        return CGSize.init(width: fitingWidth, height: fitingHeight)
    }
}

/*
 除了 String, URL, UIImage 三种类型可作为数据源返回之外, 你也可以定义自己的数据源类型:
 
 // 直接将自定义的类型遵循 ImageResourceProtocol 协议
 struct Your_Resource: ImageResourceProtocol {
    // 在此实现 ImageResourceProtocol协议 所需的方法
 }
 
 */
