//
//  CZImagePreviewer.swift
//  CZImagePreviewer
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import SnapKit
import SDWebImage

public class CZImagePreviewer: UIViewController {
    
    public weak var delegate: PreviewerDelegate?
    public var dataSource: PreviewerDataSource?
    
    /// 当前索引
    public private(set) var currentIdx = 0 {
        didSet {
            print("current index = \(currentIdx)")
        }
    }
    
    /// Cell 之间的间距
    public var spacingBetweenItem: CGFloat = 20.0
    
    /// 通过DataSource协议返回的自定义控制层
    private var cus_console: UIView?
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .init(top: 0, left: self.spacingBetweenItem * 0.5, bottom: 0, right: self.spacingBetweenItem * 0.5)
        flowLayout.minimumLineSpacing = self.spacingBetweenItem
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.CollectionViewCellReuseID)
        return collectionView
    }()
    
    private lazy var rotateAnimationImageView: UIImageView = {
        let imgView = UIImageView.init(frame: CGRect.zero)
        imgView.contentMode = .scaleAspectFit
        imgView.isHidden = true
        return imgView
    }()
    
    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapOnView(sender:)))
        return tap
    }()
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        self.modalTransitionStyle = .crossDissolve
        self.transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalTo(UIEdgeInsets(top: 0, left: -spacingBetweenItem * 0.5, bottom: 0, right: -spacingBetweenItem * 0.5))
        }
        
        self.view.addSubview(self.rotateAnimationImageView)
        self.rotateAnimationImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addGestureRecognizer(self.tap)
    }
    
    var didSetInitialIdx = false
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.didSetInitialIdx { return }
        self.scroll2Item(at: self.currentIdx, animated: false)
        self.didSetInitialIdx = true
    }
    
    public override var prefersStatusBarHidden: Bool { true }
    
    // 屏幕旋转事件发生时触发
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let mark_idx = self.currentIdx
        self.collectionView.performBatchUpdates {
            self.collectionView.reloadData()
        } completion: { finish in
            print("self.scroll2Item(at: mark_idx, animated: false)", mark_idx)
            self.scroll2Item(at: mark_idx, animated: false)
        }
        // 旋转时执行, 将 rotateAnimationImageView.isHidden 设为 false, 且为其设置图片
        self.executeWhenRotate(idx: mark_idx, coordinator: coordinator)
    }
}

// MARK: Action
extension CZImagePreviewer {
    @objc func tapOnView(sender: UITapGestureRecognizer) {
        self.dismiss()
    }
}

// MARK: 相关定义
extension CZImagePreviewer {
    public enum ImageLoadingState {
        case `default`  // 正常可预览状态
        case loading(receivedSize: Int, expectedSize: Int)  // 加载中
        case loadingFaiure  // 加载失败
        case processing     // 图片解码中
    }
}

// MARK: public function
extension CZImagePreviewer {
    
    public func display(fromImageContainer container: UIView?, current index: Int = 0, presented controller: UIViewController?) {

        self.currentIdx = index
        
        let windowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
        let controller = controller ?? windowScene.windows.first!.rootViewController
        controller?.present(self, animated: false, completion: nil)
        
    }
    
    public func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func reloadData() {
        
    }
    
}

// MARK: CollectionViewDelegate, CollectionViewDataSource, ScrollViewDelegate
extension CZImagePreviewer: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentIdx = Int((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width)
    }
}

extension CZImagePreviewer: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 从 dataSource 取得 数据
        let imgRes: ResourceProtocol? = self.dataSource?.imagePreviewer(self, imageResourceForItemAtIndex: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.CollectionViewCellReuseID, for: indexPath) as! CollectionViewCell
        cell.cellModel.delegate = self
        cell.cellModel.item = PreviewerCellItem(resource: imgRes, idx: indexPath.item)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        UIScreen.main.bounds.size
    }
    
    /// iOS 10 预加载
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { idxPath in
            let imgRes: ResourceProtocol? = self.dataSource?.imagePreviewer(self, imageResourceForItemAtIndex: idxPath.item)
            imgRes?.loadImage(progress: nil, completion: nil)
        }
    }
}

/// MARK: PreviewerCellViewModelDelegate
extension CZImagePreviewer: PreviewerCellViewModelDelegate {
    // CellModel 负责下载图片, 下载图片进度反馈
    func collectionCellViewModel(_ viewModel: PreviewerCellViewModel, idx: Int, resourceLoadingStateDidChanged state: ImageLoadingState) {
        guard let console = self.dataSource?.imagePreviewer(self, consoleForItemAtIndex: idx, resourceLoadingState: state) else { return }
        if self.cus_console == console { return }
        // 先移除
        self.cus_console?.removeFromSuperview()
        // 再添加
        self.view.addSubview(console)
    }
}

/// MARK: Helper
extension CZImagePreviewer {
    func scroll2Item(at index: Int, animated: Bool) {
        let x = CGFloat(index) * self.view.bounds.size.width + CGFloat(index) * self.spacingBetweenItem
        self.collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }
    
    // 在对比了微信的图片浏览后, 发现微信的图片浏览器在屏幕旋转事件发生时, 微信为了旋转动画的流畅, 会在顶层覆盖一个独立的 Image 视图展示旋转, 旋转完成后再将其移除
    func executeWhenRotate(idx: Int, coordinator: UIViewControllerTransitionCoordinator) {
        let cell = self.collectionView.cellForItem(at: IndexPath(item: idx, section: 0)) as? CollectionViewCell
        if let image = cell?.imageView.image {
            self.rotateAnimationImageView.isHidden = false
            self.rotateAnimationImageView.image = image
            self.collectionView.isHidden = true
        }
        // 旋转动画完成后, 恢复原来的显示
        coordinator.animate(alongsideTransition: nil) { transitionCoordinatorContext in
            self.collectionView.isHidden = false
            self.rotateAnimationImageView.isHidden = true
        }
    }
}

/// MARK: UIViewControllerTransitioningDelegate
extension CZImagePreviewer: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentTrans = AnimatedTransitioning(transitionFor: .present)
        return presentTrans
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismissTrans = AnimatedTransitioning(transitionFor: .dismiss)
        return dismissTrans
    }
}

