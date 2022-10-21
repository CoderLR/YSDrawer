## 抽屉效果
swift用转场动画实现的抽屉效果

### 动画效果 
![drawer.gif](https://img2022.cnblogs.com/blog/775305/202210/775305-20221021173716557-1700686970.gif)

### 动画类型
```
// MARK: - 抽屉动画类型
enum YSDrawerAnimationType {
    case none   // B为弹出的控制器
    case slide  // 滑动 B-> A->
    case scale  // 缩放 B-> A缩小
    case spread // 展开 B-> A不动
}
```
