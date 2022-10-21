//
//  YSDrawerInteractive.swift
//  YSDrawerDemo
//
//  Created by xj on 2022/10/12.
//

import UIKit

// MARK: - 自定义手势交互
class YSDrawerInteractive: UIPercentDrivenInteractiveTransition {
    
    /// 抽屉配置
    var drawerConfig: YSDrawerConfig?
    
    /// 是否可用交互
    var interacting: Bool = false
    
    /// 抽屉状态
    var type: YSDrawerStateType = .present
    
    /// 抽屉方向
    var direction: YSDrawerDirectionType = .left
    
    /// 操作控制器，需使用弱引用
    weak var controller: UIViewController?
    
    /// 开启变异手势默认开启
    var openEdgeGesture: Bool = true
    
    /// 定时器
    var link: CADisplayLink?
    
    /// 滑动进度
    var percent: CGFloat = 0
    
    /// 定时器相关参数
    var remainDuration: CGFloat = 0
    var remaincount: CGFloat = 0
    var oncePercent: CGFloat = 0
    var toFinish: Bool = false
    
    /// 边缘手势回调
    var transitionDirectionAutoBlock: ((_ direction: YSDrawerDirectionType) -> Void)?
    
    /// 初始化
    convenience init(type: YSDrawerStateType) {
        self.init()
        
        self.type = type
    }
    
    override init() {
        super.init()
        
        self.addNotify()
    }
    
    deinit {
        removeNotify()
        print("YSDrawerInteractive--dealloc")
    }
    
    /// 监听覆盖视图的手势
    func addNotify() {
        NotificationCenter.default.addObserver(self, selector: #selector(tapAction(notify:)), name: KTapGestureNotify, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(panAction(notify:)), name: KPanGestureNotify, object: nil)
    }
    
    /// 移除通知监听
    func removeNotify() {
        NotificationCenter.default.removeObserver(self)
    }

    /// 向controller的view添加手势
    func addPanGesture(controller: UIViewController?) {
        self.controller = controller
        
        if openEdgeGesture {
        
            let edgePanFromLeft = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
            edgePanFromLeft.edges = .left
            edgePanFromLeft.delegate = self
            controller?.view.addGestureRecognizer(edgePanFromLeft)
            
            let edgePanFromRight = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
            edgePanFromRight.edges = .right
            edgePanFromRight.delegate = self
            controller?.view.addGestureRecognizer(edgePanFromRight)
            
        } else {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
            pan.delegate = self
            self.controller?.view.addGestureRecognizer(pan)
        }
    }
}

// MARK: - ACTION
extension YSDrawerInteractive {
    
    /// 覆盖图Tap
    @objc func tapAction(notify: Notification) {
        print("mask tap action  \(type)")
        if type == .present { return }
        controller?.dismiss(animated: true)
    }
    
    /// 覆盖图Pan
    @objc func panAction(notify: Notification) {
        print("mask pan action \(type)")
        if type == .present { return }
        let pan = notify.object as! UIPanGestureRecognizer
        handlePanGesture(pan: pan)
    }
    
    /// 处理边缘手势
    @objc func handleEdgePan(_ edgPan: UIScreenEdgePanGestureRecognizer) {
        if type == .dismiss { return }
        let x = edgPan.translation(in: edgPan.view).x
        percent = 0
        percent = x / (edgPan.view?.frame.size.width ?? 393)
        direction = edgPan.edges == UIRectEdge.right ? YSDrawerDirectionType.right : YSDrawerDirectionType.left
        if direction == .right {
            percent = -percent
        }
        print("edg--percent = \(percent)")
        switch edgPan.state {
        case .began:
            self.interacting = true
            if let transitionDirectionAutoBlock = self.transitionDirectionAutoBlock {
                transitionDirectionAutoBlock(direction)
            }
            break
        case .changed:
            self.updateInteractiveTransition()
            break
        case .ended,
             .cancelled:
            self.endInteractiveTransition()
            break
            
        default:
            break
        }
    }
    
