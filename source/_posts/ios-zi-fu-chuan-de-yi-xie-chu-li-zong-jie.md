---
title: 'iOS字符串的一些处理总结'
date: 2019-04-18 20:02:56
tags: [学习总结,iOS,swift,Objective-C]
published: true
hideInList: false
feature: /post-images/ios-zi-fu-chuan-de-yi-xie-chu-li-zong-jie.jpg
---
**最近比较忙,一直陷入业务的泥沼不可自拔,很少有时间独立思考作作总结,因为平时上班遇到问题就是打开浏览器各种搜寻轮子,百分之八九十的问题也能解决,但是对于个人成长还是感觉有所缓慢,最近开始总结项目的点点滴滴,需要开始写写博客了,那就从基础的笔记写起吧,熟能生巧,由浅入深,这是一个良性的开端。**

<!-- more -->

#### 1. 汉字转拼音,用的系统的API `CFStringTransform `
```objc
///MARK:- 汉字转拼音 是否需要声调
+ (NSString *)hanziTransformPinyin:(NSString *)chinese
                     needVoiceTone:(BOOL)needTone{
    //将NSString装换成NSMutableString
    NSMutableString *pinyin = [chinese mutableCopy];
    //将汉字转换为拼音(带音标)
    if (needTone) {
        CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    }else{
        //去掉拼音的音标
        CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
        CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    }
    NSString *pinYinStr = pinyin;
    //去除掉首尾的空白字符和换行字符
    pinYinStr = [pinYinStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //去除掉其它位置的空白字符和换行字符
    pinYinStr = [pinYinStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    pinYinStr = [pinYinStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    pinYinStr = [pinYinStr stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSLog(@"去掉空白字符和换行字符的pinyin: %@", pinYinStr);
//    [pinYinStr capitalizedString];//首字母大写
    return pinYinStr;
    
}

```
#### 2. 纯英文输入,记得之前记录过设置安全键盘可以实现[限制输入中文和emoji表情的另类实现](https://www.jianshu.com/p/82c5a1ea8763),即设置输入框的属性`secureTextEntry ` ,根据键盘的弹出和隐藏动态切换,但是有一点小小的瑕疵(`在支持touchID的手机,键盘上方会出现一个小圆圈,就是类似钥匙串的玩意儿,点击之后,验证touchID,然后会看到自己以往在iCloud记录的账户密码.... 安全以及UI方面不是很符合要求`),在这里介绍另一种实现方式
```objc
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//指定输入的字符内容
NSString * kLetterVerifyInput = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:kLetterVerifyInput] invertedSet];//与英文取反的集合
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];//过滤并拼接起来
        return [string isEqualToString:filtered]; //如果匹配了这个非英文集合 则不会出现在输入框里
}
```

#### 3. 利用正则过滤字符
```objc
//根据正则，过滤特殊字符
- (NSString *)filterCharactor:(NSString *)string withRegex:(NSString *)regexStr{
    NSString *searchText = string;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:searchText options:NSMatchingReportCompletion range:NSMakeRange(0, searchText.length) withTemplate:@""];
    return result;
}
```

#### 4. 只能输入中文和只输入英文的处理(`标点符号之类的需要自己额外处理一下`)

```objc
  // 监听处理输入的字符串 把不符合要求的字符串替换掉
   @weakify(self);
    [self.nameTextfield.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        if(!x.length){
            return ;
        }
        if (self.selectedBtn.tag == 1) {
            //中文
            if (![NSString isChineseCharacter:x]) {
                //过滤非中文字符
                self.nameTextfield.text = [self filterCharactor:x withRegex:@"[^\u4e00-\u9fa5]"];
                return ;
            }
        }else{
            //英文
            NSString *lastStr = [x substringWithRange:NSMakeRange(x.length-1, 1)];
            if (![kLetterVerifyInput containsString:lastStr]) {
                self.nameTextfield.text = [x substringToIndex: x.length - 1];
                return ;
            }
        }
        self.nameTextfield.text = [self.nameTextfield.text removeWhiteSpacesFromString];//移除空格
        if (self.nameTextfield.text.length > 10) {//限制输入的长度
            self.nameTextfield.text = [self.nameTextfield.text substringToIndex:10];
        }
    }];
```

