//
//  ImageCollectionViewCell.swift
//  ImageCollectionViewCell
//
//  Created by siuzeontou on 2021/9/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Kingfisher
import CZImagePreviewer

class ExampelImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var resourceTypeLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    var image: ImageProvider? {
        didSet {
            oldValue?.cancel()
            image?.loadImage(options: [.processor(ResizingImageProcessor(referenceSize: self.bounds.size))], progress: nil, completion: { [weak self] result in
                self?.imageView.image = result.image
            })
        }
    }
}
