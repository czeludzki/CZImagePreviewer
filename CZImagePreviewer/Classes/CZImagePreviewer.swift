//
//  CZImagePreviewer.swift
//  CZImagePreviewer
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import SnapKit

open class CZImagePreviewer: UIViewController {
    
    public weak var delegate: PreviewerDelegate?
    public var dataSource: PreviewerDataSource?
    
    /// Cell 之间的间距
    public var spacingBetweenItem: CGFloat = 20.0
    
    /// 通过DataSource协议返回的自定义控制层
    private var cus_console: UIView?
    
    /// 当前索引
    public private(set) var currentIdx = -1 {
        didSet {
            if oldValue != currentIdx {
                // 当 currentIndex 发生改变, 尝试更新 self.cus_console 视图
                self.updateConsole()
                // 通知代理
                self.delegate?.imagePreviewer(self, currentIndexDidChange: currentIdx)
            }
        }
    }
    
    /// display 转场动画处理
    lazy private var animatedTransitioning_display: AnimatedTransitioning = AnimatedTransitioning(transitionFor: .present)
    /// dismiss 转场动画处理
    lazy private var animatedTransitioning_dismiss: AnimatedTransitioning = AnimatedTransitioning(transitionFor: .dismiss)
    /// 记录图片弹出的容器, 用于展示时的动画
    private weak var imageTriggerContainer: UIView?
    
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
        collectionView.backgroundColor = .clear
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
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
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
        self.view.addGestureRecognizer(self.pan)
        self.view.addGestureRecognizer(self.doubleTap)
        self.tap.require(toFail: self.doubleTap)
        self.view.addGestureRecognizer(self.longPress)
    }
    
    /// collectionView在展示后需要将 contentOffset.x 设置为跟 self.currentIdx 同步, 此值用于记录 collectionView 当前展示的页是否已跟 self.currentIdx 已同步
    var didSynchronizedCurrentIdx = false
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.didSynchronizedCurrentIdx { return }
        self.scroll2Item(at: self.currentIdx, animated: false)
        self.didSynchronizedCurrentIdx = true
    }
    
    public override var prefersStatusBarHidden: Bool { true }
    
    var isPaning: Bool = false
    open override var shouldAutorotate: Bool {
        return !self.isPaning
    }
    
    // 屏幕旋转事件发生时触发
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let mark_idx = self.currentIdx
        self.collectionView.layer.anchorPoint = CGPoint(x: self.collectionView.contentOffset.x / self.collectionView.contentSize.width, y: 0.5)
        self.collectionView.performBatchUpdates {
            self.collectionView.reloadData()
        } completion: { finish in
            self.scroll2Item(at: mark_idx, animated: false)
//            self.collectionView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
        // 旋转时执行, 将 rotateAnimationImageView.isHidden 设为 false, 且为其设置图片
//        self.executeWhenRotate(idx: mark_idx, coordinator: coordinator)
    }
    
}

// MARK: Action
extension CZImagePreviewer {
    @objc func tapOnView(sender: UITapGestureRecognizer) {
        let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CollectionViewCell
        cell?.cellModel.accessoryView?.isHidden = true
        self.cus_console?.isHidden = true
        self.dismiss()
    }
    
    @objc func longPressOnView(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.delegate?.imagePreviewer(self, didLongPressAtIndex: self.currentIdx)
        }
    }
    
    @objc func doubleTapOnView(sender: UITapGestureRecognizer) {
        let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CollectionViewCell
        if cell?.zoomingScrollView.zoomScale != 1 {
            cell?.cellModel.clearZooming()
        }else{
            let touchOn = sender.location(in: cell?.imageView)
            cell?.cellModel.zoom(rect: CGRect(x: touchOn.x, y: touchOn.y, width: 1, height: 1))
        }
    }
    
    private static var animationActorDefaultSize: CGSize = .zero
    private static var animationActorDefaultCenter: CGPoint = .zero
    @objc func panOnView(sender: UIPanGestureRecognizer) {
        
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CollectionViewCell else { return }
        let animationActor = cell.cellModel.dismissAnimationActor
        
        // 百分比
        let translationInView = sender.translation(in: self.view)
        var process = translationInView.y / self.view.bounds.size.height
        process = min(1.0, max(0.0, process))
        
        switch sender.state {
        case .began:
            Self.animationActorDefaultCenter = animationActor.center
            Self.animationActorDefaultSize = animationActor.frame.size
            self.cus_console?.isHidden = true
            cell.cellModel.accessoryView?.isHidden = true
            self.isPaning = true
        case .changed:
            animationActor.frame.size = CGSize(width: Self.animationActorDefaultSize.width * (1 - process), height: Self.animationActorDefaultSize.height * (1 - process))
            animationActor.center = CGPoint(x: Self.animationActorDefaultCenter.x + translationInView.x, y: Self.animationActorDefaultCenter.y + translationInView.y)
            self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1 - process)
        case .ended, .cancelled:
            let velocity = sender.velocity(in: self.view)
            if velocity.y > 0 {
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
                cell.cellModel.accessoryView?.isHidden = false
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
    public func display(fromImageContainer container: UIView? = nil, current index: Int = 0) {

        self.currentIdx = index
        
        let presentingController = Self.topMostController
        presentingController?.present(self, animated: true, completion: nil)
        
        self.imageTriggerContainer = container
    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true) {
            let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CollectionViewCell
            cell?.cellModel.accessoryView?.isHidden = false
            self.cus_console?.isHidden = false
            completion?()
        }
    }
    
    public func reloadData() {
        self.collectionView.reloadData()
    }
    
}

