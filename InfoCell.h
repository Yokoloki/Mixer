//
//  InfoCell.h
//  exMixer
//
//  Created by Junfeng Shen on 20/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoCell : UITableViewCell{
    IBOutlet UILabel *label;
    IBOutlet UITextField *textField;
}
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UITextField *textField;

@end
