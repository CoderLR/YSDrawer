//
//  XJNavigationViewController.swift
//  LightingRoom
//
//  Created by Mr.Yang on 2021/4/14.
//

import UIKit

class XJNavigationViewController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.interactivePopGestureRecognizer?.delegate = self
        
        // 不透明
        self.navigationBar.isTranslucent = false
        
        self.navigationBar.tintColor = UIColor(hexString: "#FF4500")
        
        // 适配iOS15导航栏问题
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),NSAttributedString.Key.foregroundColor: UIColor.black]
            //appearance.backgroundColor = UIColor.clear
            //appearance.shadowColor = UIColor.clear // 去掉线线
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        } else {
            self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),NSAttributedString.Key.foregroundColor: UIColor.black]
            //self.navigationBar.backgroundColor = UIColor.clear
            //self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            //self.navigationBar.shadowImage = UIImage() // 去掉线
        }
    }
    
    // fix iOS14 POP导航隐藏问题
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if #available(iOS 14.0, *) {
            if self.viewControllers.count > 1 {
                self.topViewController?.hidesBottomBarWhenPushed = false
            }
        }
        return super.popToViewController(viewController, animated: animated)
    }
    
    // fix iOS14 POP导航隐藏问题
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if #available(iOS 14.0, *) {
            if self.viewControllers.count > 1 {
                self.topViewController?.hidesBottomBarWhenPushed = false
            }
        }
        return super.popToRootViewController(animated: animated)
    }
    
    // 跳转控制器调用
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.topViewController?.hidesBottomBarWhenPushed = true
        super.pushViewController(viewController, animated: animated)
        self.viewControllers[0].hidesBottomBarWhenPushed = false
    }
    
    // 跳转多控制器调用
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        guard let viewController = viewControllers.last else { return }
        print("viewController = \(viewController)")
        viewController.hidesBottomBarWhenPushed = true
        super.setViewControllers(viewControllers, animated: animated)
        viewControllers[0].hidesBottomBarWhenPushed = false
    }
}