// MARK: ScrollViewDelegate, CollectionViewDelegate, CollectionViewDataSource, UICollectionViewDataSourcePrefetching
extension CZImagePreviewer: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.didSynchronizedCurrentIdx { return }    // 在非竖屏的情况下, collectionView 被添加到 superView 以后, 会马上调用 scrollViewDidScroll 方法, 导致 self.currentIdx 出错, 所以做此判断
        self.currentIdx = Int((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 从 dataSource 取得 数据
        let imgRes: ResourceProtocol? = self.dataSource?.imagePreviewer(self, imageResourceForItemAtIndex: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.CollectionViewCellReuseID, for: indexPath) as! CollectionViewCell
        cell.cellModel.delegate = self
        cell.cellModel.item = PreviewerCellItem(resource: imgRes, idx: indexPath.item)
        cell.cellModel.videoLayer = self.dataSource?.imagePreviewer(self, videoLayerForCellWith: cell.cellModel)
        cell.cellModel.accessoryView = self.dataSource?.imagePreviewer(self, accessoryViewForCellWith: cell.cellModel)
        self.dataSource?.imagePreviewer(self, videoSizeForCellWith: cell.cellModel, videoSizeSettingHandler: cell.cellModel.videoSizeSettingHandler!)
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
        self.dataSource?.imagePreviewer(self, imageLoadingStateDidChanged: state, with: viewModel)
    }
}

// MARK: Helper
extension CZImagePreviewer {
    
    /// UIApplication.shared.keyWindow 方法已过期, 定义这个方法快速找到 keyWindow
    static var keyWindow: UIWindow? {
        var keyWindow: UIWindow? = nil
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        for window in windowScene.windows where window.isKeyWindow {
            keyWindow = window
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
    
    func scroll2Item(at index: Int, animated: Bool) {
        let x = CGFloat(index) * self.view.bounds.size.width + CGFloat(index) * self.spacingBetweenItem
        self.collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }
    
    // 在对比了微信的图片浏览后, 发现微信的图片浏览器在屏幕旋转事件发生时, 微信为了旋转动画的流畅和质量, 会在顶层覆盖一个独立的 Image 视图展示旋转, 旋转完成后再将其移除
    func executeWhenRotate(idx: Int, coordinator: UIViewControllerTransitionCoordinator) {
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: idx, section: 0)) as? CollectionViewCell else { return }
        // 把 Cell 从 collectionView 中取出来, 放到 self.view
        let originalFrame = cell.frame
        let originalSuperView = cell.superview
        self.view.addSubview(cell)
        cell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // 旋转动画完成后, 恢复原来的显示
        coordinator.animate(alongsideTransition: nil) { transitionCoordinatorContext in
            originalSuperView?.addSubview(cell)
            originalSuperView?.frame = originalFrame
        }
    }
    
    // 更新 self.cus_console
    func updateConsole() {
        guard let console = self.dataSource?.imagePreviewer(self, consoleForItemAtIndex: self.currentIdx) else { return }
        if self.cus_console === console { return }
        // 先移除
        self.cus_console?.removeFromSuperview()
        // 再添加
        console._viewType = .console
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
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: self.currentIdx, section: 0)) as? CollectionViewCell else {
            return (nil, nil)
        }
        guard let container = self.delegate?.imagePreviewer(self, willDismissWithCellViewModel: cell.cellModel) else {
            return (nil, nil)
        }
        return ElementForDismissTransition(container, cell.cellModel.dismissAnimationActor)
    }

}
