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

class ResourceItem {
    var imagePath: String
    var videoURL: URL? {
        didSet {
            guard let videoURL = videoURL else { return }
            self.videoItem = VideoPlayerItem.init(videoURL: videoURL)
        }
    }
    var videoItem: VideoPlayerItem?
    
    var resType: String {
        return self.videoURL == nil ? "Image" : "Video"
    }
    
    init(imgPath: String) {
        self.imagePath = imgPath
    }
    
}


extension ExampleViewController {
    static var imagePaths: [String] = {
        var res = [
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
        res += res
        res += res
        return res
    }()
    
    static var videoURLs: [URL] = {
        var ret: [URL] = []
        for n in 1...3 {
            let url = Bundle.main.url(forResource: String(n), withExtension: "mp4")!
            ret.append(url)
        }
        return ret
    }()
    
}
