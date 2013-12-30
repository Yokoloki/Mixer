//
//  VideoEditViewController.m
//  exMixer
//
//  Created by Junfeng Shen on 18/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "VideoCutViewController.h"

#import "TrackSlider.h"

@implementation VideoCutViewController
@synthesize asset, delegate;
int videoLength;    //in 0.1sec
int startTime;      //in 0.1sec
int endTime;        //in 0.1sec
CGFloat preMin;
CGFloat preMax;
BOOL isPlaying;
static const NSString *itemStatusContext;

#pragma mark - View life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [button addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"next page button.png"] forState:UIControlStateNormal];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = doneButton;
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 440, 44)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = UITextAlignmentCenter;
        nameLabel.textColor = [[[UIColor alloc] initWithRed:0.84 green:0.76 blue:0.59 alpha:0.7] autorelease];
        nameLabel.shadowColor = [UIColor grayColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:20];
        nameLabel.text = @"Cut Video";
        self.navigationItem.titleView = nameLabel;
        [nameLabel release];
        [button release];
        [doneButton release];
        isPlaying = false;
    }
    return self;
}
- (void)dealloc{
    [self removeTimeObserverFromPlayer];
    [rangeSlider release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cut video_banner.png"]];
    CGRect fr = self.navigationController.navigationBar.frame;
    fr.size.width += 2;
    fr.origin.x -= 1;
    imageView.frame = fr;
    [(UIView *)[self.navigationController.navigationBar.subviews objectAtIndex:0] addSubview:imageView];
    [imageView release];
    [self loadSlider];
    [playerView setBusy];
    NSString *tracksKey = @"tracks";
    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:tracksKey] completionHandler:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *err = nil;
            AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&err];
            if(status == AVKeyValueStatusLoaded){
                AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
                [item addObserver:self forKeyPath:@"status" options:0 context:&itemStatusContext];
                player = [AVPlayer playerWithPlayerItem:item];
                playerView.player = player;
            }else{
                NSLog(@"The asset's tracks were not loaded:%@", [err localizedDescription]);
            }
        });
    }];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [self removeTimeObserverFromPlayer];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(context == &itemStatusContext){
        dispatch_async(dispatch_get_main_queue(), ^{
            [playerView unsetBusy];
            videoLength = endTime = CMTimeGetSeconds(asset.duration)*10;
            endTimeLabel.text = [NSString stringWithFormat:@"%.2d' %.2d.%1d''",
                                 endTime/600, endTime%600/10, endTime%10];
            [endTimeLabel layoutIfNeeded];
            [self syncTimeLabel];
        });
        return;
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
}

- (void)loadSlider{
    rangeSlider = [[RangeSlider alloc] initWithFrame:rangeView.bounds];
    preMin = 0;
    preMax = 1;
    startTime = endTime = videoLength = 0;
    startTimeLabel.text = @"00' 00.0''";
    endTimeLabel.text = @"00' 00.0''";
    currTime.text = @"00:00";
    rangeSlider.minimumRange = 0.05;
    rangeSlider.minimumValue = 0;
    rangeSlider.maximumValue = 1;
    rangeSlider.selectedMaximumValue = 1;
    rangeSlider.selectedMinimumValue = 0;
    [rangeSlider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [rangeView addSubview:rangeSlider];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)done{
    //check input fields
    if([nameField.text length] < 1){
        [nameField becomeFirstResponder];
        return;
    }
    [delegate videoCuter:self didChooseAsset:asset withTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(startTime/10.0, 600), CMTimeMakeWithSeconds((endTime - startTime)/10.0, 600)) andName:nameField.text];
}

#pragma mark - Player
- (IBAction)playORpause:(id)sender{
    if(!isPlaying){
        playButton.hidden = YES;
        pauseButton.hidden = NO;
        [player seekToTime:CMTimeMakeWithSeconds(startTime * 0.1, NSEC_PER_SEC) 
           toleranceBefore:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) 
            toleranceAfter:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC)];
        [player play];
        [self addTimeObserverToPlayer];
    }else{
        pauseButton.hidden = YES;
        playButton.hidden = NO;
        [player pause];
        [self removeTimeObserverFromPlayer];
    }    
    isPlaying = !isPlaying;
}

- (void)syncTimeLabel {
	double seconds = CMTimeGetSeconds([player currentTime]);
	if (isfinite(seconds)) {
		if (seconds < 0.0) {
			seconds = 0.0;
		}
		int secondsInt = round(seconds);
		int minutes = secondsInt/60;
        int seconds = secondsInt%60;
		currTime.text = [NSString stringWithFormat:@"%.2i:%.2i", minutes, seconds];
	}
    [currTime layoutIfNeeded];
}

