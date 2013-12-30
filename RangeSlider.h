//
//  RangeSlider.h
//  exMixer
//
//  Created by Junfeng Shen on 19/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface RangeSlider : UIControl{
    double minimumValue;
    double maximumValue;
    double minimumRange;
    double selectedMinimumValue;
    double selectedMaximumValue;
    double distanceFromCenter;
    
    float _padding;
    
    BOOL _maxThumbOn;
    BOOL _minThumbOn;
    
    UIImageView * _minThumb;
    UIImageView * _maxThumb;
    UIImageView * _track;
    UIImageView * _trackBackground;
}

@property(nonatomic) double minimumValue;
@property(nonatomic) double maximumValue;
@property(nonatomic) double minimumRange;
@property(nonatomic) double selectedMinimumValue;
@property(nonatomic) double selectedMaximumValue;

@end