//
//  CZImagePreviewer.swift
//  CZImagePreviewer
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import SnapKit
import Kingfisher

open class CZImagePreviewer: UIViewController {
    
    public enum ImageLoadingState {
        case `default`  // 正常可预览状态
        case loading(receivedSize: Int64, expectedSize: Int64)  // 加载中
        case loadingFaiure  // 加载失败
    }
    
    public weak var delegate: CZImagePreviewerDelegate?
    public weak var dataSource: CZImagePreviewerDataSource?
    
    /// Cell 之间的间距
    public var spacingBetweenItem: CGFloat = 40
    
    public var hideStatusBar: Bool = false
    
    public var statusBarStyle: UIStatusBarStyle = .lightContent
    
    /// 通过DataSource协议返回的自定义控制层
    private var cus_console: UIView?
    
    /// 当前索引
    public private(set) var currentIdx = -1 {
        didSet {
            if oldValue != -1, oldValue != currentIdx {
                print("currentIdx = \(currentIdx)")
                self.updateConsole(for: currentIdx)
                // 通知代理
                self.delegate?.imagePreviewer(self, index: oldValue, didChangedTo: currentIdx)
            }
        }
    }
    
    @objc public var contentOffset: CGPoint { self.collectionView.contentOffset }
    
    /// display 转场动画处理
    lazy private var animatedTransitioning_display: AnimatedTransitioning = AnimatedTransitioning(transitionFor: .present)
    /// dismiss 转场动画处理
    lazy private var animatedTransitioning_dismiss: AnimatedTransitioning = AnimatedTransitioning(transitionFor: .dismiss)
    /// 记录图片弹出的容器, 用于 diaplay 时的动画
    private weak var imageTriggerContainer: UIView?
    
    private lazy var collectionViewFlowLayout: CZPreviewerFlowLayout = {
        let flowLayout = CZPreviewerFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .init(top: 0, left: self.spacingBetweenItem * 0.5, bottom: 0, right: self.spacingBetweenItem * 0.5)
        flowLayout.minimumLineSpacing = self.spacingBetweenItem
        flowLayout.itemSize = self.view.bounds.size
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionViewFlowLayout)
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(CZImagePreviewerCollectionViewCell.self, forCellWithReuseIdentifier: CZImagePreviewerCollectionViewCell.CollectionViewCellReuseID)
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    
    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapOnView(sender:)))
        return tap
    }()
    
    private lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panOnView(sender:)))
        pan.delegate = self
        return pan
    }()
    
    private lazy var doubleTap: UITapGestureRecognizer = {
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapOnView(sender:)))
        doubleTap.numberOfTapsRequired = 2
        return doubleTap
    }()
    
    private lazy var longPress: UILongPressGestureRecognizer = {
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressOnView(sender:)))
        return longPress
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationCapturesStatusBarAppearance = true    // 没有这一行的话, statusBar 不会隐藏
        self.modalPresentationStyle = .overFullScreen
        self.transitioningDelegate = self
    }
    
    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
//    deinit { print(self, "销毁了") }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalTo(UIEdgeInsets(top: 0, left: -spacingBetweenItem * 0.5, bottom: 0, right: -spacingBetweenItem * 0.5))
        }
        
        self.view.addGestureRecognizer(self.tap)
        self.view.addGestureRecognizer(self.pan)
        self.view.addGestureRecognizer(self.doubleTap)
        self.tap.require(toFail: self.doubleTap)
        self.view.addGestureRecognizer(self.longPress)
        
        self.collectionView.performBatchUpdates {
            self.scroll2Item(at: self.currentIdx, animated: false)
        } completion: { finish in
            // 首次展示时, 要求dataSource返回一个铺在视图顶部的控制视图
            self.updateConsole(for: self.currentIdx)
        }
        
    }
    
    public override var prefersStatusBarHidden: Bool { self.hideStatusBar }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle { self.statusBarStyle }
    
    var isPaning: Bool = false
    open override var shouldAutorotate: Bool {
        return !self.isPaning
    }
    
    // 记录旋转发生前的 idx, 以及记录当前是否正在旋转
    typealias RotatingInfo = (isRotating: Bool, indexBeforeRotate: Int)
    // 屏幕旋转事件发生时触发
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionViewFlowLayout.rotatingInfo = RotatingInfo(true, self.currentIdx)
        (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = size
        self.collectionView.collectionViewLayout.invalidateLayout()
        print(self.collectionView.visibleCells)
        coordinator.animate(alongsideTransition: nil) { context in
            self.collectionViewFlowLayout.rotatingInfo = RotatingInfo(false, self.currentIdx)
        }
    }
    
}

