//
//  CSViewController.m
//  CSMediaPlayer
//
//  Created by CoderSahara on 09/19/2018.
//  Copyright (c) 2018 CoderSahara. All rights reserved.
//

#import "CSViewController.h"
#import "CSRemotePlayer.h"

@interface CSViewController ()

@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel; // 当前播放到几秒
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel; // 音频共有多少秒
@property (weak, nonatomic) IBOutlet UIProgressView *loadPV; // 缓存加载进度
@property (nonatomic, weak) NSTimer *timer; // 计时器
@property (weak, nonatomic) IBOutlet UISlider *playSlider; // 播放进度条
@property (weak, nonatomic) IBOutlet UIButton *mutedBtn; // 静音
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider; // 音频条

@end

@implementation CSViewController

- (NSTimer *)timer {
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self timer];
}
- (void)update {
    
    //    NSLog(@"--%zd", [CSRemotePlayer shareInstance].state);
    // 68
    // 01:08
    // 设计数据模型的
    // 弱业务逻辑存放位置的问题
    self.playTimeLabel.text =  [CSRemotePlayer shareInstance].currentTimeFormat;
    self.totalTimeLabel.text = [CSRemotePlayer shareInstance].totalTimeFormat;

    self.playSlider.value = [CSRemotePlayer shareInstance].progress;

    self.volumeSlider.value = [CSRemotePlayer shareInstance].volume;

    self.loadPV.progress = [CSRemotePlayer shareInstance].loadDataProgress;

    self.mutedBtn.selected = [CSRemotePlayer shareInstance].muted;
    
}

- (IBAction)play:(id)sender {
    // http://120.25.226.186:32812/resources/videos/minion_01.mp4
    //    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
    NSURL *url = [NSURL URLWithString:@"http://file.ichazuo.cn/09667cc1bc02c90685e2ba6d826c9885.mp3"];
    [[CSRemotePlayer shareInstance] playWithURL:url isCache:YES];}

- (IBAction)pause:(id)sender {
    [[CSRemotePlayer shareInstance] pause];
}

- (IBAction)resume:(id)sender {
    [[CSRemotePlayer shareInstance] resume];
}

- (IBAction)kuaijin:(id)sender {
    [[CSRemotePlayer shareInstance] seekWithTimeDiffer:15];
}

- (IBAction)progress:(UISlider *)sender {
    [[CSRemotePlayer shareInstance] seekWithProgress:sender.value];
}

- (IBAction)rate:(id)sender {
    [[CSRemotePlayer shareInstance] setRate:2];
}

- (IBAction)muted:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[CSRemotePlayer shareInstance] setMuted:sender.selected];
}

- (IBAction)volume:(UISlider *)sender {
    [[CSRemotePlayer shareInstance] setVolume:sender.value];
}

@end
