//
//  XJRootViewController.swift
//  YSDrawerDemo
//
//  Created by xj on 2022/7/19.
//

import UIKit

// 抽屉打开
let KNavOpenDrawerImage = UIImage(named: "icon_drawer_open") ?? UIImage()

// 抽屉关闭
let KNavCloseDrawerImage = UIImage(named: "icon_drawer_close") ?? UIImage()

class XJRootViewController: UIViewController {
    
    let btnLeft = UIButton(type: .custom)
    let btnRight = UIButton(type: .custom)
    
    /// scrollView
    fileprivate lazy var scrollView: XJBaseScrollView = {
        let scroll = XJBaseScrollView(frame: self.view.bounds)
        scroll.isPagingEnabled = true
        scroll.delegate = self
        scroll.bounces = false
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    fileprivate var titles: [String] = ["slide",
                                        "scale",
                                        "spread"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "抽屉"
        
        setupNavItem()
        
        setupUI()
        
        self.ys_registerShowEdgeGestureIntractive(openEdgeGesture: false) {[weak self] direction in
            guard let self = self else { return }
            if direction == .left {
                self.slide(.left)
            } else if direction == .right {
                self.scale(.right)
            }
        }
    }
    
    /// 加载UI
    fileprivate func setupUI() {
        self.view.addSubview(scrollView)

        let navH = UIApplication.shared.statusBarFrame.height + 44
        scrollView.contentSize = CGSize(width: 2 * self.view.frame.size.width, height: scrollView.frame.size.height - navH)
     
        for i in 0..<2 {
            let frame = CGRect(x: CGFloat(i) * scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            let tableView = self.createTableView(frame: frame)
            tableView.tag = i
            scrollView.addSubview(tableView)
        }
    }
    
    /// 创建tableView
    fileprivate func createTableView(frame: CGRect) -> UITableView {
        let tableView = UITableView(frame: frame, style: .plain)
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        return tableView
    }
    
    /// 设置导航按钮
    fileprivate func setupNavItem() {
        btnLeft.setImage(KNavOpenDrawerImage, for: .normal)
        btnLeft.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        btnLeft.addTarget(self, action: #selector(btnLeftClick(_:)), for: .touchUpInside)
        btnLeft.tag = 0
        let leftItem = UIBarButtonItem(customView: btnLeft)
        self.navigationItem.leftBarButtonItem = leftItem
        
        btnRight.setImage(KNavCloseDrawerImage, for: .normal)
        btnRight.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        btnRight.addTarget(self, action: #selector(btnRightClick(_:)), for: .touchUpInside)
        btnRight.tag = 0
        let rightItem = UIBarButtonItem(customView: btnRight)
        self.navigationItem.rightBarButtonItem = rightItem
    }
}

// MARK: - ACTION
extension XJRootViewController {
    /// 左导航点击
    @objc fileprivate func btnLeftClick(_ btn: UIButton) {
        slide(.left)
    }
    
    /// 右导航点击
    @objc fileprivate func btnRightClick(_ btn: UIButton) {
        scale(.right)
    }
    
    /// slide滑动
    func slide(_ direction: YSDrawerDirectionType) {
        let leftVc = XJLeftViewController()
        var config = YSDrawerConfig.defaultConfiguration()
        config.direction = direction
        self.ys_showDrawerViewController(viewController: leftVc, animationType: .slide, drawerConfig: config)
    }
    
    /// scale缩放
    func scale(_ direction: YSDrawerDirectionType) {
        let rightVc = XJRightViewController()
        let config = YSDrawerConfig(distance: 0.75 * UIScreen.main.bounds.size.width, maskAlpha: 0.4, scaleY: 0.8, direction: direction, backImage: UIImage(named: "bg3.jpg"))
        self.ys_showDrawerViewController(viewController: rightVc, animationType: .scale, drawerConfig: config)
    }
    
    /// spread传播
    func spread(_ direction: YSDrawerDirectionType) {
        let leftVc = XJLeftViewController()
        var config = YSDrawerConfig.defaultConfiguration()
        config.direction = direction
        self.ys_showDrawerViewController(viewController: leftVc, animationType: .spread, drawerConfig: config)
    }
}

extension XJRootViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 返回每组个数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    // 返回cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "UITableViewCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.textColor = UIColor.black
        let title = titles[indexPath.row]
        cell.textLabel?.text = title + (tableView.tag == 0 ? "--->left" : "--->Right")
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // 返回cell的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // 点击cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let direction: YSDrawerDirectionType = tableView.tag == 0 ? .left : .right
        if indexPath.row == 0 {
            slide(direction)
        } else if indexPath.row == 1 {
            scale(direction)
        } else if indexPath.row == 2 {
            spread(direction)
        }
    }
}



fileprivate var indexPathButtonKey: String = "indexPathKey"
extension UITableView {
    var indexPath: IndexPath {
        set {
             objc_setAssociatedObject(self, &indexPathButtonKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &indexPathButtonKey)) as? IndexPath ?? IndexPath(row: 0, section: 0)
        }
    }
}

// MARK: - 颜色扩展
public extension UIColor {
    
