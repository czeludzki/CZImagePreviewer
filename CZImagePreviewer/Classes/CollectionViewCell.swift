//
//  CZImagePreviewerCollectionViewCell.swift
//  CZImagePreviewerCollectionViewCell
//
//  Created by siuzeontou on 2021/9/9.
//

import UIKit
import Kingfisher

// 资源模型
internal struct CellItem {
    var resource: ResourceProvider
    var idx: Int
}

internal protocol CollectionViewCellDelegate: AnyObject {
    /// 通知代理图片加载进度
    func collectionViewCell(_ cell: CollectionViewCell, resourceLoadingStateDidChanged state: Previewer.ImageLoadingState, idx: Int, accessoryView: AccessoryView?)
}

public class CollectionViewCell: UICollectionViewCell {
    var item: CellItem?
    weak var accessoryView: AccessoryView?
    weak var delegate: CollectionViewCellDelegate?
    // 在发生拖拽dismiss事件时, 执行拖拽手势的响应的主角及动画主角. 子类重写
    var dragingActor: UIView? { nil }
    func didEndDisplay() {}
}
