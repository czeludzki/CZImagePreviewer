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
        var arr = [
            "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fdesk.fd.zol-img.com.cn%2Fg5%2FM00%2F03%2F00%2FChMkJ1bK-nSIS40cAAEuXdS6ma4AALLAAM-v7QAAS51610.jpg&refer=http%3A%2F%2Fdesk.fd.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=f8163c3b266a263733642ca2bc73fdb0",
    "https://img1.baidu.com/it/u=194556351,9437364&fm=26&fmt=auto",
    "https://img2.baidu.com/it/u=223817057,1847785609&fm=26&fmt=auto",
    "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fbbsfiles.vivo.com.cn%2Fvivobbs%2Fattachment%2Fforum%2F201804%2F01%2F185440g88mz4em7i47yzuj.jpg&refer=http%3A%2F%2Fbbsfiles.vivo.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=bf33f51101179b09a10c104a9132c80b",
                       "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201501%2F22%2F171814y11r8r254hw77148.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=72ce6e5aa851536e25281dae205e63ec",
                       "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F110202%2F292-11020203332568.jpg&refer=http%3A%2F%2Fimg.taopic.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=0929baf0277cbd650a1fb4a819e601d8"
        ]
        arr += arr
        arr += arr
        arr += arr
        return arr
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
