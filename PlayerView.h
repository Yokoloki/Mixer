//
//  PlayerView.h
//  exMixer
//
//  Created by Junfeng Shen on 19/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface PlayerView : UIView
@property (nonatomic, retain) AVPlayer *player;
- (void)setBusy;
- (void)unsetBusy;
@end

