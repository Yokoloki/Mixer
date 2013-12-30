//
//  InfoCell.m
//  exMixer
//
//  Created by Junfeng Shen on 20/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "InfoCell.h"

@implementation InfoCell
@synthesize label, textField;

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
