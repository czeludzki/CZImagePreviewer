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
public protocol ImageProvider: ResourceProvider, Kingfisher.ImageDataProvider {
    func downloadCancel()
}

public extension CZImagePreviewer.ImageProvider {
    func downloadCancel() {}
    
    /// 对 Kingfisher retrieveImage 方法进行包装, 为 ImageProvider 提供一个 加载图片的方法
    /// 如果 ImageProvider 同时继承了 Kingfisher.Resource 协议, 优先以 Kingfisher.Resource 的类型加载图片, 否则才是 Kingfisher.ImageDataProvider
    func loadImage(options: Kingfisher.KingfisherOptionsInfo?, progress: Kingfisher.DownloadProgressBlock?, completion: ((Result<UIImage, Kingfisher.KingfisherError>) -> Void)?) {
        var source: Kingfisher.Source = .provider(self)
        // 如果 self 同时继承了 Kingfisher.Resource 协议(例如 String / URL), 优先选择该协议
        if let resource = self as? Kingfisher.Resource {
            source = resource.convertToSource()
        }
        let _ = KingfisherManager.shared.retrieveImage(with: source, options: options, progressBlock: progress, downloadTaskUpdated: nil, completionHandler: {
            if case let .failure(err) = $0 {
                completion?(.failure(err))
            }
            if case let .success(retrieveImageResult) = $0 {
                completion?(.success(retrieveImageResult.image))
            }
        })
    }
}

// MARK: VideoProvider
/// CZImagePreviewer 不关心视频是怎样播放的, 只要提供 playerLayer, 视频封面 等数据即可
public protocol VideoProvider: ResourceProvider, AnyObject {
    
    /// 播放视图
    var videoView: CZImagePreviewer.VideoView? { get }
    
    /// 播放动画时需要显示的图片
    var displayAnimationActor: ImageProvider? { get }
        
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
extension String: ImageProvider, Kingfisher.Resource {
    
    public func data(handler: @escaping (Result<Data, Error>) -> Void) {}
    
    private var urlValue: URL {
        guard let res = URL.init(string: self) else {
            fatalError("Can not create URL from string: \(self)")
        }
        return res
    }
    
    public var cacheKey: String {
        self.urlValue.cacheKey
    }
    
    public var downloadURL: URL { self.urlValue }
    
    public func downloadCancel() {
        KingfisherManager.shared.downloader.cancel(url: self.downloadURL)
    }
}

extension URL: ImageProvider {
    
    // 不实现, 通过 ImageProvider.loadImage 方法加载图片时, 是以 Kingfisher.Resource 的类型进行加载
    public func data(handler: @escaping (Result<Data, Error>) -> Void) {}
        
    public func downloadCancel() {
        KingfisherManager.shared.downloader.cancel(url: self)
    }
}

/// - 请避免直接使用 UIImage 直接作为 ImageProvider. 因为缓存策略不可靠 以及 gif播放不支持.
/// - 如需 gif 播放支持, 请使用 KingFisher 处理后的 UIImage 作为 ImageProvider (例如使用 KingfisherWrapper.animatedImage(data: , options: ) 方法). 否则无法进行播放
extension UIImage: ImageProvider {
    
    private static var imageProcessQueue = DispatchQueue(label: "com.github.czeludzki.CZImagePreviewer.ImageProcess.Queue", qos: .userInitiated)
        
    var isGif: Bool {
        (self.kf.imageFrameCount ?? 0) > 1
    }
    
    public func data(handler: @escaping (Result<Data, Error>) -> Void) {
        guard let _ = self.cgImage else {
            assertionFailure("[Kingfisher] Failed to create CG context for blurring image.")
            return
        }
        
        let format: Kingfisher.ImageFormat = self.isGif ? .GIF : .JPEG
        UIImage.imageProcessQueue.async {
            if let data = self.kf.data(format: format, compressionQuality: 1) {
                handler(.success(data))
            }else{
                handler(.failure(KingfisherError.imageSettingError(reason: .emptySource)))
            }
        }
    }

    /// - 以内存地址作为 cacheKey
    /// - 为 UIImage 提供 cacheKey 主要是为了应对大图显示的场景尽可能做的一些优化. 在展示大图时, 会先为该图片生成一张小尺寸的缩略图作为展示容器的底, 并且将该缩略图缓存起来. 然后再使用 CATiledLayer 展示原图.
    /// - 这种策略其实从使用体验和性能上都并不友好.
    /// - 例如 UIImage 会因为被销毁, 这使得 cacheKey 不可靠, 极有可能导致发生重复生成缩略图而浪费算力.
    /// - 所以, 如果需要显示大图, 请尽可能使用 String / URL 作为 ImageProvider 的方案, 或者自定义 ImageProvider模型 并 提供一个稳定的 cacheKey
    public var cacheKey: String { "\(Unmanaged.passUnretained(self).toOpaque())" }
    
}
