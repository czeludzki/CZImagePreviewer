//
//  CZImagePreviewer.swift
//  CZImagePreviewer
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import SnapKit

public class CZImagePreviewer: UIViewController {
    
    public weak var delegate: CZImagePreviewerDelegate?
    public var dataSource: CZImagePreviewerDataSource?
    
    public var currentIdx = 0
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CZImagePreviewerCollectionViewCell.self, forCellWithReuseIdentifier: CZImagePreviewerCollectionViewCell.CZImagePreviewerCollectionViewCellReuseID)
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.view.addGestureRecognizer(self.tap)
    }
    
    public override var prefersStatusBarHidden: Bool { true }
}

// MARK: Action
extension CZImagePreviewer {
    @objc func tapOnView(sender: UITapGestureRecognizer) {
        self.dismiss()
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

extension CZImagePreviewer: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imgRes: ImageResourceProtocol? = self.dataSource?.imagePreviewer(self, atIndex: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CZImagePreviewerCollectionViewCell.CZImagePreviewerCollectionViewCellReuseID, for: indexPath) as! CZImagePreviewerCollectionViewCell
        cell.imageResource = imgRes
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        UIScreen.main.bounds.size
    }
}
