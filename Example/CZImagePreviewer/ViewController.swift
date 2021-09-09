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
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fbbsfiles.vivo.com.cn%2Fvivobbs%2Fattachment%2Fforum%2F201804%2F01%2F185440g88mz4em7i47yzuj.jpg&refer=http%3A%2F%2Fbbsfiles.vivo.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=bf33f51101179b09a10c104a9132c80b",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201501%2F22%2F171814y11r8r254hw77148.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=72ce6e5aa851536e25281dae205e63ec",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fdesk.fd.zol-img.com.cn%2Fg5%2FM00%2F03%2F00%2FChMkJ1bK-nSIS40cAAEuXdS6ma4AALLAAM-v7QAAS51610.jpg&refer=http%3A%2F%2Fdesk.fd.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=f8163c3b266a263733642ca2bc73fdb0",
                           "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F110202%2F292-11020203332568.jpg&refer=http%3A%2F%2Fimg.taopic.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633608077&t=0929baf0277cbd650a1fb4a819e601d8",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951183795&di=52c6e463b923dd14bb2e17d233fc2a85&imgtype=0&src=http%3A%2F%2Fattach.bbs.letv.com%2Fforum%2F201606%2F25%2F162403ipzartlyzqht3q2t.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951199349&di=c908322c95435feb41d9338c04c9acea&imgtype=0&src=http%3A%2F%2Fpic.t139.com%2Fpicture%2F201510%2Fb_561ccc4ca81d8.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495545938&di=ea90ab5d075889f335180d9984956851&imgtype=jpg&er=1&src=http%3A%2F%2Fimg15.3lian.com%2F2015%2Ff3%2F01%2F111.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495545968&di=19e21e46be73f3e7d1dc754a0a955d61&imgtype=jpg&er=1&src=http%3A%2F%2Fy2.ifengimg.com%2Fifengimcp%2Fpic%2F20140917%2F208572cc2ebbd01d8729_size505_w1044_h1600.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951280389&di=dc76722718257e9b63f239d55d642c9a&imgtype=0&src=http%3A%2F%2Fpic29.nipic.com%2F20130512%2F8952533_135542382000_2.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951121134&di=c7316d9e304be9ab6723a4e412d506ee&imgtype=0&src=http%3A%2F%2Fn.sinaimg.cn%2Fsinacn%2F20161229%2Fb5d9-fxzencv2120554.jpeg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951141310&di=16e1b5be6eb0e000c92aae6da144cfad&imgtype=0&src=http%3A%2F%2Fcar0.autoimg.cn%2Fupload%2F2014%2F6%2F13%2F201406132124130794322.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951155680&di=7ec1c26c5b5c9290f4106750a1b10e43&imgtype=0&src=http%3A%2F%2Fimg.pconline.com.cn%2Fimages%2Fupload%2Fupc%2Ftx%2Fwallpaper%2F1212%2F06%2Fc2%2F16397554_1354787416906_800x600.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951167278&di=9ee4e5b520a359855c1df2479ec61df8&imgtype=0&src=http%3A%2F%2Fb.zol-img.com.cn%2Fdesk%2Fbizhi%2Fimage%2F6%2F720x360%2F1426561861511.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951183795&di=52c6e463b923dd14bb2e17d233fc2a85&imgtype=0&src=http%3A%2F%2Fattach.bbs.letv.com%2Fforum%2F201606%2F25%2F162403ipzartlyzqht3q2t.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951199349&di=c908322c95435feb41d9338c04c9acea&imgtype=0&src=http%3A%2F%2Fpic.t139.com%2Fpicture%2F201510%2Fb_561ccc4ca81d8.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495545938&di=ea90ab5d075889f335180d9984956851&imgtype=jpg&er=1&src=http%3A%2F%2Fimg15.3lian.com%2F2015%2Ff3%2F01%2F111.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495545968&di=19e21e46be73f3e7d1dc754a0a955d61&imgtype=jpg&er=1&src=http%3A%2F%2Fy2.ifengimg.com%2Fifengimcp%2Fpic%2F20140917%2F208572cc2ebbd01d8729_size505_w1044_h1600.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951280389&di=dc76722718257e9b63f239d55d642c9a&imgtype=0&src=http%3A%2F%2Fpic29.nipic.com%2F20130512%2F8952533_135542382000_2.jpg",
                           "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1494951292383&di=f31a808921c373e651c68b6eb689fb82&imgtype=0&src=http%3A%2F%2Fimg3.3lian.com%2F2013%2Fs4%2F8%2Fd%2F59.jpg",
                           "http://s9.sinaimg.cn/orignal/5244a93cg9914e513e468&690",
                           "http://ww1.sinaimg.cn/bmiddle/63c9e579ly1fjix6vwv91j21d57b7qv5.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool { false }
    
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
        previewer.display(fromImageContainer: nil, current: indexPath.item, presented: self)
    }
    
}

extension ViewController: CZImagePreviewerDelegate {

}

extension ViewController: CZImagePreviewerDataSource {
    func imagePreviewer(_ imagePreviewer: CZImagePreviewer, atIndex index: Int) -> ImageResourceProtocol? {
        let res = self.imagePaths[index].asImgRes
        return res
    }
    
    func numberOfItems(in imagePreviewer: CZImagePreviewer) -> Int {
        self.imagePaths.count
    }
    
}
