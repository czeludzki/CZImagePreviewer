//
//  CZImagePreviewer.swift
//  CZImagePreviewer
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import SnapKit
import Kingfisher

open class Previewer: UIViewController {
    
    public enum ImageLoadingState {
        case `default`  // 正常可预览状态
        case loading(receivedSize: Int64, expectedSize: Int64)  // 加载中
        case loadingFaiure  // 加载失败
    }
    
    public weak var delegate: Delegate?
    public weak var dataSource: DataSource?
    
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
                self.updateConsole(for: currentIdx)
                // 通知代理
                self.delegate?.imagePreviewer(self, indexDidChangedTo: currentIdx, fromOldIndex: oldValue)
            }
        }
    }
    
    @objc public var contentOffset: CGPoint { self.collectionView.contentOffset }
    
    /// display 转场动画处理
    lazy private var animatedTransitioning_display: AnimatedTransitioning = AnimatedTransitioning(transitionFor: .present)
    /// dismiss 转场动画处理
    lazy private var animatedTransitioning_dismiss: AnimatedTransitioning = AnimatedTransitioning(transitionFor: .dismiss)
    
    /// 记录图片弹出的容器, 用于 diaplay 时的动画
    private weak var triggerContainer: UIView?
    /// display 动画发生时需要的图片资源
    private var triggerSource: UIImage?
    
    private(set) lazy var collectionViewFlowLayout: CollectionViewFlowLayout = {
        let flowLayout = CollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .init(top: 0, left: self.spacingBetweenItem * 0.5, bottom: 0, right: self.spacingBetweenItem * 0.5)
        flowLayout.minimumLineSpacing = self.spacingBetweenItem
        flowLayout.itemSize = self.view.bounds.size
        return flowLayout
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionViewFlowLayout)
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(CZImagePreviewer.VideoResourceCollectionViewCell.self, forCellWithReuseIdentifier: CZImagePreviewer.VideoResourceCollectionViewCell.description())
        collectionView.register(CZImagePreviewer.ImageResourceCollectionViewCell.self, forCellWithReuseIdentifier: CZImagePreviewer.ImageResourceCollectionViewCell.description())
        return collectionView
    }()
    
    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnView(sender:)))
        return tap
    }()
    
    // 在 pan 事件发生时, 记录 actor 原来的 size 及 position
    private var animationActorDefaultSize: CGSize = .zero
    private var animationActorDefaultCenter: CGPoint = .zero
    private lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.panOnView(sender:)))
        pan.delegate = self
        return pan
    }()
    
    private lazy var doubleTap: UITapGestureRecognizer = {
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(self.doubleTapOnView(sender:)))
        doubleTap.numberOfTapsRequired = 2
        return doubleTap
    }()
    
    private lazy var longPress: UILongPressGestureRecognizer = {
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(self.longPressOnView(sender:)))
        return longPress
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.transitioningDelegate = self
        self.modalPresentationCapturesStatusBarAppearance = true    // 没有这一行的话, statusBar 不会隐藏
        self.modalPresentationStyle = .overFullScreen
    }
    
    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
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
        coordinator.animate(alongsideTransition: nil) { context in
            self.collectionViewFlowLayout.rotatingInfo = RotatingInfo(false, self.currentIdx)
        }
    }
        
}

// MARK: Action
extension Previewer {
    @objc func tapOnView(sender: UITapGestureRecognizer) {
        if !(self.delegate?.imagePreviewer(self, shouldDismissWithGesture: sender, at: self.currentIdx) ?? false) { return }
        let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CZImagePreviewer.CollectionViewCell
        cell?.accessoryView?.isHidden = true
        self.cus_console?.isHidden = true
        self.dismiss(animated: true)
    }
    
