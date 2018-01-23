//
//  SunFilterManager.h
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/22.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface SunFilterManager : NSObject

+ (NSArray *)filterNames;
+ (NSArray *)filterDisplayNames;
+ (CIFilter *)filterForDisplayName:(NSString *)displayName;
+ (CIFilter *)defaultFilter;

@end
