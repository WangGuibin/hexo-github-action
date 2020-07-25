---
title: 'iOS基础知识总结'
date: 2020-03-23 13:22:53
tags: [Objective-C,学习总结,iOS,面试]
published: true
hideInList: false
feature: /post-images/ios-ji-chu-zhi-shi-zong-jie.jpg
isTop: false
---

## OC

### 内存管理

##### 内存管理的原理和原则

- 基本数据类型(`int`,`float`,`double`,`enum`,`struct`,`union`等)和C语言的类型存储在栈区,由系统分配释放
- 继承自`NSObject`的类属于`OC`类型,都遵循内存管理原则
- 谁创建,谁释放(`MRC`程序员管理,`ARC`系统封装了编译时插入`retain`和`release` 自动释放池等自动管理内存)
- `OC`方法调用的本质其实是给对象发送消息,需要引用时发送`retain`引用计数加`1`,释放时发送`release`引用计数减`1`,每个`OC`对象都有一个`retainCount`计数器占有`4`个字节
- `MRC` 设置`setter`需要判断,存在旧值,则需要先把旧值释放`release`,然后新值`retain`之后赋值


<!-- more -->


##### 内存管理中容易出现的问题和概念

* 内存泄漏: 开辟了内存空间创建了对象却没有得到真正的使用,也没有得到释放并常驻在内存中,造成对内存的浪费(不用的记得释放,养成合理使用内存的习惯,才能有效避免类似问题)

* 悬垂指针(也叫迷途指针): 就是指针指向的那块内存已经销毁(对象已经释放了),但是引用它的指针还在,然后指针自己也不知道指向的是什么鬼👻了,对象释放时需要顺带也要把引用它的指针也置为 `nil` (`OC`中任何对象给`nil`发消息都不会有反应的)

* 野指针: 还没有初始化的指针

* 僵尸对象: 一个已经被释放的对象

* 空指针: nil,NULL 