// MARK: Action
extension CZImagePreviewer {
    @objc func tapOnView(sender: UITapGestureRecognizer) {
        if !(self.delegate?.imagePreviewer(self, shouldDismissWithGesture: sender, at: self.currentIdx) ?? false) { return }
        let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CZImagePreviewerCollectionViewCell
        cell?.accessoryView?.isHidden = true
        self.cus_console?.isHidden = true
        self.dismiss()
    }
    
    @objc func longPressOnView(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.delegate?.imagePreviewer(self, didLongPressAtIndex: self.currentIdx)
        }
    }
    
    @objc func doubleTapOnView(sender: UITapGestureRecognizer) {
        let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CZImagePreviewerCollectionViewCell
        if cell?.zoomingScrollView.zoomScale != 1 {
            cell?.clearZooming()
        }else{
            let touchOn = sender.location(in: cell?.imageView)
            cell?.zoom(rect: CGRect(x: touchOn.x, y: touchOn.y, width: 1, height: 1))
        }
    }
    
    private static var animationActorDefaultSize: CGSize = .zero
    private static var animationActorDefaultCenter: CGPoint = .zero
    @objc func panOnView(sender: UIPanGestureRecognizer) {
        
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CZImagePreviewerCollectionViewCell else { return }
        let animationActor = cell.draginglyActor
        
        // 百分比
        let translationInView = sender.translation(in: self.view)
        var process = translationInView.y / self.view.bounds.size.height
        process = min(1.0, max(0.0, process))
        
        switch sender.state {
        case .began:
            Self.animationActorDefaultCenter = animationActor.center
            Self.animationActorDefaultSize = animationActor.frame.size
            self.cus_console?.isHidden = true
            cell.accessoryView?.isHidden = true
            self.isPaning = true
        case .changed:
            animationActor.frame.size = CGSize(width: Self.animationActorDefaultSize.width * (1 - process), height: Self.animationActorDefaultSize.height * (1 - process))
            animationActor.center = CGPoint(x: Self.animationActorDefaultCenter.x + translationInView.x, y: Self.animationActorDefaultCenter.y + translationInView.y)
            self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1 - process)
        case .ended, .cancelled:
            let velocity = sender.velocity(in: self.view)
            if velocity.y > 0 && (self.delegate?.imagePreviewer(self, shouldDismissWithGesture: sender, at: self.currentIdx) ?? true) {
                self.dismiss()
            }else{
                discardDismissOperation()
            }
        default:
            discardDismissOperation()
        }
        
        // 放弃 dismiss 操作
        func discardDismissOperation() {
            UIView.animate(withDuration: 0.3) {
                animationActor.frame.size = Self.animationActorDefaultSize
                animationActor.center = Self.animationActorDefaultCenter
                self.view.backgroundColor = .black
            } completion: { finish in
                self.cus_console?.isHidden = false
                cell.accessoryView?.isHidden = false
                self.isPaning = false
            }
        }
    }
}

extension CZImagePreviewer: UIGestureRecognizerDelegate {
    // 禁止 pan 手势和其他手势同时识别
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { false }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let velocity = pan.velocity(in: self.view)
        // 不响应上滑手势
        if velocity.y < 0 {
            return false
        }
        return true
    }
}

// MARK: public function
extension CZImagePreviewer {
    
