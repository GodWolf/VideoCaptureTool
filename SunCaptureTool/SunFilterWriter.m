//
//  SunFilterWriter.m
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/22.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import "SunFilterWriter.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SunContextManager.h"
#import "SunFilterManager.h"

@interface SunFilterWriter()

@property (nonatomic,strong) AVAssetWriter *assetWriter;
@property (nonatomic,strong) AVAssetWriterInput *videoWriterInput;
@property (nonatomic,strong) AVAssetWriterInput *audioWriterInput;
@property (nonatomic,strong) AVAssetWriterInputPixelBufferAdaptor *assetWriterInputPixelBufferAdaptor;

@property (nonatomic,strong) NSDictionary *videoSettings;
@property (nonatomic,strong) NSDictionary *audioSettings;

@property (nonatomic,strong) CIContext *ciContext;
@property (nonatomic,strong) CIFilter *filter;
@property (nonatomic,assign) CGColorSpaceRef colorSpace;

@property (nonatomic,assign) BOOL firstSample;
@property (nonatomic,strong) NSURL *fileUrl;

@end
@implementation SunFilterWriter

- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings audioSettings:(NSDictionary *)audioSettings {
    
    if(self = [super init]){
        
        _videoSettings = videoSettings;
        _audioSettings = audioSettings;
//        _writerQueue = dispatch_queue_create("com.sun.writerQueue", 0);
        
        _ciContext = [SunContextManager shareInstance].ciContext;
        _filter = [SunFilterManager defaultFilter];
        _colorSpace = CGColorSpaceCreateDeviceRGB();
        
    }
    return self;
}

- (void)startWritingWithFileUrl:(NSURL *)fileUrl {
    
    

    _fileUrl = fileUrl;
   
    _assetWriter = [AVAssetWriter assetWriterWithURL:_fileUrl fileType:AVFileTypeMPEG4 error:nil];
    
    _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:_videoSettings];
    _videoWriterInput.expectsMediaDataInRealTime = YES;
    _videoWriterInput.transform = SunTransformForDeviceOrientation([UIDevice currentDevice].orientation);
    
    NSDictionary *attributes =  @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),(id)kCVPixelBufferWidthKey:_videoSettings[AVVideoWidthKey],(id)kCVPixelBufferHeightKey:_videoSettings[AVVideoHeightKey],(id)kCVPixelFormatOpenGLESCompatibility:(id)kCFBooleanTrue};
    
    _assetWriterInputPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:_videoWriterInput sourcePixelBufferAttributes:attributes];
    
    if([_assetWriter canAddInput:_videoWriterInput]){
        [_assetWriter addInput:_videoWriterInput];
    }
    
    _audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:_audioSettings];
    _audioWriterInput.expectsMediaDataInRealTime = YES;
    if([_assetWriter canAddInput:_audioWriterInput]){
        [_assetWriter addInput:_audioWriterInput];
    }
    
    
    _firstSample = YES;
    _isWritting = YES;
    
}

- (void)stopWriting:(void(^)(BOOL success,NSURL *fileUrl))finishBlock {
    
    
    _isWritting = NO;
    __weak typeof(self) weakSelf = self;
   
    [weakSelf.assetWriter finishWritingWithCompletionHandler:^{
       
        if(finishBlock){
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                finishBlock(weakSelf.assetWriter.status == AVAssetWriterStatusCompleted,weakSelf.fileUrl);
            });
        }
        
    }];

}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    
    if(_isWritting == NO){
        return;
    }
   
    CMFormatDescriptionRef desc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMMediaType type = CMFormatDescriptionGetMediaType(desc);
    if(type == kCMMediaType_Video){
        
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        if (_firstSample) {
            if ([self.assetWriter startWriting]) {
                [self.assetWriter startSessionAtSourceTime:timestamp];
            }
            _firstSample = NO;
        }
        
        CVPixelBufferRef outputRenderBuffer = NULL;
        CVPixelBufferPoolRef pixelBufferPool = _assetWriterInputPixelBufferAdaptor.pixelBufferPool;
        OSStatus err = CVPixelBufferPoolCreatePixelBuffer(NULL, pixelBufferPool, &outputRenderBuffer);
        if(err){
            return;
        }
        
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer
                                                       options:nil];
        [_filter setValue:sourceImage forKey:kCIInputImageKey];
        
        CIImage *filteredImage = _filter.outputImage;
        if(!filteredImage){
            filteredImage = sourceImage;
        }
        [_ciContext render:filteredImage toCVPixelBuffer:outputRenderBuffer bounds:filteredImage.extent colorSpace:_colorSpace];
        
        if(_isWritting == YES && [_videoWriterInput isReadyForMoreMediaData]){
            [_assetWriterInputPixelBufferAdaptor appendPixelBuffer:outputRenderBuffer withPresentationTime:timestamp];
        }
        CVPixelBufferRelease(outputRenderBuffer);
    }else if(type == kCMMediaType_Audio){
        
        if(_isWritting == YES && [_audioWriterInput isReadyForMoreMediaData]){
            [_audioWriterInput appendSampleBuffer:sampleBuffer];
        }
    }
    
    
}


CGAffineTransform SunTransformForDeviceOrientation(UIDeviceOrientation orientation) {
    
    CGAffineTransform result;
    switch (orientation) {
            
        case UIDeviceOrientationLandscapeRight:
            result = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            result = CGAffineTransformMakeRotation((M_PI_2 * 3));
            break;
            
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            result = CGAffineTransformMakeRotation(M_PI_2);
            break;
            
        default:
            result = CGAffineTransformIdentity;
            break;
    }
    
    return result;
}

@end
