---
title: 'iOS的AES 128加密解密的两种模式(CBC和ECB)'
date: 2020-03-09 14:30:35
tags: []
published: true
hideInList: false
feature: /post-images/ios-de-aes-128-jia-mi-jie-mi-de-liang-chong-mo-shi-cbc-he-ecb.png
isTop: false
---
 **关于AES加密解密原理什么的不在本篇的范畴,网上很多大牛总结的很好了 
 
 <!-- more -->

 请参考[AES加密过程详解](https://blog.csdn.net/qq_38289815/article/details/80900813)**


**1. 苹果默认是`CBC`模式的,有文档为证:**

```objc
/*!
    @enum       CCOptions
    @abstract   Options flags, passed to CCCryptorCreate().

    @constant   kCCOptionPKCS7Padding   Perform PKCS7 padding.
    @constant   kCCOptionECBMode        Electronic Code Book Mode.
                                        Default is CBC.
*/
enum {
    /* options for block ciphers */
    kCCOptionPKCS7Padding   = 0x0001,
    kCCOptionECBMode        = 0x0002
    /* stream ciphers currently have no options */
};
```
**2. 一般来说,我们客户端单纯只是做做业务的话,接触的加密算法或者需要我们去深入底层的东西少之又少,通常是后端提供加密的`key`(秘钥)和`iv`(偏移量)给前端小伙伴们使用.** 

**3. `CBC`和`EBC`,在调用方看来,仅仅只是一个枚举值的区别**
```objc
//CBC模式
kCCOptionPKCS7Padding
//ECB模式
kCCOptionPKCS7Padding | kCCOptionECBMode
```
**4. 下面👇贴一段`ECB`加密解密的代码**
```objc
@implementation NSData (AESEncryption)

//AES128加密
- (NSData *)AES128ParmEncryptWithKey:(NSString *)key iv:(NSString *)iv
{
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];

    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

//解密
- (NSData *)AES128ParmDecryptWithKey:(NSString *)key iv:(NSString *)iv
{
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

@end

```
**5. 最后在[Demo地址](https://github.com/WangGuibin/TestDemo/tree/master/TestAES128/TestAES128)**