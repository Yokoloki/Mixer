//
//  AudioLibrary.h
//  exMixer
//
//  Created by Junfeng Shen on 19/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface AudioLibrary : NSObject<AVAudioPlayerDelegate>{
    NSMutableArray *kindArray;
    NSMutableArray *assetlistArray;
    NSMutableArray *namelistArray;
    NSMutableArray *urlListArray;
}
@property (nonatomic, retain) NSMutableArray *kindArray;
@property (nonatomic, retain) NSMutableArray *assetlistArray;
@property (nonatomic, retain) NSMutableArray *namelistArray;


- (void)playAudioAtSection:(NSUInteger)sec Row:(NSUInteger)row;
@end