    @objc func longPressOnView(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.delegate?.imagePreviewer(self, didLongPressAtIndex: self.currentIdx)
        }
    }
    
    @objc func doubleTapOnView(sender: UITapGestureRecognizer) {
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CZImagePreviewer.ImageResourceCollectionViewCell else { return }
        if cell.zoomingView.scrollView.zoomScale != 1 {
            cell.zoomingView.clearZooming()
        }else{
            let touchOn = sender.location(in: cell.zoomingView.target)
            cell.zoomingView.zoom(to: .init(x: touchOn.x, y: touchOn.y, width: 100, height: 100), animated: true)
        }
    }
    
    @objc func panOnView(sender: UIPanGestureRecognizer) {
        
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CZImagePreviewer.CollectionViewCell else { return }
        let animationActor = cell.dragingActor ?? cell.contentView
        
        // 百分比
        let translationInView = sender.translation(in: self.view)
        var process = translationInView.y / self.view.bounds.size.height
        process = min(1.0, max(0.0, process))
        
        switch sender.state {
        case .began:
            self.animationActorDefaultCenter = animationActor.center
            self.animationActorDefaultSize = animationActor.frame.size
            self.cus_console?.isHidden = true
            cell.accessoryView?.isHidden = true
            cell.isDismissGustureDraging = true
            self.isPaning = true
        case .changed:
            animationActor.frame.size = CGSize(width: self.animationActorDefaultSize.width * (1 - process), height: self.animationActorDefaultSize.height * (1 - process))
            animationActor.center = CGPoint(x: self.animationActorDefaultCenter.x + translationInView.x, y: self.animationActorDefaultCenter.y + translationInView.y)
            self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1 - process)
        case .ended:
            cell.isDismissGustureDraging = false
            let velocity = sender.velocity(in: self.view)
            if velocity.y > 0 && (self.delegate?.imagePreviewer(self, shouldDismissWithGesture: sender, at: self.currentIdx) ?? true) {
                self.dismiss(animated: true)
            }else{
                discardDismissOperation()
            }
        default:
            discardDismissOperation()
        }
        
        // 放弃 dismiss 操作
        func discardDismissOperation() {
            cell.isDismissGustureDraging = false
            UIView.animate(withDuration: 0.3) {
                animationActor.frame.size = self.animationActorDefaultSize
                animationActor.center = self.animationActorDefaultCenter
                self.view.backgroundColor = .black
            } completion: { finish in
                self.cus_console?.isHidden = false
                cell.accessoryView?.isHidden = false
                self.isPaning = false
            }
        }
    }
}

extension Previewer: UIGestureRecognizerDelegate {
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
extension Previewer {
    
    /// 展示方法
    /// - Parameters:
    ///   - container: 告知 Previewer 点击了哪个图片的容器以触发此方法的, 以便进行弹出 Previewer 的动画.
    ///   如为nil, 则通过默认的动画进行展示 Previewer
    ///   - fromSource: 在展示动画发生时, 为了避免一些大图或网络资源加载较慢导致卡顿, 可选择手动展示动画需要的图片.
    ///   如果传 nil, 则根据传入的 current index 从 dataSource 中获取执行动画时需要的资源
    ///   - index: 告知 Previewer 你点击的图片, 位于数据源的索引
    ///   - controller: 在哪个控制器进行模态弹框, 如 nil, 则在根控制器尝试弹框操作
    public func display(fromImageContainer container: UIView? = nil, fromSource source: UIImage? = nil, presentingController: UIViewController? = nil, current index: Int = 0) {
        
        self.currentIdx = index
        
        self.delegate?.imagePreviewer(self, willDisplayAtIndex: index)
        let presentingController = presentingController ?? Self.topMostController
        presentingController?.present(self, animated: true, completion: {
            self.delegate?.imagePreviewer(self, didDisplayAtIndex: index)
        })
        
        self.triggerSource = source
        self.triggerContainer = container
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CZImagePreviewer.CollectionViewCell
        self.cus_console?.isHidden = true
        cell?.accessoryView?.isHidden = true
        super.dismiss(animated: flag) {
            cell?.didEndDisplay()
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
            // 删除操作完成
            self.delegate?.imagePreviewer(self, didFinishDeletedItems: indexs)
        })
    }
    
