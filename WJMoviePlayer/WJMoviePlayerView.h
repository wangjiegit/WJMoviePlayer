//
//  WJMoviePlayerView.h
//  WJMoviePlayer
//
//  Created by 王杰 on 2018/9/15.
//  Copyright © 2018年 王杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@interface WJMoviePlayerView : UIView

@property (nonatomic, copy) NSURL *movieURL;//视频的URL

@property (nonatomic, strong) UIImageView *coverView;//封面

- (void)show;//展示视频

@end

//=====================================================================

@interface WJPlayerView : UIView

@property (nonatomic, strong) AVPlayer *player;

@end

//===================================================================================
//下载管理 只支持单个视频下载
@interface WJMovieDownLoadManager : NSObject

+ (instancetype)shareManager;

//删除本地缓存的视频
+ (void)clearDisk;

- (NSURLSessionDownloadTask *)downloadMovieWithURL:(NSURL *)URL
                                     progressBlock:(void(^)(CGFloat progress))progressBlock
                                           success:(void(^)(NSURL *URL))success
                                              fail:(void(^)(NSString *message))fail;
@end

//===================================================================================
//下载进度条

@interface WJProgressView : UIView

@property (nonatomic) CGFloat radius;//外圆半径 默认20

@property (nonatomic) CGFloat progress;//进度

@end

//===================================================================================
//播放失败提示
@interface WJMovieHUD : UIView

+ (void)showWithMessage:(NSString *)message;

@end



