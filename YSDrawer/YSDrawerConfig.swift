//
//  YSDrawerConfig.swift
//  YSDrawerDemo
//
//  Created by xj on 2022/10/12.
//

import UIKit


let KTapGestureNotify = NSNotification.Name("KTapGestureNotify")
let KPanGestureNotify = NSNotification.Name("KPanGestureNotify")

// MARK: - 抽屉状态
enum YSDrawerStateType {
    case present  // 打开
    case dismiss  // 关闭
}

// MARK: - 抽屉滑出方向
enum YSDrawerDirectionType {
    case none  // default
    case left  // 左侧滑出
    case right // 右侧滑出
}

// MARK: - 抽屉动画类型
enum YSDrawerAnimationType {
    case none   // B为弹出的控制器
    case slide  // 滑动 B-> A->
    case scale  // 缩放 B-> A缩小
    case spread // 展开 B-> A不动
}

// MARK: - 配置属性
struct YSDrawerConfig {
    
    // 根控制器可偏移的距离，默认为屏幕的0.75
    var distance: CGFloat = 0.75 * UIScreen.main.bounds.size.width
    
    // 手势驱动动画完成的临界点（范围0 - 1.0），默认为0.5（表示手势驱动到动画的一半则执行完动画，拖动不到一半则会取消动画）
    var finishPercent: CGFloat = 0.4
    
    // 抽屉显示动画的持续时间，默认为0.25f
    var showAnimDuration: TimeInterval = 0.25
    
    // 抽屉隐藏动画的持续时间，默认为0.25f
    var HiddenAnimDuration: TimeInterval = 0.25
    
    // 遮罩的透明度
    var maskAlpha: CGFloat = 0.4
    
    // 抽屉滑出的方向，默认为从左侧滑出
    var direction: YSDrawerDirectionType = .left
    
    // 根控制器在y方向的缩放，默认为不缩放
    var scaleY: CGFloat = 1.0
    
    // 动画切换过程中，最底层的背景图片
    var backImage: UIImage?
    
    /// 默认设置
    /// - Returns: 结构体
    static func defaultConfiguration() -> YSDrawerConfig {
        YSDrawerConfig(distance: 0.75 * UIScreen.main.bounds.size.width, maskAlpha: 0.4, scaleY: 1.0, direction: .left, backImage: nil)
    }
    
    /// 初始化
    /// - Parameters:
    ///   - distance: 距离
    ///   - maskAlpha: 透明度
    ///   - scaleY: 缩小比例
    ///   - direction: 方向
    ///   - backImage: 背景图
    init(distance: CGFloat, maskAlpha: CGFloat, scaleY: CGFloat, direction: YSDrawerDirectionType, backImage: UIImage?) {
        self.distance = distance
        self.maskAlpha = maskAlpha
        self.direction = direction
        self.backImage = backImage
        self.scaleY = scaleY
        self.finishPercent = 0.4
        self.showAnimDuration = 0.25
        self.HiddenAnimDuration = 0.25
    }
}
