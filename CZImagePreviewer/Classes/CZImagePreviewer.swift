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
    public var spacingBetweenItem = 20.0
    
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
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.CollectionViewCellReuseID)
        return collectionView
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
        NotificationCenter.default.addObserver(forName: NSNotification.Name.didChangeStatusBarOrientationNotification?, object: nil, queue: nil) {
            $0
        }
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
        self.view.addGestureRecognizer(self.tap)
    }
    
    var didSetInitialIdx = false
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.didSetInitialIdx { return }
        self.collectionView.scrollToItem(at: IndexPath(item: self.currentIdx, section: 0), at: .left, animated: false)
        self.didSetInitialIdx = true
    }
    
    public override var prefersStatusBarHidden: Bool { true }
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
extension CZImagePreviewer: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 从 dataSource 取得 数据
        let imgRes: ResourceProtocol? = self.dataSource?.imagePreviewer(self, imageResourceForItemAtIndex: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.CollectionViewCellReuseID, for: indexPath) as! CollectionViewCell
        cell.cellModel.delegate = self
        cell.cellModel.item = PreviewerCellItem(resource: imgRes, idx: indexPath.item)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        UIScreen.main.bounds.size
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentIdx = Int((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width)
    }
}

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

