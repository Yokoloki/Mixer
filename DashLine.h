//
//  DashLine.h
//  exMixer
//
//  Created by Junfeng Shen on 14/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashLine : UIView{
    double value;
    int width;
}
@property (nonatomic, assign) double value;
@property (nonatomic, assign) int width;
@end
