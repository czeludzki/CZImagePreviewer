//
//  CZImagePreviewerCollectionViewCell.swift
//  CZImagePreviewerCollectionViewCell
//
//  Created by siuzeontou on 2021/9/9.
//

import UIKit
import Kingfisher

// 资源模型
internal struct PreviewerCellItem {
    var resource: ImageProvider?
    var idx: Int
}

internal protocol CollectionViewCellDelegate: AnyObject {
    /// 通知代理图片加载进度
    func collectionViewCell(_ cell: CollectionViewCell, resourceLoadingStateDidChanged state: Previewer.ImageLoadingState, idx: Int, accessoryView: AccessoryView?)
}

public class CollectionViewCell: UICollectionViewCell {}
