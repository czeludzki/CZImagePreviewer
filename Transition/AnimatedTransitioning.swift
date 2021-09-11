//
//  DismissTransition.swift
//  Pods-CZImagePreviewer_Example
//
//  Created by siu on 2021/9/11.
//

import UIKit

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
    }
    
    func dismiss(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as? CZImagePreviewer
        let toVC = transitionContext.viewController(forKey: .to)
        
        fromVC
    }
    
}
