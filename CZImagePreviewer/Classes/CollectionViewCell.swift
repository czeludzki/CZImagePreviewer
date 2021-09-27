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
        let zoomingScrollView = UIScrollView.init(frame: CGRect.zero)
        zoomingScrollView.delegate = self.cellModel
        zoomingScrollView.showsVerticalScrollIndicator = false
        zoomingScrollView.showsHorizontalScrollIndicator = false
        zoomingScrollView.bounces = true
        zoomingScrollView.clipsToBounds = false
        zoomingScrollView.backgroundColor = UIColor.clear
        zoomingScrollView.alwaysBounceVertical = false
        zoomingScrollView.alwaysBounceHorizontal = false
        zoomingScrollView.contentInsetAdjustmentBehavior = .never
        return zoomingScrollView
    }()
    
    lazy var videoContainer: CZImagePreviewerAccessoryView = {
        let videoContainer = CZImagePreviewerAccessoryView.init()
        videoContainer._viewType = .videoView
        return videoContainer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.contentView.addSubview(self.zoomingScrollView)
        self.zoomingScrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.zoomingScrollView.addSubview(self.imageView)
        self.contentView.addSubview(self.videoContainer)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cellModel.cellDidLayoutSubviews()
    }
}
