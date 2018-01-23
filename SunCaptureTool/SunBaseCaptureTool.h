//
//  SunBaseCaptureTool.h
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/17.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SunBaseCaptureTool : NSObject

@property (nonatomic,strong,readonly) AVCaptureSession *captureSession;
@property (nonatomic,strong,readonly) dispatch_queue_t sessionQueue;

///初始化配置
- (BOOL)setupSession;

///设置显示
- (void)showToPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;


///开始捕捉画面
- (void)startSession;
///停止捕捉画面
- (void)stopSession;


///是否可以切换摄像头
- (BOOL)canSwitchCamera;
///切换摄像头
- (BOOL)switchCameras;


///是否有手电筒
- (BOOL)canTorch;
///打开手电筒
- (BOOL)turnOnTorch;
///关闭手电筒
- (BOOL)turnOffTorch;


///是否有闪光灯
- (BOOL)canFlash;
///始终开启闪光灯
- (BOOL)setFlashOn;
///始终关闭闪光灯
- (BOOL)setFlashOff;
///根据环境自动使用闪光灯
- (BOOL)setFlashAuto;


///聚焦
- (void)focusAtPoint:(CGPoint)point previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;
///曝光
- (void)exposeAtPoint:(CGPoint)point previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

@end
