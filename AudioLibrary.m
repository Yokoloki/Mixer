//
//  AudioLibrary.m
//  exMixer
//
//  Created by Junfeng Shen on 19/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "AudioLibrary.h"

@implementation AudioLibrary
@synthesize kindArray, assetlistArray, namelistArray;
- (id)init{
    self = [super init];
    self.kindArray = [[NSMutableArray alloc] init];
    self.assetlistArray = [[NSMutableArray alloc] init];
    self.namelistArray = [[NSMutableArray alloc] init];
    urlListArray = [[NSMutableArray alloc] init];
    [self loadAssets];
    return self;
}

- (void)loadAssets{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *materialPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"audioLibrary"];
    if(![fm fileExistsAtPath:materialPath]){
        [fm createDirectoryAtPath:materialPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSArray *m4aFiles = [fm contentsOfDirectoryAtPath:[[NSBundle mainBundle] resourcePath] error:nil];
        for(NSString *fileDir in m4aFiles){
            if([fileDir hasSuffix:@"m4a"]){
                NSString *prefix = [fileDir substringToIndex:[fileDir rangeOfString:@"-"].location];
                NSString *suffix = [fileDir substringFromIndex:[fileDir rangeOfString:@"-"].location +1];
                if(![fm fileExistsAtPath:[materialPath stringByAppendingPathComponent:prefix]])
                    [fm createDirectoryAtPath:[materialPath stringByAppendingPathComponent:prefix] withIntermediateDirectories:YES attributes:nil error:nil];
                [fm copyItemAtPath:[[NSBundle mainBundle] pathForResource:fileDir ofType:nil] toPath:[[materialPath stringByAppendingPathComponent:prefix] stringByAppendingPathComponent:suffix] error:nil];
            }
        }
    }
    BOOL isDir;
    NSArray *dirArray = [fm contentsOfDirectoryAtPath:materialPath error:nil];
    for(NSString *dir in dirArray){
        [fm fileExistsAtPath:[materialPath stringByAppendingPathComponent:dir] isDirectory:&isDir];
        if(!isDir) continue;
        [self.kindArray addObject:dir];
        NSString *dirPath = [materialPath stringByAppendingPathComponent:dir];
        NSArray *fileArray = [fm contentsOfDirectoryAtPath:dirPath error:nil];
        NSMutableArray *assetArray = [[NSMutableArray alloc] init];
        NSMutableArray *nameArray = [[NSMutableArray alloc] init];
        NSMutableArray *urlArray = [[NSMutableArray alloc] init];
        for(NSString *fileDir in fileArray){
            if ([fileDir hasSuffix:@"m4a"]) {
                NSString *tmpString = [dirPath stringByAppendingPathComponent:fileDir];
                [assetArray addObject:[AVAsset assetWithURL:[NSURL fileURLWithPath:tmpString]]];
                [nameArray addObject:[[fileDir lastPathComponent] substringToIndex:[fileDir rangeOfString:@".m4a"].location]];
                [urlArray addObject:[NSURL fileURLWithPath:tmpString]];
            }
        }
        [self.assetlistArray addObject:assetArray];
        [self.namelistArray addObject:nameArray];
        [urlListArray addObject:urlArray];
    }
}

- (void)playAudioAtSection:(NSUInteger)sec Row:(NSUInteger)row{
    NSLog(@"playAudioAtSection:%d Row:%d", sec, row);
    NSURL *url = (NSURL *)[(NSMutableArray *)[urlListArray objectAtIndex:sec] objectAtIndex:row];
    NSLog(@"url = %@", url);
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error != nil) {
        NSLog(@"err!: %@", error);
    }
    player.delegate = self;
    [player prepareToPlay];
    [player play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [player release];
}

@end
