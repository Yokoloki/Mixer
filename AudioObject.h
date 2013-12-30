//
//  AudioObject.h
//  exMixer
//
//  Created by Junfeng Shen on 12/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>

@interface AudioObject : NSObject{
    AVAsset *asset;
    BOOL recorded;
    BOOL smoothIn, smoothOut;
    BOOL hidden;
    double volume;
    CMTimeRange rangeTime;
    CMTime startTime;
    NSString *name;
}
@property (nonatomic, retain) AVAsset *asset;
@property (nonatomic, assign) BOOL recorded;
@property (nonatomic, assign) BOOL smoothIn;
@property (nonatomic, assign) BOOL smoothOut;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) double volume;
@property (nonatomic, assign) CMTimeRange rangeTime;
@property (nonatomic, assign) CMTime startTime;
@property (nonatomic, assign) NSString *name;

- (id)initWithAsset:(AVAsset*)theAsset;
- (id)initWithAsset:(AVAsset *)theAsset atTime:(CMTime)time;
- (id)initWithAsset:(AVAsset *)theAsset andRange:(CMTimeRange)range atTime:(CMTime)time;
- (void)setupAsset:(AVAsset *)theAsset atTime:(CMTime)time;
- (void)NameChanged:(UITextField *)textField;
- (void)smoothInVallueChanged:(UISwitch *)aSwitch;
- (void)smoothOutVallueChanged:(UISwitch *)aSwitch;
@end
