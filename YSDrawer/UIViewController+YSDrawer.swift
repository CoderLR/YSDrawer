//
//  UIViewController+YSDrawer.swift
//  YSDrawerDemo
//
//  Created by xj on 2022/10/12.
//

import UIKit

extension UIViewController {

    /// 为控制器注册手势
    /// - Parameters:
    ///   - openEdgeGesture: true 边缘触发 false 全屏触发
    ///   - transitionDirectionAutoBlock: 触发事件回调
    func ys_registerShowEdgeGestureIntractive(openEdgeGesture: Bool,
                                              transitionDirectionAutoBlock: ((_ direction: YSDrawerDirectionType) -> Void)?) {
        
        /// 动画管理类
        let animator = YSDrawerAnimator(drawerConfig: nil)
        setAnimator(target: self, animator: animator)
        
        /// 设置代理
        self.transitioningDelegate = animator
        
        /// 设置交互器
        let presentInteractive = YSDrawerInteractive(type: .present)
        presentInteractive.openEdgeGesture = openEdgeGesture
        presentInteractive.transitionDirectionAutoBlock = transitionDirectionAutoBlock
        presentInteractive.addPanGesture(controller: self)
        animator.presentInteractive = presentInteractive
    }
    

    /// 打开抽屉
    /// - Parameter viewController: 打开的控制器
    func ys_showDrawerViewController(viewController: UIViewController) {
        self.ys_showDrawerViewController(viewController: viewController, animationType: .slide, drawerConfig: nil)
    }

    
    /// 打开抽屉
    /// - Parameters:
    ///   - viewController: 打开的控制器
    ///   - coverType: 是否有阴影
    ///   - drawerConfig: 配置参数
    func ys_showDrawerViewController(viewController: UIViewController,
                                     animationType: YSDrawerAnimationType,
                                     drawerConfig: YSDrawerConfig?) {
       
        var config: YSDrawerConfig? = drawerConfig
        if drawerConfig == nil {
            config = YSDrawerConfig.defaultConfiguration()
        }
        
        /// 动画管理类
        var animator = getAnimator(target: self)
        if animator == nil {
            animator = YSDrawerAnimator(drawerConfig: config)
            setAnimator(target: viewController, animator: animator)
        }

        /// 设置代理
        viewController.transitioningDelegate = animator
        setDirection(target: viewController, direction: config?.direction ?? .none)
        
        /// 设置交互器
        let dismissInteractive = YSDrawerInteractive(type: .dismiss)
        dismissInteractive.controller = viewController
        dismissInteractive.direction = drawerConfig?.direction ?? .left

        animator?.dismissInteractive = dismissInteractive
        animator?.drawerConfig = config
        animator?.animationType = animationType
        
        /// 执行跳转
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }

    /// push控制器
    /// - Parameter controller: 控制器
    func ys_pushViewController(controller: UIViewController) {
        let nav = topNavController()
        
        let direction = getDirection(target: self)
        let subType = direction == .left ? CATransitionSubtype.fromLeft : CATransitionSubtype.fromRight
        
        let transion = CATransition()
        transion.duration = 0.2
        transion.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transion.type = CATransitionType.fade
        transion.subtype = subType
        nav?.view.layer.add(transion, forKey: nil)
        
        self.dismiss(animated: true, completion: nil)
        nav?.pushViewController(controller, animated: false)
    }
    
    
    /// present控制器
    /// - Parameters:
    ///   - controller: 控制器
    ///   - isClose: 是否关闭抽屉
    func ys_presentViewController(controller: UIViewController,
                                  isClose: Bool = true) {
        
        if !isClose {
            let topVc = topViewController()
            topVc?.present(controller, animated: true)
        } else {
            self.dismiss(animated: true) {
                let topVc = self.topViewController()
                topVc?.present(controller, animated: true)
            }
        }
    }
}

// MARK: - 扩展
extension UIViewController {
    
    // MARK: 获取导航控制器(类方法)
    /// 获取顶部控制器
    /// - Returns: VC
    func topNavController() -> UINavigationController? {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
              let rootVC = window.rootViewController else {
            return nil
        }
        
        if rootVC.isKind(of: UITabBarController.self) {
            guard let tabbarVc = rootVC as? UITabBarController else { return nil }
            let index = tabbarVc.selectedIndex
            return tabbarVc.children[index] as? UINavigationController
        } else if rootVC.isKind(of: UINavigationController.self) {
            return rootVC as? UINavigationController
        } else {
            return nil
        }
    }

    // MARK: 获取顶部控制器(类方法)
    /// 获取顶部控制器
    /// - Returns: VC
    static func topViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
              let rootVC = window.rootViewController else {
            return nil
        }
        return top(rootVC: rootVC)
    }
    
    // MARK: 获取顶部控制器(实例方法)
    /// 获取顶部控制器
    /// - Returns: VC
    func topViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
              let rootVC = window.rootViewController else {
            return nil
        }
        return Self.top(rootVC: rootVC)
    }
    
    static func top(rootVC: UIViewController?) -> UIViewController? {
        if let presentedVC = rootVC?.presentedViewController {
            return top(rootVC: presentedVC)
        }
        if let nav = rootVC as? UINavigationController,
            let lastVC = nav.viewControllers.last {
            return top(rootVC: lastVC)
        }
        if let tab = rootVC as? UITabBarController,
            let selectedVC = tab.selectedViewController {
            return top(rootVC: selectedVC)
        }
        return rootVC
    }
}

fileprivate var KDrawerAnimatorKey: String = "KDrawerAnimatorKey"
fileprivate var KDrawerDirectionKey: String = "KDrawerDirectionKey"

// MARK: - 关联属性
extension UIViewController {
    
    fileprivate func setAnimator(target: UIViewController, animator: YSDrawerAnimator?) {
        objc_setAssociatedObject(target, &KDrawerAnimatorKey, animator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    fileprivate func getAnimator(target: UIViewController) -> YSDrawerAnimator? {
        return objc_getAssociatedObject(self, &KDrawerAnimatorKey) as? YSDrawerAnimator
    }
    
    fileprivate func setDirection(target: UIViewController, direction: YSDrawerDirectionType) {
        objc_setAssociatedObject(target, &KDrawerDirectionKey, direction, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    fileprivate func getDirection(target: UIViewController) -> YSDrawerDirectionType {
        return objc_getAssociatedObject(self, &KDrawerDirectionKey) as? YSDrawerDirectionType ?? .none
    }

}
