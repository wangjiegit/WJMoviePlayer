//
//  WJMoviePlayerView.m
//  WJMoviePlayer
//
//  Created by 王杰 on 2018/9/15.
//  Copyright © 2018年 王杰. All rights reserved.
//  https://github.com/wangjiegit/WJMoviePlayer

#import "WJMoviePlayerView.h"

@interface WJMoviePlayerView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) WJPlayerView *playerView;//用来手势关闭的

@property (nonatomic, strong) UIImageView *transitionView;//做专场动画

@property (nonatomic, strong) WJProgressView *progressView;

@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, copy) NSURL *playerURL;

@end

@implementation WJMoviePlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

//展示
- (void)show {
    if (self.movieURL.path.length == 0) {
        [WJMovieHUD showWithMessage:@"视频播放地址不存在"];
        return;
    }
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [self addSubview:self.transitionView];
    [self addSubview:self.playerView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.transitionView.frame = self.bounds;
    } completion:^(BOOL finished) {
        [self prepareMovie];
    }];
}

//判断视频地址是本地的还是网络的
- (void)prepareMovie {
    if ([self.movieURL.scheme isEqualToString:@"file"]) {//本地视频
        self.playerURL = self.movieURL;
        self.playerView.player = [[AVPlayer alloc] initWithURL:self.playerURL];
    } else {
        [self insertSubview:self.progressView aboveSubview:self.transitionView];
        [self loadData];
    }
}

//播放结束 执行重复播放
- (void)playerItemDidPlayToEnd {
    [self.playerView.player seekToTime:kCMTimeZero];
    [self.playerView.player play];
}

//移动当前视频
- (void)movePanGestureRecognizer:(UIPanGestureRecognizer *)pgr {
    if (pgr.state == UIGestureRecognizerStateBegan) {
        [self.playerView.player pause];
        self.progressView.hidden = YES;
    } else if (pgr.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [pgr locationInView:pgr.view.superview];
        CGPoint point = [pgr translationInView:pgr.view];
        CGRect rect = pgr.view.frame;
        CGFloat height = rect.size.height - point.y;
        CGFloat width = rect.size.width * height / rect.size.height;
        CGFloat y = rect.origin.y + 1.5 * point.y;
        CGFloat x = location.x * (rect.size.width - width) / pgr.view.superview.frame.size.width + point.x + rect.origin.x;
        if (rect.origin.y < 0) {
            height = pgr.view.superview.frame.size.height;
            width = pgr.view.superview.frame.size.width;
            y = rect.origin.y + point.y;
            x = rect.origin.x + point.x;
        }
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:(pgr.view.superview.frame.size.height / 1.5 - y) /  (pgr.view.superview.frame.size.height / 1.5)];
        pgr.view.frame = CGRectMake(x, y, width, height);
        self.transitionView.frame = pgr.view.frame;
        [pgr setTranslation:CGPointZero inView:pgr.view];
    } else if (pgr.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [pgr velocityInView:pgr.view];
        if (velocity.y > 500 && pgr.view.frame.origin.y > 0) {
            [self closeMoviePlayerView];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                self.backgroundColor = [UIColor blackColor];
                pgr.view.frame = self.bounds;
                self.transitionView.frame = self.bounds;
            } completion:^(BOOL finished) {
                [self.playerView.player play];
                self.progressView.hidden = NO;
            }];
        }
    } else {
        [self closeMoviePlayerView];
    }
}

//监听视频是否已经准备好
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self.playerView.player play];
    self.transitionView.hidden = YES;
}

//关闭视频播放
- (void)closeMoviePlayerView {
    [self.task cancel];
    [self.playerView.player pause];
    UIImage *image = [self getMovieCurrentImage];
    if (image) {
        self.transitionView.image = image;
        self.transitionView.frame = [self convertRect:((AVPlayerLayer *)self.playerView.layer).videoRect fromView:self.playerView];
    }
    self.transitionView.hidden = NO;
    self.playerView.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.transitionView.frame =  [self.coverView convertRect:self.coverView.bounds toView:nil];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    } completion:^(BOOL finished) {
        self.transitionView.hidden = YES;
        [self removeFromSuperview];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_playerView) [_playerView.layer removeObserver:self forKeyPath:@"readyForDisplay"];
}

#pragma mark UIGestureRecognizerDelegate
//下拉才能出发手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) return YES;
    UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint point = [pgr translationInView:pgr.view];
    if (point.y > 0) return YES;
    return NO;
}

//获取当前帧画面
- (UIImage *)getMovieCurrentImage {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.playerURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime now = self.playerView.player.currentTime;
    [gen setRequestedTimeToleranceAfter:kCMTimeZero];
    [gen setRequestedTimeToleranceBefore:kCMTimeZero];
    CGImageRef image = [gen copyCGImageAtTime:now actualTime:NULL error:NULL];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    if (image) CFRelease(image);
    return thumb;
}

#pragma mark loadData

- (void)loadData {
   self.task = [[WJMovieDownLoadManager shareManager] downloadMovieWithURL:self.movieURL progressBlock:^(CGFloat progress) {
        self.progressView.progress = progress;
    } success:^(NSURL *URL) {
        [self.progressView removeFromSuperview];
        self.playerURL = URL;
        self.playerView.player = [[AVPlayer alloc] initWithURL:URL];
    } fail:^(NSString *message) {
        [self.progressView removeFromSuperview];
        [WJMovieHUD showWithMessage:message];
    }];
}

