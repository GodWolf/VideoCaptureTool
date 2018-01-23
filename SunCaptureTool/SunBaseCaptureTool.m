//
//  SunBaseCaptureTool.m
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/17.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import "SunBaseCaptureTool.h"


@interface SunBaseCaptureTool()

@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) dispatch_queue_t sessionQueue;
@property (nonatomic,weak) AVCaptureDeviceInput *activeVideoInput;

@end

@implementation SunBaseCaptureTool

- (instancetype)init {
    self = [super init];
    if (self) {
        _sessionQueue = dispatch_queue_create("com.sun.CaptureSessionQueue", NULL);
    }
    return self;
}

#pragma mark - 初始化配置
- (BOOL)setupSession {
    
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    if (![self setupSessionInputs]) {
        return NO;
    }
    
    if (![self setupSessionOutputs]) {
        return NO;
    }
    
    return YES;
}

//输入配置
- (BOOL)setupSessionInputs {
    
    //camera device
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    if(videoInput){
        if([_captureSession canAddInput:videoInput]){
            [_captureSession addInput:videoInput];
            _activeVideoInput = videoInput;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
    
    //microphone
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    if(audioInput){
        if([_captureSession canAddInput:audioInput]){
            [_captureSession addInput:audioInput];
        }else{
            return NO;
        }
    }else{
        return NO;
    }
    return YES;
}

//输出配置
- (BOOL)setupSessionOutputs {
    return NO;
}

#pragma mark - 设置显示
- (void)showToPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    
    if(_captureSession){
        [previewLayer setSession:_captureSession];
    }
}

#pragma mark - 开始捕捉画面
- (void)startSession {
    dispatch_async(_sessionQueue, ^{
        if (_captureSession.isRunning == NO) {
            [_captureSession startRunning];
        }
    });
}

#pragma mark - 停止捕捉画面
- (void)stopSession {
    dispatch_async(_sessionQueue, ^{
        if (_captureSession.isRunning == YES) {
            [_captureSession stopRunning];
        }
    });
    
}

#pragma mark - 是否可以切换摄像头
- (BOOL)canSwitchCamera {
    return self.cameraCount > 1;
}

#pragma mark - 切换摄像头
- (BOOL)switchCameras {
    
    if([self canSwitchCamera] == NO){
        return NO;
    }
    
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    if(videoInput){
        [_captureSession beginConfiguration];
        
        [_captureSession removeInput:_activeVideoInput];
        if([_captureSession canAddInput:videoInput]){
            [_captureSession addInput:videoInput];
            _activeVideoInput = videoInput;
        }else{
            [_captureSession addInput:_activeVideoInput];
            [_captureSession commitConfiguration];
            return NO;
        }
        
        [_captureSession commitConfiguration];
    }else{
        return NO;
    }
    
    return YES;
}

//没有使用的摄像头
- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if (_activeVideoInput.device.position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

//摄像头的数量
- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

//获取指定位置是的摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

#pragma mark - 是否有手电筒
- (BOOL)canTorch {
    return [_activeVideoInput.device hasTorch] && [_activeVideoInput.device isTorchAvailable];
}

#pragma mark - 打开手电筒
- (BOOL)turnOnTorch {
    
    return [self setTorchMode:(AVCaptureTorchModeOn)];
}

#pragma mark - 关闭手电筒
- (BOOL)turnOffTorch {
    
    return [self setTorchMode:(AVCaptureTorchModeOff)];
}

//改变手电筒模式
- (BOOL)setTorchMode:(AVCaptureTorchMode)torchMode {
    
    if(_activeVideoInput.device.torchMode != torchMode){
        [_activeVideoInput.device lockForConfiguration:nil];
        if([_activeVideoInput.device isTorchModeSupported:torchMode]){
            [_activeVideoInput.device setTorchMode:torchMode];
        }else{
            [_activeVideoInput.device unlockForConfiguration];
            return NO;
        }
        [_activeVideoInput.device unlockForConfiguration];
        return YES;
    }else{
        return NO;
    }
}


#pragma mark - 是否有闪光灯
- (BOOL)canFlash {
    return [_activeVideoInput.device hasFlash];
}

#pragma mark - 始终开启闪光灯
- (BOOL)setFlashOn {
    return [self setFlashMode:(AVCaptureFlashModeOn)];
}

#pragma mark - 始终关闭闪光灯
- (BOOL)setFlashOff {
    return [self setFlashMode:(AVCaptureFlashModeOff)];
}

#pragma mark - 根据环境自动使用闪光灯
- (BOOL)setFlashAuto {
    return [self setFlashMode:(AVCaptureFlashModeAuto)];
}

//设置闪光灯模式
- (BOOL)setFlashMode:(AVCaptureFlashMode)flashMode {
    
    if([self canFlash]){
        [_activeVideoInput.device lockForConfiguration:nil];
        if([_activeVideoInput.device isFlashModeSupported:flashMode]){
            [_activeVideoInput.device setFlashMode:flashMode];
        }else{
            [_activeVideoInput.device unlockForConfiguration];
            return NO;
        }
        [_activeVideoInput.device unlockForConfiguration];
        return YES;
    }else{
        return NO;
    }
}


//聚焦
- (void)focusAtPoint:(CGPoint)point previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    //转换为设备坐标
    point = [previewLayer captureDevicePointOfInterestForPoint:point];
    
    if(_activeVideoInput.device.focusPointOfInterestSupported && [_activeVideoInput.device isFocusModeSupported:(AVCaptureFocusModeContinuousAutoFocus)]){
        
        [_activeVideoInput.device lockForConfiguration:nil];
        _activeVideoInput.device.focusPointOfInterest = point;
        _activeVideoInput.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        [_activeVideoInput.device unlockForConfiguration];
    }
}

//曝光
- (void)exposeAtPoint:(CGPoint)point previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    
    point = [previewLayer captureDevicePointOfInterestForPoint:point];
    
    if(_activeVideoInput.device.isExposurePointOfInterestSupported && [_activeVideoInput.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
        
        if([_activeVideoInput.device lockForConfiguration:nil]){
            
            _activeVideoInput.device.exposurePointOfInterest = point;
            _activeVideoInput.device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            [_activeVideoInput.device unlockForConfiguration];
        }
    }
}



@end
