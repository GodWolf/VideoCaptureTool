//
//  SunFilterCaptureTool.h
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/19.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import "SunBaseCaptureTool.h"
#import "SunFilterPreviewView.h"

typedef NS_ENUM(NSUInteger, SunFilterCaptureType) {
    SunFilterCaptureTypeImage,  //图片
    SunFilterCaptureTypeVideo,  //视频
    SunFilterCaptureTypeImageVideo, //图片和视频
};

@interface SunFilterCaptureTool : SunBaseCaptureTool

- (instancetype)initWithCaptureType:(SunFilterCaptureType)captureType;

@property (nonatomic,weak) SunFilterPreviewView *previewView;

@property (nonatomic,assign,getter = isRecording) BOOL recording;

///开始录制视频
- (void)startRecording:(NSURL *)fileUrl;
///停止录制视频
- (void)stopRecording:(void(^)(BOOL success,NSURL *fileUrl))finishBlock;

@end
