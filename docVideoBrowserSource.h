//
//  docVideoBrowserSource.h
//  exMixer
//
//  Created by Junfeng Shen on 18/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "docVideoBrowserItem.h"

@class ALAssetsLibrary;

@protocol docVideoBrowserSourceDelegate;

@interface docVideoBrowserSource : NSObject
{
	NSString *_sourceName;
	NSArray *_assetItems;
	
	id <docVideoBrowserSourceDelegate> _delegate;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray *assetItems;
@property (nonatomic, assign) id <docVideoBrowserSourceDelegate> delegate;

+ (docVideoBrowserSource*)assetSource;
- (id)init;

- (void)buildSourceLibrary;
@end

@protocol docVideoBrowserSourceDelegate <NSObject>;
@optional
- (void)assetSourceLibraryDidChange:(docVideoBrowserSource *)source;
@end
