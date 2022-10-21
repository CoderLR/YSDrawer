//
//  YSDrawerTransition.swift
//  YSDrawerDemo
//
//  Created by xj on 2022/10/12.
//

import UIKit

class YSDrawerTransition: NSObject {
    
    /// 动画属性设置
    var drawerConfig: YSDrawerConfig?
    
    /// 抽屉状态
    var transitionType: YSDrawerStateType = .present
    
    /// 动画类型
    var animationType: YSDrawerAnimationType = .none
    
    /// 动画时长
    fileprivate var animationTime: TimeInterval = 0.25
    
    /// 转场上下文，需使用弱引用
    fileprivate weak var transitionContext: UIViewControllerContextTransitioning?
    
    /// 跳转之前的控制器
    fileprivate var fromVc: UIViewController? {
        get {
            return transitionContext?.viewController(forKey: .from)
        }
    }
    
    /// 跳转之后的控制器
    fileprivate var toVc: UIViewController? {
        get {
            return transitionContext?.viewController(forKey: .to)
        }
    }
    
    /// 跳转之前的视图
    fileprivate var fromView: UIView? {
        get {
            return transitionContext?.view(forKey: .from)
        }
    }
    
    /// 跳转之后的视图
    fileprivate var toView: UIView? {
        get {
            return transitionContext?.view(forKey: .to)
        }
    }
    
    convenience init(transitionType: YSDrawerStateType, animationType: YSDrawerAnimationType, drawerConfig: YSDrawerConfig?) {
        self.init()
        self.transitionType = transitionType
        self.animationType = animationType
        self.drawerConfig = drawerConfig
    }
    
    override init() {
        super.init()
       
    }
    
    deinit {
        print("YSDrawerTransition---dealloc")
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension YSDrawerTransition: UIViewControllerAnimatedTransitioning {
    
    /// 转场动画持续的时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationTime
    }
    
    /// 转场要做的动画
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        print("animateTransition type = \(transitionType) anition = \(animationType)")
        
        // 转场上下文
        self.transitionContext = transitionContext
        
        if transitionType == .present {

            switch animationType {
            case .slide:
                slideTransitionAnimationShow(transitionContext)
            case .scale:
                scaleTransitionAnimationShow(transitionContext)
            case .spread:
                spreadTransitionAnimationShow(transitionContext)
            default: break
            }
        } else if transitionType == .dismiss {
            switch animationType {
            case .slide:
                slideTransitionAnimationHidden(transitionContext)
            case .scale:
                scaleTransitionAnimationHidden(transitionContext)
            case .spread:
                spreadTransitionAnimationHidden(transitionContext)
            default: break
            }
        }
    }
    
    /// 动画结束
    func animationEnded(_ transitionCompleted: Bool) {
        //print("\(#function)----\(transitionCompleted)")
        if transitionCompleted {
        
        }
    }
}

// MARK: - Animated实现
extension YSDrawerTransition {
    
