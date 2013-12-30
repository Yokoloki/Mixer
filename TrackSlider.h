//
//  TrackSlider.h
//  exMixer
//
//  Created by Junfeng Shen on 12/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackSlider : UIControl{
    double startValue;
    double rangeValue;
    double tapStartPosition;    
    double _padding;
    
    int objID;
    BOOL _tapped;
    
    UIImageView * _minThumb;
    UIImageView * _maxThumb;
    UIImageView * _track;
    UIImageView * _trackBackground;
}

@property(nonatomic) double startValue;
@property(nonatomic) double rangeValue;
@property(nonatomic) int objID;
@end
