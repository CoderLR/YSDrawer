//
//  YSDrawerAnimator.swift
//  YSDrawerDemo
//
//  Created by xj on 2022/10/12.
//

import UIKit

class YSDrawerAnimator: NSObject {
    
    /// 抽屉配置
    var drawerConfig: YSDrawerConfig? {
        didSet {
            self.presentInteractive?.drawerConfig = drawerConfig
            self.dismissInteractive?.drawerConfig = drawerConfig
        }
    }
    
    /// 动画类型
    var animationType: YSDrawerAnimationType = .none

    /// 转场交互对象
    var dismissInteractive: YSDrawerInteractive?
    var presentInteractive: YSDrawerInteractive?
    
    convenience init(drawerConfig: YSDrawerConfig?) {
        self.init()
        self.drawerConfig = drawerConfig
    }
    
    deinit {
        print("YSDrawerAnimator---dealloc")
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension YSDrawerAnimator: UIViewControllerTransitioningDelegate {
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return YSDrawerTransition(transitionType: .dismiss, animationType: animationType, drawerConfig: drawerConfig)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return YSDrawerTransition(transitionType: .present, animationType: animationType, drawerConfig: drawerConfig)
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.presentInteractive?.interacting == true ? self.presentInteractive : nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.dismissInteractive?.interacting == true ? self.dismissInteractive : nil
    }
}