    public func scroll2Item(at index: Int, animated: Bool) {
        let x = CGFloat(index) * self.view.bounds.size.width + CGFloat(index) * self.spacingBetweenItem
        self.collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }
    
}

// MARK: ScrollViewDelegate, CollectionViewDelegate, CollectionViewDataSource, UICollectionViewDataSourcePrefetching
extension Previewer: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentIdx = Int((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let resourceProvider = self.dataSource?.imagePreviewer(self, resourceForItemAtIndex: indexPath.item)
        var cell: CollectionViewCell?
        if let resourceProvider = resourceProvider as? CZImagePreviewer.ImageProvider {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CZImagePreviewer.ImageResourceCollectionViewCell.description(), for: indexPath) as! CZImagePreviewer.ImageResourceCollectionViewCell
            cell?.item = CellItem(resource: resourceProvider, idx: indexPath.item)
        }
        if let resourceProvider = resourceProvider as? CZImagePreviewer.VideoProvider {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CZImagePreviewer.VideoResourceCollectionViewCell.description(), for: indexPath) as! CZImagePreviewer.VideoResourceCollectionViewCell
            cell?.item = CellItem(resource: resourceProvider, idx: indexPath.item)
        }
        cell?.delegate = self
        return cell!
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CollectionViewCell else { return }
        cell.willDisplay()
        // 获取辅助视图
        cell.accessoryView = self.dataSource?.imagePreviewer(self, accessoryViewForCell: cell, at: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CZImagePreviewer.CollectionViewCell else { return }
        cell.didEndDisplay()
    }
    
    /// 数据预加载
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            let resource: ResourceProvider? = self.dataSource?.imagePreviewer(self, resourceForItemAtIndex: $0.item)
            if let resource = resource as? VideoProvider {
                resource.perload()
            }
            if let resource = resource as? ImageProvider {
                resource.loadImage(options: nil, progress: nil, completion: nil)
            }
        }
    }
    
}

/// MARK: PreviewerCellViewControllerDelegate
extension Previewer: CollectionViewCellDelegate {
    
    // CellModel 负责下载图片, 下载图片进度反馈
    func collectionViewCell(_ cell: CZImagePreviewer.CollectionViewCell, resourceLoadingStateDidChanged state: ImageLoadingState, idx: Int, accessoryView: AccessoryView?) {
        self.dataSource?.imagePreviewer(self, imageLoadingStateDidChanged: state, at: idx, accessoryView: cell.accessoryView)
    }
    
}

// MARK: Helper
extension Previewer {
    
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
extension Previewer: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animatedTransitioning_display
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animatedTransitioning_dismiss
    }
}

// MARK: UIViewControllerAnimatedTransitioning
extension Previewer: AnimatedTransitioningContentProvider {
    
    // 提供一个视图, 作为展示时的转场动画发生时的动画元素
    func transitioningElementForDisplay(animatedTransitioning: AnimatedTransitioning) -> ElementForDisplayTransition {
        let resource = self.dataSource?.imagePreviewer(self, resourceForItemAtIndex: self.currentIdx)
        var imageProvider: ImageProvider? = resource as? ImageProvider
        if let triggerSource = self.triggerSource {
            imageProvider = triggerSource
        }
        return ElementForDisplayTransition(self.triggerContainer, imageProvider)
    }
    
    func transitioningElementForDismiss(animatedTransitioning: AnimatedTransitioning) -> ElementForDismissTransition {
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CZImagePreviewer.CollectionViewCell else {
            return (nil, nil)
        }
        guard let container = self.delegate?.imagePreviewer(self, willDismissWithCell: cell, at: self.currentIdx) else {
            return (nil, nil)
        }
        return ElementForDismissTransition(container, cell.dragingActor)
    }

}
