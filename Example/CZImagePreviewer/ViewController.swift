//
//  ViewController.swift
//  CZImagePreviewer
//
//  Created by czeludzki on 09/07/2021.
//  Copyright (c) 2021 czeludzki. All rights reserved.
//

import UIKit
import Pods_CZImagePreviewer_Example

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var imagePaths = [
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fdesk.fd.zol-img.com.cn%2Fg5%2FM00%2F03%2F00%2FChMkJ1bK-nSIS40cAAEuXdS6ma4AALLAAM-v7QAAS51610.jpg&refer=http%3A%2F%2Fdesk.fd.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=f8163c3b266a263733642ca2bc73fdb0",
        "https://img1.baidu.com/it/u=194556351,9437364&fm=26&fmt=auto",
        "https://img2.baidu.com/it/u=223817057,1847785609&fm=26&fmt=auto",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fbbsfiles.vivo.com.cn%2Fvivobbs%2Fattachment%2Fforum%2F201804%2F01%2F185440g88mz4em7i47yzuj.jpg&refer=http%3A%2F%2Fbbsfiles.vivo.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=bf33f51101179b09a10c104a9132c80b",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201501%2F22%2F171814y11r8r254hw77148.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=72ce6e5aa851536e25281dae205e63ec",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F110202%2F292-11020203332568.jpg&refer=http%3A%2F%2Fimg.taopic.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=0929baf0277cbd650a1fb4a819e601d8",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fdesk.fd.zol-img.com.cn%2Fg5%2FM00%2F03%2F00%2FChMkJ1bK-nSIS40cAAEuXdS6ma4AALLAAM-v7QAAS51610.jpg&refer=http%3A%2F%2Fdesk.fd.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=f8163c3b266a263733642ca2bc73fdb0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fbbsfiles.vivo.com.cn%2Fvivobbs%2Fattachment%2Fforum%2F201804%2F01%2F185440g88mz4em7i47yzuj.jpg&refer=http%3A%2F%2Fbbsfiles.vivo.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=bf33f51101179b09a10c104a9132c80b",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201501%2F22%2F171814y11r8r254hw77148.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=72ce6e5aa851536e25281dae205e63ec",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F110202%2F292-11020203332568.jpg&refer=http%3A%2F%2Fimg.taopic.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=0929baf0277cbd650a1fb4a819e601d8",        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fdesk.fd.zol-img.com.cn%2Fg5%2FM00%2F03%2F00%2FChMkJ1bK-nSIS40cAAEuXdS6ma4AALLAAM-v7QAAS51610.jpg&refer=http%3A%2F%2Fdesk.fd.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=f8163c3b266a263733642ca2bc73fdb0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fbbsfiles.vivo.com.cn%2Fvivobbs%2Fattachment%2Fforum%2F201804%2F01%2F185440g88mz4em7i47yzuj.jpg&refer=http%3A%2F%2Fbbsfiles.vivo.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=bf33f51101179b09a10c104a9132c80b",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201501%2F22%2F171814y11r8r254hw77148.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=72ce6e5aa851536e25281dae205e63ec",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F110202%2F292-11020203332568.jpg&refer=http%3A%2F%2Fimg.taopic.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=0929baf0277cbd650a1fb4a819e601d8",        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fdesk.fd.zol-img.com.cn%2Fg5%2FM00%2F03%2F00%2FChMkJ1bK-nSIS40cAAEuXdS6ma4AALLAAM-v7QAAS51610.jpg&refer=http%3A%2F%2Fdesk.fd.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=f8163c3b266a263733642ca2bc73fdb0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fbbsfiles.vivo.com.cn%2Fvivobbs%2Fattachment%2Fforum%2F201804%2F01%2F185440g88mz4em7i47yzuj.jpg&refer=http%3A%2F%2Fbbsfiles.vivo.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=bf33f51101179b09a10c104a9132c80b",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201501%2F22%2F171814y11r8r254hw77148.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=72ce6e5aa851536e25281dae205e63ec",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F110202%2F292-11020203332568.jpg&refer=http%3A%2F%2Fimg.taopic.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=0929baf0277cbd650a1fb4a819e601d8",        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fdesk.fd.zol-img.com.cn%2Fg5%2FM00%2F03%2F00%2FChMkJ1bK-nSIS40cAAEuXdS6ma4AALLAAM-v7QAAS51610.jpg&refer=http%3A%2F%2Fdesk.fd.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=f8163c3b266a263733642ca2bc73fdb0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fbbsfiles.vivo.com.cn%2Fvivobbs%2Fattachment%2Fforum%2F201804%2F01%2F185440g88mz4em7i47yzuj.jpg&refer=http%3A%2F%2Fbbsfiles.vivo.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=bf33f51101179b09a10c104a9132c80b",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201501%2F22%2F171814y11r8r254hw77148.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=72ce6e5aa851536e25281dae205e63ec",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F110202%2F292-11020203332568.jpg&refer=http%3A%2F%2Fimg.taopic.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=0929baf0277cbd650a1fb4a819e601d8",        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fdesk.fd.zol-img.com.cn%2Fg5%2FM00%2F03%2F00%2FChMkJ1bK-nSIS40cAAEuXdS6ma4AALLAAM-v7QAAS51610.jpg&refer=http%3A%2F%2Fdesk.fd.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=f8163c3b266a263733642ca2bc73fdb0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fbbsfiles.vivo.com.cn%2Fvivobbs%2Fattachment%2Fforum%2F201804%2F01%2F185440g88mz4em7i47yzuj.jpg&refer=http%3A%2F%2Fbbsfiles.vivo.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=bf33f51101179b09a10c104a9132c80b",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201501%2F22%2F171814y11r8r254hw77148.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=72ce6e5aa851536e25281dae205e63ec",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F110202%2F292-11020203332568.jpg&refer=http%3A%2F%2Fimg.taopic.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=0929baf0277cbd650a1fb4a819e601d8",        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fdesk.fd.zol-img.com.cn%2Fg5%2FM00%2F03%2F00%2FChMkJ1bK-nSIS40cAAEuXdS6ma4AALLAAM-v7QAAS51610.jpg&refer=http%3A%2F%2Fdesk.fd.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=f8163c3b266a263733642ca2bc73fdb0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fbbsfiles.vivo.com.cn%2Fvivobbs%2Fattachment%2Fforum%2F201804%2F01%2F185440g88mz4em7i47yzuj.jpg&refer=http%3A%2F%2Fbbsfiles.vivo.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=bf33f51101179b09a10c104a9132c80b",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201501%2F22%2F171814y11r8r254hw77148.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=72ce6e5aa851536e25281dae205e63ec",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F110202%2F292-11020203332568.jpg&refer=http%3A%2F%2Fimg.taopic.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=0929baf0277cbd650a1fb4a819e601d8",        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fdesk.fd.zol-img.com.cn%2Fg5%2FM00%2F03%2F00%2FChMkJ1bK-nSIS40cAAEuXdS6ma4AALLAAM-v7QAAS51610.jpg&refer=http%3A%2F%2Fdesk.fd.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=f8163c3b266a263733642ca2bc73fdb0",
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fbbsfiles.vivo.com.cn%2Fvivobbs%2Fattachment%2Fforum%2F201804%2F01%2F185440g88mz4em7i47yzuj.jpg&refer=http%3A%2F%2Fbbsfiles.vivo.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=bf33f51101179b09a10c104a9132c80b",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201501%2F22%2F171814y11r8r254hw77148.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=72ce6e5aa851536e25281dae205e63ec",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F110202%2F292-11020203332568.jpg&refer=http%3A%2F%2Fimg.taopic.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=0929baf0277cbd650a1fb4a819e601d8"
    ]
    
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

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagePaths.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCellID", for: indexPath) as! ImageCollectionViewCell
        cell.imageURL = self.imagePaths[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previewer = CZImagePreviewer.init()
        previewer.delegate = self
        previewer.dataSource = self
        let cell = self.collectionView.cellForItem(at: indexPath)
        previewer.display(fromImageContainer: cell, current: indexPath.item)
    }
    
}

