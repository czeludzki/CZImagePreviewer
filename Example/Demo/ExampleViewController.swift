//
//  ViewController.swift
//  CZImagePreviewer
//
//  Created by czeludzki on 09/07/2021.
//  Copyright (c) 2021 czeludzki. All rights reserved.
//

import UIKit
import CZImagePreviewer

class ExampleViewController: UIViewController {
    
    lazy var dataSources: [ResourceItem] = {
        var ret: [ResourceItem] = Self.imagePaths.compactMap {
            var item = ResourceItem(imgPath: $0)
            if Int.random(in: 1...100) % 3 == 0 {
                let url = Self.videoURLs[Int.random(in: 0...2)]
                item.videoURL = url
            }
            return item
        }
        return ret
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var imagePreviewer: CZImagePreviewer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override var shouldAutorotate: Bool { true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override var prefersStatusBarHidden: Bool { false }
}

extension ExampleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCellID", for: indexPath) as! ExampelImageCollectionViewCell
        cell.imageURL = self.dataSources[indexPath.item].imagePath
        cell.resourceTypeLabel.text = self.dataSources[indexPath.item].resType
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 创建 CZImagePreviewer 以及 显示
        let previewer = CZImagePreviewer.init()
        previewer.delegate = self
        previewer.dataSource = self
        let cell = self.collectionView.cellForItem(at: indexPath)
        previewer.display(fromImageContainer: cell, current: indexPath.item)
        self.imagePreviewer = previewer
    }
    
}

extension ExampleViewController: CZImagePreviewerDelegate {
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithCell cell: CZImagePreviewerCollectionViewCell, at index: Int) -> UIView? {
        self.collectionView.cellForItem(at: IndexPath(item: index, section: 0))
    }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, index oldIndex: Int, didChangedTo newIndex: Int) {
        if case 0..<self.dataSources.count = oldIndex {
            if self.dataSources[oldIndex].videoItem?.isPlaying == true {
                self.dataSources[oldIndex].videoItem?.player.pause()
            }
        }
    }

}

extension ExampleViewController: CZImagePreviewerDataSource {
    
    func numberOfItems(in imagePreviewer: CZImagePreviewer) -> Int {
        self.dataSources.count
    }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, imageResourceForItemAtIndex index: Int) -> CZImagePreviewerResource? {
        // String / URL / UIImage 类型可以将属性 .asImgRes 作为返回值直接返回
        let res = self.dataSources[index].imagePath
        return res
    }
    
    // 这个视图被添加到 CZImagePreviewer 的顶部, 不参与滑动交互, 可以放一些通用按钮例如 下载图片/分享/编辑 等等
    // 使用者也可以自己持有这个视图实例, 然后每次都返回相同的视图实例, CZImagePreviewer 在加入此视图到superview前会对视图实例进行地址判断, 防止重复添加 或 没必要的先移除再添加
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int) -> CZImagePreviewerAccessoryView? {
        let view = CZImagePreviewerAccessoryView(frame: .zero)
        let idxTag = UIButton(type: .system)
        idxTag.setTitle(String(index), for: .normal)
        idxTag.tintColor = .white
        idxTag.layer.cornerRadius = 8
        idxTag.layer.borderWidth = 1
        idxTag.layer.borderColor = UIColor.white.cgColor
        idxTag.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        view.addSubview(idxTag)
        idxTag.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.bottomMargin.equalTo(view.snp.bottomMargin)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        let deleteBtn = UIButton(type: .system)
        deleteBtn.setTitle("删除", for: .normal)
        deleteBtn.tintColor = .white
        deleteBtn.layer.cornerRadius = 8
        deleteBtn.layer.borderWidth = 1
        deleteBtn.layer.borderColor = UIColor.white.cgColor
        deleteBtn.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        deleteBtn.addTarget(self, action: #selector(deleteBtnOnClick(sender:)), for: .touchUpInside)
        deleteBtn.contentEdgeInsets = UIEdgeInsets.init(top: 6, left: 12, bottom: 6, right: 12)
        view.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.bottomMargin.equalTo(view.snp.bottomMargin)
        }
        return view
    }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, accessoryViewForCell cell: CZImagePreviewerCollectionViewCell, at index: Int) -> CZImagePreviewerAccessoryView? {
        let view = self.dataSources[index].videoItem?.videoConsole
        return view
    }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoLayerForCell cell: CZImagePreviewerCollectionViewCell, at index: Int) -> CALayer? {
        let videoItem = self.dataSources[index].videoItem
        return videoItem?.playerLayer
    }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoSizeForCell cell: CZImagePreviewerCollectionViewCell, at index: Int, videoSizeSettingHandler: (CGSize?) -> Void) {
        let videoItem = self.dataSources[index].videoItem
        videoSizeSettingHandler(videoItem?.player.currentItem?.presentationSize ?? .zero)
    }
    
}

// MARK: Action
extension ExampleViewController {
    @objc func deleteBtnOnClick(sender: UIButton) {
        guard let currentIdx = self.imagePreviewer?.currentIdx else { return }
        self.dataSources.remove(at: currentIdx)
        self.imagePreviewer?.deleteItems(at: [currentIdx])
        self.collectionView.reloadData()
    }
}
