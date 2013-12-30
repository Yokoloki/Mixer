//
//  IndexedCell.m
//  exMixer
//
//  Created by Junfeng Shen on 24/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "IndexedCell.h"

@implementation IndexedCell
@synthesize indexPath;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