#### 5. 一些判断纯中文,纯英文,纯数字的正则的方法
```objc
//限制中文输入 判断是否中文
+ (BOOL)isChineseCharacter:(NSString*)source {
    //参考了 https://www.jianshu.com/p/b40b3c618fec
    NSString *regex = @"^[\\u4E00-\\u9FEA]+$";
    return ([source rangeOfString:regex options:NSRegularExpressionSearch].length>0);
}
//严格限制英文输入
+ (BOOL)isEnglishCharacter:(NSString*)source {
    NSString *upperRegex = @"^[\\u0041-\\u005A]+$";
    NSString *lowerRegex = @"^[\\u0061-\\u007A]+$";
    BOOL isEnglish = (([source rangeOfString:upperRegex options:NSRegularExpressionSearch].length>0) || ([source rangeOfString:lowerRegex options:NSRegularExpressionSearch].length>0));
    return isEnglish;
}
//判断数字
+ (BOOL)isNumber:(NSString*)source {
    NSString *regex = @"^[\\u0030-\\u0039]+$";
    return ([source rangeOfString:regex options:NSRegularExpressionSearch].length>0);
}
```

#### 6. URL含有中文或者百分号`%`,有时候需要根据业务需求编码或者解码,如下:
```objc
//以下是添加的NSString的category方法
///MARK:- URL包含中文转码 编码/Encode
- (NSString *)urlEncodeUTF8String{
    if (@available(iOS 9.0, *)) {
        NSString  *newUrlString = [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        return newUrlString;
    }else{
        NSString  *newUrlString = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return newUrlString;
    }
}
///MARK:- URL包含中文百分号的形式 需要转成中文 解码/Decode
- (NSString *)urlDecodeUTF8String{
    if (@available(iOS 9.0, *)) {
        NSString  *newUrlString = [self stringByRemovingPercentEncoding];
        return newUrlString;
    }else{
        NSString *newUrlString = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return newUrlString;
    }
}
```

#### 7.   解析URL的参数 即问好后面的参数键值对,入参是 `[url query]` 值得注意的是如果urlString含有中文的话,调用` [url query]`是读不出数据`(null)`, 我认为采用字符串截取比较安全的做法,不用转来转去,我也是这样做的  
```objc
    // 扫二维码或者什么操作获取一段URLString 即
    if (![URLString containsString:@"?"]) {
          // 没问号 做其他处理
         return ;
      }
      // 有问号去解析参数
      NSInteger location = [URLString rangeOfString:@"?"].location + 1;
     NSString *query = [URLString substringFromIndex: location];
    获取到query 自然就可以获取到参数字典

+ (NSDictionary*)dictionaryFromQuery:(NSString*)query{
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&"];//分割键值对
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="]; //提取键值
        if (kvPair.count == 2) {//字典一个键 一个值
            NSString* key = [[kvPair objectAtIndex:0] stringByRemovingPercentEncoding];
            NSString* value = [[kvPair objectAtIndex:1] stringByRemovingPercentEncoding];
            [pairs setObject:value forKey:key];
        }
    }
    return [NSDictionary dictionaryWithDictionary:pairs];
}
```

#### 8. 提取字符串中的数字部分 (`局限是会把所有数字都提取出来 可以自己使用逗号分隔,数组切割区分,因为我当时的需求是一串字符串中有且只有一串连续的数字  所有全部提取出来就是了`)
```objc
- (NSString *)getNumberFromString{
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return[[self componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
}
```

#### 9.  全角标点符号转半角符号
```objc
- (NSString *)full2HalfWithNSString:(NSString *)string {
    if (nil == string || [@"" isEqual:string]) {
        return @"";
    }
    NSMutableString *convertedString = [string mutableCopy];
    CFStringTransform((CFMutableStringRef)convertedString, NULL, kCFStringTransformFullwidthHalfwidth, false);
    NSString *newString = [NSString stringWithString:convertedString];
    newString = [newString stringByReplacingOccurrencesOfString:@"　" withString:@" "];
    newString = [newString stringByReplacingOccurrencesOfString:@"‘" withString:@"'"];
    newString = [newString stringByReplacingOccurrencesOfString:@"’" withString:@"'"];
    newString = [newString stringByReplacingOccurrencesOfString:@"`" withString:@"'"];
    newString = [newString stringByReplacingOccurrencesOfString:@"‚" withString:@","];
    newString = [newString stringByReplacingOccurrencesOfString:@"，" withString:@","];
    newString = [newString stringByReplacingOccurrencesOfString:@"；" withString:@";"];
    newString = [newString stringByReplacingOccurrencesOfString:@"｡" withString:@"."];
    newString = [newString stringByReplacingOccurrencesOfString:@"？" withString:@"?"];
    newString = [newString stringByReplacingOccurrencesOfString:@"！" withString:@"!"];
    newString = [newString stringByReplacingOccurrencesOfString:@"--" withString:@"—"];
    return newString;
}
```

