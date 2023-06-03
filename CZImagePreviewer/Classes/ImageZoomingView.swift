//
//  ImageScrollView.swift
//  CZImagePreviewer_Example
//
//  Created by siu on 2023/5/31.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

public protocol ImageZoomingViewTarget: UIView {
    var contentSize: CGSize? { get }
    func imageZoomingView(_ view: ImageZoomingView, maximumZoomScaleDidUpdate scale: CGFloat)
}

public extension ImageZoomingViewTarget {
    func imageZoomingView(_ view: ImageZoomingView, maximumZoomScaleDidUpdate scale: CGFloat) {}
}

public class ImageZoomingView: UIView {
    
    lazy var scrollView: UIScrollView = {
        let res = UIScrollView.init()
        res.showsVerticalScrollIndicator = false
        res.showsHorizontalScrollIndicator = false
        res.bounces = true
        res.clipsToBounds = false
        res.backgroundColor = UIColor.clear
        res.alwaysBounceVertical = false
        res.alwaysBounceHorizontal = false
        res.contentInsetAdjustmentBehavior = .never
        res.delegate = self
        return res
    }()
    
    let target: ImageZoomingViewTarget
    
    public init(_ target: ImageZoomingViewTarget) {
        self.target = target
        super.init(frame: .zero)
        self.scrollView.addSubview(target)
        self.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateScrollViewConfiguration()
    }
    
    func clearZooming(animate: Bool = true) {
        self.scrollView.setZoomScale(1, animated: animate)
    }
    
    func zoom(to: CGRect, animated: Bool) {
        self.scrollView.zoom(to: to, animated: animated)
    }
}

extension ImageZoomingView {
    /// 更新 zoomingScroll 的配置
    func updateScrollViewConfiguration() {
        
        guard let targetContentSize = self.target.contentSize else {
            self.scrollView.minimumZoomScale = 1
            self.scrollView.maximumZoomScale = 1
            self.scrollView.setZoomScale(1, animated: false)
            return
        }
        
        let screenSize = UIScreen.main.bounds.size
        self.scrollView.contentSize = targetContentSize
        
        // 不缩放的情况下, 图片在屏幕上的大小
        let imageFitingSizeInScreen: CGSize = targetContentSize.scaleAspectFiting(toSize: screenSize)
        
        self.target.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: imageFitingSizeInScreen.width, height: imageFitingSizeInScreen.height))
        self.target.center = CGPoint.init(x: screenSize.width * 0.5, y: screenSize.height * 0.5)
        
        // 计算最大/最小缩放
        self.scrollView.minimumZoomScale = 1
        let maxZoomScale = (targetContentSize.height * targetContentSize.width) / (imageFitingSizeInScreen.width * imageFitingSizeInScreen.height)
        self.scrollView.maximumZoomScale = maxZoomScale > 1 ? maxZoomScale : 2
        
        self.target.imageZoomingView(self, maximumZoomScaleDidUpdate: self.scrollView.maximumZoomScale)
        
        // 初始缩放系数
        self.scrollView.setZoomScale(1, animated: false)
        self.layoutIfNeeded()
    }
    
    // 使 scrollView 中的内容保持居中
    func keepCentral() {
        let scrollW = UIScreen.main.bounds.width
        let scrollH = UIScreen.main.bounds.height
        
        let contentSize = self.scrollView.contentSize
        let offsetX = scrollW > contentSize.width ? (scrollW - contentSize.width) * 0.5 : 0
        let offsetY = scrollH > contentSize.height ? (scrollH - contentSize.height) * 0.5 : 0
        
        let centerX = contentSize.width * 0.5 + offsetX
        let centerY = contentSize.height * 0.5 + offsetY
        
        self.target.center = CGPoint(x: centerX, y: centerY)
    }
}

extension ImageZoomingView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? { self.target }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.keepCentral()
    }
}
