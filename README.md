# JXBottomSheetView

项目中有类似于外卖软件的已点菜品列表，类似于下图：

![meituan.gif](https://upload-images.jianshu.io/upload_images/1085173-77587ed9d77747a8.gif?imageMogr2/auto-orient/strip)

可以看到列表的显示与隐藏，都只能通过按钮触发。不能通过手势驱动。不能设置最小可显示范围。针对以上问题，就有了这个项目。

其实以上的需求核心问题就一个，如何优雅的解决：当内容还未到最大可显示范围时，列表里的内容不能滚动；当内容显示到最大的时候，如何不断开当前滚动手势，继续滚动列表里的内容。

之前写了一个类似的底部列表滚动视图，地址：https://github.com/pujiaxin33/JXBottomSheetTableView 里面的实现方案还是挺有趣的，对外完全封装了里面的滚动控制细节，且以UITableView的子类实现。无奈越骚的操作越容易翻车。里面的应用场景比较狭窄，需求一变动就GG了。
所以重新写了这个库，使用场景更大，使用更方便，交互更友善，好了，不说了，快上车吧！

# 原理

为`JXBottomSheetView`添加一个`UIPanGestureRecognizer`，成为其`delegate`，并让`shouldRecognizeSimultaneouslyWithOtherGestureRecognizer`方法返回true；
如此一来，内容承载视图与列表视图的滚动手势可以同时响应了。接着，我们需要处理好当内容承载视图未显示到最大值时，列表视图(UITableView、UICollectionView)的`contentOffset.y`会被强制设置为0，营造一种列表内容未滚动的假象；
当内容承载视图滚动到最大的时候，就放开对列表视图的滚动限制。
其他一些细节可以参看源码了解；

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

# 安装

swift版本：5.0+

```ruby
use_frameworks!
target '<Your Target Name>' do
    pod 'JXBottomSheetView'
end
```

# 注意

- 内部会影响到外部的代码
  ```contentView.bounces = false
  if let tableView = contentView as? UITableView {
            tableView.estimatedRowHeight = 0
        }
  ```

- 数据源的增删，请使用`reloadData`，而不是`insertRows`、`deleteRows`刷新页面。因为...你试一下就知道了。