#pragma mark Getter

- (WJProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[WJProgressView alloc] init];
        _progressView.frame = self.bounds;
    }
    return _progressView;
}

- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[WJPlayerView alloc] initWithFrame:self.bounds];
        _playerView.backgroundColor = [UIColor clearColor];
        [_playerView.layer addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:nil];
        UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanGestureRecognizer:)];
        pgr.delegate = self;
        [_playerView addGestureRecognizer:pgr];
    }
    return _playerView;
}

- (UIImageView *)transitionView {
    if (!_transitionView) {
        _transitionView = [[UIImageView alloc] init];
        _transitionView.frame = [self.coverView convertRect:self.coverView.bounds toView:nil];
        _transitionView.contentMode = UIViewContentModeScaleAspectFit;
        _transitionView.image = self.coverView.image;
    }
    return _transitionView;
}

@end

@implementation WJPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return ((AVPlayerLayer *)self.layer).player;
}

- (void)setPlayer:(AVPlayer *)player {
    ((AVPlayerLayer *)self.layer).player = player;
}

@end

//===================================================================================
//下载管理 只支持单个视频下载

@interface WJMovieDownLoadManager()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, copy) void(^success)(NSURL *URL);

@property (nonatomic, copy) void(^fail)(NSString *message);

@property (nonatomic, copy) void(^progressBlock)(CGFloat progress);

@end

@implementation WJMovieDownLoadManager

+ (instancetype)shareManager {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:queue];
    }
    return self;
}

- (NSURLSessionDownloadTask *)downloadMovieWithURL:(NSURL *)URL
                                     progressBlock:(void(^)(CGFloat progress))progressBlock
                                           success:(void(^)(NSURL *URL))success
                                              fail:(void(^)(NSString *message))fail {
    self.progressBlock = progressBlock;
    self.success = success;
    self.fail = fail;
    NSString *name = [[NSFileManager defaultManager] displayNameAtPath:URL.path];
    NSString *filePath = [[[self class] filePath] stringByAppendingPathComponent:name];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists) {
        if (self.success) self.success([NSURL fileURLWithPath:filePath]);
        [self clearAllBlock];
        return nil;
    }
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:URL];
    [task resume];
    return task;
}

- (void)clearAllBlock {
    self.success = nil;
    self.fail = nil;
    self.progressBlock = nil;
}

#pragma mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSString *name = [[NSFileManager defaultManager] displayNameAtPath:downloadTask.currentRequest.URL.path];
    NSString *filePath = [[[self class] filePath] stringByAppendingPathComponent:name];
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:filePath error:nil];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressBlock) self.progressBlock(totalBytesWritten * 1.0 / totalBytesExpectedToWrite);
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    NSString *name = [[NSFileManager defaultManager] displayNameAtPath:task.currentRequest.URL.path];
    NSString *filePath = [[[self class] filePath] stringByAppendingPathComponent:name];
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isExists) {
            if (self.success) self.success([NSURL fileURLWithPath:filePath]);
        } else {
            if (error.code != NSURLErrorCancelled && self.fail) self.fail(@"下载失败");
        }
        [self clearAllBlock];
    });
}

#pragma mark 文件管理
+ (NSString *)filePath {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [path stringByAppendingPathComponent:@"wj_movie_file"];
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!isExists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

+ (void)clearDisk {
    [[NSFileManager defaultManager] removeItemAtPath:[self filePath] error:nil];
}

@end

//===================================================================================
//下载进度条

@implementation WJProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.radius = 20;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor colorWithWhite:0 alpha:0.1] set];
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0) radius:self.radius startAngle:-M_PI_2 endAngle:2 * M_PI - M_PI_2  clockwise:YES];
    [bgPath fill];
    
    [[UIColor colorWithWhite:1 alpha:0.9] set];
    [bgPath addArcWithCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0) radius:self.radius startAngle:-M_PI_2 endAngle:2 * M_PI - M_PI_2  clockwise:YES];
    [bgPath stroke];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0) radius:self.radius - 2 startAngle:-M_PI_2 endAngle:self.progress * 2 * M_PI - M_PI_2  clockwise:YES];
    [path addLineToPoint:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)];
    [path fill];
}

@end

//===================================================================================
//播放失败提示
@implementation WJMovieHUD {
    UILabel *label;
}

- (instancetype)initWithMessage:(NSString *)message {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = message;
        label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        label.layer.cornerRadius = 6;
        label.layer.masksToBounds = YES;
        [self addSubview:label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    label.frame = CGRectMake(20, (self.frame.size.height - 60) / 2.0, self.frame.size.width - 40, 60);
}

+ (void)showWithMessage:(NSString *)message {
    if (message.length == 0) return;
    WJMovieHUD *hud = [[WJMovieHUD alloc] initWithMessage:message];
    hud.backgroundColor = [UIColor clearColor];
    hud.frame = [UIScreen mainScreen].bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud removeFromSuperview];
    });
}

@end

