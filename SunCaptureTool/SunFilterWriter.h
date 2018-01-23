//
//  SunFilterWriter.h
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/22.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SunFilterWriter : NSObject

- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings audioSettings:(NSDictionary *)audioSettings;

@property (nonatomic,strong) dispatch_queue_t writerQueue;
@property (nonatomic,assign) BOOL isWritting;

///开始写入
- (void)startWritingWithFileUrl:(NSURL *)fileUrl;
///停止写入
- (void)stopWriting:(void(^)(BOOL isSuccess,NSURL *fileUrl))finishBlock;
///处理帧数据
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
