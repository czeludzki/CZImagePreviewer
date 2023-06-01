//
//  VideoView.swift
//  CZImagePreviewer
//
//  Created by siuzeontou on 24/5/2022.
//

import UIKit
import Combine
import CZImagePreviewer
import SnapKit

class VideoConsole: AccessoryView {
    
    var totalTimeLabelText: String? {
        didSet {
            self.playerProgressControl.totalTimeLabel.text = self.totalTimeLabelText
        }
    }
    
    var progressTimeLabelText: String? {
        didSet {
            if self.playerProgressControl.slider.isPaning { return }
            self.playerProgressControl.progressTimeLabel.text = self.progressTimeLabelText
        }
    }
    
    var sliderProgress: Double? {
        didSet {
            guard let sliderProgress = sliderProgress else { return }
            self.playerProgressControl.slider.updateProgress(progress: sliderProgress)
        }
    }
    
    lazy var playBtn: UIButton = {
        let res = UIButton.init(type: .custom)
        res.layer.borderColor = UIColor.white.cgColor
        res.layer.borderWidth = 1
        res.setTitle("PLAY", for: .normal)
        return res
    }()
    
    lazy var playerProgressControl: PlayerProgressControl = {
        let res = PlayerProgressControl.init(frame: .zero)
        return res
    }()
    
    lazy var asshole: UIActivityIndicatorView = {
        let res = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.white)
        return res
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.viewType = .accessoryView
        
        self.addSubview(self.playBtn)
        self.playBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.addSubview(self.playerProgressControl)
        self.playerProgressControl.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom).offset(-88)
            make.left.equalTo(self.safeAreaLayoutGuide.snp.left).priority(ConstraintPriority.medium)
            make.right.equalTo(self.safeAreaLayoutGuide.snp.right).priority(ConstraintPriority.medium)
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
