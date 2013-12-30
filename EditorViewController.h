//
//  MainViewController.h
//  exMixer
//
//  Created by Junfeng Shen on 20/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import "MBProgressHUD.h"
#import "TrackEditor.h"
#import "AudioObject.h"
#import "AccurateSlider.h"
#import "TrackSlider.h"
#import "DashLine.h"
#import "CALevelMeter.h"
#import "PlayerView.h"
#import "AudioLibrary.h"
#import "IndexedCell.h"

@interface EditorViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, MBProgressHUDDelegate>{
    IBOutlet UITableView *materialTable;
    IBOutlet UITableView *audioTable;
    
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *exportButton;
    IBOutlet UIButton *addTrackButton;
    
    AVPlayer *player;
    IBOutlet PlayerView *playerView;
    IBOutlet UIView *playerSliderView;
    IBOutlet UIView *playerBackground;
    
    TrackEditor *editor;
    
    AudioLibrary *library;
    
    NSString *projName;
}
@property (nonatomic, retain) IBOutlet UITableView *materialTable;
@property (nonatomic, retain) IBOutlet UITableView *audioTable;
@property (nonatomic, retain) NSString *projName;

- (void)setupAsset:(AVAsset *)asset withTimeRange:(CMTimeRange)timerange andName:(NSString *)theName;
- (IBAction)addTrack:(id)sender;
- (IBAction)showORhideButtons:(id)sender;
- (IBAction)play_OR_stop_Tracks:(id)sender;
@end
