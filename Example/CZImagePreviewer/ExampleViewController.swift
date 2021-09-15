//
//  ViewController.swift
//  CZImagePreviewer
//
//  Created by czeludzki on 09/07/2021.
//  Copyright (c) 2021 czeludzki. All rights reserved.
//

import UIKit
import Pods_CZImagePreviewer_Example

class ExampleViewController: UIViewController {
    
    lazy var res: [ResourceItem] = {
        var ret: [ResourceItem] = []
        self.imagePaths.forEach {
            var item = ResourceItem(imgPath: $0)
            if Int.random(in: 1...100) % 3 == 0 {
                let url = videoURLs[Int.random(in: 0...2)]
                item.videoURL = url
            }
            ret.append(item)
        }
        return ret
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool { true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
}

extension ExampleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.res.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCellID", for: indexPath) as! ExampelImageCollectionViewCell
        cell.imageURL = self.res[indexPath.item].imagePath
        cell.resourceTypeLabel.text = self.res[indexPath.item].resType
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 创建 CZImagePreviewer 以及 显示
        let previewer = CZImagePreviewer.init()
        previewer.delegate = self
        previewer.dataSource = self
        let cell = self.collectionView.cellForItem(at: indexPath)
        previewer.display(fromImageContainer: cell, current: indexPath.item)
    }
    
}

extension ExampleViewController: PreviewerDelegate {
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithCellViewModel viewModel: PreviewerCellViewModel) -> UIView? {
        self.collectionView.cellForItem(at: IndexPath(item: viewModel.idx, section: 0))
    }
}

extension ExampleViewController: PreviewerDataSource {
    
    func numberOfItems(in imagePreviewer: CZImagePreviewer) -> Int {
        self.res.count
    }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, imageResourceForItemAtIndex index: Int) -> ResourceProtocol? {
        // String / URL / UIImage 类型可以将属性 .asImgRes 作为返回值直接返回
        let res = self.res[index].imagePath.asImgRes
        return res
    }
    
    // 这个视图被添加到 CZImagePreviewer 的顶部, 不参与滑动交互, 可以放一些通用按钮例如 下载图片/分享/编辑 等等
    // 使用者也可以自己持有这个视图实例, 然后每次都返回相同的视图实例, CZImagePreviewer 在加入此视图到superview前会对视图实例进行地址判断, 防止重复添加 或 没必要的先移除再添加
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int) -> CZImagePreviewer.AccessoryView? {
        let view = CZImagePreviewer.AccessoryView(frame: .zero)
        let centerView = UIButton(type: .system)
        centerView.setTitle(String(index), for: .normal)
        centerView.tintColor = .black
        centerView.layer.cornerRadius = 8
        centerView.layer.borderWidth = 1
        centerView.layer.borderColor = UIColor.white.cgColor
        centerView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        view.addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.bottomMargin.equalTo(view.snp.bottomMargin)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        return view
    }
    
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, accessoryViewForCellWith viewModel: PreviewerCellViewModel, resourceLoadingState: CZImagePreviewer.ImageLoadingState) -> CZImagePreviewer.AccessoryView? {
        
        let view = self.res[viewModel.idx].vm?.consoleView
        print(view)
        return view
        
    }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoLayerForCellWith viewModel: PreviewerCellViewModel) -> CALayer? {
        
        self.res[viewModel.idx].vm?.playerLayer
        
    }
}
