//
//  ImageProvider.swift
//  ImageProvider
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import Kingfisher
import UniformTypeIdentifiers

public protocol ResourceProvider {}

// MARK: ImageProvider
/// 任何模型只需继承此协议, 即可作为 Previewer 的数据源
/// URL 及 String 默认实现
public protocol ImageProvider: ResourceProvider {
    var cacheKey: String { get }
    func loadImage(options: Kingfisher.KingfisherOptionsInfo?, progress: Kingfisher.DownloadProgressBlock?, completion: ((Result<UIImage, Kingfisher.KingfisherError>) -> Void)?)
    func downloadCancel()
}

public extension CZImagePreviewer.ImageProvider {
    func downloadCancel() {}
}

// MARK: VideoProvider
/// CZImagePreviewer 不关心视频是怎样播放的, 只要提供 playerLayer, 视频封面 等数据即可
public protocol VideoProvider: ResourceProvider, AnyObject {
    
    /// 播放视图
    var videoView: CZImagePreviewer.VideoView? { get }
        
    // CZImagePreviewer 需要监听 video size 的改变, 以便提供更好的 dismiss 动画效果
    typealias VideoSizeProvider = (_ videoSize: CGSize) -> Void
    // VideoProvider 应该在视频尺寸发生变化时调用此闭包告知 CZImagePreviewer
    var videoSizeProvider: VideoSizeProvider? { get set }
    
    // CZImgePreviewer 需要在 cell 离开屏幕时控制其播放状态
    func play()
    func pause()
    
    /// cell 即将要离开画面了
    func cellDidEndDisplay()
    
    /// 在这个方法里告诉 VideoProvider 实例, 可以对视频数据进行预加载了
    func perload()
}

public extension CZImagePreviewer.VideoProvider {
    func cellDidEndDisplay() {}
    /// 在这个方法里告诉 VideoProvider 实例, 可以对视频数据进行预加载了
    func perload() {}
}

/*
 使 String, URL 两种类型默认遵循 ImageProvider 协议
*/
extension String: ImageProvider {
    
    private var urlValue: URL {
        guard let res = URL.init(string: self) else {
            fatalError("Can not create URL from string: \(self)")
        }
        return res
    }
    
    public var cacheKey: String { self.urlValue.cacheKey }
    
    public func loadImage(options: KingfisherOptionsInfo?, progress: DownloadProgressBlock?, completion: ((Result<UIImage, KingfisherError>) -> Void)?) {
        self.urlValue.loadImage(options: options, progress: progress, completion: completion)
    }
    
    public func downloadCancel() {
        KingfisherManager.shared.downloader.cancel(url: self.urlValue)
    }
}

extension URL: ImageProvider {
    
    public func loadImage(options: KingfisherOptionsInfo?, progress: DownloadProgressBlock?, completion: ((Result<UIImage, KingfisherError>) -> Void)?) {
        KingfisherManager.shared.retrieveImage(with: self, options: options, progressBlock: progress, downloadTaskUpdated: nil) {
            if case let .failure(err) = $0 {
                completion?(.failure(err))
            }
            if case let .success(retrieveImageResult) = $0 {
                completion?(.success(retrieveImageResult.image))
            }
        }
    }
        
    public func downloadCancel() {
        KingfisherManager.shared.downloader.cancel(url: self)
    }
}

/// - 请避免直接使用 UIImage 直接作为 ImageProvider. 超大图加载无法用到 CATiledLayer 以降低内存使用峰值
/// - 因为缓存策略不可靠 以及 gif播放不支持.
/// - 如需 gif 播放支持, 请使用 KingFisher 处理后的 UIImage 作为 ImageProvider (例如使用 KingfisherWrapper.animatedImage(data: , options: ) 方法). 否则无法进行播放
extension UIImage: ImageProvider {
    
    public var contentURL: URL? { nil }
    
    public func loadImage(options: KingfisherOptionsInfo?, progress: DownloadProgressBlock?, completion: ((Result<UIImage, KingfisherError>) -> Void)?) {
        let pixel = self.size.width * self.size.height
        progress?(Int64(pixel), Int64(pixel))
        completion?(.success(self))
    }
    
    /// - 以内存地址作为 cacheKey
    /// - 为 UIImage 提供 cacheKey 主要是为了应对大图显示的场景尽可能做的一些优化. 在展示大图时, 会先为该图片生成一张小尺寸的缩略图作为展示容器的底, 并且将该缩略图缓存起来. 然后再使用 CATiledLayer 展示原图.
    /// - 这种策略其实从使用体验和性能上都并不友好.
    /// - 例如 UIImage 会因为被销毁而使得 cacheKey 不可靠, 极有可能导致发生重复生成缩略图而浪费算力.
    /// - 所以, 如果需要显示大图, 请尽可能使用 String / URL 作为 ImageProvider 的方案, 或者自定义 ImageProvider模型 并 提供一个稳定的 cacheKey
    public var cacheKey: String { "\(Unmanaged.passUnretained(self).toOpaque())" }
    
}
