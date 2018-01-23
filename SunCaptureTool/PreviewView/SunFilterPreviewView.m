//
//  SunFilterPreviewView.m
//  SunCapture
//
//  Created by 孙兴祥 on 2018/1/22.
//  Copyright © 2018年 sunxiangxiang. All rights reserved.
//

#import "SunFilterPreviewView.h"
#import "SunContextManager.h"
#import "SunFilterManager.h"

@interface SunFilterPreviewView()

@property (nonatomic,assign) CGRect drawableBounds;
@property (nonatomic,strong) CIFilter *filter;
@property (nonatomic,strong) CIContext *coreImageContext;

@end
@implementation SunFilterPreviewView

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
    
    if(self = [super initWithFrame:frame context:context]){
        self.enableSetNeedsDisplay = NO;
        self.backgroundColor = [UIColor blackColor];
        self.opaque = YES;
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.frame = frame;
        
        _filter = [SunFilterManager defaultFilter];
        _coreImageContext = [SunContextManager shareInstance].ciContext;
        
        [self bindDrawable];
        _drawableBounds = CGRectMake(0, 0, self.drawableWidth, self.drawableHeight);
    }
    return self;
}

- (void)showCIImage:(CIImage *)sourceImage {
    
    [self bindDrawable];
    [_filter setValue:sourceImage forKey:kCIInputImageKey];
    CIImage *filteredImage = _filter.outputImage;
    
    if(filteredImage){
        
        CGRect clipRect = [self getClipRectWithSourceRect:filteredImage.extent previewRect:self.drawableBounds];
        [self.coreImageContext drawImage:filteredImage inRect:self.drawableBounds fromRect:clipRect];
    }
    [self display];
    [self.filter setValue:nil forKey:kCIInputImageKey];
}

- (CGRect)getClipRectWithSourceRect:(CGRect)sourceRect previewRect:(CGRect)previewRect {
    
    CGFloat sourceAspectRatio = sourceRect.size.width/sourceRect.size.height;
    CGFloat previewAspectRatio = previewRect.size.width/previewRect.size.height;
    
    CGRect drawRect = sourceRect;
    if(sourceAspectRatio > previewAspectRatio){
        
        CGFloat scaledHeight = drawRect.size.height * previewAspectRatio;
        drawRect.origin.x += (drawRect.size.width-scaledHeight)/2.0;
        drawRect.size.width = scaledHeight;
    }else{
        
        drawRect.origin.y = (drawRect.size.height-drawRect.size.width/previewAspectRatio)/2.0;
        drawRect.size.height = drawRect.size.width/previewAspectRatio;
    }
    return drawRect;
}

@end
