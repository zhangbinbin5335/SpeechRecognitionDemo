
[官方文档](https://developer.apple.com/reference/speech?language=objc)

## Speech
IOS 10.0+ 支持

可以识别实时语音和预先录制好的语音文件。

## 开始语音识别
### 1. 提示用户可以使用语音识别功能。
### 2. 在info.plist文件添加NSSpeechRecognitionUsageDescription，说明你的app使用该功能的原因。
     (Live audio 会使用到麦克风，还需要添加 NSMicrophoneUsageDescription)  
### 3. 使用 requestAuthorization: 请求权限. 如果用户拒绝或设备不支持，优雅的展示拒绝界面。    
    // code
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        NSLog(@"SFSpeechRecognizerAuthorizationStatus = %ld",(long)status);
    }];
### 4. 用户允许后，创建 SFSpeechRecognizer 对象，和语音识别请求。
    // 4. 创建 SFSpeechRecognizer 对象
    SFSpeechRecognizer* speechRec = [[SFSpeechRecognizer alloc]
                                     initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    if (!speechRec.isAvailable) {
        return;
    }  
     // 创建识别请求
    SFSpeechURLRecognitionRequest:识别已经语音文件、预录好的。
    SFSpeechAudioBufferRecognitionRequest:识别实时语音或在内存中的内容  
    //    SFSpeechURLRecognitionRequest* speechUrlReq = [[SFSpeechURLRecognitionRequest alloc]initWithURL:@""];
    _request = [[SFSpeechAudioBufferRecognitionRequest alloc]init]; 
    

### 5. 将请求传给SFSpeechRecognizer对象，开始识别。
    语音识别是增量的，所以识别回调可能不止一次，通过 final属性判断是否识别完毕。
    实时语音使用SFSpeechAudioBufferRecognitionRequest将语音流增加到当前识别进程中。  
### 6. 当录音结束，识别也就结束了。开始一个新的识别任务前，需要确保前一个任务已经结束了。  
    live audio的时候需要设置一个音频流
    
    // code
    self.bufferEngine = [[AVAudioEngine alloc]init];
    self.buffeInputNode = [self.bufferEngine inputNode];
    AVAudioFormat *format =[self.buffeInputNode outputFormatForBus:0];
    [self.buffeInputNode installTapOnBus:0
                              bufferSize:1024
                                  format:format
                                   block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
       
                                       [weakSelf.request appendAudioPCMBuffer:buffer];
    }];  
    
    // 开发测试需要使用真机,否则无法识别。  

[Demo Code](https://github.com/zhangbinbin5335/SpeechRecognitionDemo.git)
