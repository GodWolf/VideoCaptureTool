//
//  SunStillImageCaptureTool.h
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/19.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import "SunBaseCaptureTool.h"

typedef NS_ENUM(NSUInteger, SunCaptureType) {
    SunCaptureTypeImage,    //图片
    SunCaptureTypeVideo,    //视频
    SunCaptureTypeImageVideo,   //图片和视频
};
@interface SunNormalCaptureTool : SunBaseCaptureTool

- (instancetype)initWithCaptureType:(SunCaptureType)captureType;

///捕捉图片
- (void)captureImage:(void(^)(UIImage *image))getImageBlock;

///开始开始录制，fileUrl：视频保存路径mp4
- (void)startRecordVideoWithFileUrl:(NSURL *)fileUrl;
///停止录制视频
- (void)stopRecordVideo:(void(^)(BOOL success,NSURL *fileUrl))videoFinishBlock;

@end
