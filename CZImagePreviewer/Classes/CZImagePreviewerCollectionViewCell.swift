//
//  CZImagePreviewerCollectionViewCell.swift
//  CZImagePreviewerCollectionViewCell
//
//  Created by siuzeontou on 2021/9/9.
//

import UIKit
import SDWebImage

class CZImagePreviewerCollectionViewCell: UICollectionViewCell {
    static let CZImagePreviewerCollectionViewCellReuseID = "CZImagePreviewerCollectionViewCellReuseID"
    
    lazy var imageView: UIImageView = {
        let ret = UIImageView.init(frame: CGRect.zero)
        return ret
    }()
    
    var imageResource: ImageResourceProtocol? {
        didSet {
            
            func progress(receivedSize: Int, expectedSize: Int, targetURL: URL?) {
                print(receivedSize, expectedSize, targetURL)
            }
            func completion(image: UIImage?, data: Data?, error: Error?, cacheType: SDImageCacheType, finish: Bool, targetURL: URL?) {
                self.imageView.image = image
            }
            
            /// 不知道为什么不能直接调用 imageResource?.loadImage() 方法
            /// 直接调用的结果是, 总会走到 extension ImgSourceNamespaceWrapper: ImageResourceProtocol 的默认实现中去,
            /// 而不是 extension ImgSourceNamespaceWrapper where WrappedValueType == String 指定 String 的实现
            /// 除非像下面做的, 对 imageResource 进行转型, 编译器才会调用到正确的函数, 也就是走 extension ImgSourceNamespaceWrapper where WrappedValueType == String 指定的实现
            
            if let res = imageResource as? ImgSourceNamespaceWrapper<String> {
                res.loadImage(progress: progress(receivedSize:expectedSize:targetURL:), completion: completion(image:data:error:cacheType:finish:targetURL:))
                return
            }
            
            if let res = imageResource as? ImgSourceNamespaceWrapper<URL> {
                res.loadImage(progress: progress(receivedSize:expectedSize:targetURL:), completion: completion(image:data:error:cacheType:finish:targetURL:))
                return
            }
            
            if let res = imageResource as? ImgSourceNamespaceWrapper<UIImage> {
                res.loadImage(progress: progress(receivedSize:expectedSize:targetURL:), completion: completion(image:data:error:cacheType:finish:targetURL:))
                return
            }
            
            imageResource?.loadImage(progress: progress(receivedSize:expectedSize:targetURL:), completion: completion(image:data:error:cacheType:finish:targetURL:))
            
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
