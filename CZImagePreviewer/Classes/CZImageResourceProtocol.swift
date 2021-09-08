//
//  CZImageSourceProtocol.swift
//  CZImageSourceProtocol
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import SDWebImage

/*
 除了 String, URL, UIImage 三种类型可作为数据源返回之外, 你也可以定义自己的数据源类型, 具体为下面两种做法
 1.直接将自定义的类型遵循 ImageResourceProtocol 协议
 struct Your_Resource: ImageResourceProtocol {
    // 在此实现 ImageResourceProtocol协议 所需的方法
 }
 
 2.通过命名空间 .szt 访问 ImageResourceProtocol 协议方法
 struct Your_Resource {}
 extension Your_Resource: ImgSourceNamespaceWrappable {}
 extension ImgSourceNamespaceWrapper where WrappedValueType == Your_Resource {
    // 在此实现 ImageResourceProtocol协议 所需的方法
    self.wrappedValue 就是 Your_Resource实例, 具体可参考下面 String, URL, UIImage 的做法
 }
 
 */

// 定义协议, 规定 CZImagePreviewerDataSource 数据源代理方法返回的泛型支持此协议
public protocol ImageResourceProtocol: ImgSourceNamespaceProtocol {
    
    /// 加载进度
    typealias LoadImageProgress = (Int, Int, URL?) -> ()
    /// 完成
    typealias LoadImageCompletion = (UIImage?, Data?, Error?, SDImageCacheType, Bool, URL?) -> ()
    
    /// 加载图片的方法.
    /// 使用者只需遵循此协议, 在此方法参数两个闭包中提供内容, 即可作为数据源返回值
    func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?)
}

/// 使 结构体ImgSourceNamespaceWrapper 遵循 ImageResourceProtocol 协议, 以便 下面的 String, URL, UIImage 的实例可以通过 .szt 命名空间(属性) 调用 ImageResourceProtocol 协议的方法
extension ImgSourceNamespaceWrapper: ImageResourceProtocol {
    // 默认实现中不做操作
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {}
}

/*
 使 UIImage, String, URL 三种类型遵循 ImgSourceNamespaceWrappable 协议
 使它们都可以访问 .szt 结构体实例, 从而可以通过 .szt 访问 ImageResourceProtocol协议 的方法
*/

extension String: ImgSourceNamespaceWrappable {}
/// 约束结构体 ImgSourceNamespaceWrapper 的 泛型WrappedValueType 为 String, 指定当 泛型WrappedValueType 为 String 时调用的方法
extension ImgSourceNamespaceWrapper where T == String {
    
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
extension ImgSourceNamespaceWrapper where WrappedValueType == UIImage {
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        let imgSize: Int = Int(self.wrappedValue.size.height * self.wrappedValue.size.width)
        if let progress = progress {
            progress(imgSize, imgSize, nil)
        }
        if let completion = completion {
            completion(self.wrappedValue, self.wrappedValue.sd_imageData(), nil, .none, true, nil)
        }
    }
}
