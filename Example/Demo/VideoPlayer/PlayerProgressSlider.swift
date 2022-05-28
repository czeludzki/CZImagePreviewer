//
//  PlayerProgressSlider.swift
//  CZImagePreviewer
//
//  Created by siuzeontou on 24/5/2022.
//

import UIKit

class PlayerProgressSlider: UIView {

    private(set) var progress: Double = 0
    
    lazy var totalProgressLine: UIView = {
        let res = UIView.init(frame: .zero)
        res.backgroundColor = .darkGray
        res.setContentHuggingPriority(UILayoutPriority.init(rawValue: 249), for: NSLayoutConstraint.Axis.horizontal)
        res.setContentCompressionResistancePriority(UILayoutPriority.init(rawValue: 249), for: NSLayoutConstraint.Axis.horizontal)
        return res
    }()
    
    lazy var playingProgressLine: UIView = {
        let res = UIView.init(frame: .zero)
        res.backgroundColor = .white
        return res
    }()
    
    lazy var niple: UIView = {
        let res = UIView.init(frame: .zero)
        res.backgroundColor = .white
        res.layer.cornerRadius = 6
        res.layer.masksToBounds = true
        return res
    }()
    
    var progressChangedHandler: ((_ isManual: Bool, _ gestureState: UIGestureRecognizer.State?, _ progress: Double) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.totalProgressLine)
        self.totalProgressLine.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.addSubview(self.playingProgressLine)
        self.playingProgressLine.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(self.totalProgressLine).multipliedBy(0)
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.addSubview(self.niple)
        self.niple.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(self.playingProgressLine.snp.right)
            make.width.height.equalTo(12)
        }
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.pan(sender:)))
        self.addGestureRecognizer(pan)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateSliderUI(progress: self.progress)
    }
    
    private var beganLeft: Double = 0
    public private(set) var isPaning = false
    @objc func pan(sender: UIPanGestureRecognizer) {
        var movePercentage: Double = 0
        
        if sender.state == .began {
            self.isPaning = true
            self.beganLeft = self.niple.frame.minX
            self.niple.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.progressChangedHandler?(true, sender.state, self.progress)
        } else if sender.state == .changed {
            var newLeft = self.beganLeft + sender.translation(in: self).x
            if newLeft < 0 { newLeft = 0 }
            if newLeft > self.bounds.width - self.niple.bounds.width * 0.5 {
                newLeft = self.bounds.width - self.niple.bounds.width * 0.5
            }
            movePercentage = newLeft / (self.bounds.width - self.niple.bounds.width * 0.5)
            self.progress = movePercentage
            self.updateSliderUI(progress: movePercentage)
            self.progressChangedHandler?(true, sender.state, self.progress)
        } else if sender.state == .failed || sender.state == .ended || sender.state == .cancelled {
            self.progressChangedHandler?(true, sender.state, self.progress)
            self.niple.transform = .identity
            // 延迟设置 isPaning 状态, 避免 seek 的时候, 松手, 出现进度条闪一下的情况(因为视频依然在播放, 进度监听导致了进度条回跳)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isPaning = false
            }
        }
    }
    
    private func updateSliderUI(progress: Double) {
        self.playingProgressLine.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalTo(self.totalProgressLine).multipliedBy(progress)
        }
        self.layoutIfNeeded()
    }
    
    // 当外部改变播放进度时调用
    public func updateProgress(progress: Double) {
        if self.isPaning { return }
        self.progress = progress
        self.updateSliderUI(progress: progress)
        self.progressChangedHandler?(false, nil, self.progress)
    }
}
