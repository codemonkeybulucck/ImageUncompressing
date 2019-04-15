//
//  ViewController.m
//  Image uncompressing
//
//  Created by lemon on 2018/9/3.
//  Copyright © 2018年 Lemon. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+LMDecode.h"

@interface ViewController ()
@property (nonatomic, strong) NSArray *imageArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self testOriginAndDecodeDraw];
    
}


- (void)testPNGAndJPGDraw{
    self.imageArray = @[@"256x192",@"1024x768",@"2048x1536",@"512x384",@"128x96"];
    for (NSString *imageName in self.imageArray) {
        NSLog(@"-----begin draw %@ -------",imageName);;
        UIImage *originImage = [self imageNamed:imageName ofType:@"png"];
        [self drawImage:originImage];
        UIImage *originImage1 = [self imageNamed:imageName ofType:@"jpg"];
        [self drawImage:originImage1];
        NSLog(@"-----end draw %@ -------",imageName);;
    }
}


- (void)testOriginAndDecodeDraw{
    UIImage *originImage = [self imageNamed:@"1024x768" ofType:@"png"];
    NSLog(@"------begin origin image draw-------");
    [self drawImage:originImage];
    NSLog(@"------end origin image draw-------");
    
    NSLog(@"------begin decode image draw-------");
    [originImage decodeImageWithCompletion:^(UIImage * _Nonnull image) {
        [self drawImage:image];
        NSLog(@"------end decode image draw-------");
    }];


}

- (void)drawImage:(UIImage *)image {
    CFAbsoluteTime before = CFAbsoluteTimeGetCurrent();
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetShouldAntialias(context, NO);
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    [image drawAtPoint:CGPointZero];
    
    UIGraphicsEndImageContext();
    
    CFAbsoluteTime after = CFAbsoluteTimeGetCurrent();
    
    NSLog(@"Draw: %.2f ms", (after - before) * 1000);
}


- (UIImage *)imageNamed:(NSString *)name ofType:(NSString *)ext {
    CFAbsoluteTime before = CFAbsoluteTimeGetCurrent();
    
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    CFAbsoluteTime after = CFAbsoluteTimeGetCurrent();
    
    NSLog(@"%@", path.lastPathComponent);
    NSLog(@"Init: %.2f ms", (after - before) * 1000);
    
    return image;
}

- (UIImage *)decodeImage:(UIImage *)image{
    if (!image) return NULL;
    CGImageRef imageRef = image.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) return NULL ;
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0,  CGColorSpaceCreateDeviceRGB(), bitmapInfo);
    if (!context) return NULL;
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CFRelease(context);
    UIImage *originImage =[UIImage imageWithCGImage:newImage scale:[UIScreen mainScreen].scale orientation:image.imageOrientation];
    return originImage;
}


@end
