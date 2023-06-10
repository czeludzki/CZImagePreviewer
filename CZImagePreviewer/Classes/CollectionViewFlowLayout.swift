//
//  PreviewerFlowLayout.swift
//  CZImagePreviewer
//
//  Created by siuzeontou on 2021/9/17.
//

import UIKit

class CollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var rotatingInfo: Previewer.RotatingInfo?
    
    var attributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    
    override func prepare() {
        super.prepare()
        
        self.attributes.removeAll()
        
        guard let collectionView = self.collectionView else { return }
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let idxPath = IndexPath(item: item, section: 0)
            let attr = self.layoutAttributesForItem(at: idxPath)
            self.attributes[idxPath] = attr
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard self.rotatingInfo?.isRotating == true, let idx = self.rotatingInfo?.indexBeforeRotate, let newOffset = self.attributes[IndexPath(item: idx, section: 0)]?.frame.origin else {
            return proposedContentOffset
        }
        return CGPoint(x: (newOffset.x + (self.collectionView?.frame.minX ?? 0)), y: newOffset.y)
    }
        
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if self.rotatingInfo?.isRotating == true {
            // 去掉旋转时默认的淡出淡入隐式动画
            return nil
        }else{
            return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        }
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if self.rotatingInfo?.isRotating == true {
            // 去掉旋转时 DisappearingItem 的隐式动画
            let attr = self.layoutAttributesForItem(at: itemIndexPath)
            return attr
        }else{
            return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        }
    }
}
