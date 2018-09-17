//
//  WJPhotoMovieManager.m
//  WJMoviePlayer
//
//  Created by 王杰 on 2018/9/15.
//  Copyright © 2018年 王杰. All rights reserved.
//  https://github.com/wangjiegit/WJMoviePlayer

#import "WJPhotoMovieManager.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface WJPhotoMovieManager()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) void(^callBack)(NSURL *mediaURL, UIImage *coverImage);

@end

@implementation WJPhotoMovieManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static id manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.videoMaximumDuration = 15;
    }
    return self;
}

- (void)showControllerWithCallBack:(void(^)(NSURL *mediaURL, UIImage *coverImage))callBack {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;//不支持相册功能
    self.callBack = callBack;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {//用户首次打开 还未授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {//系统alert弹窗回调
            [self checkAuthorizationStatus:status];
        }];
        return;
    }
    [self checkAuthorizationStatus:status];
}

- (void)checkAuthorizationStatus:(PHAuthorizationStatus)status {
    if (status != PHAuthorizationStatusAuthorized) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您还未开启相册访问权限" message:@"" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
        [alert addAction:action];
        action = [UIAlertAction actionWithTitle:@"去授权" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alert addAction:action];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        return;
    }
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    vc.mediaTypes = @[(NSString *)kUTTypeMovie];
    vc.allowsEditing = YES;
    vc.videoMaximumDuration = self.videoMaximumDuration;
    vc.delegate = self;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSURL *mediaURL = info[UIImagePickerControllerMediaURL];
    PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[info[UIImagePickerControllerReferenceURL]] options:PHFetchOptions.new];
    PHAsset *asset = result.firstObject;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    __block UIImage *image = nil;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        image = [UIImage imageWithData:imageData];
    }];
    if (self.callBack) self.callBack(mediaURL, image);
    self.callBack = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
