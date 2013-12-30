//
//  docVideoItem.h
//  exMixer
//
//  Created by Junfeng Shen on 18/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CMTime.h>

@class AVAsset;
enum {
	AssetBrowserItemFillModeCrop,
	AssetBrowserItemFillModeAspectFit
};
typedef NSInteger AssetBrowserItemFillMode;

@interface docVideoBrowserItem : NSObject <NSCopying> {
	NSURL *_URL;
	UIImage *_thumbnailImage;
	NSString *_title;
	AVAsset *_asset;
	CMTime _thumbnailTime;
	BOOL _canGenerateThumbnailImage;
	BOOL _audioOnly;
}

- (id)initWithURL:(NSURL*)URL;
- (id)initWithURL:(NSURL*)URL andTitle:(NSString*)title;
// With AssetBrowserItemFillModeAspectFit size acts as a maximum size. Pass CGRectZero for a full size thumbnail;
// With AssetBrowserItemFillModeCrop the image is cropped to fit size. If the asset does not have enough resolution 
// than the returned image have be the aspect ratio specified by size, but lower resolution.
// Retrieve the generated thumbnail with the thumbnailImage property.
- (void)generateThumbnailWithSize:(CGSize)size fillMode:(AssetBrowserItemFillMode)mode;
- (void)generateThumbnailAsynchronouslyWithSize:(CGSize)size fillMode:(AssetBrowserItemFillMode)mode completionHandler:(void (^)(UIImage *thumbnail, NSError *error))handler;
- (UIImage*)placeHolderImage;


@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly, retain) UIImage *thumbnailImage;
@property (nonatomic, readonly) BOOL canGenerateThumbnailImage;
@property (nonatomic, readonly) BOOL audioOnly;
@property (nonatomic, readonly) AVAsset *asset;

@property (nonatomic) CMTime thumbnailTime;

- (void)clearThumbnailCache;
- (void)clearAssetCache;

@end
