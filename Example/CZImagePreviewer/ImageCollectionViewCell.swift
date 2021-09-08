//
//  ImageCollectionViewCell.swift
//  ImageCollectionViewCell
//
//  Created by siuzeontou on 2021/9/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import SDWebImage

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    var imageURL: String? {
        didSet {
            self.imageView.sd_setImage(with: URL(string: imageURL ?? ""))
        }
    }
}
