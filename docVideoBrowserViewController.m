//
//  LocalVideoBrowserViewController.m
//  exMixer
//
//  Created by Junfeng Shen on 18/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "docVideoBrowserViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface docVideoBrowserViewController(docVideoBrowserViewControllerPrivate) <docVideoBrowserSourceDelegate, UIScrollViewDelegate,UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>
- (void)updateCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)updateActiveAssetSources;
- (void)enableThumbnailGeneration;
- (void)disableThumbnailGeneration;
- (void)updateThumbnails;
- (void)generateThumbnails;

@end

NSString *const kAssetBrowserGenerateThumbnails = @"AssetBrowserGenerateThumbnails";

@implementation docVideoBrowserViewController

@synthesize assetSources = _assetSources;
@synthesize delegate = _delegate;
@synthesize tableView;
enum {
	AssetBrowserScrollDirectionDown,
    AssetBrowserScrollDirectionUp
};

#pragma mark -
#pragma mark Initialization

- (id)init {
    self = [super init];
    if(self != nil){
		_thumbnailScale = [[UIScreen mainScreen] scale];
		_activeAssetSources = [[NSMutableArray alloc] initWithCapacity:0];
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 440, 44)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = UITextAlignmentCenter;
        nameLabel.textColor = [[[UIColor alloc] initWithRed:0.84 green:0.76 blue:0.59 alpha:0.7] autorelease];
        nameLabel.shadowColor = [UIColor grayColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:20];
        nameLabel.text = @"Choose An Asset";
        self.navigationItem.titleView = nameLabel;
        [nameLabel release];
	}
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
	self.tableView.rowHeight = 65.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
	float decel = UIScrollViewDecelerationRateNormal - (UIScrollViewDecelerationRateNormal - UIScrollViewDecelerationRateFast)/2.0;
	self.tableView.decelerationRate = decel;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	_lastTableViewYContentOffset = self.tableView.contentOffset.y;
	[self enableThumbnailGeneration];
	// Don't reinitialize asset sources.
	if ([self.assetSources count] > 0)
		return;
	// Okay now generate the list of Assets to be displayed.
	// This should be quick since we are not creating assets or thumbnails.
	NSMutableArray *sources = [NSMutableArray arrayWithCapacity:0];
    [sources addObject:[docVideoBrowserSource assetSource]];
	self.assetSources = [[sources copy] autorelease];
	
	for (docVideoBrowserSource *source in sources) {
		[source buildSourceLibrary];
	}
	[self updateActiveAssetSources];
	if ([sources count] == 1) {
		_singleSourceTypeMode = YES;
		//self.title = [[sources objectAtIndex:0] name];
	}
	else {
		self.tableView.sectionHeaderHeight = 22.0;
	}
	[self.tableView reloadData];
	for (docVideoBrowserSource *source in sources) {
		source.delegate = self;	
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self updateThumbnails];
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	if (indexPath) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[self disableThumbnailGeneration];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	// If we aren't presenting the image picker.
	if (!self.modalViewController) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		if (indexPath)
			[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// If a thumbnail finished while we were rotating then its cell might not have been updated, but the cell could still be cached.
	for (UITableViewCell *visibleCell in [self.tableView visibleCells]) {
		NSIndexPath *indexPath = [self.tableView indexPathForCell:visibleCell];
		[self updateCell:visibleCell forRowAtIndexPath:indexPath];
	}
}

#pragma mark -
#pragma mark Table view data source

