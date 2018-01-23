//
//  SunFilterCaptureTool.m
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/19.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import "SunFilterCaptureTool.h"
#import "SunFilterWriter.h"

@interface SunFilterCaptureTool()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic,assign) SunFilterCaptureType captureType;
@property (nonatomic,strong) SunFilterWriter *videoWriter;

@property (nonatomic,strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic,strong) AVCaptureAudioDataOutput *audioDataOutput;


@end
@implementation SunFilterCaptureTool

- (instancetype)initWithCaptureType:(SunFilterCaptureType)captureType;
{
    self = [super init];
    if (self) {
        _captureType = captureType;
    }
    return self;
}

- (BOOL)setupSessionOutputs {
    
    if(_captureType == SunFilterCaptureTypeImage){
        return [self addVideoDataOutput];
    }else{
        return [self addVideoDataOutput] && [self addAudioDataOutput] && [self setupVideoWritter];
    }
    return YES;
}

- (BOOL)addVideoDataOutput {
    
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    if(_videoDataOutput == nil){
        return NO;
    }
    _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
    _videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
    [_videoDataOutput setSampleBufferDelegate:self queue:self.sessionQueue];
    if([self.captureSession canAddOutput:_videoDataOutput]){
        [self.captureSession addOutput:_videoDataOutput];
    }else{
        return NO;
    }
    
    return YES;
}

- (BOOL)addAudioDataOutput {
    
    _audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    if(_audioDataOutput == nil){
        return NO;
    }
    [_audioDataOutput setSampleBufferDelegate:self queue:self.sessionQueue];
    if([self.captureSession canAddOutput:_audioDataOutput]){
        [self.captureSession addOutput:_audioDataOutput];
    }else{
        return NO;
    }
    return YES;
}

- (BOOL)setupVideoWritter {
    
    NSDictionary *videoSettings = [_videoDataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeMPEG4];
    NSDictionary *audioSetting = [_audioDataOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeMPEG4];
    
    _videoWriter = [[SunFilterWriter alloc] initWithVideoSettings:videoSettings audioSettings:audioSetting];
    _videoWriter.writerQueue = self.sessionQueue;
    if(!_videoWriter){
        return NO;
    }
    return YES;
}


///开始录制视频
- (void)startRecording:(NSURL *)fileUrl {
    
    if(_recording == YES){
        return;
    }
    [_videoWriter startWritingWithFileUrl:fileUrl];
    _recording = YES;
}
///停止录制视频
- (void)stopRecording:(void(^)(BOOL success,NSURL *fileUrl))finishBlock {
    
    if(_recording == NO){
        return;
    }
    _recording = NO;
    [_videoWriter stopWriting:finishBlock];
}



#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    //展示
    if(_previewView && output == _videoDataOutput){
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
        [_previewView showCIImage:sourceImage];
    }
    
    
    //写入视频
    if(_recording == YES && _videoWriter){
        [_videoWriter processSampleBuffer:sampleBuffer];
    }
    
    
}

@end
