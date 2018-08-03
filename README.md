# JXBottomSheetView

之前写了一个类似的列表滚动视图，地址：https://github.com/pujiaxin33/JXBottomSheetTableView 里面的实现方案还是挺有趣的，对外完全封装了里面的滚动控制细节，且以UITableView的子类实现。无奈越骚的操作越容易翻车。里面的应用场景比较狭窄，需求一变动就GG了。
所以重新写了这个库，使用场景更大，使用更方便，交互更友善，好了，不说了，快上车吧！

# 特性

- 支持长距离滚动，不断手势：当列表视图滚动到规定的最高点时，停止视图移动，转而滚动里面的内容；
- 内容自适应：当列表的数据源发生变动时，会根据最新的`contentSize`调整布局；
- 切换流畅：最大、最小的手势切换，借鉴了系统`UIScrollView`的`PagingEnabled`切换效果；

# 预览

- 普通短距离滚动

![](https://github.com/pujiaxin33/JXBottomSheetView/blob/master/JXBottomSheetView/Gif/NormalScroll.gif)

- 长距离滚动，手势没有停掉。滚动到顶部的时候，继续滚动里面的内容

![](https://github.com/pujiaxin33/JXBottomSheetView/blob/master/JXBottomSheetView/Gif/Scroll.gif)

- 内容自适应，根据`contentView`的`contentSize`自动调整布局

![](https://github.com/pujiaxin33/JXBottomSheetView/blob/master/JXBottomSheetView/Gif/Changed.gif)

# 属性/方法

属性/方法 | 描述 |
----|------|
**defaultMininumDisplayHeight** | 默认最小内容高度，当contentSize.height更小时，会更新mininumDisplayHeight值。  | 
**defaultMaxinumDisplayHeight** | 默认最大内容高度，当contentSize.height更小时，会更新maxinumDisplayHeight值。  | 
**displayState** | 当前展示状态，最大或最小  | 
**triggerDistance** | 滚动多少距离，可以触发展开和收缩状态切换。  | 
**triggerVelocity** | 触发状态切换的滚动速度，points/second  | 
**contentView: UIScrollView** | 用于承载内容的视图，UITableView、UICollectionView皆可。  | 
**displayMax()** | 显示最大内容  | 
**displayMin()** | 显示最小内容  | 


# 使用

```
        tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        
        let bottomSheet = JXBottomSheetView(contentView: tableView)
        bottomSheet.defaultMininumDisplayHeight = 100
        bottomSheet.defaultMaxinumDisplayHeight = 300
        bottomSheet.displayState = .minDisplay
        bottomSheet.frame = self.view.bounds
        view.addSubview(bottomSheet)
```

# 注意

- 内部会影响到外部的代码
  ```contentView.bounces = false
  if let tableView = contentView as? UITableView {
            tableView.estimatedRowHeight = 0
        }
  ```

- 数据源的增删，请使用`reloadData`，而不是`insertRows`、`deleteRows`刷新页面。因为...你试一下就知道了。



