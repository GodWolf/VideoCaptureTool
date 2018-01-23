//
//  SunFilterManager.m
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/22.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import "SunContextManager.h"

@implementation SunContextManager

+ (instancetype)shareInstance {
    
    static SunContextManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[SunContextManager alloc] init];
    });
    return shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _eaglContext = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES2)];
        _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace:[NSNull null]}];
    }
    return self;
}

@end
