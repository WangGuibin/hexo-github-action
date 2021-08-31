---
title: "iOS音频流混音实践"
date: 2021-08-31 21:32:53
tags: [音频处理,音视频,踩坑记录]
published: true
isTop: false
---


**背景:**

>  xx项目某个业务流程的某个功能,需要采集用户的操作全过程(录屏+录音),初看需求时,想到`ReplayKit `是最切合需求的,因为ReplayKit系统录屏自带三路数据分别是视频帧数据`CMSampleBuffer`, `App`音频`PCM CMSampleBuffer`,麦克风音频`PCM CMSampleBuffer`,如此一来需求瞬间就解决了,但是后来因为麦克风权限被另一个三方通话`VoIP`功能的`SDK`抢占了,所以麦克风数据只能由他们提供,并且授权弹窗老是被用户拒绝,所以`ReplayKit`录屏方案被领导否了,另外`App`内部播放的声音也是一样需求业务方提供,如此一来,录屏获取图像可以换成定时器(`CADisplayLink`)+截图(绘制图层获取`UIImage`转`CVPixelBuffer`)生成视频的方案,而音频推流只能通过混音才能保证音画同步~

<!-- more -->

####  定时器 + 截图实现录屏功能的核心代码

```objc
///MARK:- 起一个CADisplayLink定时器 通过CGImageRef => CVPixelBufferRef 
- (void)snapshotWithImage {
    @autoreleasepool {
        //通过Graphics context拿到截屏图片
        UIGraphicsBeginImageContextWithOptions(self.recordView.bounds.size, NO, 0);
      //这种方式生成的视频可以录制到动画 但是局限性也很明显比如视频和相机预览的图层无法捕捉到以及系统的一些组件(键盘...等)也无法录制到
        [self.recordView drawViewHierarchyInRect:self.recordView.bounds afterScreenUpdates:NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //UIImage 对象获取 CGImageRef
        CGImageRef imgRef = image.CGImage;
        // CGImage => bitmap
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                                 nil];

        CVPixelBufferRef pixelBuffer = NULL;
        CGFloat frameWidth = CGImageGetWidth(imgRef);
        CGFloat frameHeight = CGImageGetHeight(imgRef);
        //创建CVPixelBuffer
        CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                              frameWidth,
                                              frameHeight,
                                              kCVPixelFormatType_32ARGB,
                                              (__bridge CFDictionaryRef) options,
                                              &pixelBuffer);

        NSParameterAssert(status == kCVReturnSuccess && pixelBuffer != NULL);
        //上锁
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        //获得基地址
        void *pxdata = CVPixelBufferGetBaseAddress(pixelBuffer);
        NSParameterAssert(pxdata != NULL);
        //获取设备的颜色通道
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        //创建bitmap
        CGContextRef context = CGBitmapContextCreate(pxdata,
                                                     frameWidth,
                                                     frameHeight,
                                                     8,
                                                     CVPixelBufferGetBytesPerRow(pixelBuffer),
                                                     rgbColorSpace,
                                                     (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
        NSParameterAssert(context);
        //transform调整
        CGContextConcatCTM(context, CGAffineTransformIdentity);
        // 画图
        CGContextDrawImage(context, CGRectMake(0,0,frameWidth,frameHeight),imgRef);
        //释放
        CGColorSpaceRelease(rgbColorSpace);
        //回调出去 推流处理或者显示 此处也可利用`AVAssetWriter`写入本地视频文件
      if (pixelBuffer != NULL) {
            !self.screenRecordCallback? : self.screenRecordCallback(pixelBuffer);
          }
        //释放上下文
        CGContextRelease(context);
        //解锁
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        //释放buffer
        CVPixelBufferRelease(pixelBuffer);
    }
}

```



####  混音的前提条件 

