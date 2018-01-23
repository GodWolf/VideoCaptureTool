//
//  SunStillImageCaptureTool.m
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/19.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import "SunNormalCaptureTool.h"
#import <AVFoundation/AVFoundation.h>

@interface SunNormalCaptureTool()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic,assign) SunCaptureType captureType;

@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic,strong) AVCaptureConnection *stillImageConnection;

@property (nonatomic,strong) AVCaptureMovieFileOutput *videoOutput;
@property (nonatomic,strong) AVCaptureConnection *videoConnection;

@property (nonatomic,copy) void(^getImageBlock)(UIImage *image);
@property (nonatomic,copy) void(^videoFinishBlock)(BOOL success,NSURL *fileUrl);

@end
@implementation SunNormalCaptureTool

- (instancetype)initWithCaptureType:(SunCaptureType)captureType
{
    self = [super init];
    if (self) {
        _captureType = captureType;
    }
    return self;
}

- (BOOL)setupSessionOutputs {
    
    if(_captureType == SunCaptureTypeImage){
        return [self addStillImageOutput];
    }else if (_captureType == SunCaptureTypeVideo){
        return [self addVideoOutput];
    }else{
        return [self addStillImageOutput] && [self addVideoOutput];
    }
    return YES;
}

//添加静态图片输出
- (BOOL)addStillImageOutput {
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if(_stillImageOutput == nil){
        return NO;
    }
    _stillImageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if([self.captureSession canAddOutput:_stillImageOutput]){
        [self.captureSession addOutput:_stillImageOutput];
    }else{
        return NO;
    }
    
    return YES;
}

//添加视频输出
- (BOOL)addVideoOutput {
    
    _videoOutput = [[AVCaptureMovieFileOutput alloc] init];
    if(_videoOutput == nil){
        return NO;
    }
    if([self.captureSession canAddOutput:_videoOutput]){
        [self.captureSession addOutput:_videoOutput];
    }else{
        return NO;
    }
    return YES;
}

#pragma mark - 捕捉图片
- (void)captureImage:(void(^)(UIImage *image))getImageBlock {
    
    if(!getImageBlock){
        return;
    }
    _getImageBlock = getImageBlock;
    if(_stillImageConnection == nil){
        _stillImageConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        //调整图片方向
        if(_stillImageConnection.isVideoOrientationSupported){
            _stillImageConnection.videoOrientation = [self currentVideoOrientation];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:_stillImageConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        
        UIImage *image = nil;
        if(imageDataSampleBuffer){
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            image = [UIImage imageWithData:imageData];
        }
        
        if(weakSelf.getImageBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.getImageBlock(image);
            });
        }
        
    }];
    
}

#pragma mark - 开始开始录制
- (void)startRecordVideoWithFileUrl:(NSURL *)fileUrl {
    
    NSLog(@"relativeString = %@",fileUrl.relativeString);
    NSLog(@"absoluteString = %@",fileUrl.absoluteString);
    if(_videoConnection == nil){
        _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        if([_videoConnection isVideoOrientationSupported]){
            _videoConnection.videoOrientation = [self currentVideoOrientation];
        }
        if([_videoConnection isVideoStabilizationSupported]){
            _videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    if(_videoOutput.isRecording == NO){
        
        if([[NSFileManager defaultManager] fileExistsAtPath:fileUrl.relativeString]){
            [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
        }
        dispatch_async(self.sessionQueue, ^{
            [_videoOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        });
    }

}

#pragma mark - 停止录制视频
- (void)stopRecordVideo:(void(^)(BOOL success,NSURL *fileUrl))videoFinishBlock {
    
    _videoFinishBlock = videoFinishBlock;
    if(_videoOutput.isRecording == YES){
        [_videoOutput stopRecording];
    }
}

- (AVCaptureVideoOrientation)currentVideoOrientation {
    
    AVCaptureVideoOrientation orientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:{
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        }
        case UIDeviceOrientationLandscapeRight:{
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        }
        case UIDeviceOrientationLandscapeLeft:{
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        }
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    
    if(_videoFinishBlock){
        dispatch_async(dispatch_get_main_queue(), ^{
            _videoFinishBlock(error == nil,outputFileURL);
        });
    }
}

@end