- (void)addTimeObserverToPlayer {
	if (_timeObserver)
		return;
	_timeObserver = [[player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
					  ^(CMTime time) {
                          int seconds = 10*CMTimeGetSeconds([player currentTime]);
                          if(seconds >= endTime)
                              [self playORpause:nil];
						  [self syncTimeLabel];
                      }] retain];
}

- (void)removeTimeObserverFromPlayer {
	if (_timeObserver) {
		[player removeTimeObserver:_timeObserver];
		[_timeObserver release];
		_timeObserver = nil;
	}
}


#pragma mark - Slider

- (void)sliderValueDidChange:(RangeSlider *)slider{
    NSLog(@"Slider Range: %f - %f", slider.selectedMinimumValue, slider.selectedMaximumValue);
    double seekTime = 0.1;
    if((fabs(slider.selectedMinimumValue - preMin))*videoLength > 1){
        preMin = slider.selectedMinimumValue;
        startTime = preMin*videoLength;
        startTimeLabel.text = [NSString stringWithFormat:@"%.2d' %.2d.%1d''",
                                    startTime/600, startTime%600/10, startTime%10];
        seekTime *= startTime;
        [self syncTimeLabel];
    }
    else if((fabs(slider.selectedMaximumValue - preMax))*videoLength > 1){
        preMax = slider.selectedMaximumValue;
        endTime = preMax*videoLength;
        endTimeLabel.text = [NSString stringWithFormat:@"%.2d' %.2d.%1d''",
                                  endTime/600, endTime%600/10, endTime%10];
        seekTime *= endTime;
    }
    double tolerance = 0.1f * videoLength / rangeSlider.bounds.size.width;
    [player seekToTime:CMTimeMakeWithSeconds(seekTime, NSEC_PER_SEC) 
       toleranceBefore:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) 
        toleranceAfter:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)];
}

- (IBAction)startTimeInc:(id)sender{
    startTime++;
    if(startTime >= endTime)
        startTime = endTime-1;
    startTimeLabel.text = [NSString stringWithFormat:@"%.2d' %.2d.%1d''",
                                startTime/600, startTime%600/10, startTime%10];
    preMin = (double)startTime/videoLength;
    rangeSlider.selectedMinimumValue = preMin;
    [rangeSlider layoutSubviews];
    [player seekToTime:CMTimeMakeWithSeconds(startTime*0.1, NSEC_PER_SEC) 
       toleranceBefore:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) 
        toleranceAfter:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC)];
    [self syncTimeLabel];
}
- (IBAction)startTimeDec:(id)sender{
    startTime--;
    if(startTime < 0)
        startTime = 0;
    startTimeLabel.text = [NSString stringWithFormat:@"%.2d' %.2d.%1d''",
                                startTime/600, startTime%600/10, startTime%10];
    preMin = (double)startTime/videoLength;
    rangeSlider.selectedMinimumValue = preMin;
    [rangeSlider layoutSubviews];
    [player seekToTime:CMTimeMakeWithSeconds(startTime*0.1, NSEC_PER_SEC) 
       toleranceBefore:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) 
        toleranceAfter:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC)];
    [self syncTimeLabel];
}
- (IBAction)endTimeInc:(id)sender{
    endTime++;
    if(endTime>videoLength)
        endTime = videoLength;
    endTimeLabel.text = [NSString stringWithFormat:@"%.2d' %.2d.%1d''",
                                endTime/600, endTime%600/10, endTime%10];
    preMax = (double)endTime/videoLength;
    rangeSlider.selectedMaximumValue = preMax;
    [rangeSlider layoutSubviews];
    [player seekToTime:CMTimeMakeWithSeconds(endTime*0.1, NSEC_PER_SEC) 
       toleranceBefore:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) 
        toleranceAfter:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC)];
}
- (IBAction)endTimeDec:(id)sender{
    endTime--;
    if(endTime<=startTime)
        endTime = startTime+1;
    endTimeLabel.text = [NSString stringWithFormat:@"%.2d' %.2d.%1d''",
                                endTime/600, endTime%600/10, endTime%10];
    preMax = (double)endTime/videoLength;
    rangeSlider.selectedMaximumValue = preMax;
    [rangeSlider layoutSubviews];
    [player seekToTime:CMTimeMakeWithSeconds(endTime*0.1, NSEC_PER_SEC) 
       toleranceBefore:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) 
        toleranceAfter:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC)];
}

@end
