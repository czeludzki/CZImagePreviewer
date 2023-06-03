//
//  Example_Resource.swift
//  CZImagePreviewer_Example
//
//  Created by siu on 2021/9/14.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CZImagePreviewer
import Combine

class VideoResource: CZImagePreviewer.VideoProvider {
    
    // MARK: VideoProvider
    var videoView: VideoView?
    
    var displayAnimationActor: ImageProvider?
    
    func play() {
        self.videoItem.player.play()
    }
    
    func pause() {
        self.videoItem.player.pause()
    }
    
    let videoItem: VideoPlayerItem
    
    var videoSize: CGSize {
        return self.videoItem.playItem.presentationSize
    }
    
    var videoSizeProvider: VideoSizeProvider? {
        didSet {
            self.videoSizeProvider?(self.videoItem.playItem.presentationSize)
        }
    }
    
    private var anyCancellable: Set<AnyCancellable> = []
    
    init(videoPath: String, cover: ImageProvider? = nil) {
        self.videoItem = VideoPlayerItem.init(videoURL: URL.init(string: videoPath)!)!
        self.displayAnimationActor = cover
        
        if let playerLayer = self.videoItem.playerLayer {
            self.videoView = CZImagePreviewer.VideoView.init(playerLayer: playerLayer)
        }
        
        // 监听 videoItem.playerItem.presentationSize 的变化
        self.videoItem.playItem.publisher(for: \.presentationSize).sink { [weak self] size in
            self?.videoSizeProvider?(size)
        }.store(in: &self.anyCancellable)
    }
    
}

extension ExampleViewController {
    
    static var imagePaths: [String] = [
        "file://" + Bundle.main.path(forResource: "largeImg0", ofType: "jpg")!,
        "file://" + Bundle.main.path(forResource: "largeImg1", ofType: "jpg")!,
        "file://" + Bundle.main.path(forResource: "largeImg2", ofType: "jpg")!,
        "file://" + Bundle.main.path(forResource: "gif0", ofType: "gif")!,
        "file://" + Bundle.main.path(forResource: "gif1", ofType: "gif")!,
        "file://" + Bundle.main.path(forResource: "gif2", ofType: "gif")!,
        "file://" + Bundle.main.path(forResource: "gif3", ofType: "gif")!,
        "file://" + Bundle.main.path(forResource: "gif4", ofType: "gif")!,
        "file://" + Bundle.main.path(forResource: "gif5", ofType: "gif")!
    ]
    
    static var videoPaths: [String] = [
        "file://" + Bundle.main.path(forResource: "1", ofType: "mp4")!,
        "file://" + Bundle.main.path(forResource: "2", ofType: "mp4")!,
        "file://" + Bundle.main.path(forResource: "3", ofType: "mp4")!
    ]
    
    static func resourcePaths() -> [String] {
        var res = Self.imagePaths + Self.videoPaths
        res += res
        res += res
        return res
    }
    
}
