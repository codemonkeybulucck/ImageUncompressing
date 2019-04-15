//
//  UIImage+LMDecode.m
//  Image uncompressing
//
//  Created by lemon on 2019/4/15.
//  Copyright © 2019年 Lemon. All rights reserved.
//

#import "UIImage+LMDecode.h"

@implementation UIImage (LMDecode)
- (void)decodeImageWithCompletion:(void(^)(UIImage *image))completion{
    //在子线程执行解码操作
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        CFAbsoluteTime before = CFAbsoluteTimeGetCurrent();
        CGImageRef imageRef = self.CGImage;
        //获取像素宽和像素高
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        if (width == 0 || height == 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(self);
            });
        }
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        //判断颜色是否含有alpha通道
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        //在iOS中，使用的是小端模式，在mac中使用的是大端模式，为了兼容，我们使用kCGBitmapByteOrder32Host，32位字节顺序，该宏在不同的平台上面会自动组装换成不同的模式。
        /*
         #ifdef __BIG_ENDIAN__
         # define kCGBitmapByteOrder16Host kCGBitmapByteOrder16Big
         # define kCGBitmapByteOrder32Host kCGBitmapByteOrder32Big
         #else    //Little endian.
         # define kCGBitmapByteOrder16Host kCGBitmapByteOrder16Little
         # define kCGBitmapByteOrder32Host kCGBitmapByteOrder32Little
         #endif
         */
        
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        //根据是否含有alpha通道，如果有则使用kCGImageAlphaPremultipliedFirst，ARGB否则使用kCGImageAlphaNoneSkipFirst，RGB
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        //创建一个位图上下文
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0,  CGColorSpaceCreateDeviceRGB(), bitmapInfo);
        if (!context) return;
        //将原始图片绘制到上下文当中
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        //创建一张新的解压后的位图
        CGImageRef newImage = CGBitmapContextCreateImage(context);
        CFRelease(context);
        UIImage *originImage =[UIImage imageWithCGImage:newImage scale:[UIScreen mainScreen].scale orientation:self.imageOrientation];
        //回到主线程回调
        CFAbsoluteTime after = CFAbsoluteTimeGetCurrent();
        NSLog(@"decode: %.2f ms", (after - before) * 1000);
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(originImage);
        });
    });
}


@end
