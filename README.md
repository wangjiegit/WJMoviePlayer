# WJMoviePlayer

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