混音原理介绍可参考 [使用这个混音技术，你也能与爱豆隔空对唱](https://zhuanlan.zhihu.com/p/42110735)

> 并非任何两路音频流都可以直接混合。两路音视频流，必须符合以下条件才能混合：
>
> 
>
> - 格式相同，要解压成 PCM 格式。
> - 采样率相同，要转换成相同的采样率。主流采样率包括：16k Hz、32k Hz、44.1k Hz 和 48k Hz。
> - 帧长相同，帧长由编码格式决定，PCM 没有帧长的概念，开发者自行决定帧长。为了和主流音频编码格式的帧长保持一致，推荐采用 20ms 为帧长。
> - 位深（Bit-Depth）或采样格式 (Sample Format) 相同，承载每个采样点数据的 bit 数目要相同。
> - 声道数相同，必须同样是单声道或者双声道 (立体声)。这样，把格式、采样率、帧长、位深和声道数对齐了以后，两个音频流就可以混合了。
>
> 
>
> 在混音之前，还需要做回声消除、噪音抑制和静音检测等处理。回声消除和噪音抑制属于语音前处理范畴的工作。在编码之前，采集、语音前处理、混音之前的处理、混音和混音之后的处理应该按顺序进行。静音抑制（VAD，Voice Activity Detect）可做可不做。对于终端混音，是要把采集到的主播声音和从音频文件中读到的伴奏声音混合。如果主播停顿一段时间不发出声音，通过 VAD 检测到了，那么这段时间不混音，直接采用伴奏音乐的数据就好了。然而，为了简单起见，也可以不做 VAD。主播不发声音的期间，继续做混音也可以（主播的声音为零振幅）。



#### 混音算法

​	参考一个C++的[repo代码](https://github.com/cugxchen/MuxerAudio)

1. 叠加法: 这种方法数据量比较大,容易溢出 `y = a + b + c`

   ```c
   for (int i = 0; i < channels; ++i)
   {
     //叠加法
     sumBuf[i] = LimAmp(Sum(buf1[i], buf2[i], buf3[i], buf4[i]));
   }
   fwrite(sumBuf, sizeof(Int16), NUM, pMux);
   ```

   

2. 加权平均法: 这种方法两路数据问题不大,随着音源数量增加,声音质量会降低 `y = (a + b + c)/3`

   ```c
   for (int i = 0; i < channels; ++i)
   {
     //加权平均法
     sumBuf[i] = LimAmp(AAW(buf1[i], buf2[i], buf3[i], buf4[i]));//从打印看没有溢出的
   }
   fwrite(sumBuf, sizeof(Int16), NUM, pMux);
   ```

   

3. 自定义权重法: 设定比重,哪个声音大就比重加大一些 `y = (sgn(a)*a^2 + sgn(b)*b^2 + sgn(c)*c^2)/(abs(a) + abs(b) + abs(c))`

   ```c
   for (int i = 0; i < channels; ++i)
   {
     //自对齐权重法
     sumBuf[i] = LimAmp(ASW(buf1[i], buf2[i], buf3[i], buf4[i]));
   }
   fwrite(sumBuf, sizeof(Int16), NUM, pMux);
   ```

   

4. 归一化 参考[改进型归一化混音算法](https://blog.csdn.net/jeffasd/article/details/77335874)

 ```c
 static void pcmAudioMix(SInt16 *bufferA, SInt16 *bufferB, UInt32 bufferLength){
     char * sourseFile[2];
     sourseFile[0] = (char *)bufferA;
     sourseFile[1] = (char *)bufferB;
     Mix(sourseFile, 2, (char *)bufferB, bufferLength);
 }
  
 static void Mix(char **buffers,int number,char *mix_buf, UInt32 bufferLength){
     //归一化混音
     int const MAX = 32767;
     int const MIN = -32768;
     
     double f = 1;
     int output;
     for (int i = 0; i < bufferLength; i++){
         int temp = 0;
         for (int j = 0; j < number; j++){
             char *point = buffers[j];
             if (j == 0) {
                 int mixTemp = *(short *)(point + i*2);
                 temp += (int)(mixTemp);
             }else{
                 temp += *(short *)(point + i*2);
             }
         }
         output = (int)(temp * f);
         
         if (output > MAX){
             f = (double)MAX / (double)(output);
             output = MAX;
         }
         if (output < MIN){
             f = (double)MIN / (double)(output);
             output = MIN;
         }
         if (f < 1){
             f += ((double)1 - f) / (double)32;
         }
         *(short *)(mix_buf + i*2) = (short)output;
     }
 }
 ```

目前也是采用的该算法

```objc
int main()
{
    
    FILE * fp1;
    FILE * fp2;
    FILE * fpmix;
    
    int size = 4*1024;
    int channels = 2;//双声道
    //本地pcm文件读取流的方式进行混合 在线的流得根据实际场景去处理
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"mic" ofType:@"pcm"];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"pcm"];
    // 输出混合后的pcm文件的地址
    NSString *mix_path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"mix.pcm"];
    
    // 打开FP读写
    fp1 = fopen([path1 UTF8String],"rb");
    if (fp1 == NULL){
        printf("Open FILE1 failed!");
    }
    
    fp2 = fopen([path2 UTF8String],"rb");
    if (fp2 == NULL){
        printf("Open FILE2 failed!");
    }
    
    fpmix = fopen([mix_path UTF8String],"wb");
    if (fpmix == NULL){
        printf("Open MIX_FILE failed!");
    }
    
    short *src_data1, *src_data2, *mix_data;
    //初始化分配内存空间
    src_data1 = (short *)malloc(size);
    if (src_data1 == NULL){
        printf("Malloc data1 failed!");
    }
    
    src_data2 = (short *)malloc(size);
    if (src_data2 == NULL){
        printf("Malloc data2 failed!");
    }
    
    mix_data = (short *)malloc(size);
    if (mix_data == NULL){
        printf("Malloc mix_data failed!");
    }
    
    int ret1,ret2;
    //定义二维数组为数据源格式
    char *sourse_data[2];
    printf("开始混音!!\n");

    //循环读取文件流数据
    while(1){
        ret1 = fread(src_data1, 1, size, fp1);
        ret2 = fread(src_data2, 1, size, fp2);
        
        sourse_data[0] = (char *)src_data1;
        sourse_data[1] = (char *)src_data2;
        
        if(ret1 > 0 && ret2 > 0){
            //调用混音
            Mix(sourse_data, channels,(char *)mix_data, size);
            fwrite(mix_data, 1, size, fpmix);
        }else if( (ret1 > 0) && (ret2 == 0)){
            //ret2已读完 把ret1继续读完写入
            fwrite(src_data1, 1, ret1, fpmix);
        }else if( (ret2 > 0) && (ret1 == 0)){
            //ret1已读完 把ret2继续读完写入
            fwrite(src_data2, 1, ret2, fpmix);
        }else if( (ret1 == 0) && (ret2 == 0)){
            //数据为空 或者均读取完
            break;
        }
    }
    printf("混合完毕!!\n");
    
    free(src_data1);
    free(src_data2);
    free(mix_data);
    
    fclose(fp1);
    fclose(fp2);
    fclose(fpmix);
    
    return 0;
}

```



5. github找的一个`a+b-ab`的一个实现,不明觉厉就是了~

   ```c
   #define  MY_INT16_MAX   32767
   #define  MY_INT16_MIN  -32768
   
   // 混音算法
   inline short TPMixSamples(short a, short b)
   {
    int result = a < 0 && b < 0 ? ((int)a + (int)b) - (((int)a * (int)b) / MY_INT16_MIN) : ( a > 0 && b > 0 ? ((int)a + (int)b) - (((int)a * (int)b)/MY_INT16_MAX) : a + b);
    return result > MY_INT16_MAX ? MY_INT16_MAX : (result < MY_INT16_MIN ? MY_INT16_MIN : result);
   }
   
   ```



####  常用的相关代码块

* `ASDB` 音频格式描述结构体

```objc
    AudioStreamBasicDescription inputFormat = {0}; //结构体初始化
    inputFormat.mSampleRate = 44100;//采样率,每秒钟的采样频率
    inputFormat.mFormatID = kAudioFormatLinearPCM;//格式类型
    inputFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;//大小端等标识
    inputFormat.mChannelsPerFrame = 2;//声道数
    inputFormat.mFramesPerPacket = 1;//一个数据包一帧
    inputFormat.mBitsPerChannel = 16;//采样位数或位深度
    inputFormat.mBytesPerFrame = inputFormat.mBitsPerChannel / 8 * inputFormat.mChannelsPerFrame;//每帧多少个字节
    inputFormat.mBytesPerPacket = inputFormat.mBytesPerFrame * inputFormat.mFramesPerPacket;//一个包几个字节

```

* 音频`CMSampleBufferRef`转`NSData`

  ```objc
  - (void)pushAudioBuffer:(CMSampleBufferRef)sampleBuffer {
      AudioBufferList audioBufferList;
      CMBlockBufferRef blockBuffer;
      
      CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);
      
      for( int y=0; y<audioBufferList.mNumberBuffers; y++ ) {
          AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
          void* audio = audioBuffer.mData;
          NSData *data = [NSData dataWithBytes:audio length:audioBuffer.mDataByteSize];
          [self pushAudio:data];
      }
      CFRelease(blockBuffer);
  }
  ```

* `NSData`转`CMSampleBufferRef`

  ```objc
  -(AudioStreamBasicDescription)getASBD{
    	int channels = 2;
      AudioStreamBasicDescription format = {0};
      format.mSampleRate = 44100;
      format.mFormatID = kAudioFormatLinearPCM;
      format.mFormatFlags =  kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
      format.mChannelsPerFrame = channels;
      format.mBitsPerChannel = 16;
      format.mFramesPerPacket = 1;
      format.mBytesPerFrame = format.mBitsPerChannel / 8 * format.mChannelsPerFrame;
      format.mBytesPerPacket = format.mBytesPerFrame * format.mFramesPerPacket;
      format.mReserved = 0;
      return format;
  }
  
  - (CMSampleBufferRef)convertAudioSampleWithData:(NSData *)audioData{
      int channels = 2;
      AudioBufferList audioBufferList;
      audioBufferList.mNumberBuffers = 1;
      audioBufferList.mBuffers[0].mNumberChannels = channels;
      audioBufferList.mBuffers[0].mDataByteSize = audioData.length;
      audioBufferList.mBuffers[0].mData = audioData.bytes;
      
      AudioStreamBasicDescription asbd = [self getASBD];
      CMSampleBufferRef buff = NULL;
      static CMFormatDescriptionRef format = NULL;
      CMSampleTimingInfo timing = {CMTimeMake(1,44100), kCMTimeZero, kCMTimeInvalid };
      OSStatus error = 0;
      if(format == NULL){
        error = CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &asbd, 0, NULL, 0, NULL, NULL, &format);
      }
          
      error = CMSampleBufferCreate(kCFAllocatorDefault, NULL, false, NULL, NULL, format, len/(2*channels), 1, &timing, 0, NULL, &buff);
      
      if (error) {
          NSLog(@"CMSampleBufferCreate returned error: %ld", (long)error);
          return NULL;
      }
      
      error = CMSampleBufferSetDataBufferFromAudioBufferList(buff, kCFAllocatorDefault, kCFAllocatorDefault, 0, &audioBufferList);
      
      if(error){
          NSLog(@"CMSampleBufferSetDataBufferFromAudioBufferList returned error: %ld", (long)error);
          return NULL;
      }
      return buff;
  }
  ```



​	其实`iOS`底层`AudioUnit`框架可以通过输入输出不同的`bus`进行混音  `可参考`[AUGraph结合RemoteI/O Unit与Mixer Unit](https://www.jianshu.com/p/f8bb0cc1075e), 但是局限在于需要调用硬件接口,则需要麦克风权限以及扬声器都需设置相关的音频会话 [AVAudioSession](https://blog.csdn.net/ByteDanceTech/article/details/114325538) ,如果是本地文件+麦克风录音用系统提供的就OK了

业务场景较为复杂且数据源分散由不同的`SDK`提供,这时就只能做数据层的处理了,避免各个`SDK`之间相互抢占系统音频会话的设置权限. 



####   参考文献

* [音频混音的算法实现](https://blog.csdn.net/dxpqxb/article/details/78329403)
* [简单的混音算法](https://blog.csdn.net/TopsLuo/article/details/72769800)
* [声网基于ReplayKit的两路音频流重采样以及混音代码](https://github.com/AgoraIO/Advanced-Video/tree/master/iOS%26macOS/Agora-Screen-Sharing/Agora-Screen-Sharing-iOS-Broadcast)
* [byte*与CMSampleBufferRef互相转换](https://blog.csdn.net/u011270282/article/details/51792071)
* [PCM音频数据调整音量](https://www.jianshu.com/p/ca2cb00418a7)
* [播放PCM](https://www.jianshu.com/p/57dd36e704be)
* [AVAudioSession详解](https://www.cnblogs.com/junhuawang/p/7920989.html)