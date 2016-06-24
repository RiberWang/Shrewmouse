//
//  MouseButton.h
//  Shrewmouse
//
//  Created by Riber on 16/6/21.
//  Copyright © 2016年 Riber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MouseButton : UIButton

- (void)startMoving;
- (void)outOfHole;
- (void)resetMoveDistance;

@end
