//
//  PlayerView.m
//  exMixer
//
//  Created by Junfeng Shen on 19/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//
#import "PlayerView.h"

@implementation PlayerView
UIActivityIndicatorView *busyIndicator;

- (void)dealloc{
    self.player = nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (Class)layerClass{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
	return [(AVPlayerLayer*)[self layer] player];
}


- (void)setPlayer:(AVPlayer*)player
{
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

- (void)setBusy{
    busyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    busyIndicator.frame = CGRectMake((self.frame.size.width-busyIndicator.frame.size.width)/2, (self.frame.size.height-busyIndicator.frame.size.height)/2, busyIndicator.frame.size.width, busyIndicator.frame.size.height);
    [self addSubview:busyIndicator];
    [busyIndicator startAnimating];
}

- (void)unsetBusy{
    if(busyIndicator != nil){
        [busyIndicator removeFromSuperview];
        busyIndicator = nil;
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
