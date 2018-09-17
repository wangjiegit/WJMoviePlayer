# WJMoviePlayer 播放网络视频（先下载，后播放，类似微信朋友圈效果）

![gif](https://github.com/wangjiegit/WJMoviePlayer/blob/master/WJMoviePlayer/WJMoviePlayer.gif)

# WJMoviePlayerView是网络视频下载后播放视图 集成了下载动画 下拉关闭视图等功能

@param NSURL *movieURL  //视频的URL

@param UIImageView *coverView;//转场动画需要的View

WJMoviePlayerView *playerView = [[WJMoviePlayerView alloc] init];

playerView.movieURL = webURL;

playerView.coverView = imgView;

[playerView show];




# WJPhotoMovieManager 用来获取本地相册的视频

@param NSTimeInterval videoMaximumDuration;//编辑本地视频的最大时间

[[WJPhotoMovieManager manager] showControllerWithCallBack:^(NSURL *mediaURL, UIImage *coverImage) {

self.imgView.image = coverImage;

self.localURL = mediaURL;

}];


# WJMovieDownLoadManager 清理本地缓存

[WJMovieDownLoadManager clearDisk];//清理本地缓存
