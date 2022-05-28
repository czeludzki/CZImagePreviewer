//
//  PlayerProgressControl.swift
//  CZImagePreviewer
//
//  Created by siuzeontou on 24/5/2022.
//

import UIKit

class PlayerProgressControl: UIView {
    
    lazy var progressTimeLabel: UILabel = {
        let res = UILabel.init(frame: .zero)
        res.font = UIFont.systemFont(ofSize: 11)
        res.textColor = .white
        res.text = "00:00"
        return res
    }()
    
    lazy var totalTimeLabel: UILabel = {
        let res = UILabel.init(frame: .zero)
        res.font = UIFont.systemFont(ofSize: 11)
        res.textColor = .white
        res.text = "00:00"
        return res
    }()
    
    lazy var slider: PlayerProgressSlider = {
        let res = PlayerProgressSlider.init(frame: .zero)
        res.setContentHuggingPriority(UILayoutPriority.init(rawValue: 249), for: NSLayoutConstraint.Axis.horizontal)
        res.setContentCompressionResistancePriority(UILayoutPriority.init(rawValue: 249), for: NSLayoutConstraint.Axis.horizontal)
        return res
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.addSubview(self.progressTimeLabel)
        self.progressTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(self.safeAreaLayoutGuide.snp.left).offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(32)
        }
        
        self.addSubview(self.slider)
        self.slider.snp.makeConstraints { make in
            make.left.equalTo(self.progressTimeLabel.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
            make.top.bottom.equalToSuperview()
        }
        
        self.addSubview(self.totalTimeLabel)
        self.totalTimeLabel.snp.makeConstraints { make in
            make.right.equalTo(self.snp.right).offset(-16)
            make.centerY.equalToSuperview()
            make.left.equalTo(self.slider.snp.right).offset(12)
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
