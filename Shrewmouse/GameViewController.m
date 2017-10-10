//
//  GameViewController.m
//  Shrewmouse
//
//  Created by Riber on 16/4/14.
//  Copyright © 2016年 Riber. All rights reserved.
//

#import "GameViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MouseButton.h"
#import "DeveloperInfo.h"

#define WindowSize [UIScreen mainScreen].bounds.size
#define SystemVersion [[[UIDevice currentDevice] systemVersion] doubleValue]
#define FRAME_TIMER_BAR CGRectMake(95, 443, 200, 18)//时间条
#define RGBA(R, G, B, A) [UIColor colorWithRed:(R/255.0) green:(G/255.0) blue:(B/255.0) alpha:(A)]

extern int score;

@interface GameViewController ()<UIAlertViewDelegate> {
    AVAudioPlayer *_musicPlayer; // 背景音乐
    NSTimer *_timer; // 定时器
    UILabel *_gradeLabel; //得分显示
    NSMutableArray *_mouses; // 地鼠
    
    UIButton *_startButton; // 开始按钮
    DeveloperInfo *_developerInfo; //开发者信息
}

@end


@implementation GameViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];

    
    [self initGame];
    [self addDeveloperInformation];
    
}

- (void)addDeveloperInformation {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    button.frame = CGRectMake(WindowSize.width-20, WindowSize.height-20, 20, 20);
    [button addTarget:self action:@selector(infomation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _developerInfo = [[[NSBundle mainBundle] loadNibNamed:@"DeveloperInfo" owner:self options:nil] lastObject];
    _developerInfo.frame = CGRectMake((WindowSize.width-210)/2.0, WindowSize.height, 210, 135);
    _developerInfo.backgroundColor = [UIColor greenColor];
//    _developerInfo.alpha = 0.8;
    _developerInfo.layer.masksToBounds = YES;
    _developerInfo.layer.cornerRadius = 5;
    [self.view addSubview:_developerInfo];
    
    _developerInfo.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infomation:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [_developerInfo addGestureRecognizer:tap];
    
}

- (void)infomation:(UIButton *)button {
    if (_developerInfo.frame.origin.y == WindowSize.height) {
        [UIView animateWithDuration:1 animations:^{
            _developerInfo.frame = CGRectMake((WindowSize.width-210)/2.0, (WindowSize.height-135)/2.0, 210, 135);
        }];
    }
    else {
        [UIView animateWithDuration:1 animations:^{
            _developerInfo.frame = CGRectMake((WindowSize.width-210)/2.0, WindowSize.height, 210, 135);
        }];
    }
}

#pragma mark - 初始化游戏
- (void)initGame {
    [self initBackGroundImage];
    
    [self initMusicSwitchAndGrade];
    
    [self createMouse];
    
    [self createTimeBar];
    
    [self timerStart];
    
    [self playMusic];

}

#pragma mark - 初始化 音乐开关 和分数显示
- (void)initMusicSwitchAndGrade {
    
    // 创建音乐开关
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(WindowSize.width-120, 25, 70, 40)];
    labelName.text = @"背景音乐";
    labelName.font = [UIFont systemFontOfSize:15 weight:15];
    
    labelName.textColor = [UIColor whiteColor];
    [self.view addSubview:labelName];
    
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(WindowSize.width-50, 30, 40, 30)];
    [mySwitch addTarget:self action:@selector(switchOn:) forControlEvents:UIControlEventValueChanged];
    [mySwitch setOn:YES];
    mySwitch.thumbTintColor = [UIColor whiteColor];
    mySwitch.onTintColor = [UIColor greenColor];
    [self.view addSubview:mySwitch];
    
    // 显示得分
    _gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake((WindowSize.width-100)/2.0, 40, 100, 60)];
    _gradeLabel.text = @"得分:  0";
    _gradeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_gradeLabel];
}