* 一个NSObject占用多少内存？[查看OC对象占用至少多少字节](https://blog.csdn.net/a_horse/article/details/82532304)

  > 1、系统分配了16个字节给NSObject对象（可以通过malloc_size函数得到）
  > 2、但NSObject对象内部只使用了8个字节空间（在64bit环境下，可以通过class_getInstanceSize函数获得）



###  OC中的几个小常识

##### `#import` , `#include`,`@class`的区别在哪里?

- `#include`是`C`语言中的导入头文件的方式,会出现重复导入的情况
- `#import`是``#include`的改进版,针对同一个头文件只会导入一次,避免递归导入问题
- `@class` 类的声明,可以避免循环导入互相引用头文件报错的问题,还有就是提高编译效率,如果头文件链式引用的话容易出现重复编译的问题(可优化编译耗时)



##### `static`,`extern`,`const`的使用

`static`可以修饰

- 静态局部变量:  *保证局部变量永远只初始化一次，在程序的运行过程中永远有且只有一份内存， 生命周期类似全局变量了，但是作用域不变。*

```objc
 //push到这个页面,页面添加按钮点击进行累加操作 点两下pop页面,再次进入继续点击按钮累加 观察控制台打印
    static int count = 0;
    count += 1;
    NSLog(@"计数: %d",count);
// 控制台打印结果如下: 
//第一次进入该页面点击打印
计数: 1
计数: 2
//第二次进入该页面点击打印
计数: 3
计数: 4

```

- 修饰静态全局变量:  *使全局变量的作用域仅限于当前文件内部，即当前文件内部才能访问该全局变量* 

  例如单例:

```objc
static ShareManager *_manager = nil;
+ (ShareManager *)shareInstance{
    if (!_manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _manager = [[ShareManager alloc] init];
        });
    }
    return _manager;
}
```

- 修饰静态函数: *`static`修饰的函数叫静态函数,外部文件无法访问这个函数,函数当前文件可以访问*

```objc
static inline void hello(){
    NSLog(@"你好!");
}
```



`extern` 外部引用的意思,其实是用于修饰外部全局变量的关键字,在`iOS`中被定义了多种别名,其实本质还是`extern`,当然自己开发的时候也可以自定义别名,可以增加代码可读性.

```objective-c
    FOUNDATION_EXPORT
    FOUNDATION_EXTERN
    UIKIT_EXTERN
```

#####  OC中`@property`的几个关键字用法 [iOS面试之@property](https://juejin.im/post/5c105c7ce51d4562d138086f?utm_source=gold_browser_extension)

<details>
<summary>查看代码示例 show the code</summary>
<pre><code class="java">
// @property = iVar + setter + getter
// 默认是atomic原子的 读写线程安全但耗性能  一般设置nonatomic是非原子的 节省开销
//基本数据类型
@property (nonatomic,assign) int age;
@property (nonatomic,assign) float distance;
@property (nonatomic,assign) double aValue;
@property (nonatomic,assign) NSInteger count1;
@property (nonatomic,assign) NSUInteger count2;
@property (nonatomic,assign) CGFloat number1;
//枚举类型
@property (nonatomic,assign) NSTextAlignment align;
//结构体
@property (nonatomic,assign) CGSize size;
@property (nonatomic,assign) CGRect frame;
//代理委托
@property (nonatomic,assign) id<HelloDelegate> assignDelegate;
@property (nonatomic,weak) id<HelloDelegate> weakDelegate;
//弱引用属性
@property (nonatomic,weak) ShareManager *weakManager;
//IB拉线视图
@property (nonatomic,weak) IBOutlet UIView *testView;
//字符串
@property (nonatomic,copy) NSString *name;
//block/闭包
@property (nonatomic,copy) dispatch_block_t block;
//强引用对象
@property (nonatomic,strong) NSArray *arr;
@property (nonatomic,strong) NSMutableArray *arrM;
@property (nonatomic,strong) NSDictionary *dic;
@property (nonatomic,strong) NSMutableArray *dicM;
@property (nonatomic,strong) ShareManager  *strongManager;
//默认是readwrite 对于外部引用是可读可写 设置readonly是只读
@property (nonatomic,strong,readonly) ShareManager  *strongManager2;
</code></pre>
</details>
----------------------------

##### `NSObject`中类方法`load`和`initialize` [load和initialize](http://blog.y500.me/initialize-vs-load/)

> 这两个类方法会在类被使用时主动调用，但是调用时机和调用顺序却截然不同。

- `initialize`方法是在该类接收到第一个消息之前调用.
- 父类的 `initialize` 方法先于子类的 `initialize` 方法调用.
- 如果子类中没有实现 `initialize` 方法，或者子类显示调用父类实现` [super initialize]`, 那么则会调用其父类的实现。也就是说，父类的 `initialize` 可能会被调用多次。
- 在应用程序生命周期里，`runtime` 只会向每个类发送一次 `initialize` 消息. 所以如果category中实现了`initialize`方法，那么原来类中的则不会被调用.
- `load`在类或者`category`被添加到`runtime`的时候调用，该调用发生在main函数之前
- 父类`load`方法先于子类调用，类本身`load`方法先于`category`中调用。
- 不需要在`load`和`initialize`方法中显式的去调用父类的方法。



## UI

### 一些常见的知识点

#####  UIView和CALayer的区别?

view: 负责用户交互,事件响应

layer: 负责绘制展示内容,隐式动画



##### 如何高效绘制圆角?

```objectivec
//采用贝塞尔曲线绘制 上下左右四个角 可大可小/可有可无/易于控制 
    //可选枚举
    typedef NS_OPTIONS(NSUInteger, UIRectCorner) {
        UIRectCornerTopLeft     = 1 << 0,
        UIRectCornerTopRight    = 1 << 1,
        UIRectCornerBottomLeft  = 1 << 2,
        UIRectCornerBottomRight = 1 << 3,
        UIRectCornerAllCorners  = ~0UL
    };

   UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerAllCorners) cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;


```



###  布局

#####  更新布局

- `layoutIfNeeded`强制更新布局
- `setNeedsDisplay`重绘,适用于需要重写`drawRect:`绘制的视图
- `updateConstraintsIfNeeded`标记需要更新约束,然后调用`layoutIfNeeded`才会生效

##### 纯代码

- 系统AutoLayout 
  - [iOS 自动布局总结篇](https://www.jianshu.com/p/c476f797fedc)
- frame布局
  -  [参考](https://www.jianshu.com/p/98c8e18d7fea)

> PS：bounds与frame有一定区别。
> bounds只用来描述视图的尺寸，就像一页A4纸，不论把它放在桌子上还是地板上，它的bounds都不发生变化。
> frame除了能够描述视图的尺寸外还能描述视图的位置。再如A4纸，从桌子上挪到地板上，它的frame就发生变化了

- Masonry约束布局
  -  [参考一](https://www.jianshu.com/p/587efafdd2b3) 
  -  [参考二](http://tutuge.me/2017/03/12/autolayout-example-with-masonry5/)
- StackView布局
  -  [参考](https://www.jianshu.com/p/19fbf3ee2840)
- 基于YogaKit的Flexbox布局
  - [iOS - FlexBox 布局之 YogaKit](https://www.cnblogs.com/baitongtong/p/11778738.html)

- 其他第三方布局库
  - [SDAutoLayout](https://github.com/gsdios/SDAutoLayout)
  - [MyLayout](https://github.com/youngsoft/MyLinearLayout)

##### IB拉线

 XIB结合代码

StoryBoard结合代码

> 利用`IB_DESIGNABLE`和`IBInspectable`修饰,然后再重写setter,在IB面板上即可出现添加可勾选☑️的属性列表,此方法适用自定义类,不建议在category中设置,category的话是比较耗性能,时不时爆个红~ 

```objectivec
IB_DESIGNABLE
@interface WGBCustomButton : UIButton

@property (nonatomic,assign) IBInspectable CGFloat space;
@property (nonatomic,assign) IBInspectable CGFloat   borderWidth;
@property (nonatomic,strong) IBInspectable  UIColor * borderColor;
@property (nonatomic,assign) IBInspectable CGFloat  radius;
@property (nonatomic,strong) IBInspectable  UIColor *bgColor;
@property (nonatomic,assign) IBInspectable  BOOL  buttonHighlighted;
@property (nonatomic,strong) IBInspectable  UIColor *selectedBgColor;
@property (nonatomic,strong) IBInspectable  UIColor *normalBgColor;

@end

```



### 生命周期

`UIViewController`生命周期

```objectivec
// 初始化构造方法
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSLog(@"%s", __FUNCTION__);
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    
    }
    return self;
}

// IB编译后解码
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
     NSLog(@"%s", __FUNCTION__);
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

// IB加载完成
- (void)awakeFromNib {
    [super awakeFromNib];
     NSLog(@"%s", __FUNCTION__);
}

// 加载视图 
- (void)loadView {
    NSLog(@"%s", __FUNCTION__);
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor redColor];
}

//视图加载完成
- (void)viewDidLoad {
    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
}


//视图将要出现
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
}

//将要布局子视图
- (void)viewWillLayoutSubviews {
    NSLog(@"%s", __FUNCTION__);
    [super viewWillLayoutSubviews];
}

//子视图布局(可能会被多次调用)
- (void)layoutSubviews{
    [super layoutSubviews];
    	//此处能够获取准确frame
}


// 子视图已经布局完毕
- (void)viewDidLayoutSubviews {
    NSLog(@"%s", __FUNCTION__);
    [super viewDidLayoutSubviews];
    	//此处能够获取准确frame
}

//视图已经出现
- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%s", __FUNCTION__);
    [super viewDidAppear:animated];
}

//视图将要消失
- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"%s", __FUNCTION__);
    [super viewWillDisappear:animated];
}

//视图已经消失
- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"%s", __FUNCTION__);
    [super viewDidDisappear:animated];
}

//出现内存警告  //模拟内存警告:点击模拟器->hardware-> Simulate Memory Warning
- (void)didReceiveMemoryWarning {
    NSLog(@"%s", __FUNCTION__);
    [super didReceiveMemoryWarning];
}

// 视图被销毁
- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

//控制台打印如下:
18:03:41.577 ViewControllerLifeCircle[32254:401790] -[ViewController initWithCoder:]
18:03:41.579 ViewControllerLifeCircle[32254:401790] -[ViewController awakeFromNib]
18:03:41.581 ViewControllerLifeCircle[32254:401790] -[ViewController loadView]
18:03:46.485 ViewControllerLifeCircle[32254:401790] -[ViewController viewDidLoad]
18:03:46.486 ViewControllerLifeCircle[32254:401790] -[ViewController viewWillAppear:]
18:03:46.487 ViewControllerLifeCircle[32254:401790] -[ViewController viewWillLayoutSubviews]
18:03:46.488 ViewControllerLifeCircle[32254:401790] -[ViewController viewDidLayoutSubviews]
18:03:46.488 ViewControllerLifeCircle[32254:401790] -[ViewController viewWillLayoutSubviews]
18:03:46.488 ViewControllerLifeCircle[32254:401790] -[ViewController viewDidLayoutSubviews]
18:03:46.490 ViewControllerLifeCircle[32254:401790] -[ViewController viewDidAppear:]
19:03:13.308 ViewControllerLifeCircle[32611:427962] -[ViewController viewWillDisappear:]
19:03:14.683 ViewControllerLifeCircle[32611:427962] -[ViewController viewDidDisappear:]
19:03:14.683 ViewControllerLifeCircle[32611:427962] -[ViewController dealloc]
19:12:05.927 ViewControllerLifeCircle[32611:427962] -[ViewController didReceiveMemoryWarning]
```



### 动画

##### UIView动画  [UIView动画UIView Animation总结](http://www.cocoachina.com/articles/19794)

- 常用的块动画

```objectivec
/// 参数一 : 时长  
/// 参数二 : 执行动画块
/// 参数三 : 动画结束时回调
[UIView animateWithDuration:0.25 animations:^{
  //做动画: 修改视图大小位置,透明度,颜色,transform等属性
} completion:^(BOOL finished) {
  //动画结束回调
}];       
/// 参数一 : 时长
/// 参数二 : 延时几秒执行
/// 参数三 : 动画函数枚举
/// 参数四 : 执行动画块
/// 参数五 : 动画结束时回调
[UIView animateWithDuration:0.25 delay:1.0 options:(UIViewAnimationOptionAllowUserInteraction) animations:^{
  //执行动画
} completion:^(BOOL finished) {
  //动画结束回调
}]; 
```

- `Spring`弹性动画

```objectivec
/// 参数一: 执行时长
    /// 参数二: 延时几秒执行
    /// 参数三: 阻尼值 0~1之间取值 值越小弹性越大
    /// 参数四: 初始速度 默认为0 值越大 动画执行的越快
    /// 参数五: 动画执行曲线函数
    /// 参数六: 执行动画块
    /// 参数七: 动画结束时回调
    [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        //执行动画
    } completion:^(BOOL finished) {
        //动画结束
    }];
```

- 视图转场动画

```objectivec
    UIView *aView = nil;//替换项目中实际的view
    UIView *bView = nil;//替换项目中实际的view
    //从一个视图过渡到另一个视图
    [UIView transitionFromView:aView toView:bView duration:0.25 options:(UIViewAnimationOptionCurveLinear) completion:^(BOOL finished) {
        //转场结束
    }];
    
    //单个视图向右翻转转场
    [UIView transitionWithView:aView duration:0.25 options:(UIViewAnimationOptionTransitionFlipFromRight) animations:^{
        //转场过程中 做一些改变
    } completion:^(BOOL finished) {
        //转场结束
    }];

```

##### 核心动画



## 网络

### http

>  超文本传输协议,是一种建立在TCP上的无状态连接，整个基本的工作流程是客户端发送一个HTTP请求，说明客户端想要访问的资源和请求的动作，服务端收到请求之后，服务端开始处理请求，并根据请求做出相应的动作访问服务器资源，最后通过发送HTTP响应把结果返回给客户端

 [HTTP协议超级详解](https://www.cnblogs.com/an-wen/p/11180076.html)

##### HEAD

工作中只用过一次,用于检测CDN回源,主要是获取Header中的字段值进行判断是否上报

##### GET

参数拼接到URL上是暴露的,相对于POST来说不安全(POST将参数放到body里),传输数据量小,受限于URL最大长度[*URL最大长度*问题 ](https://www.baidu.com/link?url=6QrTUOfAvDPuZo5IiUykxyECWlRjatZHflDTimgeKB3MMnAPlomQOXj1IKlsAwHrxAlGKixhByKSNZFXsYf4Q3eKbrqJ8d9wh5Zq1YJMdGu&wd=&eqid=ae2e0e330015c461000000055e7575ff)   表单默认请求方式数据集必须为ASCII,执行效率比POST高

##### POST

安全,参数不可见(放到body中),数据类型没有限制, 可传输的数据容量大([GET和POST可传递的值到底有多大？](https://www.cnblogs.com/zxj159/articles/2428376.html)) 

### TCP/UDP

tcp是长连接,能够保证传输数据的完整性

udp是发出去就不管的,容易丢包

 [TCP和UDP的最完整的区别](https://www.cnblogs.com/williamjie/p/9390164.html)

### Socket/WebSocket

socket: `应用层与TCP/IP协议族通信的中间软件抽象层，它是一组接口，提供一套调用TCP/IP协议的API`

websocket: `一种双向通信协议。在建立连接后，WebSocket服务器端和客户端都能主动向对方发送或接收数据，就像Socket一样；(而http服务端不能主动联系客户端，只能有客户端发起,太被动啦) ,只要建立一次HTTP请求，就可以连续不断的得到服务器推送的消息，节省带宽和服务器端的压力~`

### WebServer模拟本地接口请求数据

[盘点Mac上搭建本地WebServer的几种方式 ](https://www.cnblogs.com/wgb1234/p/12514220.html#/cnblog/works/article/12466122)

### 三次握手🤝/四次挥手👋

**三次握手(通道的建立):**   

> （1）在建立通道时，客户端首先要向服务端发送一个SYN同步信号。
>
> （2）服务端在接收到这个信号之后会向客户端发出SYN同步信号和ACK确认信号。
>
> （3）当服务端的ACK和SYN到达客户端后，客户端与服务端之间的这个“通道”就会被建立起来。

PS. 以上整个过程有点像叫人开门的感觉, 大声呼喊听得见吗? 听得见的话就把门打开, 然后对方清晰听到后把门开开,即成功建立连接,要是没听见(没连接上)或者没有听清楚(ack丢失了),那就得加大分贝多喊几次(反复发送ack直到确认) ... 

**四次挥手(通道的关闭):**

> （1）在数据传输完毕之后，客户端会向服务端发出一个FIN终止信号。
>
> （2）服务端在收到这个信号之后会向客户端发出一个ACK确认信号。
>
> （3）如果服务端此后也没有数据发给客户端时服务端会向客户端发送一个FIN终止信号。
>
> （4）客户端在收到这个信号之后会回复一个Ack确认信号，在服务端接收到这个信号之后，服务端与客户端的通道也就关闭了。

PS. 以上过程有点像黑帮交易验货~  到达交易约定地点之后,由甲方提出要验货,乙方听到后点了点头,然后让小弟把大箱子搬了出来,甲方打开之后验货没有问题,然后叫小弟把装钱的箱子提了上来交给乙方, 乙方清点之后也没有问题,银货两讫,各自退散~ 

## 多线程
#####  基本概念

1. 手机里每一个App就一个独立的进程,负责运行的程序内存分配,每个进程有独立的虚拟的内存空间, 线程是CPU执行任务的基本单元,是进程执行任务的路径
2. 队列: 串行和并行, 串行是一个任务接着一个任务执行,并行是指在不同队列即多个CPU同时执行不同的任务 (多核才有可能实现真正的并行)
3. 并发: 单核情况下,单位时间内多个任务快速切换执行,造成同时执行的假象(异步执行任务才有并发一说)
4. 同步和异步: 分配了一堆任务,同步是指阻塞式的一个任务执行完再执行下一个任务, 异步是指分不同优先级调度任务顺序来执行任务
5. 主线程和子线程: 每个进程必有一条线程即主线程,异步才会开子线程

#####  GCD 

1. 创建队列

```objectivec
// 队列类型
dispatch_queue_t

// 第一个参数：队列名称
// 第二个参数：队列类型
dispatch_queue_create(const char *label, dispatch_queue_attr_t attr);

/** 队列类型
  // 串行队列标识：本质就是NULL，但建议不要写成NULL，可读性不好
  DISPATCH_QUEUE_SERIAL
  // 并行队列标识
  DISPATCH_QUEUE_CONCURRENT
*/

//创建一条自定义并行队列
dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);


//创建全局并发队列
// 第一个参数：队列优先级 默认填0
// 第二个参数：保留参数，暂时无用，填0即可
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

// 全局并发队列的优先级
#define DISPATCH_QUEUE_PRIORITY_HIGH 2               // 高
#define DISPATCH_QUEUE_PRIORITY_DEFAULT 0            // 默认(中)
#define DISPATCH_QUEUE_PRIORITY_LOW (-2)             // 低
#define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN // 后台

//创建串行队列（队列类型传递DISPATCH_QUEUE_SERIAL或者NULL）
dispatch_queue_t queue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
// 主队列(特殊的串行队列)中的任务，都会放到主线程中执行
dispatch_queue_t queue = dispatch_get_main_queue();
```

常用的几种:

- `dispatch_once_t` 一次性代码块
- `dispatch_after和dispatch_time_t` 设置延时或者倒计时
- `dispatch_barrier_async` 栅栏函数,拦截之前任务执行完才让执行下一个
- `dispatch_group` 分组处理多任务统一回调问题
- `dispatch_semaphore_t` 信号量,线程同步,防止资源抢占

[OC高级-GCD使用总结](https://www.jianshu.com/p/77c5051aede2)

[iOS多线程：『GCD』详尽总结](https://juejin.im/post/5a90de68f265da4e9b592b40)

##### NSOperation

[OC高级-NSOperation 和 NSOperationQueue](https://www.jianshu.com/p/8ccf51bdbb2f)

 [iOS 多线程之NSOperation篇举例详解](https://www.cnblogs.com/zhanglinfeng/p/4980087.html)

## 设计模式  [参考](https://github.com/Binlogo/Design-Patterns-In-Swift-CN)

## 性能优化 [参考](https://www.jianshu.com/p/b8346c1a4145)

## 本地持久化方案

#####  本地数据库sqlite3.0+FMDB

-  [SQLite与FMDB的使用](https://www.cnblogs.com/guohai-stronger/p/9251131.html)

##### 归档

<details>
<summary> 查看归档相关代码 show the code </summary>
<pre> <code class="objectivec">
#import &ltFoundation/Foundation.h&gt
#import "YYModel.h"<br>
@interface Person : NSObject&ltNSCoding, NSCopying&gt
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *age;
@end<br><br>#import "Person.h"
@implementation Person
//重写以下几个方法 
- (void)encodeWithCoder:(NSCoder*)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super init];
    return [self yy_modelInitWithCoder:aDecoder];
}
- (id)copyWithZone:(NSZone*)zone {
    return [self yy_modelCopy];
}
- (NSUInteger)hash {
    return [self yy_modelHash];
}
- (BOOL)isEqual:(id)object {
    return [self yy_modelIsEqual:object];
}
@end<br><br>#import &ltUIKit/UIKit.h&gt<br>
@interface ViewController : UIViewController
@end<br><br>#import "ViewController.h"
#import "Person.h"
<br>#define KDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject]<br><br>#define kPersonInfoPath [KDocumentPath stringByAppendingPathComponent:@"personInfo.archiver"]
<br>@interface ViewController ()<br>
@end
<br>
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
<br>
//先存档  然后屏蔽这段代码  看看是否归档到了本地
//    NSMutableArray *dataArray =[NSMutableArray array];
//
//    for (NSInteger i = 10; i &lt 20 ; i++) {
//        Person * p =[Person new];
//        p.name = [NSString stringWithFormat:@"name==-%ld",i];
//        p.age = [NSString stringWithFormat:@"+++%ld岁",i];
//        [dataArray addObject:p];
//    }
//
//    BOOL ret =  [NSKeyedArchiver archiveRootObject:dataArray toFile:kPersonInfoPath];
//
//    if (ret) {
//        NSLog(@"归档成功");
//    }else{
//        NSLog(@"归档失败");
//    }
    NSArray *arr =[NSKeyedUnarchiver unarchiveObjectWithFile:kPersonInfoPath];
    for (Person *p in arr) {
        NSLog(@"名字%@,年龄%@", p.name,p.age);
    }
}
@end
</code>
</pre>
</details>
-------

##### keychain

这个需要绑定唯一标识,不会因为应用卸载而消除,可以重置系统或者手动删除

#####  写文件到沙盒

- Document目录,一般持久化的数据都存储在这个目录,iCloud会自动备份Document中的所有文件,一般重要的文件存储在这里

```objectivec
NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
```

- tmp临时目录,临时文件夹里面的文件，由系统回收， 如磁盘内存不足，重启手机，应用进程杀掉，都会清除临时文件,系统自动管理该目录的文件

```objectivec
NSString *tmpDir = NSTemporaryDirectory();
```



- Library 存储默认设置或者一些状态信息

  - Library/Caches 缓存目录,iCloud不会备份,系统不会自动清除,需要写代码去清除 

  ```objectivec
  NSString *cacheDir =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastobject];
  ```

  - Library/Preferences 存储偏好设置 NSUserDefaults



## Runtime

- 黑魔法方法交换实现

```objectivec
//实例方法交换
+ (void)wgb_swizzleInstanceMethodWithClass:(Class)originClass
                          OriginMethod:(SEL)originMethod
                         swappedMethod:(SEL)swappedMethod {
    
    SEL originalSelector = originMethod;
    SEL swappedSelector = swappedMethod;
    
    Method originalMethod = class_getInstanceMethod(originClass, originalSelector);
    Method newMethod = class_getInstanceMethod(originClass, swappedSelector);
    
    BOOL didAddMethod = class_addMethod(originClass, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (didAddMethod) {
        class_replaceMethod(originClass, swappedSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}
//类方法交换
+ (void)wgb_swizzleClassMethodWithClass:(Class)originClass
                       OriginMethod:(SEL)originMethod
                      swappedMethod:(SEL)swappedMethod {
    SEL originalSelector = originMethod;
    SEL swappedSelector = swappedMethod;
    
    Method originalMethod = class_getClassMethod(originClass, originalSelector);
    Method newMethod = class_getClassMethod(originClass, swappedSelector);
    
    BOOL didAddMethod = class_addMethod(originClass, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (didAddMethod) {
        class_replaceMethod(originClass, swappedSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

```

- category中生成关联对象

```objectivec
@property (nonatomic,assign) NSInteger totalScore; 

-(void)setTotalScore:(NSInteger)totalScore{
    objc_setAssociatedObject(self, @selector(totalScore), @(totalScore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSInteger)totalScore{
    id value = objc_getAssociatedObject(self, _cmd);
    return [value integerValue];
}

```

- 字典转模型

```objectivec
- (instancetype)initWithDict:(NSDictionary *)dict {

    if (self = [self init]) {
        //(1)获取类的属性及属性对应的类型
        NSMutableArray * keys = [NSMutableArray array];
        NSMutableArray * attributes = [NSMutableArray array];
        /*
         * 例子
         * name = value3 attribute = T@"NSString",C,N,V_value3
         * name = value4 attribute = T^i,N,V_value4
         */
        unsigned int outCount;
        objc_property_t * properties = class_copyPropertyList([self class], &outCount);
        for (int i = 0; i < outCount; i ++) {
            objc_property_t property = properties[i];
            //通过property_getName函数获得属性的名字
            NSString * propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            [keys addObject:propertyName];
            //通过property_getAttributes函数可以获得属性的名字和@encode编码
            NSString * propertyAttribute = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
            [attributes addObject:propertyAttribute];
        }
        //立即释放properties指向的内存
        free(properties);

        //(2)根据类型给属性赋值
        for (NSString * key in keys) {
            if ([dict valueForKey:key] == nil) continue;
            [self setValue:[dict valueForKey:key] forKey:key];
        }
    }
    return self;

}
```

- 消息动态转发

```objectivec
- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params
{
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        return nil;
    }
    const char* retType = [methodSig methodReturnType];
    
    if (strcmp(retType, @encode(void)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        return nil;
    }
    
    if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(BOOL)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(CGFloat)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
}

```

- 实现`NSCoding`自动归档和解档

```objectivec
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int outCount;
        Ivar * ivars = class_copyIvarList([self class], &outCount);
        for (int i = 0; i < outCount; i ++) {
            Ivar ivar = ivars[i];
            NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList([self class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}
```



## Runloop

[参考一]( https://github.com/qiaoyoung/RunLoop)

[参考二]( https://github.com/diwu/RunLoopWorkDistribution)

[iOS RunLoop](https://www.jianshu.com/p/413811babe1e)

## 音视频处理

### 音频

##### 

- [iOS音频掌柜-- AVAudioSession](https://www.jianshu.com/p/3e0a399380df)

- [AVAudioSession管理需要注意的问题](https://www.jianshu.com/p/c1195f90f081)

#####  录制

```objectivec
-(void)setupRecorder{
    //设置音频会话
    NSError *sessionError;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&sessionError];
    if (sessionError){
        NSLog(@"Error creating session: %@",[sessionError description]);
    }else{
        [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    }
    //录音设置
    //创建录音文件保存路径
    NSURL *url = [self getSavePath];
    //创建录音机
    NSError *error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.setting error:&error];
    if (error) {
        NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
    }
    _audioRecorder.delegate = self;
    _audioRecorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
    [_audioRecorder prepareToRecord];
    if (![_audioRecorder isRecording]) {
        [_audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
    }
}

// !!!: 录音设置
-(NSDictionary *)setting{
    if (_setting==nil) {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        //录音格式
        [setting setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
        //采样率，8000/11025/22050/44100/96000（影响音频的质量）,8000是电话采样率
        [setting setObject:@(22050) forKey:AVSampleRateKey];
        //通道 , 1/2
        [setting setObject:@(2) forKey:AVNumberOfChannelsKey];
        //采样点位数，分为8、16、24、32, 默认16
        [setting setObject:@(16) forKey:AVLinearPCMBitDepthKey];
        //是否使用浮点数采样
        [setting setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
        // 录音质量
        [setting setObject:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
        //....其他设置等
    }
    return _setting;
}

//默认录制是PCM格式的 也可直接设置录制aac格式
let recordSettings:[String : AnyObject] = [
            AVFormatIDKey:             NSNumber(value: kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey : NSNumber(value:AVAudioQuality.max.rawValue),
            AVNumberOfChannelsKey:     NSNumber(value:2),
            AVSampleRateKey :          NSNumber(value:11025.0),
            //AVEncoderBitRateKey:       NSNumber(value:64000),
            AVLinearPCMBitDepthKey:    NSNumber(value:16)
            ]

```

##### 播放

- AudioServicesCreateSystemSoundID(url,soundId)  用于播放音效 
- AVPlayer  本地/远程的音视频均可播放
- AVAudioPlayer 只支持播放本地音频文件
- AudioToolbox中的Audio Queue Services

##### 转格式

- wav [参考WAV文件格式](https://www.jianshu.com/p/5a91edee4871)
- aac 体积小,音质尚可,手机语音音频传输用得多 可直接录制 [iOS下解码AAC并播放](https://www.jianshu.com/p/5b12022cdc88)
- mp3 早期音乐音频格式 [wav转mp3](https://www.jianshu.com/p/45a520d6b05e)
- amr 安卓的比aac体积还小的音频格式 [amr和wav互转](https://github.com/WangGuibin/AmrToWav)

[iOS的音频文件的格式转换](https://github.com/qq631192328/PFAudioLib)

[Mac终端音频格式转换](https://www.jianshu.com/p/a3de5e777692)

### 视频

#####  录制

- 通过系统相机的录制
- 基于`AVFoundation`自定义相机
- 第三方GPUImage自定义相机

##### 播放

- AVPlayer 需要自定义UI
- AVPlayerViewController 封装好的拿来即用

##### 转格式

录制格式为mov需要转成mp4

```objectivec
+ (void)convertAvcompositionToAvasset:(AVURLAsset *)composition presentName:(NSString *)presentName completion:(void (^)(AVAsset * _Nonnull, NSURL * _Nonnull))completion {
    // 导出视频
    AVAssetExportSession *exporter = [AVAssetExportSession exportSessionWithAsset:composition presetName:presentName];
    // 生成一个文件路径
    NSInteger randNumber = arc4random();
    NSString *exportPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%ldvideo.mp4", (long)randNumber]];
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    // 导出
    if (exporter) {
        exporter.outputURL = exportURL;  // 设置路径
        exporter.outputFileType = AVFileTypeMPEG4;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (AVAssetExportSessionStatusCompleted == exporter.status) {   // 导出完成
                    NSURL *URL = exporter.outputURL;
                    AVAsset *avAsset = [AVAsset assetWithURL:URL];                    
                    if (completion) {
                        completion(avAsset, URL);
                    }
                } else {
                    if (completion) {
                        completion(nil, nil);
                    }
                }
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(nil, nil);
            }
        });
    }
}

```



##### 存储到相册

`和保存图片到相册类似的C接口`

```objectivec

// Adds a video to the saved photos album. The optional completionSelector should have the form:
//  - (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
UIKIT_EXTERN void UISaveVideoAtPathToSavedPhotosAlbum(NSString *videoPath, __nullable id completionTarget, __nullable SEL completionSelector, void * __nullable contextInfo) API_AVAILABLE(ios(3.1)) API_UNAVAILABLE(tvos);

```