    /// 展示方法
    /// - Parameters:
    ///   - container: 告知 Previewer 点击了哪个图片的容器以触发此方法的, 以便进行弹出 Previewer 的动画.
    ///   如为nil, 则通过默认的动画进行展示 Previewer
    ///   注意: 目前只支持 UIImageView 类型, 即使可以传入 UIView 及其子类, 但只对 UIImageView 做处理, 其他类型都只执行默认的动画
    ///   - index: 告知 Previewer 你点击的图片, 位于数据源的索引
    ///   - controller: 在哪个控制器进行模态弹框, 如 nil, 则在根控制器尝试弹框操作
    public func display(fromImageContainer container: UIView? = nil, presentingController: UIViewController? = nil, current index: Int = 0) {

        self.currentIdx = index
        
        self.delegate?.imagePreviewer(self, willDisplayAtIndex: index)
        let presentingController = presentingController ?? Self.topMostController
        presentingController?.present(self, animated: true, completion: {
            self.delegate?.imagePreviewer(self, didDisplayAtIndex: index)
        })
        
        self.imageTriggerContainer = container
    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CZImagePreviewerCollectionViewCell
        self.cus_console?.isHidden = true
        cell?.accessoryView?.isHidden = true
        self.dismiss(animated: true) {
            cell?.accessoryView?.isHidden = false
            self.cus_console?.isHidden = false
            self.delegate?.imagePreviewerDidDismiss(self)
            completion?()
        }
    }
    
    public func reloadData() {
        self.collectionView.reloadData()
    }
    
    public func deleteItems(at indexs: [Int]) {
        let idxPaths: [IndexPath] = indexs.compactMap { i in
            return IndexPath(item: i, section: 0)
        }
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: idxPaths)
        }, completion: { finish in
            // 删除完毕后更新 currentIdx
            self.currentIdx = Int((self.collectionView.contentOffset.x + self.collectionView.bounds.size.width * 0.5) / self.collectionView.bounds.size.width)
        })
    }
    
    public func scroll2Item(at index: Int, animated: Bool) {
        let x = CGFloat(index) * self.view.bounds.size.width + CGFloat(index) * self.spacingBetweenItem
        self.collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }
    
    /// 默认状态下, 视频层(videoView)位于图片层(zoomingScrollView)之上
    /// 此方法可使当前显示的cell隐藏视频层(videoView)
    /// 当这个 cell 被移出屏幕后, 此值会被重置到默认状态
    public func hideVideoViewAtCurrentItem() {
        let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CZImagePreviewerCollectionViewCell
        cell?.videoContainer.isHidden = true
    }
    
    /// 默认状态下, 视频层(videoView)位于图片层(zoomingScrollView)之上
    /// 此方法可使当前显示的cell隐藏图片层(zoomingScrollView)
    /// 当这个 cell 被移出屏幕后, 此值会被重置到默认状态
    public func hideImageViewAtCurrentItem() {
        let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CZImagePreviewerCollectionViewCell
        cell?.zoomingScrollView.isHidden = true
    }
    
}

// MARK: ScrollViewDelegate, CollectionViewDelegate, CollectionViewDataSource, UICollectionViewDataSourcePrefetching
extension CZImagePreviewer: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentIdx = Int((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CZImagePreviewerCollectionViewCell.CollectionViewCellReuseID, for: indexPath) as! CZImagePreviewerCollectionViewCell
        cell.delegate = self
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CZImagePreviewerCollectionViewCell else { return }
        // 从 dataSource 取得 数据
        let imgRes: CZImagePreviewerResource? = self.dataSource?.imagePreviewer(self, imageResourceForItemAtIndex: indexPath.item)
        cell.videoLayer = self.dataSource?.imagePreviewer(self, videoLayerForCell: cell, at: indexPath.item)
        cell.accessoryView = self.dataSource?.imagePreviewer(self, accessoryViewForCell: cell, at: indexPath.item)
        cell.item = PreviewerCellItem(resource: imgRes, idx: indexPath.item)
        self.dataSource?.imagePreviewer(self, videoSizeForCell: cell, at: indexPath.item, videoSizeSettingHandler: cell.videoSizeSettingHandler)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 在 cell 离开屏幕后, 重置其 zoomingScrollView 和 videoView 的隐藏状态. 默认是 图像层 不隐藏, 视频层 隐藏
        (cell as? CZImagePreviewerCollectionViewCell)?.videoContainer.isHidden = true
        (cell as? CZImagePreviewerCollectionViewCell)?.zoomingScrollView.isHidden = false
    }
    
    /// 数据预加载
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { idxPath in
            let imgRes: CZImagePreviewerResource? = self.dataSource?.imagePreviewer(self, imageResourceForItemAtIndex: idxPath.item)
            imgRes?.loadImage(progress: nil, completion: nil)
        }
    }
    
}

