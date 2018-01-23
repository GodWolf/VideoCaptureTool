//
//  SunFilterManager.m
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/22.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import "SunFilterManager.h"


@implementation SunFilterManager

+ (NSArray *)filterNames {
    
    return @[
             @"CIPhotoEffectNoir",
             @"CIPhotoEffectChrome",
             @"CIPhotoEffectInstant",
             @"CIPhotoEffectFade",
             @"CIPhotoEffectMono",
             @"CIPhotoEffectProcess",
             @"CIPhotoEffectTonal",
             @"CIPhotoEffectTransfer"];
}

+ (NSArray *)filterDisplayNames {
    
    NSMutableArray *displayNames = [NSMutableArray array];
    
    for (NSString *filterName in [self filterNames]) {
        
        [displayNames addObject:[[filterName componentsSeparatedByString:@"CIPhotoEffect"] lastObject]];
    }
    
    return displayNames;
}

+ (CIFilter *)defaultFilter {
    return [CIFilter filterWithName:[[self filterNames] firstObject]];
}

+ (CIFilter *)filterForDisplayName:(NSString *)displayName {
    for (NSString *name in [self filterNames]) {
        if ([name containsString:displayName]) {
            return [CIFilter filterWithName:name];
        }
    }
    return nil;
}

@end
