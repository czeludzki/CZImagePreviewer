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
    typealias ElementForDisplayTransition = (container: UIView?, resource: ImageProvider?)
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
        
        guard let keyWindow = Previewer.keyWindow,
              let toView = transitionContext.view(forKey: .to),
              let toVC = transitionContext.viewController(forKey: .to) as? AnimatedTransitioningContentProvider else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        toView.frame = transitionContext.containerView.bounds
        transitionContext.containerView.addSubview(toView)
        
        let transitioningElementForDisplay = toVC.transitioningElementForDisplay(animatedTransitioning: self)
        guard let elementContainer = transitioningElementForDisplay.container, let resource = transitioningElementForDisplay.resource else {
            toView.alpha = 0
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut) {
                toView.alpha = 1
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            return
        }

        // 计算 targetContainer 在 keyWindow 中的位置
        let targetFrame = elementContainer.convert(elementContainer.bounds, to: keyWindow)
        // 如果该视图不在屏幕中, 执行 planB 动画
        if !keyWindow.bounds.contains(targetFrame) {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        // 创建动画关键元素
        let actor = UIImageView()
        actor.contentMode = .scaleAspectFit
        resource.loadImage(options: [.processor(ResizingImageProcessor(referenceSize: targetFrame.size, mode: .aspectFill))], progress: nil) {
            guard case let .success(img) = $0 else { return }
            actor.image = img
        }
        
        transitionContext.containerView.addSubview(actor)
        // 将触发视图frame赋值到imageView
        actor.frame = targetFrame
        toView.isHidden = true
        transitionContext.containerView.backgroundColor = .clear
        // 开始动画
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext)) {
            actor.frame = CGRect.init(origin: CGPoint.zero, size: transitionContext.containerView.bounds.size)
            actor.center = transitionContext.containerView.center
            transitionContext.containerView.backgroundColor = .black
        } completion: { finish in
            toView.isHidden = false
            actor.removeFromSuperview()
            transitionContext.containerView.backgroundColor = .clear
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
    
    func dismiss(_ transitionContext: UIViewControllerContextTransitioning) {
        
        guard let keyWindow = Previewer.keyWindow,
              let fromVC = transitionContext.viewController(forKey: .from) as? AnimatedTransitioningContentProvider
        else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        // 动画要返回到哪个容器, 主要是为了得到其在 keywindow 上的相对定位
        guard let back2Container = fromVC.transitioningElementForDismiss(animatedTransitioning: self).container,
              let animationActor = fromVC.transitioningElementForDismiss(animatedTransitioning: self).animationActor  // 动画要素
        else {
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut) {
                fromVC.view.alpha = 0
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            return
        }
        
        // 计算 back2Container 在屏幕中的位置
        var targetFrame = back2Container.convert(back2Container.bounds, to: keyWindow)
        if !keyWindow.bounds.contains(targetFrame) {
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut) {
                fromVC.view.alpha = 0
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
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
