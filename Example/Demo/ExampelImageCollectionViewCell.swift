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
    
    @IBOutlet weak var asshole: UIActivityIndicatorView!
    
    var image: ImageProvider? {
        didSet {
            self.asshole.isHidden = false
            self.imageView.isHidden = true
            guard let provider = image else { return }
            provider.loadImage(options: [.processor(ResizingImageProcessor(referenceSize: self.bounds.size, mode: .aspectFill)), .processingQueue(.dispatch(DispatchQueue.global()))], progress: nil, completion: { [weak self] result in
                if self?.image?.cacheKey != provider.cacheKey { return }
                self?.imageView.image = result.image
                self?.asshole.isHidden = true
                self?.imageView.isHidden = false
            })
        }
    }
}
