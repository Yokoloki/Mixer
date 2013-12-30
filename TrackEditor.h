//
//  TrackEditor.h
//  exMixer
//
//  Created by Junfeng Shen on 12/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
@interface TrackEditor: NSObject{
    AVAsset *video;
    double videoLength;//in 1s
    CMTimeRange videoRange;
    NSMutableArray *audioArray;
    AVMutableComposition *composition;
}
@property (nonatomic, retain) NSMutableArray *audioArray;
@property (nonatomic, retain) AVMutableComposition *composition;
@property (nonatomic, retain) AVAsset *video;
@property (nonatomic, assign) double videoLength;

- (id)initWithVideo:(AVAsset *)asset withTimeRange:(CMTimeRange)timerange;
- (AVPlayerItem *)videoItem;
- (AVPlayerItem *)assembAudios;
- (AVPlayerItem *)playWithAudio:(NSInteger)audioID;
@end