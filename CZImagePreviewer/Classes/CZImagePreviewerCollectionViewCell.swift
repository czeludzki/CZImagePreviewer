//
//  CZImagePreviewerCollectionViewCell.swift
//  CZImagePreviewerCollectionViewCell
//
//  Created by siuzeontou on 2021/9/9.
//

import UIKit

class CZImagePreviewerCollectionViewCell: UICollectionViewCell {
    static let CZImagePreviewerCollectionViewCellReuseID = "CZImagePreviewerCollectionViewCellReuseID"
    
    lazy var imageView: UIImageView = {
        let ret = UIImageView.init(frame: CGRect.zero)
        return ret
    }()
    
    var imageResource: ImageResourceProtocol? {
        didSet {
            imageResource?.loadImage(progress: { receivedSize, expectedSize, targetURL in
                print(receivedSize, expectedSize, targetURL)
            }, completion: { [weak self] image, data, error, cacheType, finish, targetURL in
                print(image)
                self?.imageView.image = image
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.imageView)
        self.imageView.backgroundColor = UIColor.red
        self.imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
