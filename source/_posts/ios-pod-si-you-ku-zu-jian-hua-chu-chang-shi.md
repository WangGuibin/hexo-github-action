---
title: 'iOS pod私有库组件化初尝试'
date: 2019-03-26 20:22:12
tags: [cocopods,组件化,git,设计模式,学习总结,iOS]
published: true
hideInList: false
feature: https://api.lyiqk.cn/purelady?cdd6a546
isTop: false
---

​	很早以前就听说过组件化,但那个时候只是浅显的以为只有web前端才有的东西,现如今早已是大前端时代,组件化自然也是在业界普及,没有真正自己去实操这个东西,就犹如附骨之疽,很难受~ 
什么叫组件化呢? 带着这个问题去寻找答案。

<!-- more -->

   > 百度百科
   >
   > > 组件化是指解耦复杂系统时将多个功能模块拆分、重组的过程，有多种属性、状态反映其内部特性。

看字面意思,也大概能获取一些信息,比如`解耦`,`模块拆分`,`重组`等, 其实就把软件工程形容成一家大工厂, 写代码就是生产各种零配件, 生产到组装的一系列的过程活动就是组件化。

举两个耳熟能详的例子吧:

- A女士在微信上收到朋友的一条淘宝吱口令链接,她根据信息提示复制之后打开淘宝App, 淘宝一启动弹出提示框,询问是否跳转该商品了解详情, 点击是直接跳到一个路径比较深的页面(平时正常访问都是要列表或者某个具体的商品点击之后才能呈现的页面)
- B先生在某浏览器上查找一个问题,刷到一个知乎的回答,但是只显示了一半,需要打开App才能阅读全文以及回复评论等操作,点击那个引导按钮,浏览器唤起知乎App,知乎跳转了该问题的回答列表

以上均是日常可见的组件化场景,这种国民级的应用无需我来打广告了吧(避嫌)

其实组件化的方案有很多种,什么url-block,protocol-class, target-action等, 它们共同的特点就是独立出一个中间层/中间件, 用于处理调度业务的一个逻辑层, 使其业务模块解耦。

业界流行代表作: 

[MGJRouter](https://github.com/meili/MGJRouter)

[CTMediator](https://github.com/casatwy/CTMediator)

[BeeHive](https://github.com/alibaba/BeeHive/blob/master/README-CN.md)



我参考的是`casa`大佬的[CTMediator](https://github.com/casatwy/CTMediator),因为它短小精悍, 容易理解和实践。

就仅仅两个接口

```objective-c
// 远程App调用入口
- (id)performActionWithUrl:(NSURL *)url completion:(void(^)(NSDictionary *info))completion;
// 本地组件调用入口
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget;
```

实践步骤:

## 1. 利用category独立业务模块,利用runtime运行时调用action的方法,获取业务对象供外部使用

```objective-c
@interface CTMediator (CTMediatorModuleAActions)

- (UIViewController *)CTMediator_viewControllerForDetail;

@end
  
NSString * const kCTMediatorTargetA = @"A"; //模块A
NSString * const kCTMediatorActionNativFetchDetailViewController = @"nativeFetchDetailViewController"//方法名
  
@implementation CTMediator (CTMediatorModuleAActions)

- (UIViewController *)CTMediator_viewControllerForDetail{
    UIViewController *viewController = [self performTarget: kCTMediatorTargetA
                              action: kCTMediatorActionNativFetchDetailViewController
                              params: @{@"key":@"value"} //参数
                   shouldCacheTarget:NO  //是否缓存
                                   ];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[UIViewController alloc] init];
    }
}
@end

  
```



## 2. 建立Target_Actions,实现返回对应的业务对象

```objective-c
@interface Target_A : NSObject
//CTMediator里的规则是 `Action_`+ `actionName` + `:`匹配
- (UIViewController *)Action_nativeFetchDetailViewController:(NSDictionary *)params;

@end

@implementation Target_A

- (UIViewController *)Action_nativeFetchDetailViewController:(NSDictionary *)params{
    // 因为action是从属于ModuleA的，所以action直接可以使用ModuleA里的所有声明
    DemoModuleADetailViewController *viewController = [[DemoModuleADetailViewController alloc] init];
    viewController.valueLabel.text = params[@"key"];
    return viewController;
}
@end
```



## 3. 使用者调用组件,获取业务对象处理业务,实现组件化

```objective-c
    if (indexPath.row == 0) {
        UIViewController *viewController = [[CTMediator sharedInstance] CTMediator_viewControllerForDetail];
        
        // 获得view controller之后，在这种场景下，到底push还是present，其实是要由使用者决定的，mediator只要给出view controller的实例就好了
        [self presentViewController:viewController animated:YES completion:nil];
    }
    
    if (indexPath.row == 1) {
        UIViewController *viewController = [[CTMediator sharedInstance] CTMediator_viewControllerForDetail];
        [self.navigationController pushViewController:viewController animated:YES];
    }

```



很久没写文章了,那就水这么一篇吧 



​																	于 2019年03月26日 深圳宝安



参考博文

[iOS 从零到一搭建组件化项目框架](https://www.jianshu.com/p/59c2d2c4b737)

[iOS组件化的几种实现](https://www.cnblogs.com/fishbay/p/7216084.html)