    /// slide动画--打开
    func slideTransitionAnimationShow(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVc = self.fromVc else { return }
        guard let toVc = self.toVc else { return }
        let containerView = transitionContext.containerView
        
        let maskView = YSMaskView.shared()
        maskView.frame = fromVc.view.bounds
        fromVc.view.addSubview(maskView)
        
        let screenW = UIScreen.main.bounds.size.width
        let width: CGFloat = drawerConfig?.distance ?? 0
        var x = -width * 0.5
        var ret: CGFloat = 1.0
        if drawerConfig?.direction == .right {
            x = screenW - width * 0.5
            ret = -1.0
        }
        
        toVc.view.frame = CGRect(x: x, y: 0, width: CGRectGetWidth(containerView.frame), height: CGRectGetHeight(containerView.frame))
        containerView.addSubview(toVc.view)
        containerView.addSubview(fromVc.view)
        
        // 计算缩放后平移距离
        let scaleY = drawerConfig?.scaleY ?? 0
        let translationX = width - (screenW * (1 - scaleY) * 0.5)
        let t1 = CGAffineTransformMakeScale(scaleY, scaleY)
        let t2 = CGAffineTransformMakeTranslation(ret * translationX, 0)
        let fromVCTransform = CGAffineTransformConcat(t1, t2)
        var toVCTransform: CGAffineTransform!
        if drawerConfig?.direction == .right {
            toVCTransform = CGAffineTransformMakeTranslation(ret * (x - CGRectGetWidth(containerView.frame) + width), 0)
        } else {
            toVCTransform = CGAffineTransformMakeTranslation(ret * width * 0.5, 0)
        }
        
        UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: 0)) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                fromVc.view.transform = fromVCTransform
                toVc.view.transform = toVCTransform
                maskView.alpha = self.drawerConfig?.maskAlpha ?? 0.4
            }
        } completion: { finished in
            if transitionContext.transitionWasCancelled{
                print("show------cancle")
                YSMaskView.destroy()
                transitionContext.completeTransition(false)
            } else {
                print("show------finish")
                maskView.isUserInteractionEnabled = true

                if !toVc.isKind(of: UINavigationController.self) {
                    maskView.toViewSubViews = fromVc.view.subviews
                }
                transitionContext.completeTransition(true)
                containerView.addSubview(fromVc.view)
            }
        }
    }
    
    /// slide动画--关闭
    func slideTransitionAnimationHidden(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVc = self.fromVc else { return }
        guard let toVc = self.toVc else { return }
        
        let maskView = YSMaskView.shared()
        
        if !toVc.isKind(of: UINavigationController.self) {
            for view in toVc.view.subviews {
                if !maskView.toViewSubViews.contains(view) {
                    view.removeFromSuperview()
                }
            }
        }

        UIView.animateKeyframes(withDuration: 0.25, delay: 0.03, options: .calculationModeLinear) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                toVc.view.transform = CGAffineTransformIdentity
                fromVc.view.transform = CGAffineTransformIdentity
                maskView.alpha = 0
            }
        } completion: { finished in
            if transitionContext.transitionWasCancelled {
                print("hidden------cancle")
                transitionContext.completeTransition(false)
            } else {
                print("hidden------finish")
                maskView.toViewSubViews = []
                YSMaskView.destroy()
                transitionContext.completeTransition(true)
            }
        }
    }
    
    /// scale动画--打开
    func scaleTransitionAnimationShow(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVc = self.fromVc else { return }
        guard let toVc = self.toVc else { return }
        let containerView = transitionContext.containerView
        
        let maskView = YSMaskView.shared()
        maskView.frame = fromVc.view.bounds
        fromVc.view.addSubview(maskView)

        var imageV: UIImageView?
        if let backImage = drawerConfig?.backImage {
            imageV = UIImageView(frame: containerView.bounds)
            imageV?.image = backImage
            imageV?.transform = CGAffineTransformMakeScale(1.4, 1.4)
            imageV?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        if let imageV = imageV {
            containerView.addSubview(imageV)
        }
        
        let screenW = UIScreen.main.bounds.size.width
        let width: CGFloat = drawerConfig?.distance ?? 0
        var x = -width * 0.5
        var ret: CGFloat = 1.0
        if drawerConfig?.direction == .right {
            x = screenW - width * 0.5
            ret = -1.0
        }
        
        toVc.view.frame = CGRect(x: x, y: 0, width: CGRectGetWidth(containerView.frame), height: CGRectGetHeight(containerView.frame))
        containerView.addSubview(toVc.view)
        containerView.addSubview(fromVc.view)
        
        // 计算缩放后平移距离
        let scaleY = drawerConfig?.scaleY ?? 0
        let translationX = width - (screenW * (1 - scaleY) * 0.5)
        let t1 = CGAffineTransformMakeScale(scaleY, scaleY)
        let t2 = CGAffineTransformMakeTranslation(ret * translationX, 0)
        let fromVCTransform = CGAffineTransformConcat(t1, t2)
        var toVCTransform: CGAffineTransform!
        if drawerConfig?.direction == .right {
            toVCTransform = CGAffineTransformMakeTranslation(ret * (x - CGRectGetWidth(containerView.frame) + width), 0)
        } else {
            toVCTransform = CGAffineTransformMakeTranslation(ret * width * 0.5, 0)
        }
        
        UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: 0)) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                fromVc.view.transform = fromVCTransform
                toVc.view.transform = toVCTransform
                imageV?.transform = CGAffineTransformIdentity
                maskView.alpha = self.drawerConfig?.maskAlpha ?? 0.4
            }
        } completion: { finished in
            if transitionContext.transitionWasCancelled {
                print("show------cancle")
                imageV?.removeFromSuperview()
                YSMaskView.destroy()
                transitionContext.completeTransition(false)
            } else {
                print("show------finish")
                maskView.isUserInteractionEnabled = true

                if !toVc.isKind(of: UINavigationController.self) {
                    maskView.toViewSubViews = fromVc.view.subviews
                }
                
                transitionContext.completeTransition(true)
                containerView.addSubview(fromVc.view)
            }
        }
    }
    
    /// scale动画--关闭
    func scaleTransitionAnimationHidden(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVc = self.fromVc else { return }
        guard let toVc = self.toVc else { return }
        let containerView = transitionContext.containerView
        
        let maskView = YSMaskView.shared()
        
        if !toVc.isKind(of: UINavigationController.self) {
            for view in toVc.view.subviews {
                if !maskView.toViewSubViews.contains(view) {
                    view.removeFromSuperview()
                }
            }
        }
        
        var backImageView: UIImageView?
        if containerView.subviews.first?.isKind(of: UIImageView.self) ?? false {
            backImageView = containerView.subviews.first as? UIImageView
        }
        
        UIView.animateKeyframes(withDuration: 0.25, delay: 0.03, options: .calculationModeLinear) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                toVc.view.transform = CGAffineTransformIdentity
                fromVc.view.transform = CGAffineTransformIdentity
                maskView.alpha = 0
                backImageView?.transform = CGAffineTransformMakeScale(1.4, 1.4)
            }
        } completion: { finished in
            if transitionContext.transitionWasCancelled {
                print("hidden------cancle")
                transitionContext.completeTransition(false)
            } else {
                print("hidden------finish")
                maskView.toViewSubViews = []
                YSMaskView.destroy()
                backImageView?.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
    
    /// spread动画--打开
    func spreadTransitionAnimationShow(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVc = self.fromVc else { return }
        guard let toVc = self.toVc else { return }
        let containerView = transitionContext.containerView
        
        let maskView = YSMaskView.shared()
        maskView.frame = fromVc.view.bounds
        fromVc.view.addSubview(maskView)

        let screenW = UIScreen.main.bounds.size.width
        let width: CGFloat = drawerConfig?.distance ?? 0
        var x = -width
        var ret: CGFloat = 1.0
        if drawerConfig?.direction == .right {
            x = screenW
            ret = -1.0
        }
        
        toVc.view.frame = CGRect(x: x, y: 0, width: width, height: CGRectGetHeight(containerView.frame))
        containerView.addSubview(fromVc.view)
        containerView.addSubview(toVc.view)
        
        let toVCTransform = CGAffineTransformMakeTranslation(ret * width, 0)
        
        UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: 0)) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                toVc.view.transform = toVCTransform
                maskView.alpha = self.drawerConfig?.maskAlpha ?? 0.4
            }
        } completion: { finished in
            if transitionContext.transitionWasCancelled {
                print("showmask------cancle")
                YSMaskView.destroy()
                transitionContext.completeTransition(false)
            } else {
                print("showmask------finish")
                transitionContext.completeTransition(true)
                maskView.toViewSubViews = fromVc.view.subviews
                containerView.addSubview(fromVc.view)
                containerView.bringSubviewToFront(toVc.view)
                maskView.isUserInteractionEnabled = true
            }
        }
    }
    
    /// spread动画--关闭
    func spreadTransitionAnimationHidden(_ transitionContext: UIViewControllerContextTransitioning) {
        slideTransitionAnimationHidden(transitionContext)
    }

}

class YSMaskView: UIView, UIGestureRecognizerDelegate {
    
    var toViewSubViews: [UIView] = []
    
    //单例(创建、销毁)
    private static var _instance: YSMaskView?
    class func shared() -> YSMaskView {
        guard let instance = _instance else {
            _instance = YSMaskView()
            return _instance!
        }
        return instance
    }
    
    //结束互动销毁对象，销毁单例对象，用变量记录销毁时机
    class func destroy() {
        _instance?.removeFromSuperview()
        _instance = nil
    }
    
    /// 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        self.alpha = 0
        
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        self.addGestureRecognizer(pan)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapGesture() {
        NotificationCenter.default.post(name: KTapGestureNotify, object: nil)
    }
    
    @objc func panGesture(_ pan: UIPanGestureRecognizer) {
        NotificationCenter.default.post(name: KPanGestureNotify, object: pan)
    }
    
    deinit {
        print("YSMaskView--dealloc")
    }
}
