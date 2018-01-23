//
//  SunNormalPreviewLayer.m
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/19.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import "SunNormalPreviewView.h"

@implementation SunNormalPreviewView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        ((AVCaptureVideoPreviewLayer *)self.layer).videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return self;
}

@end