    /// 全屏手势触发
    @objc func panGesture(_ pan: UIPanGestureRecognizer) {
        print("controller pan action \(type)")
        if type == .dismiss { return }
        handlePanGesture(pan: pan)
    }
    
    /// 处理pan手势交互
    func handlePanGesture(pan: UIPanGestureRecognizer) {
        self.percent = 0
        let x = pan.translation(in: pan.view).x
        let width = pan.view?.frame.size.width ?? 1.0
        percent = x / width
        
        if (direction == .right && type == .present) || (direction == .left && type == .dismiss) {
            percent = -percent
        }
        
        print("percent = \(percent)")
        
        switch pan.state {
        case .began:
            break
        case .changed:
            if !interacting {
                if type == .present {
                    if abs(x) > 20 {
                        self.showBeganTranslationX(x: x, pan: pan)
                    }
                } else {
                    self.hiddenBeganTranslationX(x: x)
                }
                
            } else {
                self.updateInteractiveTransition()
            }
            break
        case .ended,
             .cancelled:
            self.endInteractiveTransition()
            break
            
        default:
            break
        }
    }
    
    func showBeganTranslationX(x: CGFloat, pan: UIPanGestureRecognizer) {
        print("showBeganTranslationX")
        if x >= 0 {
            direction = .left
        } else {
            direction = .right
        }
        
        if (x < 0 && direction == .left) || (x > 0 && direction == .right) { return }
        
        self.interacting = true
        
        if let transitionDirectionAutoBlock = transitionDirectionAutoBlock {
            transitionDirectionAutoBlock(direction)
        }
    }
    
    func hiddenBeganTranslationX(x: CGFloat) {
        print("hiddenBeganTranslationX")
        if (x < 0 && direction == .right) || (x > 0 && direction == .left) { return }
        
        self.interacting = true
        
        self.controller?.dismiss(animated: true)
    }
    
    func updateInteractiveTransition() {
        percent = CGFloat(fminf(fmaxf(Float(percent), 0.03), 0.97))
        self.update(percent)
    }
    
    func endInteractiveTransition() {
        print("endInteractiveTransition")
        self.interacting = false
        
        startTimerAnimationWithFinishTransition(percent > drawerConfig?.finishPercent ?? 0.4)
    }
    
    func startTimerAnimationWithFinishTransition(_ finish: Bool) {
        print("startTimerAnimationWithFinishTransition")
        if finish && percent >= 1 {
            self.finish(); return
        } else if !finish && percent <= 0 {
            self.cancel(); return
        }
        
        toFinish = finish
        
        remainDuration = finish ? self.duration * (1 - percent) : self.duration * percent
        remaincount = 60 * remainDuration
        oncePercent = finish ? ((1 - percent) / remaincount) : (percent / remaincount)
        
        starDisplayLink()
    }
    
    /// 创建定时器
    func starDisplayLink() {
        self.link = CADisplayLink(target: self, selector: #selector(updateLink))
        self.link?.add(to: RunLoop.current, forMode: .common)
    }
    
    /// 销毁定时器
    func stopDisplayerLink() {
        if self.link != nil {
            self.link?.invalidate()
            self.link = nil
        }
    }
    
    /// 定时执行
    @objc func updateLink() {
        if percent > 0.97 && toFinish {
            self.stopDisplayerLink()
            self.finish()
        } else if percent <= 0.03 && !toFinish {
            self.stopDisplayerLink()
            self.cancel()
        } else {
            if toFinish {
                percent += oncePercent
            } else {
                percent -= oncePercent
            }
            let p = fminf(fmaxf(Float(percent), 0.03), 0.97)
            self.update(CGFloat(p))
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension YSDrawerInteractive: UIGestureRecognizerDelegate {
    
    func viewController(view: UIView?) -> UIViewController? {
        var next: UIView? = view
        while (next?.superview != nil) {
            let nextResponder = next?.next
            if nextResponder?.isKind(of: UIViewController.self) ?? false {
                return nextResponder as? UIViewController
            }
            next = next?.superview
        }
        return nil
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if viewController(view: otherGestureRecognizer.view)?.isKind(of: UITableViewController.self) ?? false {
            return true
        }
        return false
    }
}