    // MARK: 1.1、根据 RGBA 设置颜色颜色
    /// 根据 RGBA 设置颜色颜色
    /// - Parameters:
    ///   - r: red 颜色值
    ///   - g: green颜色值
    ///   - b: blue颜色值
    ///   - alpha: 透明度
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        // 提示：在 extension 中给系统的类扩充构造函数，只能扩充：遍历构造函数
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    
    // MARK: 1.2、十六进制字符串设置颜色
    /// 十六进制字符串设置颜色
    /// - Parameters:
    ///   - hex: 十六进制字符串
    ///   - alpha: 透明度
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        let color = Self.hexStringToColorRGB(hexString: hexString)
        guard let r = color.r, let g = color.g, let b = color.b else {
            #if DEBUG
            assert(false, "不是十六进制值")
            #endif
            return nil
        }
        self.init(r: r, g: g, b: b, alpha: alpha)
    }
    
    // MARK: 3.1、根据 十六进制字符串 颜色获取 RGB，如：#3CB371 或者 ##3CB371 -> 60,179,113
    /// 根据 十六进制字符串 颜色获取 RGB
    /// - Parameter hexString: 十六进制颜色的字符串，如：#3CB371 或者 ##3CB371 -> 60,179,113
    /// - Returns: 返回 RGB
    static func hexStringToColorRGB(hexString: String) -> (r: CGFloat?, g: CGFloat?, b: CGFloat?) {
        // 1、判断字符串的长度是否符合
        guard hexString.count >= 6 else {
            return (nil, nil, nil)
        }
        // 2、将字符串转成大写
        var tempHex = hexString.uppercased()
        // 检查字符串是否拥有特定前缀
        // hasPrefix(prefix: String)
        // 检查字符串是否拥有特定后缀。
        // hasSuffix(suffix: String)
        // 3、判断开头： 0x/#/##
        if tempHex.hasPrefix("0x") || tempHex.hasPrefix("##") {
            tempHex = String(tempHex[tempHex.index(tempHex.startIndex, offsetBy: 2)..<tempHex.endIndex])
        }
        if tempHex.hasPrefix("#") {
            tempHex = String(tempHex[tempHex.index(tempHex.startIndex, offsetBy: 1)..<tempHex.endIndex])
        }
        // 4、分别取出 RGB
        // FF --> 255
        var range = NSRange(location: 0, length: 2)
        let rHex = (tempHex as NSString).substring(with: range)
        range.location = 2
        let gHex = (tempHex as NSString).substring(with: range)
        range.location = 4
        let bHex = (tempHex as NSString).substring(with: range)
        // 5、将十六进制转成 255 的数字
        var r: UInt32 = 0, g: UInt32 = 0, b: UInt32 = 0
        Scanner(string: rHex).scanHexInt32(&r)
        Scanner(string: gHex).scanHexInt32(&g)
        Scanner(string: bHex).scanHexInt32(&b)
        return (r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
    }
    
    // MARK: 4.2、随机色
    /// 随机色
    static var randomColor: UIColor {
        return UIColor(r: CGFloat(arc4random()%256), g: CGFloat(arc4random()%256), b: CGFloat(arc4random()%256), alpha: 1.0)
    }
}

// MARK: - ScrollView支持侧滑返回
class XJBaseScrollView: UIScrollView {
    /*
    /// 是否支持多手势触发，返回YES，则可以多个手势一起触发方法，返回NO则为互斥.
    /// 是否允许多个手势识别器共同识别，一个控件的手势识别后是否阻断手势识别继续向下传播，默认返回NO；如果为YES，
    /// 响应者链上层对象触发手势识别后，如果下层对象也添加了手势并成功识别也会继续执行，否则上层对象识别后则不再继续传播
    /// 一句话总结就是此方法返回YES时，手势事件会一直往下传递，不论当前层次是否对该事件进行响应。
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.isPanBackAction(gestureRecognizer: gestureRecognizer) { return true }
        return false
    }
    
    /// 判断是否是全屏的返回手势
    func isPanBackAction(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        /// 在最左边时候 && 是pan手势 && 手势往右拖
        if self.contentOffset.x == 0 {
            if gestureRecognizer == self.panGestureRecognizer {
                /// 根据速度获取拖动方向
                let velocity = self.panGestureRecognizer.velocity(in: self.panGestureRecognizer.view)
                /// 手势向右滑动
                if velocity.x > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    /// 如果是全屏的左滑返回,那么ScrollView的左滑就没用了,返回NO,让ScrollView的左滑失效
    /// 不写此方法的话,左滑时,那个ScrollView上的子视图也会跟着左滑的
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.isPanBackAction(gestureRecognizer: gestureRecognizer) { return false }
        return true
    }
     */
    /// 如果是全屏的左滑返回,那么ScrollView的左滑就没用了,返回NO,让ScrollView的左滑失效
    /// 不写此方法的话,左滑时,那个ScrollView上的子视图也会跟着左滑的
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        if pan.translation(in: self).x > 0 && self.contentOffset.x == 0 {
            return false
        }
        if pan.translation(in: self).x < 0 && self.contentSize.width - self.contentOffset.x <= self.bounds.size.width {
            return false
        }
        
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
