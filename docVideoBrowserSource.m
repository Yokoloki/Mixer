//
//  docVideoBrowserSource.m
//  exMixer
//
//  Created by Junfeng Shen on 18/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "docVideoBrowserSource.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

@implementation docVideoBrowserSource

@synthesize name = _sourceName, assetItems = _assetItems, delegate = _delegate;

+ (docVideoBrowserSource*)assetSource
{
	return [[[self alloc] init] autorelease];
}

- (id)init{
	if (self = [super init]) {
		self.name = @"Choose An Asset";
		self.assetItems = [NSArray array];
	}
	return self;
}

- (void)updateAssetItemsAndSignalDelegate:(NSMutableArray*)newItems{	
	NSArray *immutableAssetItems = [newItems copy];
	self.assetItems = immutableAssetItems;
	[immutableAssetItems release];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(assetSourceLibraryDidChange:)]) {
		[self.delegate assetSourceLibraryDidChange:self];
	}
}

- (void)updateLibraryFromFolderAtPath:(NSString*)directoryPath{
	NSMutableArray *paths = [NSMutableArray arrayWithCapacity:0];
	NSArray *subPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
	if (subPaths) {
		for (NSString *subPath in subPaths) {
			NSString *pathExtension = [subPath pathExtension];
			CFStringRef preferredUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)pathExtension, NULL);
			BOOL fileConformsToUTI = UTTypeConformsTo(preferredUTI, kUTTypeAudiovisualContent);
			CFRelease(preferredUTI);
			NSString *path = [directoryPath stringByAppendingPathComponent:subPath];
			
			if (fileConformsToUTI) {
				[paths addObject:path];
			}
		}
	}
	// A better approach would be to keep around a dictionary of assetURLs -> AssetBrowserItems
	// Then try to pull from that dictionary before creating a new AssetBrowserItem.
	// This way thumbnail and other caches will be preserved between library updates.
	// Also this would make it easier to figure out which indicies were added/removed so that
	// the view controller could animate the table view cell changes.
	
	NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:0];
	for (NSString *path in paths) {
		docVideoBrowserItem *item = [[[docVideoBrowserItem alloc] initWithURL:[NSURL fileURLWithPath:path]] autorelease];
		[items addObject:item];
	}
	
	[self updateAssetItemsAndSignalDelegate:items];	
	[items release];
}

- (void)buildSourceLibrary{
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"docPath=%@",documentsDirectory);
	[self updateLibraryFromFolderAtPath:documentsDirectory];
}

- (void)dealloc {	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_sourceName release];
	[_assetItems release];
	_delegate = nil;
	[super dealloc];
}

@end