#pragma mark - 地鼠就位
- (void)createMouse {
    _mouses = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 9; i++) {
        MouseButton *mouse = nil;
        
        // 4 4s
        if (WindowSize.height == 480) {
            mouse = [[MouseButton alloc] initWithFrame:CGRectMake(21+102*(i%3), 205+93*(i/3), 79, 56)];
        }
        // 5 5s
        else if (WindowSize.height == 568) {
            mouse = [[MouseButton alloc] initWithFrame:CGRectMake(23+100*(i%3), 260+110*(i/3), 79, 56)];
        }
        
        // 6 6s
        else if (WindowSize.height == 667) {
            mouse = [[MouseButton alloc] initWithFrame:CGRectMake(33+120*(i%3), 273+130*(i/3), 79, 56)];
        }
        
        // 6p 6sp
        else if (WindowSize.height == 736) {
            mouse = [[MouseButton alloc] initWithFrame:CGRectMake(35+133*(i%3), 285+125*(i/3), 79, 56)];
            
            mouse.frame = CGRectMake(35+132*(i%3), 285+135*(i/3), 79, 56);

        }
        
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:201+i/3];
        [self.view insertSubview:mouse belowSubview:imageView];
        //[self.view bringSubviewToFront:mouse];
        
        if (mouse != nil) {
            [_mouses addObject:mouse];
        }
    }
}

- (void)chooseMoles {
    static unsigned int i = 0;
    if (i % 5 == 0) { // 降低选中频率  这里调用5次才出洞一个地鼠
        // 从创建的地鼠中随机一个地鼠出洞
        MouseButton *mole = [_mouses objectAtIndex:arc4random()%9];
        // 出洞
        [mole startMoving];
    }
    i++;
    
    for (MouseButton *newMole in _mouses) {
        //选中之后的地鼠 _isStartMoving==YES就可以出洞
        [newMole outOfHole];
    }
}

- (void)timerStart {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(gameStart) userInfo:nil repeats:YES];
}

- (void)gameStart {
    [self chooseMoles];
    [self timeGo];
    
    _gradeLabel.text = [NSString stringWithFormat:@"得分:  %d", score];
}

#pragma mark - 时间条 倒计时
- (void)createTimeBar {
    CGRect frame = CGRectMake(95, 443, 200, 18);//时间条
    
    // 处理不同版本的iphone 适配屏幕
    // 4 4s
    if (WindowSize.height == 480) {
        
    }
    // 5 5s
    else if (WindowSize.height == 568) {
        frame = CGRectMake(95, 540, 200, 20);
    }
    
    // 6 6s
    else if (WindowSize.height == 667) {
        frame = CGRectMake(110, 590, 234, 22);
    }
    
    // 6p 6sp
    else if (WindowSize.height == 736) {
        frame = CGRectMake(122, 634, 261, 27);
    }
    
    UIView *redView = [[UIView alloc] initWithFrame:frame];
    redView.tag = 10000;
    redView.backgroundColor = [UIColor redColor];
    redView.alpha = 0.7;
    redView.layer.masksToBounds = YES;
    redView.layer.cornerRadius = 12;
    [self.view addSubview:redView];
}

- (void)timeGo {
    UIView *redView = [self.view viewWithTag:10000];

    float width = redView.frame.size.width;
    CGRect frame = redView.frame;

    if (width > 0)
    {
        if (WindowSize.height == 480) {
            width -= 1;
        }
        // 5 5s
        else if (WindowSize.height == 568) {
            width -= 1;
        }
        
        // 6 6s
        else if (WindowSize.height == 667) {
            width -= 2;
        }
        
        // 6p 6sp
        else if (WindowSize.height == 736) {
            width -= 3;
        }
    }
    
    // 时间到 弹出alert
    else
    {
        // 停止 定时器
        [_timer setFireDate:[NSDate distantFuture]];
        
        if (SystemVersion >= 8.0)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"游戏结束" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"再来一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self gameAgain:nil];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self gameCancel];
            }];
            
            [alertController addAction:doneAction];
            [alertController addAction:cancelAction];
//            [alertController.view setNeedsLayout];
//            self.automaticallyAdjustsScrollViewInsets = NO;
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"游戏结束" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"再来一次", nil];
            alertView.delegate = self;
            [alertView show];
        }
    }
    
    frame.size.width = width;
    
    redView.frame = frame;
}