/// MARK: PreviewerCellViewControllerDelegate
extension CZImagePreviewer: CollectionViewCellDelegate {
    
    // CellModel 负责下载图片, 下载图片进度反馈
    func collectionViewCell(_ cell: CZImagePreviewerCollectionViewCell, resourceLoadingStateDidChanged state: ImageLoadingState, idx: Int, accessoryView: CZImagePreviewerAccessoryView?) {
        self.dataSource?.imagePreviewer(self, imageLoadingStateDidChanged: state, at: idx, accessoryView: cell.accessoryView)
    }
    
}

// MARK: Helper
extension CZImagePreviewer {
    
    /// UIApplication.shared.keyWindow 方法已过期, 定义这个方法快速找到 keyWindow
    static var keyWindow: UIWindow? {
        var keyWindow: UIWindow? = nil
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
            for window in windowScene.windows where window.isKeyWindow {
                keyWindow = window
            }
        } else {
            keyWindow = UIApplication.shared.keyWindow
        }
        return keyWindow
    }
    
    static var topMostController: UIViewController? {
        
        func lambda(viewController: UIViewController?) -> UIViewController? {
            
            if let presentedViewController = viewController?.presentedViewController {
                return lambda(viewController: presentedViewController)
            }
            
            // UITabBarController
            if let tabBarController = viewController as? UITabBarController,
               let selectedViewController = tabBarController.selectedViewController {
                return lambda(viewController: selectedViewController)
            }
            
            // UINavigationController
            if let navigationController = viewController as? UINavigationController,
               let visibleViewController = navigationController.visibleViewController {
                return lambda(viewController: visibleViewController)
            }
            
            // UIPageController
            if let pageViewController = viewController as? UIPageViewController,
               pageViewController.viewControllers?.count == 1 {
                return lambda(viewController: pageViewController.viewControllers?.first)
            }
            
            // child view controller
            for subview in viewController?.view?.subviews ?? [] {
                if let childViewController = subview.next as? UIViewController {
                    return lambda(viewController: childViewController)
                }
            }
            
            return viewController
        }
        
        let rootViewController = Self.keyWindow?.rootViewController
        let ret: UIViewController? = lambda(viewController: rootViewController)
        
        return ret
    }
    
    // 更新 self.cus_console
    func updateConsole(for index: Int) {
        guard let console = self.dataSource?.imagePreviewer(self, consoleForItemAtIndex: index) else { return }
        if self.cus_console === console { return }
        // 先移除
        self.cus_console?.removeFromSuperview()
        // 再添加
        self.view.addSubview(console)
        self.cus_console = console
        console.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

// MARK: UIViewControllerTransitioningDelegate
extension CZImagePreviewer: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? { self.animatedTransitioning_display }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? { self.animatedTransitioning_dismiss }
}

// MARK: UIViewControllerAnimatedTransitioning
extension CZImagePreviewer: AnimatedTransitioningContentProvider {
    
    // 提供一个视图, 作为展示时的转场动画发生时的动画元素
    func transitioningElementForDisplay(animatedTransitioning: AnimatedTransitioning) -> ElementForDisplayTransition {
        let imgRes = self.dataSource?.imagePreviewer(self, imageResourceForItemAtIndex: self.currentIdx)
        return ElementForDisplayTransition(self.imageTriggerContainer, imgRes)
    }
    
    func transitioningElementForDismiss(animatedTransitioning: AnimatedTransitioning) -> ElementForDismissTransition {
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CZImagePreviewerCollectionViewCell else {
            return (nil, nil)
        }
        guard let container = self.delegate?.imagePreviewer(self, willDismissWithCell: cell, at: self.currentIdx) else {
            return (nil, nil)
        }
        return ElementForDismissTransition(container, cell.draginglyActor)
    }

}
