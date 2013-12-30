//
//  VideoPickupViewController.h
//  exMixer
//
//  Created by Junfeng Shen on 18/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoCutViewController.h"
#import "docVideoBrowserViewController.h"
@protocol docVideoBrowserViewControllerDelegate;
@protocol VideoPickupViewControllerDelegate;

@interface VideoPickupViewController : UIViewController<UITableViewDelegate, docVideoBrowserViewControllerDelegate>{
    IBOutlet UITableView *tableView;
    id<VideoPickupViewControllerDelegate> delegate;
}
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) id<VideoPickupViewControllerDelegate> delegate;

- (void)dismiss:(id)sender;
- (IBAction)next:(id)sender;
@end


@protocol VideoPickupViewControllerDelegate <NSObject>

- (void)videoPicker:(VideoPickupViewController *)videoPicker didChooseAsset:(AVAsset *)asset;

@end