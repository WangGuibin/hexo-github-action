---
title: 'iOS如何简单实现绘制爱心?'
date: 2020-03-22 17:36:05
tags: [Objective-C,iOS,CSS,前端,大前端]
published: true
hideInList: false
isTop: false
---
> 灵感来源于前端CSS画红心的原理  [参考](https://www.cnblogs.com/yingzi1028/p/6248937.html)

![](https://github.com/WangGuibin/MyFilesRepo/images/heart_demo.png)

<!-- more -->



# 上代码
```objectivec

#import <UIKit/UIKit.h>
/**
    灵感来自于前端CSS画红心的原理: 一个正方形 + 两个圆 + 整体旋转一定的角度
*/

NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface WGBHeartView : UIView
//❤心有多大?
@property (nonatomic,assign) IBInspectable CGFloat heartSize;
//❤心的颜色?
@property (nonatomic,strong) IBInspectable UIColor *heartColor;
@end
NS_ASSUME_NONNULL_END


#import "WGBHeartView.h"

@interface WGBHeartView()

@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIView *leftView;
@property (nonatomic,strong) UIView *rightView;

@end

@implementation WGBHeartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfig];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initConfig];
    }
    return self;
}

- (void)initConfig{
        //默认值
    self.heartSize = 150.0;
    self.heartColor = [UIColor redColor];
    [self addSubview: self.bottomView];
    [self addSubview: self.leftView];
    [self addSubview: self.rightView];
    //提前旋转45度
    self.transform = CGAffineTransformMakeRotation(M_PI_4);
}

//去除设置背景色 
- (void)setBackgroundColor:(UIColor *)backgroundColor{
    backgroundColor = [UIColor clearColor];
    [super setBackgroundColor:backgroundColor];
}

- (void)setHeartSize:(CGFloat)heartSize{
    _heartSize = heartSize;
    CGFloat partSize = heartSize/3.0;
    self.bottomView.frame = CGRectMake(partSize, partSize, partSize*2 , partSize*2);
    self.leftView.frame = CGRectMake(0, partSize, partSize*2 , partSize*2);
    self.rightView.frame = CGRectMake(partSize, 0, partSize*2 , partSize*2);
    
    self.leftView.layer.cornerRadius = partSize;
    self.rightView.layer.cornerRadius = partSize;
}

- (void)setHeartColor:(UIColor *)heartColor{
    _heartColor = heartColor;
    self.bottomView.backgroundColor = heartColor;
    self.leftView.backgroundColor = heartColor;
    self.rightView.backgroundColor = heartColor;
}

    ///MARK:- lazy load
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_bottomView];
    }
    return _bottomView;
}
- (UIView *)leftView{
    if (!_leftView) {
        _leftView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_leftView];
    }
    return _leftView;
}

- (UIView *)rightView{
    if (!_rightView) {
        _rightView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_rightView];
    }
    return _rightView;
}

@end

```
![IB设置的过程](https://github.com/WangGuibin/MyFilesRepo/images/heart2IB.png)

# 简单调用如下: 
```objectivec
    WGBHeartView *heartView = [[WGBHeartView alloc] initWithFrame:CGRectMake(100, 100, 100 , 100)];
    heartView.heartColor = [UIColor blackColor];//默认颜色是红色
    heartView.heartSize = 100; //这个尺寸最好是设置与视图宽高一致 生成的爱心❤️比较规则
    [self.view addSubview: heartView];
    
    for (NSInteger i = 0; i < 6; i += 1) {
        CGFloat heartWH = 50.0f;
        CGFloat margin = 15.0f;
        WGBHeartView *heartItemView = [[WGBHeartView alloc] initWithFrame:CGRectMake(20 + (heartWH+margin)*i,   250, heartWH , heartWH)];
        heartItemView.heartColor = [UIColor colorWithRed:arc4random()%256/255.0f green:arc4random()%256/255.0f  blue:arc4random()%256/255.0f alpha:1.0f];
        heartItemView.heartSize = heartWH;
        [self.view addSubview: heartItemView];
    }

```

