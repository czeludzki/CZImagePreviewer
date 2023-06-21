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
            self.imageView?.kf.setImage(with: URL.init(string: "https://th.bing.com/th/id/R.c0e7c30f2b81a52a9fbed13ba9f28a48?rik=c6lndw8w1nWBqA&riu=http%3a%2f%2fwww.rw-designer.com%2ficon-image%2f14102-128x128x32.png&ehk=zUcHJ0A7%2bEz1Jq6hqRy9QmTmpbEfbwmcN6lzzD%2bpnjY%3d&risl=&pid=ImgRaw&r=0")!)
            return
            self.asshole.isHidden = false
            self.imageView.isHidden = true
            guard let provider = image else { return }
            provider.loadImage(options: [.processor(ResizingImageProcessor(referenceSize: self.bounds.size, mode: .aspectFit))], progress: nil, completion: { [weak self] result in
                if self?.image?.cacheKey != provider.cacheKey { return }
                self?.imageView.image = result.image
                self?.asshole.isHidden = true
                self?.imageView.isHidden = false
            })
        }
    }
}
