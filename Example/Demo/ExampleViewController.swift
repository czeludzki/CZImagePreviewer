//
//  ViewController.swift
//  CZImagePreviewer
//
//  Created by czeludzki on 09/07/2021.
//  Copyright (c) 2021 czeludzki. All rights reserved.
//

import UIKit
import CZImagePreviewer
import Kingfisher

class ExampleViewController: UIViewController {
    
    lazy var dataSources: [CZImagePreviewer.ResourceProvider] = {
        var res = Self.resourcePaths().reduce(into: [CZImagePreviewer.ResourceProvider]()) { partialResult, path in
            if (path as NSString).pathExtension == "mp4" {
                // 从 Self.imagePaths 中随机选择一个元素来充当视频封面图
                let idx = Int.random(in: 0...Self.imagePaths.count - 1)
                let cover = Self.imagePaths[idx]
                // 组建 VideoResource
                let provider = VideoResource.init(videoPath: path, cover: cover)
                partialResult.append(provider)
            }else{
                partialResult.append(path)
            }
        }
        print(res)
        return res
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var imagePreviewer: Previewer?
    
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
        if let imageResource = self.dataSources[indexPath.item] as? ImageProvider {
            cell.image = imageResource
            cell.resourceTypeLabel.text = "Image"
        }
        if let videoResource = self.dataSources[indexPath.item] as? VideoResource {
            cell.image = videoResource.displayAnimationActor
            cell.resourceTypeLabel.text = "Video"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 创建 CZImagePreviewer 以及 显示
        let previewer = Previewer.init()
        previewer.delegate = self
        previewer.dataSource = self
        let cell = self.collectionView.cellForItem(at: indexPath)
        previewer.display(fromImageContainer: cell, current: indexPath.item)
        self.imagePreviewer = previewer
    }
    
}

extension ExampleViewController: CZImagePreviewer.Delegate {
    func imagePreviewer(_ imagePreviewer: Previewer, willDismissWithCell cell: CollectionViewCell, at index: Int) -> UIView? {
        self.collectionView.cellForItem(at: IndexPath(item: index, section: 0))
    }
    
    func imagePreviewer(_ imagePreviewer: Previewer, index oldIndex: Int, didChangedTo newIndex: Int) {
        
    }
    
    func imagePreviewer(_ imagePreviewer: Previewer, didLongPressAtIndex index: Int) {
        
    }

}

extension ExampleViewController: CZImagePreviewer.DataSource {
    
    func numberOfItems(in imagePreviewer: Previewer) -> Int {
        self.dataSources.count
    }
    
    func imagePreviewer(_ imagePreviewer: Previewer, resourceForItemAtIndex index: Int) -> ResourceProvider? {
        let res = self.dataSources[index]
        return res
    }
    
    // 这个视图被添加到 CZImagePreviewer 的顶部, 不参与滑动交互, 可以放一些通用按钮例如 下载图片/分享/编辑 等等
    // 使用者也可以自己持有这个视图实例, 然后每次都返回相同的视图实例, CZImagePreviewer 在加入此视图到superview前会对视图实例进行地址判断, 防止重复添加 或 没必要的先移除再添加
    func imagePreviewer(_ imagePreviewer: Previewer, consoleForItemAtIndex index: Int) -> AccessoryView? {
        let view = AccessoryView(frame: .zero)
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
        deleteBtn.addTarget(self, action: #selector(self.deleteBtnOnClick(sender:)), for: .touchUpInside)
        deleteBtn.contentEdgeInsets = UIEdgeInsets.init(top: 6, left: 12, bottom: 6, right: 12)
        view.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.bottomMargin.equalTo(view.snp.bottomMargin)
        }
        return view
    }
    
    func imagePreviewer(_ imagePreviewer: Previewer, accessoryViewForCell cell: CollectionViewCell, at index: Int) -> AccessoryView? {
        // 图片类型
        if let imageProvider = self.dataSources[index] as? ImageProvider {
            
        }
        // 视频类型
        guard let videoResource = self.dataSources[index] as? VideoResource else { return nil }
        let view = videoResource.videoItem.videoConsole
        return view
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
