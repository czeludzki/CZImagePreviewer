//
//  DismissTransition.swift
//  Pods-CZImagePreviewer_Example
//
//  Created by siu on 2021/9/11.
//

import UIKit
import Kingfisher

// MARK: 要求遵守了此协议的实例提供一个视图, 在转场动画发生时展示
protocol AnimatedTransitioningContentProvider: UIViewController {

    /// 要求取得展示时的转场关键元素
    typealias ElementForDisplayTransition = (container: UIView?, resource: CZImagePreviewerResource?)
    func transitioningElementForDisplay(animatedTransitioning: AnimatedTransitioning) -> ElementForDisplayTransition
    
    /// 要求取得消失时的转场关键元素
    typealias ElementForDismissTransition = (container: UIView?, animationActor: UIView?)
    func transitioningElementForDismiss(animatedTransitioning: AnimatedTransitioning) -> ElementForDismissTransition
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
              let elementResource = toVC.transitioningElementForDisplay(animatedTransitioning: self).resource
        else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        toView.frame = transitionContext.containerView.bounds
        transitionContext.containerView.addSubview(toView)
        
        guard let elementContainer = toVC.transitioningElementForDisplay(animatedTransitioning: self).container else {
            toView.alpha = 0
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut) {
                toView.alpha = 1
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            return
        }

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
        imageView.contentMode = .scaleAspectFit
        
        // UIImageView 加载图片
        elementResource.loadImage(progress: nil) { success, image in
            imageView.image = image
        }
        
        // 计算图片以 scaleAspectFiting 的模式显示在屏幕上的实际大小
        let scaleAspectFitingSize = imageView.image?.size.scaleAspectFiting(toSize: transitionContext.containerView.bounds.size)
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
            transitionContext.containerView.backgroundColor = .clear
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
    
    func dismiss(_ transitionContext: UIViewControllerContextTransitioning) {
        
        guard let keyWindow = CZImagePreviewer.keyWindow,
              let fromVC = transitionContext.viewController(forKey: .from) as? AnimatedTransitioningContentProvider,
              let back2Container = fromVC.transitioningElementForDismiss(animatedTransitioning: self).container,  // 动画要返回到哪个容器, 主要是为了得到其在 keywindow 上的相对定位
              let animationActor = fromVC.transitioningElementForDismiss(animatedTransitioning: self).animationActor  // 动画要素
        else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        // 计算 back2Container 在屏幕中的位置
        var targetFrame = back2Container.convert(back2Container.bounds, to: keyWindow)
        if !keyWindow.bounds.contains(targetFrame) {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        // 对 targetFrame 进行微调, 防止当 animationActor.superview 是 scrollView 时, targetFrame.origin 不准确
        targetFrame.origin.x += animationActor.superview?.bounds.origin.x ?? 0
        targetFrame.origin.y += animationActor.superview?.bounds.origin.y ?? 0
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext)) {
            animationActor.frame = targetFrame
            transitionContext.containerView.backgroundColor = .clear
            fromVC.view.backgroundColor = .clear
        } completion: { finish in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
    
}
