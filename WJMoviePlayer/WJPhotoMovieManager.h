//
//  WJPhotoMovieManager.h
//  WJMoviePlayer
//
//  Created by 王杰 on 2018/9/15.
//  Copyright © 2018年 王杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WJPhotoMovieManager : NSObject

@property (nonatomic) NSTimeInterval videoMaximumDuration;//视频最大时间

+ (instancetype)manager;

- (void)showControllerWithCallBack:(void(^)(NSURL *mediaURL, UIImage *coverImage))callBack;

@end
