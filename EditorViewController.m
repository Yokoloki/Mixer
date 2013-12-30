//
//  MainViewController.m
//  exMixer
//
//  Created by Junfeng Shen on 20/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "EditorViewController.h"

@implementation EditorViewController
@synthesize materialTable, audioTable, projName;
static const NSString *itemStatusContext;
NSMutableDictionary *recordSettings;
NSString *recordFile;
AVAudioRecorder *recorder;
BOOL lockAudioTable;
BOOL lockCurrentCell;
BOOL isPlayingTracks;
BOOL isPlayingAudio;
BOOL isRecording;
NSInteger selectedRow = -1;
NSInteger preSelectedRow = -1;
DashLine *dashLineView;
AccurateSlider *acSlider;
NSTimer *dashLineTimer;
NSTimer *recordingTimer;
MBProgressHUD *HUD;
NSString *projDir;
NSDateFormatter *dateformat;
long libraryBitmap;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatAppleLossless] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
        dashLineView = [[DashLine alloc] initWithFrame:CGRectMake(395, 350, 500, 400)];
        dashLineView.width = 498;
        dashLineView.hidden = YES;
        dateformat = [[NSDateFormatter alloc] init];
        library = [[AudioLibrary alloc] init];
        libraryBitmap = 0x0;
    }
    return self;
}

- (void)setupAsset:(AVAsset *)asset withTimeRange:(CMTimeRange)timerange andName:(NSString *)theName{
    projName = theName;
    editor = [[TrackEditor alloc] initWithVideo:asset withTimeRange:timerange];
    NSFileManager *manager = [NSFileManager defaultManager];
    projDir = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:projName] retain];
    if(![manager fileExistsAtPath:projDir]){
        [manager createDirectoryAtPath:projDir withIntermediateDirectories:NO attributes:nil error:nil];
        NSLog(@"mkdir %@", projDir);
    }
    [dateformat setDateFormat:@"HH:mm:ss_yyyy/MM/dd"];
}

