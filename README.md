# CellTimerDemo

一个在多行cell中展示倒计时，使用定时器的Demo

文章地址：http://www.jianshu.com/p/97ec4b8f018c

>本文借鉴了IGListKit中多cell通知方案

公司需要做限时抢购的业务，这里面有两个需求点：

1.在多个cell中显示倒计时

在每个cell中添加定时器是不现实的，必定会增加许多性能开销，所以肯定是使用一个定时器，关键在于如何通知到cell刷新UI

2.本地时间可能和服务器时间存在误差

有的手机可能时间没有和网络同步，或者用户故意调整了时间，所以本地时间存在错误的可能，所以就定下使用服务器时间

#### 1.在多个cell中显示倒计时
思路是这样的：将需要接收定时器通知的对象注册到定时器单例中，存放在数组里面，当定时器更新的时候遍历数组回调通知
##### 定时器的创建
**注意：**默认暂停定时器,定时器默认是加载到当前runloop中的，在进行UI界面操作比如滑动列表时，由于在main runloop中NSTimer是同步交付的被“阻塞”，就会导致NSTimer计时出现延误
解决这种延误的方法，一种是在子线程中进行NSTimer的操作，在主线程中修改UI界面显示操作结果；另一种是仍然在主线程中进行NSTimer操作，但是将NSTimer实例加到main runloop的特定mode（模式）中。避免被复杂运算操作或者UI界面刷新所干扰。
```
timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {[unowned self] (_) in
     self.onTimer()
})
//下面这种方法要求onTimer是@objc
//Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true) 
```
##### 注册通知
这里使用NSHashTable存放注册对象的数组，可以防止循环引用注册对象释放不掉
swift的protocol是一个很好的东西，这样可以更好的规范谁可以注册通知
```
@objc
protocol TimerListener: class {
    func didOnTimer(announcer: YZTimerUtil, timeInterval: TimeInterval)
}
```
```
private let map: NSHashTable<TimerListener> = NSHashTable<TimerListener>.weakObjects()
```
##### 何时注册删除通知
一开始是在willDisplay、didEndDisplaying方法中进行通知注册的，后来发现没有必要，因为cell创建后就是要接收通知的willDisplay、didEndDisplaying中还要进行cell类型的判断，所以就改为cell- init/deinit中
```
    deinit {
        YZTimerUtil.sharedInstance.removeListener(listener: self)
    }
  //这里cell使用的是SB
    override func awakeFromNib() {
        super.awakeFromNib()
        YZTimerUtil.sharedInstance.addListener(listener: self)
    }
```
#### 2.本地时间可能和服务器时间存在误差
这里看项目需求吧，如果项目对时间要求没有那么严格，不做服务器时间对比也行，反正服务器那边会进行判断的，有些对时间要求严格的肯定是要做对比的，比如手机手令的动态码
我的思路是在定时器初始化的时候进行网络请求，拿到服务器的当前时间，然后计算本地和服务器时间的差值，后面就用这个差值进行计算。当然，受网络状态的影响，这个时间可能也不是准确的时间，但是这个时间误差会在一个可控范围内，为了精确时间差，可以每隔一段时间就校准一次，如果要更精准的，可以通过请求的requestTime/responseTime进行算法计算
```
    /// 从服务器请求最新的时间，简单示例
    func resetServerTime() {
        // 从服务器请求最新的时间
        // 。。。
        var success = true
        
        if success {
            // 请求成功
            serverTimeInterval = 0
        } else {
            // 如果请求失败，隔一段时间再请求一次
            perform(#selector(resetServerTime), with: nil, afterDelay: rloadTimeInterval)
        }
    }
```
demo里面的代码很详细，也很简单，建议可以看看
