//
//  ViewController.m
//  SpeechRecognitionDemo
//
//  Created by zhangbinbin on 2017/3/27.
//  Copyright © 2017年 zhangbinbin. All rights reserved.
//

#import "ViewController.h"

#import <Speech/Speech.h>

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UILabel *result;

@property (strong, nonatomic) SFSpeechAudioBufferRecognitionRequest* request;

@property(nonatomic, strong) AVAudioEngine* bufferEngine;
@property(nonatomic, strong) AVAudioInputNode* buffeInputNode;
@property(nonatomic, strong) SFSpeechRecognitionTask* bufferTask;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 开始语音识别
    
    /**
     *  1. 提示用户可以使用语音识别功能
     *  2. 在info.plist文件添加NSSpeechRecognitionUsageDescription，说明你的app使用该功能的原因。
     *     (Live audio 会使用到麦克风，还需要添加 NSMicrophoneUsageDescription)
     *  3. 使用 request​Authorization:​ 请求权限. 如果用户拒绝或设备不支持，优雅的展示拒绝界面。
     *  4. 用户允许后，创建 SFSpeech​Recognizer 对象，和语音识别请求。
     *     SFSpeech​URLRecognition​Request:识别已经语音文件、预录好的。
     *     SFSpeech​Audio​Buffer​Recognition​Request:识别实时语音或在内存中的内容
     *  5. 将请求传给SFSpeech​Recognizer对象，开始识别。
     *      语音识别是增量的，所以识别回调可能不止一次，通过 final属性判断是否识别完毕。
     *      实时语音使用SFSpeech​Audio​Buffer​Recognition​Request将语音流增加到当前识别进程中。
     *  6. 当录音结束，识别也就结束了。开始一个新的识别任务前，需要确保前一个任务已经结束了。
     */
    
    // 3. 请求权限
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        NSLog(@"SFSpeechRecognizerAuthorizationStatus = %ld",(long)status);
    }];
}

- (IBAction)startRecognition:(id)sender {
    
    self.result.text = @"";
    __weak typeof(self) weakSelf = self;
    
    // 4. 创建 SFSpeech​Recognizer 对象
    SFSpeechRecognizer* speechRec = [[SFSpeechRecognizer alloc]
                                     initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    if (!speechRec.isAvailable) {
        return;
    }
    
    // 创建识别请求，这里只测试实时语音的识别
    //    SFSpeechURLRecognitionRequest* speechUrlReq = [[SFSpeechURLRecognitionRequest alloc]initWithURL:@""];
    _request = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
    
    // 将请求传给 SFSpeech​Recognizer 对象, block handle，也可以通过代理handel
    [speechRec recognitionTaskWithRequest:_request
                            resultHandler:^(SFSpeechRecognitionResult * _Nullable result,
                                            NSError * _Nullable error){
                                
                                NSLog(@"result = %@",result);
                                NSLog(@"error = %@",error);
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (result) {
                                        weakSelf.result.text = result.bestTranscription.formattedString;
                                    }
                                });
                            }
     ];
    
    
    // 监听一个标识位并拼接流文件
    self.bufferEngine = [[AVAudioEngine alloc]init];
    self.buffeInputNode = [self.bufferEngine inputNode];
    AVAudioFormat *format =[self.buffeInputNode outputFormatForBus:0];
    [self.buffeInputNode installTapOnBus:0
                              bufferSize:1024
                                  format:format
                                   block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
       
                                       [weakSelf.request appendAudioPCMBuffer:buffer];
    }];
    
    // 准备并启动引擎
    [self.bufferEngine prepare];
    NSError *error = nil;
    if (![self.bufferEngine startAndReturnError:&error]) {
        NSLog(@"%@",error.userInfo);
    };
}

- (IBAction)stopRecognition:(id)sender {
    [self.bufferEngine stop];
    [self.buffeInputNode removeTapOnBus:0];
    [_request endAudio];
    self.request = nil;
    self.bufferTask = nil;
}



















@end
