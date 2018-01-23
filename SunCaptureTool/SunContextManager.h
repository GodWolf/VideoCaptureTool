//
//  SunFilterManager.h
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/22.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <CoreImage/CoreImage.h>

@interface SunContextManager : NSObject

+ (instancetype)shareInstance;

@property (nonatomic,strong) EAGLContext *eaglContext;
@property (nonatomic,strong) CIContext *ciContext;

@end
