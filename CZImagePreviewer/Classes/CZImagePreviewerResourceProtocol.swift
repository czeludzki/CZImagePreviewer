//
//  CZImageSourceProtocol.swift
//  CZImageSourceProtocol
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import Kingfisher

// 定义协议, 任何模型只需遵循此协议, 在此方法参数两个闭包中提供内容, 即可作为数据源返回值
public protocol CZImagePreviewerResourceProtocol {
    /// 加载进度
    typealias LoadImageProgress = Kingfisher.DownloadProgressBlock
    /// 完成
    typealias LoadImageCompletion = (_ success: Bool, _ image: UIImage?) -> Void
    
    /// 加载图片的方法.
    /// 使用者只需遵循此协议, 在此方法参数两个闭包中提供内容, 即可作为数据源返回值
    func loadImage(progress: Kingfisher.DownloadProgressBlock?, completion: LoadImageCompletion?)
}

/// 使 结构体ImgSourceNamespaceWrapper 遵循 ResourceProtocol 协议, 以便 下面的 String, URL, UIImage 的实例可以通过 .szt 命名空间(属性) 调用 ResourceProtocol 协议的方法
extension NamespaceWrapper: CZImagePreviewerResourceProtocol {
    
    // 默认实现中不做操作
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        
        /// 不知道为什么在类型不明确的情况下(仅知道当前是 ResourceProtocols 类型, 不是 ImgSourceNamespaceWrapper<String> 类型), 不能直接调用 imageResource?.loadImage() 方法
        /// 直接调用的结果是, 总会走到这个默认实现,
        /// 而不是 extension ImgSourceNamespaceWrapper where WrappedValueType == String 指定 String 的实现
        /// 除非像下面做的, 对 ResourceProtocol 进行转型, 编译器才会调用到正确的函数, 也就是走 extension ImgSourceNamespaceWrapper where WrappedValueType == String 指定的实现
        
        if let res = self as? NamespaceWrapper<String> {
            res.loadImage(progress: progress, completion: completion)
            return
        }
        
        if let res = self as? NamespaceWrapper<URL> {
            res.loadImage(progress: progress, completion: completion)
            return
        }
        
        if let res = self as? NamespaceWrapper<UIImage> {
            res.loadImage(progress: progress, completion: completion)
            return
        }
        
        fatalError("错误的类型调用了 loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) 函数, 请检查")
    }
    
}