extension ViewController: PreviewerDelegate {
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithCellViewModel viewModel: PreviewerCellViewModel) -> UIView? {
        self.collectionView.cellForItem(at: IndexPath(item: viewModel.idx, section: 0))
    }
}

extension ViewController: PreviewerDataSource {
    
    func numberOfItems(in imagePreviewer: CZImagePreviewer) -> Int {
        self.imagePaths.count
    }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, imageResourceForItemAtIndex index: Int) -> ResourceProtocol? {
        let res = self.imagePaths[index].asImgRes
        return res
    }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, accessoryViewForCellWith viewModel: PreviewerCellViewModel, resourceLoadingState: CZImagePreviewer.ImageLoadingState) -> CZImagePreviewer.AccessoryView? {
        let view = CZImagePreviewer.AccessoryView(frame: .zero)
        let centerView = UIButton(type: .system)
        centerView.setTitle(String(viewModel.idx), for: .normal)
        centerView.backgroundColor = .red
        centerView.addTarget(self, action: #selector(self.buttonOnClick(sender:)), for: .touchUpInside)
        view.addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        return view
    }
    
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int) -> CZImagePreviewer.AccessoryView? {
        let view = CZImagePreviewer.AccessoryView(frame: .zero)
        let centerView = UIButton(type: .system)
        centerView.setTitle(String(index), for: .normal)
        centerView.backgroundColor = .red
        centerView.addTarget(self, action: #selector(self.buttonOnClick(sender:)), for: .touchUpInside)
        view.addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.bottom.equalTo(12)
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        return view
    }

    @objc func buttonOnClick(sender: UIButton) {
        print("buttonOnClick")
    }
    
}
