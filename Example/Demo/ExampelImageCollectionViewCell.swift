//
//  ImageCollectionViewCell.swift
//  ImageCollectionViewCell
//
//  Created by siuzeontou on 2021/9/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Kingfisher

class ExampelImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var resourceTypeLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    var imageURL: String? {
        didSet {
            guard let url = imageURL else { return }
            self.imageView.kf.setImage(with: URL.init(string: url), placeholder: nil, options: nil, completionHandler: nil)
        }
    }
}