- (void)dealloc{
    [recordSettings release];
    [dashLineView release];
    [dateformat release];
    [library release];
    [editor release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    buttonStatus = NO;
    lockAudioTable = NO;
    isPlayingTracks = NO;
    isPlayingAudio = NO;
    isRecording = NO;
    acSlider = [[AccurateSlider alloc] initWithFrame:playerSliderView.bounds];
    [acSlider addTarget:self action:@selector(playerSliderMoved:) forControlEvents:UIControlEventValueChanged];
    [playerSliderView addSubview:acSlider];
    [self.materialTable registerNib:[UINib nibWithNibName:@"materialCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"materialCell"];
    [self.audioTable registerNib:[UINib nibWithNibName:@"normalAudioCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"normalAudioCell"];
    [self.audioTable registerNib:[UINib nibWithNibName:@"extendAudioCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"extendAudioCell"];
    [self.audioTable registerNib:[UINib nibWithNibName:@"recordAudioCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"recordAudioCell"];
    [self.view addSubview:dashLineView];
    [playerView setBusy];
    AVPlayerItem *item = [editor videoItem];
    [item addObserver:self forKeyPath:@"status" options:0 context:&itemStatusContext];
    player = [AVPlayer playerWithPlayerItem:item];
    playerView.player = player;
}

- (void)viewDidUnload
{
    [acSlider release];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(tableView == audioTable)
        return 1;
    else
        return [library.kindArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView ==materialTable){
        long status = 0x1 & (libraryBitmap >> section);
        if (status == 0x1)
            return [[library.assetlistArray objectAtIndex:section] count];
        else 
            return 0;
    }
    else
        return [editor.audioArray count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"materialHeaderView" owner:nil options:nil] objectAtIndex:0];
    view.tag = section;
    if ((0x1 & (libraryBitmap >> section)) == 0x1){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Display click2.png"]];
        imageView.frame = CGRectMake(13, 32, 17, 17);
        [view addSubview:imageView];
        [imageView release];
    }
    else{
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Display click1.png"]];
        imageView.frame = CGRectMake(15, 31, 15, 18);
        [view addSubview:imageView];
        [imageView release];
    }
    UITextField *nameText = (UITextField *)[view viewWithTag:61];
    nameText.text = [library.kindArray objectAtIndex:section];
    UITapGestureRecognizer *tGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadLibraryForView:)];
    [view addGestureRecognizer:tGr];
    [tGr release];
    return view;
}

- (void)reloadLibraryForView:(id)sender{
    UITapGestureRecognizer *tgr = (UITapGestureRecognizer *)sender;
    int section = tgr.view.tag;
    long statusBit = 0x1 << section;
    libraryBitmap = libraryBitmap ^ statusBit;
    [self.materialTable reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if(tableView == materialTable){
        cell = [tableView dequeueReusableCellWithIdentifier:@"materialCell"];
        UILabel *label = (UILabel *)[cell viewWithTag:61];
        label.text = (NSString *)[(NSMutableArray *)[library.namelistArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        UIButton *playButton = (UIButton *)[cell viewWithTag:62];
        [playButton addTarget:self action:@selector(playLibraryAudio:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *addButton = (UIButton *)[cell viewWithTag:63];
        [addButton addTarget:self action:@selector(addAudioFromLibrary:) forControlEvents:UIControlEventTouchUpInside];
        IndexedCell *iCell = (IndexedCell *)cell;
        iCell.indexPath = indexPath;
    }else if(tableView == audioTable){
        AudioObject *obj = (AudioObject *)[editor.audioArray objectAtIndex:indexPath.row];
        if(selectedRow == indexPath.row){
            if([[editor.audioArray objectAtIndex:indexPath.row] recorded]){
                cell = [tableView dequeueReusableCellWithIdentifier:@"extendAudioCell"];
                UIButton *playButton = (UIButton *)[cell viewWithTag:300];
                [playButton addTarget:self action:@selector(play_OR_pause_SelectedAudio:) forControlEvents:UIControlEventTouchUpInside];
                UIButton *volumeButton = (UIButton *)[cell viewWithTag:301];
                [volumeButton addTarget:self action:@selector(switchVolumeSubView:) forControlEvents:UIControlEventTouchUpInside];
                //
                //
                //
                //UIButton *libraryButton = (UIButton *)[cell viewWithTag:302];
                //
                //
                //
                UIButton *hideButton = (UIButton *)[cell viewWithTag:303];
                [hideButton addTarget:self action:@selector(hide_OR_unhide_SelectedAudio:) forControlEvents:UIControlEventTouchUpInside];
                UIButton *deleteButton = (UIButton *)[cell viewWithTag:304];
                [deleteButton addTarget:self action:@selector(deleteSelectedAudio:) forControlEvents:UIControlEventTouchUpInside];
                UIView *volumeView = (UIView *)[cell viewWithTag:310];
                volumeView.frame = CGRectMake(590, 0, volumeView.frame.size.width, volumeView.frame.size.height);
                UISlider *volumeSlider = (UISlider *)[volumeView viewWithTag:311];
                volumeSlider.value = obj.volume;
                [volumeSlider addTarget:self action:@selector(volumeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
                UISwitch *inSwitch = (UISwitch *)[volumeView viewWithTag:312];
                inSwitch.on = obj.smoothIn;
                [inSwitch addTarget:obj action:@selector(smoothInVallueChanged:) forControlEvents:UIControlEventTouchUpInside];
                UISwitch *outSwitch = (UISwitch *)[volumeView viewWithTag:313];
                outSwitch.on = obj.smoothOut;
                [outSwitch addTarget:obj action:@selector(smoothOutVallueChanged:) forControlEvents:UIControlEventTouchUpInside];
            }else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"recordAudioCell"];
                UIButton *startButton = (UIButton *)[cell viewWithTag:200];
                [startButton addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchUpInside];
                UIButton *stopButton = (UIButton *)[cell viewWithTag:201];
                [stopButton addTarget:self action:@selector(stopRecording:) forControlEvents:UIControlEventTouchUpInside];
            }
        }else
            cell = [tableView dequeueReusableCellWithIdentifier:@"normalAudioCell"];
        if (obj.hidden) {
            NSArray *views = [cell subviews];
            for(UIView *v in views)
                v.alpha = 0.7;
        }else {
            NSArray *views = [cell subviews];
            for(UIView *v in views)
                v.alpha = 1;
        }
        UIView *sliderView = [cell viewWithTag:100];
        [[sliderView viewWithTag:99] removeFromSuperview];
        TrackSlider *slider = [[[TrackSlider alloc] initWithFrame:sliderView.bounds] autorelease];
        slider.objID = indexPath.row;
        slider.tag = 99;
        slider.startValue = CMTimeGetSeconds(obj.startTime)/editor.videoLength;
        slider.rangeValue = CMTimeGetSeconds(obj.rangeTime.duration)/editor.videoLength;
        [slider addTarget:self action:@selector(syncPlayerWhenSliderMove:) forControlEvents:UIControlEventValueChanged];
        [sliderView addSubview:slider];
        UITextField *nameField = (UITextField *)[cell viewWithTag:98];
        nameField.text = obj.name;
        [nameField addTarget:self action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [nameField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [nameField addTarget:obj action:@selector(NameChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(tableView == audioTable)
        return 0;
    else
        return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == materialTable)
        return 50;
    else if(tableView == audioTable){
        if(selectedRow == indexPath.row)
            return 140;
        else
            return 61;
    }
    return -1;
}

#pragma mark - Table view delegate

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(lockCurrentCell && selectedRow == indexPath.row) return nil;
    if(tableView == audioTable && !lockAudioTable){
        preSelectedRow = selectedRow;
        selectedRow = indexPath.row;
        return  indexPath;
    }
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(selectedRow != preSelectedRow){
        lockCurrentCell = NO;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, [NSIndexPath indexPathForRow:preSelectedRow inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    else {
        selectedRow = -1;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:preSelectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - AVAudioRecorder methods
TrackSlider *currSlider;
CMTime startTimeWhenRecord;
- (void)startRecording:(id)sender{
    if(isPlayingTracks) return;
    if(isRecording){
        NSLog(@"recorder is already recording");
        return;
    }
    isRecording = YES;
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.dimBackground = YES;
    HUD.delegate = self;
    HUD.hidden = NO;
	[HUD showWhileExecuting:@selector(prepareToRecord:) onTarget:self withObject:nil animated:YES];
}

- (void)prepareToRecord:(id)sender{
    lockAudioTable = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    NSString *path = [projDir stringByAppendingFormat:@"/%d.m4a", (int)[[NSDate date] timeIntervalSince1970]];
    NSURL *url = [NSURL fileURLWithPath:path];
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&err];
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    currSlider = (TrackSlider *)[[audioTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]] viewWithTag:99];
    currSlider.enabled = NO;
    acSlider.enabled = NO;
    acSlider.value = currSlider.startValue;
    [self syncVideo];
    [recorder record];
    startTimeWhenRecord = [player currentTime];
    [self syncDashline];
    [self playVideo];
    [self performSelectorOnMainThread:@selector(setupLevelMeter) withObject:nil waitUntilDone:!HUD];
}

- (void)setupLevelMeter{
    CALevelMeter *levelMeter = (CALevelMeter *)[[audioTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]] viewWithTag:202];
    [levelMeter setRecorder:recorder];
    recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(syncViewsWhenRecording) userInfo:nil repeats:YES];
}

- (void)syncViewsWhenRecording{
    currSlider.rangeValue = acSlider.value - currSlider.startValue;
    [currSlider layoutSubviews];
    if(CMTimeGetSeconds(player.currentTime)+0.05 > editor.videoLength){
        [self stopRecording:nil];
    }
}

- (void) stopRecording:(id)sender{
    if(isPlayingTracks) return;
    if(!recorder.isRecording)
        NSLog(@"recorder is not recording");
    else {
        isRecording = NO;
        [recorder stop];
        [self stopVideo];
        currSlider.enabled = YES;
        currSlider = nil;
        acSlider.enabled = YES;
        AudioObject *obj = (AudioObject *)[editor.audioArray objectAtIndex:selectedRow];
        [obj setupAsset:[AVAsset assetWithURL:recorder.url] atTime:startTimeWhenRecord];
        lockAudioTable = NO;
        CALevelMeter *levelMeter = (CALevelMeter *)[[audioTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]] viewWithTag:202];
        [levelMeter setRecorder:nil];
        recorder = nil;
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag{
    [recordingTimer invalidate];
    recordingTimer = nil;
    if(flag)
        NSLog(@"Successfully recorded.");
    else {
        NSLog(@"Failed to record");
    }
    [self.audioTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedRow inSection:0]] withRowAnimation:YES];
}
#pragma mark - CellButton Methods

double audioStartValue;
double audioEndTime;
- (void)play_OR_pause_SelectedAudio:(id)sender{
    if (isPlayingTracks) return;
    if(isPlayingAudio){
        [self resetPlayerToValue:acSlider.value];
    }else{
        lockAudioTable = YES;
        CGRect fr = playerView.frame;
        [player release];
        [playerView release];
        playerView = [[PlayerView alloc] initWithFrame:fr];
        [playerBackground addSubview:playerView];        
        [playerView setBusy];
        
        AVPlayerItem *item = [editor playWithAudio:selectedRow];
        [item addObserver:self forKeyPath:@"status" options:0 context:&itemStatusContext];
        player = [AVPlayer playerWithPlayerItem:item];
        playerView.player = player;
        audioStartValue = CMTimeGetSeconds([(AudioObject*)[editor.audioArray objectAtIndex:selectedRow] startTime])/editor.videoLength;
        acSlider.value = audioStartValue;
        audioEndTime = CMTimeGetSeconds([(AudioObject*)[editor.audioArray objectAtIndex:selectedRow] startTime]) + CMTimeGetSeconds([(AudioObject*)[editor.audioArray objectAtIndex:selectedRow] rangeTime].duration);
        [self syncVideo];
        [player play];
        timeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.02, 600) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [self syncSlider_AND_DashLine_WhenPlaying];
            if(CMTimeGetSeconds(player.currentTime) + 0.05 > audioEndTime)
                [self resetPlayerToValue:audioStartValue];
        }];
        isFullScreen = NO;
        isPlayingAudio = YES;
    }
}

- (void)hide_OR_unhide_SelectedAudio:(id)sender{
    AudioObject *obj = [editor.audioArray objectAtIndex:selectedRow];
    obj.hidden = !obj.hidden;
    [self.audioTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)deleteSelectedAudio:(id)sender{
    [editor.audioArray removeObjectAtIndex:selectedRow];
    [self.audioTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)switchVolumeSubView:(id)sender{
    UITableViewCell *cell = [self.audioTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]];
    UIView *volumeView = [cell viewWithTag:310];
    if(volumeView.frame.origin.x == 590){
        lockCurrentCell = YES;
        [UIView beginAnimations: nil context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: 0.3f];
        volumeView.frame = CGRectOffset(volumeView.frame, -volumeView.frame.size.width, 0);
        [UIView commitAnimations];
    }else {
        lockCurrentCell = NO;
        [UIView beginAnimations: nil context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: 0.3f];
        volumeView.frame = CGRectOffset(volumeView.frame, volumeView.frame.size.width, 0);
        [UIView commitAnimations];
    }
}

NSTimer *volumeTimer;
- (void)volumeSliderValueChanged:(UISlider *)slider{
    AudioObject *obj = [editor.audioArray objectAtIndex:selectedRow];
    obj.volume = slider.value;
    UITableViewCell *cell = [self.audioTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]];
    UILabel *label = (UILabel *)[cell viewWithTag:315];
    label.text = [NSString stringWithFormat:@"%.1f x", slider.value];
    UIView *popView = (UIView *)[cell viewWithTag:314];
    popView.hidden = NO;
    popView.frame = CGRectMake(375+113*slider.value, popView.frame.origin.y, popView.frame.size.width, popView.frame.size.height);
    if(volumeTimer != nil)
        [volumeTimer invalidate];
    volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideVolumePopView:) userInfo:popView repeats:NO];
}
- (void)hideVolumePopView:(NSTimer*)timer{
    
    if(volumeTimer != nil){
        ((UIView*)timer.userInfo).hidden = YES;
        volumeTimer = nil;
    }
}

- (void)addAudioFromLibrary:(id)sender{
    IndexedCell *cell = (IndexedCell *)[[sender superview] superview];
    NSIndexPath *path = cell.indexPath;
    AudioObject *obj = [[AudioObject alloc] initWithAsset:(AVAsset *)[(NSMutableArray *)[library.assetlistArray objectAtIndex:path.section] objectAtIndex:path.row]];
    obj.name = (NSString *)[(NSMutableArray *)[library.namelistArray objectAtIndex:path.section] objectAtIndex:path.row];
    [editor.audioArray addObject:obj];
    [self.audioTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)playLibraryAudio:(id)sender{
    IndexedCell *cell = (IndexedCell *)[[sender superview] superview];
    NSIndexPath *path = cell.indexPath;
    [library playAudioAtSection:path.section Row:path.row];
}

#pragma mark - SideButton Methods
BOOL buttonStatus;

- (IBAction)showORhideButtons:(id)sender{
    if(buttonStatus){
        addTrackButton.hidden = true;
        exportButton.hidden = true;
        backButton.hidden = true;
    }else {
        addTrackButton.hidden = false;
        exportButton.hidden = false;
        backButton.hidden = false;
    }
    buttonStatus = !buttonStatus;
}

- (IBAction)addTrack:(id)sender{
    AudioObject *newObj = [[AudioObject alloc] init];
    newObj.name =  [[dateformat stringFromDate:[NSDate date]] retain];
    [editor.audioArray addObject:newObj];
    [newObj release];
    [self.audioTable reloadData];
}

- (IBAction)backToProjects:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Slider Methods
- (void)syncDashline{
    dashLineView.value = acSlider.value;
    [dashLineView setNeedsDisplay];
    dashLineView.hidden = NO;
}
NSTimer *slideWhenPlayingTimer;
- (void)playerSliderMoved:(id)sender{
    if(isPlayingAudio || isPlayingTracks){
        if(slideWhenPlayingTimer != nil){
            [slideWhenPlayingTimer invalidate];
        }else {
            [player pause];
        }
        slideWhenPlayingTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(resumePlaying:) userInfo:nil repeats:NO];
    }
    [self syncVideo];
    [self syncDashline];
    if(dashLineTimer!= nil)
        [dashLineTimer invalidate];
    dashLineTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideDashLine:) userInfo:nil repeats:NO];
}

- (void)resumePlaying:(id)sender{
    [player play];
    slideWhenPlayingTimer = nil;
}

- (void)syncPlayerWhenSliderMove:(TrackSlider *)slider{
    AudioObject *obj = [editor.audioArray objectAtIndex:slider.objID];
    obj.startTime = CMTimeMakeWithSeconds(slider.startValue*editor.videoLength, 600);
    acSlider.value = slider.startValue;
    [acSlider layoutSubviews];
    [self syncDashline];
    [self syncVideo];
    if(dashLineTimer!= nil)
        [dashLineTimer invalidate];
    dashLineTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideDashLine:) userInfo:nil repeats:NO];
}

- (void)hideDashLine:(id)sender{
    dashLineView.hidden = YES;
    dashLineTimer = nil;
}

#pragma mark - Player Methods
BOOL isFullScreen;
id timeObserver;

- (void)resetPlayerToValue:(CGFloat)value{
    CGRect fr = playerView.frame;
    [player pause];
    [player removeTimeObserver:timeObserver];
    timeObserver = nil;
    dashLineView.hidden = YES;
    [player release];
    [playerView release];
    playerView = [[PlayerView alloc] initWithFrame:fr];
    [playerBackground addSubview:playerView];
    lockAudioTable = NO;
    acSlider.enabled = YES;
    [playerView setBusy];
    AVPlayerItem *item = [editor videoItem];
    [item addObserver:self forKeyPath:@"status" options:0 context:&itemStatusContext];
    player = [AVPlayer playerWithPlayerItem:item];
    playerView.player = player;
    acSlider.value = value;
    [acSlider layoutSubviews];
    [self syncVideo];
    isPlayingAudio = NO;
    isPlayingTracks = NO;
    isFullScreen = NO;
}
- (IBAction)play_OR_stop_Tracks:(id)sender{
    if(isPlayingAudio || isRecording) return;
    if(isPlayingTracks){
        [self resetPlayerToValue:acSlider.value];
    }else {
        lockAudioTable = YES;
        CGRect fr = playerView.frame;
        [player release];
        [playerView release];
        playerView = [[PlayerView alloc] initWithFrame:fr];
        [playerBackground addSubview:playerView];
        [playerView setBusy];
        AVPlayerItem *item = [editor assembAudios];
        [item addObserver:self forKeyPath:@"status" options:0 context:&itemStatusContext];
        player = [AVPlayer playerWithPlayerItem:item];
        playerView.player = player;
        [player play];
        timeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.02, 600) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [self syncSlider_AND_DashLine_WhenPlaying];
            if(CMTimeGetSeconds(player.currentTime) + 0.05 > editor.videoLength)
                [self resetPlayerToValue:0.0];
        }];
        isFullScreen = NO;
        isPlayingTracks = YES;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(context == &itemStatusContext){
        dispatch_async(dispatch_get_main_queue(), ^{
            [playerView unsetBusy];
        });
        return;
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
}

- (void)syncSlider_AND_DashLine_WhenPlaying{
    if(!isFullScreen){
        double currentTime = CMTimeGetSeconds([player currentTime]);
        acSlider.value = currentTime/editor.videoLength;
        [acSlider layoutSubviews];
        [self syncDashline];
    }
}
- (void)playVideo{
    [player play];
    timeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.02, 600) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [self syncSlider_AND_DashLine_WhenPlaying];
        if(CMTimeGetSeconds(player.currentTime)+ 0.05 > editor.videoLength)
            [self stopVideo];
    }];
}

