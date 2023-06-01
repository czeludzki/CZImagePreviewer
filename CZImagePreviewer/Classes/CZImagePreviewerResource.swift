//
//  CZImageSourceProtocol.swift
//  CZImageSourceProtocol
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import Kingfisher

// 任何模型只需遵循此协议, 在此方法参数两个闭包中提供内容, 即可作为数据源返回值
public protocol Resource {
    /// 加载进度
    typealias LoadImageProgress = Kingfisher.DownloadProgressBlock
    /// 完成
    typealias LoadImageCompletion = (Swift.Result<UIImage, KingfisherError>) -> Void
    
    /// 加载图片的方法.
    /// 使用者只需遵循此协议, 在此方法参数两个闭包中提供内容, 即可作为数据源返回值
    func loadImage(progress: Kingfisher.DownloadProgressBlock?, completion: LoadImageCompletion?)
}

/*
 使 UIImage, String, URL 三种类型默认遵循 ImgSourceNamespaceWrappable 协议
*/
extension String: Resource {
    
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        guard let url = URL(string: self) else { return }
        KingfisherManager.shared.retrieveImage(with: url, options: [], progressBlock: progress, downloadTaskUpdated: nil) {
            if case let .success(res) = $0 {
                completion?(.success(res.image))
            }
            if case let .failure(err) = $0 {
                completion?(.failure(err))
            }
        }
    }
    
}

extension URL: Resource {
    
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        KingfisherManager.shared.retrieveImage(with: self, options: [], progressBlock: progress, downloadTaskUpdated: nil) {
            if case let .success(res) = $0 {
                completion?(.success(res.image))
            }
            if case let .failure(err) = $0 {
                completion?(.failure(err))
            }
        }
    }
    
}

extension UIImage: Resource {
    
    public func loadImage(progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        let imgSize: Int = Int(self.size.height * self.size.width)
        if let progress = progress {
            progress(Int64(imgSize), Int64(imgSize))
        }
        completion?(.success(self))
    }
    
}
