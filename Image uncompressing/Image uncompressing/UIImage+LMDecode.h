//
//  UIImage+LMDecode.h
//  Image uncompressing
//
//  Created by lemon on 2019/4/15.
//  Copyright © 2019年 Lemon. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface UIImage (LMDecode)
- (void)decodeImageWithCompletion:(void(^)(UIImage *image))completion;
@end

NS_ASSUME_NONNULL_END
