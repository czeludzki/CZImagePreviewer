//
//  ImageProvider.swift
//  ImageProvider
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import Kingfisher

public protocol ResourceProvider {}

// MARK: ImageProvider
// 任何模型只需遵循此协议, 在此方法参数两个闭包中提供内容, 即可作为数据源返回值
public protocol ImageProvider: ResourceProvider {
    /// 加载进度
    typealias LoadImageProgress = Kingfisher.DownloadProgressBlock
    /// 完成
    typealias LoadImageCompletion = (Swift.Result<UIImage, KingfisherError>) -> Void
    
    /// 加载图片的方法.
    /// 使用者只需遵循此协议, 在此方法参数两个闭包中提供内容, 即可作为数据源返回值
    func loadImage(options: KingfisherOptionsInfo?, progress: Kingfisher.DownloadProgressBlock?, completion: LoadImageCompletion?)
    
    func cancel()
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
 使 UIImage, String, URL 三种类型默认遵循 ImageProvider 协议
*/
extension String: ImageProvider {
    
    public func loadImage(options: KingfisherOptionsInfo?, progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        guard let url = URL(string: self) else { return }
        KingfisherManager.shared.retrieveImage(with: url, options: options, progressBlock: progress) {
            if case let .success(res) = $0 {
                completion?(.success(res.image))
            }
            if case let .failure(err) = $0 {
                completion?(.failure(err))
            }
        }
    }
    
    public func cancel() {
        guard let url = URL(string: self) else { return }
        KingfisherManager.shared.downloader.cancel(url: url)
    }
}

extension URL: ImageProvider {
    
    public func loadImage(options: KingfisherOptionsInfo?, progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        KingfisherManager.shared.retrieveImage(with: self, options: options, progressBlock: progress) {
            if case let .success(res) = $0 {
                completion?(.success(res.image))
            }
            if case let .failure(err) = $0 {
                completion?(.failure(err))
            }
        }
    }
    
    public func cancel() {
        KingfisherManager.shared.downloader.cancel(url: self)
    }
}

extension UIImage: ImageProvider {
    
    public func loadImage(options: KingfisherOptionsInfo?, progress: LoadImageProgress?, completion: LoadImageCompletion?) {
        let imgSize: Int = Int(self.size.height * self.size.width)
        if let progress = progress {
            progress(Int64(imgSize), Int64(imgSize))
        }
        completion?(.success(self))
    }
    
    public func cancel() {}
    
}
