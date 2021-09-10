//
//  CZImagePreviewerCollectionViewCell.swift
//  CZImagePreviewerCollectionViewCell
//
//  Created by siuzeontou on 2021/9/9.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    static let CollectionViewCellReuseID = NSStringFromClass(CollectionViewCell.self) + "ReuseID"
    
    lazy var cellModel: PreviewerCellViewModel = {
        PreviewerCellViewModel(cell: self)
    }()
    
    lazy var imageView: UIImageView = {
        let ret = UIImageView.init(frame: CGRect.zero)
        ret.backgroundColor = .clear
        ret.clipsToBounds = true
        ret.contentMode = .scaleAspectFill
        return ret
    }()
    
    lazy var zoomingScrollView: UIScrollView = {
        let ret = UIScrollView.init(frame: CGRect.zero)
        ret.delegate = self.cellModel
        ret.showsVerticalScrollIndicator = false
        ret.showsHorizontalScrollIndicator = false
        ret.bounces = true
        ret.clipsToBounds = false
        ret.backgroundColor = UIColor.clear
        ret.alwaysBounceVertical = false
        ret.alwaysBounceHorizontal = false
        return ret
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.contentView.addSubview(self.zoomingScrollView)
        self.contentView.backgroundColor = .red
        self.zoomingScrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.zoomingScrollView.addSubview(self.imageView)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cellModel.updateScrollViewConfiguration()
        self.cellModel.keepCentral()
    }
}