- (void)updateActiveAssetSources {
	[_activeAssetSources removeAllObjects];
	for (docVideoBrowserSource *source in self.assetSources) {
		if ( ([source.assetItems count] > 0) ) {
			[_activeAssetSources addObject:source];
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
	return [_activeAssetSources count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section  {
	if (_singleSourceTypeMode)
		return nil;
	
	docVideoBrowserSource *source = [_activeAssetSources objectAtIndex:section];
	NSString *name = [source.assetItems count] > 0 ? source.name : nil;
	return name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numRows = 0;
	numRows = [[[_activeAssetSources objectAtIndex:section] assetItems] count];
	return numRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
	static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
        cell.textLabel.textColor = [[[UIColor alloc] initWithRed:0.84 green:0.76 blue:0.59 alpha:0.7] autorelease];
	}
    docVideoBrowserSource *source = [_activeAssetSources objectAtIndex:indexPath.section];
	docVideoBrowserItem *item = [[source assetItems] objectAtIndex:indexPath.row];
	cell.textLabel.text = item.title;
	UIImage *thumb = item.thumbnailImage;
	if (!thumb) {
		thumb = [item placeHolderImage];
		if (!item.audioOnly && item.canGenerateThumbnailImage) {
			[self updateThumbnails];
		}
	}
	cell.imageView.image = thumb;
	cell.accessoryType = UITableViewCellAccessoryNone;
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	docVideoBrowserItem *selectedItem = [[(docVideoBrowserSource*)[_activeAssetSources objectAtIndex:indexPath.section] assetItems] objectAtIndex:indexPath.row];
    [self.delegate assetBrowser:self didChooseAsset:selectedItem.asset];
}

#pragma mark -
#pragma mark Asset Library Delegate

- (void)assetSourceLibraryDidChange:(docVideoBrowserSource*)source
{	
	[self updateActiveAssetSources];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Thumbnail Generation

- (void)enableThumbnailGeneration
{
	_thumbnailGenerationEnabled = YES;
}

- (void)disableThumbnailGeneration
{
	_thumbnailGenerationEnabled = NO;
}

- (void)updateThumbnails
{
	if (! _thumbnailGenerationEnabled) {
		return;
	}
	if (! _thumbnailGenerationIsRunning) {
		// Run after this run loop iteration is done, don't cause table view display to slow down.
		NSArray *modes = [[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil];
		[self performSelector:@selector(generateThumbnails) withObject:nil afterDelay:0.0 inModes:modes];
		_thumbnailGenerationIsRunning = YES;
		[modes release];
	}
}

- (void)displayGeneratedThumbnail:(UIImage*)thumbnail forAssetItem:(docVideoBrowserItem*)assetItem error:(NSError*)error
{	
	// Need to find the indexPath again, since it may have changed.
	NSUInteger sourceIdx = 0;
	for (docVideoBrowserSource *source in _activeAssetSources) {
		NSUInteger idx = [source.assetItems indexOfObject:assetItem];
		if (idx != NSNotFound) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:sourceIdx];
			NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
			
			if ([visibleIndexPaths containsObject:indexPath]) 
			{
				UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
				if (cell) {
					cell.imageView.image = thumbnail;
					[cell setNeedsLayout];
				}
			}
			break;
		}
		sourceIdx++;
	}
}

- (void)generateThumbnails
{	
	if (! _thumbnailGenerationEnabled) {
		_thumbnailGenerationIsRunning = NO;
		return;
	}
	
	_thumbnailGenerationIsRunning = YES;
	
	NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
	
	id objOrEnumerator = (_lastTableViewScrollDirection == AssetBrowserScrollDirectionDown) ? (id)visibleIndexPaths : (id)[visibleIndexPaths reverseObjectEnumerator];
	for (NSIndexPath *path in objOrEnumerator) 
	{
		NSArray *assetItemsInSection = [[_activeAssetSources objectAtIndex:path.section] assetItems];
		docVideoBrowserItem *assetItem = ([assetItemsInSection count] > path.row) ? [assetItemsInSection objectAtIndex:path.row] : nil;
		if (assetItem && assetItem.canGenerateThumbnailImage && (assetItem.thumbnailImage == nil)) {
			CGFloat targetHeight = self.tableView.rowHeight -1.0; // The contentView is one point smaller than the cell because of the divider.
			targetHeight *= _thumbnailScale;
			
			CGFloat targetAspectRatio = 1.5;
			CGSize targetSize = CGSizeMake(targetHeight*targetAspectRatio, targetHeight);
			
			[assetItem generateThumbnailAsynchronouslyWithSize:targetSize fillMode:AssetBrowserItemFillModeCrop completionHandler:^(UIImage *thumbnail, NSError *error) 
             {
                 if (error) {
                     NSLog(@"Couldn't generate thumbnail for %@, error:%@", assetItem, error);
                 }
                 if (!thumbnail) {
                     thumbnail = [assetItem placeHolderImage];
                 }
                 [self displayGeneratedThumbnail:thumbnail forAssetItem:assetItem error:error];
                 
                 // Continue generating until all thumbnails in range have been finished.
                 [self generateThumbnails];
             }];
			
			return;
		}
	}
	
	_thumbnailGenerationIsRunning = NO;
	
	return;
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self disableThumbnailGeneration];
}

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate) {
		[self enableThumbnailGeneration];
		[self updateThumbnails];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self enableThumbnailGeneration];
	[self updateThumbnails];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	CGFloat newOffset = self.tableView.contentOffset.y;
	CGFloat oldOffset = _lastTableViewYContentOffset;
	
	if (newOffset > oldOffset)
		_lastTableViewScrollDirection = AssetBrowserScrollDirectionDown;
	else if (newOffset < oldOffset)
		_lastTableViewScrollDirection = AssetBrowserScrollDirectionUp;
	
	_lastTableViewYContentOffset = newOffset;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Get rid of AVAsset and thumbnail caches.
	NSLog(@"%@ memory warning, clearing asset and thumbnail caches", self);
	for (docVideoBrowserSource *source in self.assetSources) {
		for (docVideoBrowserItem *item in [source assetItems]) {
			[item clearAssetCache];
			[item clearThumbnailCache];
		}
	}
}

- (void)dealloc 
{
	NSLog(@"assetBrowser: dealloc");
	_delegate = nil;
    
	[_assetSources release];
	[_activeAssetSources release];
	
	[super dealloc];
}

@end
