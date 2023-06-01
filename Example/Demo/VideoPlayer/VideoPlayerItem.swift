//
//  VideoPlayerItem.swift
//  CZImagePreviewer
//
//  Created by siuzeontou on 24/5/2022.
//

import UIKit
import AVFoundation

class VideoPlayerItem: NSObject {
    
    private(set) lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        player.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        return player
    }()
    
    private(set) var playerLayer: AVPlayerLayer?
    
    private(set) var playItem: AVPlayerItem
    private var notificationTokens: [AnyObject] = []
    
    private(set) lazy var videoConsole: VideoConsole = {
        let res = VideoConsole.init(frame: .zero)
        res.playBtn.addTarget(self, action: #selector(self.playBtnOnClick(sender:)), for: .touchUpInside)
        return res
    }()
    
    private(set) var isPlaying: Bool = false {
        didSet {
            let btnTitle = self.isPlaying ? "PAUSE" : "PLAY"
            self.videoConsole.playBtn.setTitle(btnTitle, for: .normal)
        }
    }
    
    private(set) var videoURL: URL
    init?(videoURL: URL) {
        
        self.videoURL = videoURL
        self.playItem = AVPlayerItem.init(url: videoURL)
        super.init()
        
        self.player.replaceCurrentItem(with: self.playItem)
        self.playerLayer = AVPlayerLayer.init(player: self.player)
        self.videoConsole.totalTimeLabelText = self.playItem.asset.duration.timeStr
        
        self.player.addPeriodicTimeObserver(forInterval: CMTime.init(value: CMTimeValue.init(1), timescale: CMTimeScale.init(1)), queue: nil) { [weak self] time in
            self?.videoConsole.progressTimeLabelText = time.timeStr
            if let totalDuration = self?.playItem.asset.duration {
                let progress = (time.seconds / totalDuration.seconds).isNaN ? 0 : (time.seconds / totalDuration.seconds)
                self?.videoConsole.sliderProgress = progress
            }
        }
        
        let token = NotificationCenter.default.addObserver(forName: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.playItem, queue: nil) { [weak self] notification in
            self?.player.seek(to: CMTime(value: 0, timescale: 1))
        }
        self.notificationTokens.append(token)
        
        self.videoConsole.playerProgressControl.slider.progressChangedHandler = { [weak self] isManual, state, progress in
            if !isManual { return }
            guard let totalDuration = self?.playItem.asset.duration else { return }
            if state == .ended {
                let seekTo = Double(totalDuration.seconds) * progress
                self?.player.seek(to: CMTime.init(value: CMTimeValue(seekTo), timescale: 1))
            } else if state == .changed {
                let progressTime = CMTime.init(value: CMTimeValue.init(totalDuration.seconds * progress), timescale: CMTimeScale.init(1))
                self?.videoConsole.playerProgressControl.progressTimeLabel.text = progressTime.timeStr
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? AVPlayer !== self.player { return }
        if keyPath == "rate" {
            self.isPlaying = self.player.rate != 0
        }
        if keyPath == "status" {
            if self.player.status == .readyToPlay {
                self.videoConsole.asshole.stopAnimating()
            }
            if self.player.status == .failed {
                self.videoConsole.asshole.stopAnimating()
            }
        }
    }
    
    deinit {
        self.player.removeObserver(self, forKeyPath: "rate")
        self.player.removeObserver(self, forKeyPath: "status")
        self.notificationTokens.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }
    
    @objc func playBtnOnClick(sender: UIButton) {
        if self.isPlaying {
            self.player.pause()
        }else{
            self.player.play()
        }
    }
    
    public func stop() {
        self.player.pause()
        self.player.seek(to: CMTime.zero)
    }
}

extension CMTime {
    
    var seconds: Double { CMTimeGetSeconds(self).isNaN ? 0 : CMTimeGetSeconds(self) }
    
    var timeStr: String {
        let duration = self.seconds
        let date = Date.init(timeIntervalSince1970: duration)
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: Date.init(timeIntervalSince1970: 0), to: date)
        
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        let hourStr = String.init(format: "%02d", hour)
        let minuteStr = String.init(format: "%02d", minute)
        let secondStr = String.init(format: "%02d", second)
        return components.hour == 0 ? "\(minuteStr):\(secondStr)" : "\(hourStr):\(minuteStr):\(secondStr)"
    }
}
