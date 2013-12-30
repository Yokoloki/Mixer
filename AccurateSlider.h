//
//  AccurateSlider.h
//  exMixer
//
//  Created by Junfeng Shen on 16/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccurateSlider : UIControl{
    double value;
    double _padding;
    BOOL _ThumbOn;
    UIImageView * _Thumb;
    UIImageView * _trackBackground;
}

@property(nonatomic) double value;


@end
