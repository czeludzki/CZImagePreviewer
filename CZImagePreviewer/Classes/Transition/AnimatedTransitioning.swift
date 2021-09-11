//
//  DismissTransition.swift
//  Pods-CZImagePreviewer_Example
//
//  Created by siu on 2021/9/11.
//

import UIKit

// MARK: 要求遵守了此协议的实例提供一个视图, 在转场动画发生时展示
protocol AnimatedTransitioningContentProvider {
    var viewForAnimatedTransitioning: UIView { get }
}

class AnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum For {
        case present
        case dismiss
    }
    
    var transitionFor: For
    
    convenience init(transitionFor: For) {
        self.init()
        self.transitionFor = transitionFor
    }
    
    private override init() {
        self.transitionFor = .present
        super.init()
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
    
    func dismiss(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as? AnimatedTransitioningContentProvider
        let fromView = fromVC?.viewForAnimatedTransitioning
        let toView = transitionContext.view(forKey: .to)
        
        transitionContext.completeTransition(true)
    }
    
    func present(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to) as? AnimatedTransitioningContentProvider
        
        let toView = toVC?.viewForAnimatedTransitioning
        
        transitionContext.completeTransition(true)
    }

}