#pragma mark - 初始化背景
- (void)initBackGroundImage {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BackImage" ofType:@"plist"];
    
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    
    float orginY = 0.f;
    
    for (NSDictionary *dic in array) {
        NSString *name = dic[@"name"];
        NSString *rect = dic[@"rect"];
        
        int order = [dic[@"order"] intValue];
        
        CGRect frame = CGRectFromString(rect);

        frame.size.width = WindowSize.width;
        frame.origin.y = orginY;
        frame.size.height = frame.size.height/frame.size.width*(WindowSize.height-150);

        // 处理不同版本的iphone 适配屏幕
        // 4 4s
        if (WindowSize.height == 480) {
            orginY += frame.size.height-35;
        }
        // 5 5s
        else if (WindowSize.height == 568) {
            orginY += frame.size.height-52;
        }
        
        // 6 6s
        else if (WindowSize.height == 667) {
            orginY += frame.size.height-48;
        }
        
        // 6p 6sp
        else if (WindowSize.height == 736) {
            orginY += frame.size.height-48;
            if (order == 3) {
                frame.size.height = frame.size.height+45;
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = [UIImage imageNamed:name];
        imageView.tag = 200 + order;
        [self.view addSubview:imageView];
    }
    
    // 创建开始按钮
    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _startButton.frame = CGRectMake((WindowSize.width-200)/2, WindowSize.height-200, 200, 44);
    _startButton.backgroundColor = RGBA(138, 161, 15, 1);
    _startButton.alpha = 0.8;
    _startButton.layer.cornerRadius = 10;
    _startButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_startButton setTitle:@"开 始" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _startButton.titleLabel.font = [UIFont systemFontOfSize:30];
    _startButton.hidden = YES;
    [_startButton addTarget:self action:@selector(gameAgain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];
    [self.view bringSubviewToFront:_startButton]; // 放到视图的最前面
}

- (void)switchOn:(UISwitch *)mySwitch {
    if (mySwitch.isOn) {
        [_musicPlayer play];
    }
    else
    {
        [_musicPlayer stop];
    }
}

#pragma mark - 播放音乐
- (void)playMusic {
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"gophermusic" ofType:@"mp3"];
    _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:musicPath] error:nil];
    
    [_musicPlayer prepareToPlay];
    _musicPlayer.numberOfLoops = -1;
    [_musicPlayer play];
}

#pragma mark - alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self gameAgain:nil];
    }
    else {
        [self gameCancel];
    }
}

- (void)gameAgain:(UIButton *)button {
    if (button.hidden == NO) {
        button.hidden = YES;
    }
    
    [_timer setFireDate:[NSDate distantPast]]; // 开始定时器
    
    UIView *redView = [self.view viewWithTag:10000];
    CGRect frame = redView.frame;
    // 4 4s
    if (WindowSize.height == 480) {
        frame = CGRectMake(95, 443, 200, 18);
    }
    // 5 5s
    else if (WindowSize.height == 568) {
        frame = CGRectMake(95, 540, 200, 20);
    }
    // 6 6s
    else if (WindowSize.height == 667) {
        frame = CGRectMake(110, 590, 234, 22);
    }
    // 6p 6sp
    else if (WindowSize.height == 736) {
        frame = CGRectMake(122, 634, 261, 27);
    }
    
    redView.frame = frame;
    
    score = 0;
}

- (void)gameCancel {
    _startButton.hidden = NO;
    
    for (int i = 0; i < _mouses.count; i++) {
        MouseButton *mouse = _mouses[i];
        [mouse resetMoveDistance];
        
        // 4 4s
        if (WindowSize.height == 480) {
            mouse.frame = CGRectMake(21+102*(i%3), 205+93*(i/3), 79, 56);
        }
        // 5 5s
        else if (WindowSize.height == 568) {
            mouse.frame = CGRectMake(23+100*(i%3), 260+110*(i/3), 79, 56);
        }
        // 6 6s
        else if (WindowSize.height == 667) {
            mouse.frame =CGRectMake(33+120*(i%3), 273+130*(i/3), 79, 56);
        }
        // 6p 6sp
        else if (WindowSize.height == 736) {
            mouse.frame = CGRectMake(35+132*(i%3), 285+135*(i/3), 79, 56);
        }
    }
}

@end