- (void)stopVideo{
    [player pause];
    [player removeTimeObserver:timeObserver];
    timeObserver = nil;
    dashLineView.hidden = YES;
}

- (void)syncVideo{
    double seekTime = acSlider.value * editor.videoLength;
    double tolerance = editor.videoLength / acSlider.frame.size.width;
    [player seekToTime:CMTimeMakeWithSeconds(seekTime, NSEC_PER_SEC) 
       toleranceBefore:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) 
        toleranceAfter:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)];
}

- (IBAction)fullScreenButton:(id)sender{
    isFullScreen = YES;
}

#pragma mark - HUD delegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

#pragma mark - TextField
int animatedDis;
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField:textField up:NO];
}


- (void) animateTextField:(UITextField*)textField up:(BOOL)up
{
    CGPoint temp = [textField.superview convertPoint:textField.frame.origin toView:nil];
    if(up) {
        int moveUpValue = temp.x+textField.frame.size.height;
        animatedDis = 352-(768-moveUpValue-5);
    }
    if(animatedDis>0){
        int movement = (up ? -animatedDis : animatedDis);
        [UIView beginAnimations: nil context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: 0.3f];
        self.view.frame = CGRectOffset(self.view.frame, movement, 0);
        [UIView commitAnimations];
    }
}
@end
