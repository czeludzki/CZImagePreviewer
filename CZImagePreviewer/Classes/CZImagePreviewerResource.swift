//
//  CZImageSourceProtocol.swift
//  CZImageSourceProtocol
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import Kingfisher

// 定义协议, 任何模型只需遵循此协议, 在此方法参数两个闭包中提供内容, 即可作为数据源返回值
public protocol CZImagePreviewerResource {
    /// 加载进度
    typealias LoadImageProgress = Kingfisher.DownloadProgressBlock
    /// 完成
    typealias LoadImageCompletion = (_ success: Bool, _ image: UIImage?) -> Void
    
    /// 加载图片的方法.
    /// 使用者只需遵循此协议, 在此方法参数两个闭包中提供内容, 即可作为数据源返回值
    func loadImage(progress: Kingfisher.DownloadProgressBlock?, completion: LoadImageCompletion?)
}

/*
 使 UIImage, String, URL 三种类型默认遵循 ImgSourceNamespaceWrappable 协议
*/

extension String: CZImagePreviewerResource {
    
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        guard let url = URL(string: self) else { return }
        KingfisherManager.shared.retrieveImage(with: url, options: [.preloadAllAnimationData], progressBlock: progress, downloadTaskUpdated: nil) {
            if case .success(_) = $0 {
                completion?(true, $0.image)
            }else{
                completion?(false, nil)
            }
        }
    }
    
}

extension URL: CZImagePreviewerResource {
    
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        KingfisherManager.shared.retrieveImage(with: self, options: [.preloadAllAnimationData], progressBlock: progress, downloadTaskUpdated: nil) {
            if case .success(_) = $0 {
                completion?(true, $0.image)
            }else{
                completion?(false, nil)
            }
        }
    }
    
}

extension UIImage: CZImagePreviewerResource {
    
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        let imgSize: Int = Int(self.size.height * self.size.width)
        if let progress = progress {
            progress(Int64(imgSize), Int64(imgSize))
        }
        if let completion = completion {
            completion(true, self)
        }
    }
    
}
