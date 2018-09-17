//
//  ViewController.m
//  WJMoviePlayer
//
//  Created by 王杰 on 2018/9/15.
//  Copyright © 2018年 wangjie. All rights reserved.
//  https://github.com/wangjiegit/WJMoviePlayer

#import "ViewController.h"
#import "WJMoviePlayerView.h"
#import "WJPhotoMovieManager.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *dataSource;

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, copy) NSURL *localURL;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
    tableView.tableHeaderView = [self tableViewHeaderView];
    tableView.rowHeight = 245;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[WJMovieCell class] forCellReuseIdentifier:NSStringFromClass([WJMovieCell class])];
    [self.view addSubview:tableView];
}

- (UIView *)tableViewHeaderView {
    UIView *header = [[UIView alloc] init];
    header.frame = CGRectMake(0, 0, self.view.frame.size.width, 250);
    self.imgView = [[UIImageView alloc] init];
    self.imgView.frame = CGRectMake(10, 0, self.view.frame.size.width - 20, 200);
    self.imgView.backgroundColor = [UIColor lightGrayColor];
    self.imgView.contentMode = UIViewContentModeScaleAspectFill;
    self.imgView.userInteractionEnabled = YES;
    self.imgView.clipsToBounds = YES;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playLocalMovie)];
    [self.imgView addGestureRecognizer:tgr];
    [header addSubview:self.imgView];
    
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake((header.frame.size.width - 150) / 2, 210, 150, 40);
    [btn setTitle:@"添加本地视频" forState:(UIControlStateNormal)];
    btn.layer.cornerRadius = 6;
    btn.clipsToBounds = YES;
    [btn addTarget:self action:@selector(addLocalMovie) forControlEvents:(UIControlEventTouchUpInside)];
    [header addSubview:btn];
    return header;
}

//添加本地视频
- (void)addLocalMovie {
    //回调后已经置nil self不会导致循环引用
    [[WJPhotoMovieManager manager] showControllerWithCallBack:^(NSURL *mediaURL, UIImage *coverImage) {
        self.imgView.image = coverImage;
        self.localURL = mediaURL;
    }];
}

//播放视频
- (void)playLocalMovie {
    WJMoviePlayerView *playerView = [[WJMoviePlayerView alloc] init];
    playerView.movieURL = self.localURL;
    playerView.coverView = self.imgView;
    [playerView show];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WJMovieCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WJMovieCell class]) forIndexPath:indexPath];
    if (indexPath.row < self.dataSource.count) {
        [cell config:self.dataSource[indexPath.row] indexPath:indexPath];
        __weak typeof(self) weakSelf = self;
        cell.block = ^(UIImageView *view) {
            //播放网络url视频 先下载 再播放
            WJMoviePlayerView *playerView = [[WJMoviePlayerView alloc] init];
            playerView.movieURL = [NSURL URLWithString:weakSelf.dataSource[indexPath.row][@"URL"]];
            playerView.coverView = view;
            [playerView show];
        };
    }
    return cell;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[@{@"title":@"[MV]许嵩-明智之举",@"image":@"xugao",@"URL":@"http://qukufile2.qianqian.com/data2/video/597847057/84d570444d8e6cbfa6ddb77a728adb5d/597847057.mp4"},
                        @{@"title":@"[MV]刘惜君-嗜睡症",@"image":@"liuxijun",@"URL":@"http://qukufile2.qianqian.com/data2/video/570682058/1a8e5117ab7771debd227223ab94b785/570682058.mp4"},
                        @{@"title":@"[MV]林俊杰-曹操",@"image":@"linjunjie",@"URL":@"http://qukufile2.qianqian.com/data2/video/540847399/06c7b633f980795fbd3a4f68dea2f215/540847399.mp4"},
                        @{@"title":@"[MV]薛之谦-狐狸",@"image":@"xueziqian",@"URL":@"http://qukufile2.qianqian.com/data2/video/568332098/79659a8232ee1a466be2bfd79252fb15/568332098.mp4"},
                        @{@"title":@"[MV]二珂-三角题",@"image":@"zhouerke",@"URL":@"http://qukufile2.qianqian.com/data2/video/558163449/1fe03d5c48f0cb079b2302a03d4c6f1b/558163449.mp4"},
                        @{@"title":@"MIC男团《Mad love》",@"image":@"mic",@"URL":@"http://qukufile2.qianqian.com/data2/video/570123298/7271486f5f2c3625c48d0cca2b0c5a33/570123298.mp4"},
                        @{@"title":@"[MV]胡彦斌-高手",@"image":@"huyanbing",@"URL":@"http://qukufile2.qianqian.com/data2/video/560398487/0e01d4062c78d8ffb0c9fc4fc4a2ae1d/560398487.mp4"},
                        @{@"title":@"[MV]摩登兄弟刘宇宁-有多少爱可以重来",@"image":@"modexiongdi",@"URL":@"http://qukufile2.qianqian.com/data2/video/603683369/2641f94dc58b5120cba7d539c723d315/603683369.mp4"}];
    }
    return _dataSource;
}


@end


@implementation WJMovieCell {
    UILabel *label;
    UIImageView *imgView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor grayColor];
        [self.contentView addSubview:label];
        
        imgView = [[UIImageView alloc] init];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.clipsToBounds = YES;
        imgView.userInteractionEnabled = YES;
        [self.contentView addSubview:imgView];
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playMoiveEvent)];
        [imgView addGestureRecognizer:tgr];
    }
    return self;
}

- (void)config:(id)data indexPath:(NSIndexPath *)indexPath {
    if (![data isKindOfClass:[NSDictionary class]]) return;
    label.text = data[@"title"];
    imgView.image = [UIImage imageNamed:data[@"image"]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    label.frame = CGRectMake(10, 10, self.frame.size.width - 20, 15);
    imgView.frame = CGRectMake(10, 35, label.frame.size.width, 200);
}

- (void)playMoiveEvent {
    if (self.block) {
        self.block(imgView);
    }
}

@end
