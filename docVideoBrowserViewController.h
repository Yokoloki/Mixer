//
//  LocalVideoBrowserViewController.h
//  exMixer
//
//  Created by Junfeng Shen on 18/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CMTime.h>
#import "docVideoBrowserSource.h"

@protocol docVideoBrowserViewControllerDelegate;

@interface docVideoBrowserViewController:UIViewController <UITableViewDelegate, UITableViewDataSource>{
@private
	NSArray *_assetSources;
	NSMutableArray *_activeAssetSources;
	BOOL _singleSourceTypeMode;
	
	id<docVideoBrowserViewControllerDelegate> _delegate;
	
	BOOL _thumbnailGenerationIsRunning;
	BOOL _thumbnailGenerationEnabled;
	
	CGFloat _lastTableViewYContentOffset;
	BOOL _lastTableViewScrollDirection;
	
	CGFloat _thumbnailScale;
}

@property (nonatomic, assign) id<docVideoBrowserViewControllerDelegate> delegate;
// These should be private, don't use them.
@property (nonatomic, retain) NSArray *assetSources;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end

@protocol docVideoBrowserViewControllerDelegate <NSObject>

- (void)assetBrowser:(docVideoBrowserViewController *)assetBrowser didChooseAsset:(AVAsset *)asset;

@end
