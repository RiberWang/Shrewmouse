//
//  MouseButton.m
//  Shrewmouse
//
//  Created by Riber on 16/6/21.
//  Copyright © 2016年 Riber. All rights reserved.
//

#import "MouseButton.h"
#import <AVFoundation/AVFoundation.h>

#define Speed 10
int score; // 分数 全局变量

@interface MouseButton ()
{
    AVAudioPlayer *_player;
    BOOL _isMoveHole;
    int _moveDistance;
}
@end

@implementation MouseButton

- (id)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame]) {
     
        [self setImage:[UIImage imageNamed:@"Mole01.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"Mole04.png"] forState:UIControlStateDisabled];
        
        // 刚开始 时禁用
        self.enabled = NO;
        _isMoveHole = NO;
        _moveDistance = 0;
        
        [self addTarget:self action:@selector(shrewMouse) forControlEvents:UIControlEventTouchDown];
        
        [self createMusic];
    }
    
    return self;
}

- (void)shrewMouse
{
    [_player play];
    
    score++;
    self.enabled = NO;
    
    ///
    if (_moveDistance < 60) { //表示向上走得时候 被点击
        _moveDistance = 120 - _moveDistance;
    }
}

- (void)startMoving {
    _isMoveHole = YES;
    
    if (_moveDistance == 0) {
        self.enabled = YES;
    }
}

- (void)resetMoveDistance {
    _moveDistance = 0;
}

- (void)outOfHole
{
    if (_isMoveHole == NO) {
        return;
    }
    
    CGPoint point = self.center;
    if (_moveDistance < 60) {
        point.y -= Speed;
    }
    else
    {
        point.y += Speed;
    }
    
    self.center = point;
    _moveDistance += Speed;
    
    if (_moveDistance == 120) {
        _moveDistance = 0;
        self.enabled = NO;
        _isMoveHole = NO;
    }
    
}

- (void)createMusic {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Sound15" ofType:@"wav"];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:nil];
    [_player prepareToPlay];
}

@end
