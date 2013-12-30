//
//  VideoEditViewController.h
//  exMixer
//
//  Created by Junfeng Shen on 18/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>

#import "RangeSlider.h"
#import "PlayerView.h"
@protocol VideoCutViewControllerDelegate;

@interface VideoCutViewController : UIViewController{
    IBOutlet PlayerView *playerView;
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *pauseButton;
    IBOutlet UILabel *currTime;
    
    IBOutlet UITextField *nameField;
    
    IBOutlet UIView *rangeView;
    IBOutlet UILabel *startTimeLabel;
    IBOutlet UILabel *endTimeLabel;
    
    AVPlayer *player;
    AVAsset *asset;
    RangeSlider *rangeSlider;
    id _timeObserver;
    id<VideoCutViewControllerDelegate> delegate;
}
@property (nonatomic, retain) AVAsset *asset;
@property (nonatomic, retain) id<VideoCutViewControllerDelegate> delegate;

- (IBAction)playORpause:(id)sender;

- (IBAction)startTimeInc:(id)sender;
- (IBAction)startTimeDec:(id)sender;
- (IBAction)endTimeInc:(id)sender;
- (IBAction)endTimeDec:(id)sender;

@end

@protocol VideoCutViewControllerDelegate <NSObject>
- (void)videoCuter:(VideoCutViewController *)videoCuter didChooseAsset:(AVAsset *)asset withTimeRange:(CMTimeRange) range andName:(NSString *) name;

@end