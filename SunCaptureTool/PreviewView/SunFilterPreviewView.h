//
//  SunFilterPreviewView.h
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/22.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface SunFilterPreviewView : GLKView

- (void)showCIImage:(CIImage *)sourceImage;

@end
