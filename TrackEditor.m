//
//  TrackEditor.m
//  exMixer
//
//  Created by Junfeng Shen on 12/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//
#import "TrackEditor.h"
#import "AudioObject.h"

@implementation TrackEditor
@synthesize audioArray, video, composition, videoLength;
- (id)init{
    self = [super init];
    if (self){
        videoRange = CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
        self.videoLength = 0;
        self.audioArray = [[NSMutableArray alloc] init];
        self.composition = nil;
    }
    return self;
}

- (id)initWithVideo:(AVAsset *)asset withTimeRange:(CMTimeRange)timerange{
    self = [self init];
    self.video = asset;
    NSArray *key = [NSArray arrayWithObject:@"duration"];
    [self.video loadValuesAsynchronouslyForKeys:key completionHandler:^{
        NSError *err = nil;
        AVKeyValueStatus trackStatus = [asset statusOfValueForKey:@"duration" error:&err];
        switch (trackStatus) {
            case AVKeyValueStatusLoaded:
                NSLog(@"Successful loaded");
                videoRange = timerange;
                self.videoLength = CMTimeGetSeconds(videoRange.duration);
                break;
            case AVKeyValueStatusFailed:
                NSLog(@"Asset loading failed");
                break;
            case AVKeyValueStatusCancelled:
                NSLog(@"Loading asset cancelled");
                break;
        }        
    }];
    if([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0){
        AudioObject *obj = [[AudioObject alloc] initWithAsset:asset andRange:timerange atTime:kCMTimeZero];
        obj.name = @"Background";
        [self.audioArray addObject:obj];
        [obj release];
    }
    return self;
}

- (void)dealloc{
    [self.audioArray release];
    [self.video release];
    [self.composition release];
    [super dealloc];
}

- (AVPlayerItem *)videoItem{
    [composition release];
    composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:videoRange ofTrack:[[video tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:composition];
    return item;
}

- (AVPlayerItem *)assembAudios{
    [composition release];
    composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:videoRange ofTrack:[[video tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    NSMutableArray *mixArray = [[NSMutableArray alloc] init];
    for(int i=0; i<[audioArray count]; i++){
        AudioObject *obj = [audioArray objectAtIndex:i];
        if(obj.hidden) continue;
        //Add audioTrack
        AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:obj.rangeTime ofTrack:[[obj.asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:obj.startTime error:nil];
        //Set audioMix
        AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
        [trackMix setVolume:obj.volume atTime:kCMTimeZero];
        if(obj.smoothIn){
            [trackMix setVolumeRampFromStartVolume:0 toEndVolume:obj.volume timeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(2, 600))];
        }
        if(obj.smoothOut){
            [trackMix setVolumeRampFromStartVolume:obj.volume toEndVolume:0 timeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(CMTimeGetSeconds(obj.startTime)+CMTimeGetSeconds(obj.rangeTime.duration)-2, 600), CMTimeMakeWithSeconds(2, 600))];
        }
        [mixArray addObject:trackMix];
    }
    AVMutableAudioMix *mix = [AVMutableAudioMix audioMix];
    mix.inputParameters = [NSArray arrayWithArray:mixArray];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:composition];
    item.audioMix = mix;
    [mixArray release];
    return item;
}


- (AVPlayerItem *)playWithAudio:(NSInteger)audioID{
    [composition release];
    composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:videoRange ofTrack:[[video tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    AudioObject *obj = [audioArray objectAtIndex:audioID];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:obj.rangeTime ofTrack:[[obj.asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:obj.startTime error:nil];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:composition];
    return item;
}
@end
