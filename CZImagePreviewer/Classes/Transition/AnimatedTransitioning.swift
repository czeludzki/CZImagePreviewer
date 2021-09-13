//
//  DismissTransition.swift
//  Pods-CZImagePreviewer_Example
//
//  Created by siu on 2021/9/11.
//

import UIKit
import SDWebImage

// MARK: 要求遵守了此协议的实例提供一个视图, 在转场动画发生时展示
protocol AnimatedTransitioningContentProvider: UIViewController {

    /// 要求取得展示时的转场关键元素
    typealias ElementForTransition = (container: UIView?, resource: ResourceProtocol?)
    
    func transitioningElementForDisplay(animatedTransitioning: AnimatedTransitioning) -> ElementForTransition
    func transitioningElementForDismiss(animatedTransitioning: AnimatedTransitioning) -> UIView?
}

class AnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum For {
        case present
        case dismiss
    }
    
    var transitionFor: For
    
    init(transitionFor: For) {
        self.transitionFor = transitionFor
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 0.3 }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if self.transitionFor == .dismiss {
            self.dismiss(transitionContext)
        }
        
        if self.transitionFor == .present {
            self.present(transitionContext)
        }
    }
    
    func present(_ transitionContext: UIViewControllerContextTransitioning) {
        
        guard let keyWindow = CZImagePreviewer.keyWindow,
              let toView = transitionContext.view(forKey: .to),
              let toVC = transitionContext.viewController(forKey: .to) as? AnimatedTransitioningContentProvider,
              let elementContainer = toVC.transitioningElementForDisplay(animatedTransitioning: self).container,
              let elementResource = toVC.transitioningElementForDisplay(animatedTransitioning: self).resource
        else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        toView.frame = transitionContext.containerView.bounds
        transitionContext.containerView.addSubview(toView)
        // 计算 targetContainer 在keyWindow中的位置
        let targetFrame = elementContainer.convert(elementContainer.bounds, to: keyWindow)
        // 如果该视图不在屏幕中, 执行 planB 动画
        if !keyWindow.bounds.contains(targetFrame) {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        // 创建 UIImageView 作为动画关键元素
        let imageView = UIImageView.init(frame: .zero)
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        
        // UIImageView 加载图片
        elementResource.loadImage(progress: nil, completion: { img, _, _, _, _, _ in
            imageView.image = img
        })
        
        // 计算图片以 scaleAspectFiting 的模式显示在屏幕上的实际大小
        let scaleAspectFitingSize = imageView.image?.asImgRes.scaleAspectFiting(toSize: transitionContext.containerView.bounds.size)
        transitionContext.containerView.addSubview(imageView)
        // 将触发视图frame赋值到imageView
        imageView.frame = targetFrame
        toView.isHidden = true
        transitionContext.containerView.backgroundColor = .clear
        // 开始动画
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext)) {
            imageView.frame = CGRect.init(origin: CGPoint.zero, size: scaleAspectFitingSize ?? transitionContext.containerView.bounds.size)
            imageView.center = transitionContext.containerView.center
            transitionContext.containerView.backgroundColor = .black
        } completion: { finish in
            toView.isHidden = false
            imageView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
    
    func dismiss(_ transitionContext: UIViewControllerContextTransitioning) {
                
        guard let keyWindow = CZImagePreviewer.keyWindow,
              let toVC = transitionContext.viewController(forKey: .to),
              let fromView = transitionContext.view(forKey: .from),
              let fromVC = transitionContext.viewController(forKey: .from) as? AnimatedTransitioningContentProvider,
              let back2Container = fromVC.transitioningElementForDismiss(animatedTransitioning: self),
              let animationElement = fromView.snapshotView(afterScreenUpdates: true)
        else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        fromView.isHidden = true
        // 计算 back2Container 在屏幕中的位置
        let targetFrame = back2Container.convert(back2Container.bounds, to: keyWindow)
        transitionContext.containerView.addSubview(animationElement)
        animationElement.frame = transitionContext.containerView.bounds
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext)) {
            animationElement.frame = targetFrame
        } completion: { finish in
            animationElement.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
    
}
