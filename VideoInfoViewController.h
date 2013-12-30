//
//  VideoInfoViewController.h
//  exMixer
//
//  Created by Junfeng Shen on 20/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoCell.h"

@interface VideoInfoViewController : UIViewController<UITableViewDelegate>{
    IBOutlet UITableView *tableview;
}
@property (nonatomic, retain) IBOutlet UITableView *tableview;

@end
