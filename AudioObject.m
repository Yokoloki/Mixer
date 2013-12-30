//
//  AudioObject.m
//  exMixer
//
//  Created by Junfeng Shen on 12/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "AudioObject.h"

@implementation AudioObject
@synthesize asset, smoothIn, smoothOut, recorded, hidden, volume, rangeTime, startTime, name;
- (id)init{
    self = [super init];
    if(self){
        asset = nil;
        smoothIn = smoothIn = hidden = recorded = NO;
        volume = 1.0;
        self.rangeTime = CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
        self.startTime = kCMTimeZero;
    }
    return self;
}
- (id)initWithAsset:(AVAsset *)theAsset{
    self = [self init];
    recorded = YES;
    self.asset = theAsset;
    NSArray *key = [NSArray arrayWithObject:@"duration"];
    [self.asset loadValuesAsynchronouslyForKeys:key completionHandler:^{
        NSError *err = nil;
        AVKeyValueStatus trackStatus = [asset statusOfValueForKey:@"duration" error:&err];
        switch (trackStatus) {
            case AVKeyValueStatusLoaded:
                self.rangeTime = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
                break;
            case AVKeyValueStatusFailed:
                NSLog(@"Asset loading failed");
                break;
            case AVKeyValueStatusCancelled:
                NSLog(@"Loading asset cancelled");
                break;
        }        
    }];
    return self;
}
- (id)initWithAsset:(AVAsset *)theAsset atTime:(CMTime)time{
    self = [self initWithAsset:theAsset];
    self.startTime = time;
    return self;
}
- (id)initWithAsset:(AVAsset *)theAsset andRange:(CMTimeRange)range atTime:(CMTime)time{
    self = [self init];
    recorded = YES;
    self.asset = theAsset;
    self.startTime = time;
    self.rangeTime = range;
    return self;
}

- (void)setupAsset:(AVAsset *)theAsset atTime:(CMTime)time{
    recorded = YES;
    self.asset = theAsset;
    NSArray *key = [NSArray arrayWithObject:@"duration"];
    [self.asset loadValuesAsynchronouslyForKeys:key completionHandler:^{
        NSError *err = nil;
        AVKeyValueStatus trackStatus = [asset statusOfValueForKey:@"duration" error:&err];
        switch (trackStatus) {
            case AVKeyValueStatusLoaded:
                self.rangeTime = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
                break;
            case AVKeyValueStatusFailed:
                NSLog(@"Asset loading failed");
                break;
            case AVKeyValueStatusCancelled:
                NSLog(@"Loading asset cancelled");
                break;
        }        
    }];
    self.startTime = time;
}


- (void)NameChanged:(UITextField *)textField{
    self.name = [[textField text] retain];
    NSLog(@"name after changed %@", self.name);
}

- (void)smoothInVallueChanged:(UISwitch *)aSwitch{
    self.smoothIn = aSwitch.on;
}

- (void)smoothOutVallueChanged:(UISwitch *)aSwitch{
    self.smoothOut = aSwitch.on;
}
@end
