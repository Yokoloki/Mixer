//
//  IndexedCell.h
//  exMixer
//
//  Created by Junfeng Shen on 24/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndexedCell : UITableViewCell{
    NSIndexPath *indexPath;
}

@property (nonatomic, retain) NSIndexPath *indexPath;
@end
