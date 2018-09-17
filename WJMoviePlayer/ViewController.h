//
//  ViewController.h
//  WJMoviePlayer
//
//  Created by 王杰 on 2018/9/15.
//  Copyright © 2018年 wangjie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@end

@interface WJMovieCell : UITableViewCell

@property (nonatomic, copy) void(^block)(UIImageView *view);

- (void)config:(id)data indexPath:(NSIndexPath *)indexPath;

@end

