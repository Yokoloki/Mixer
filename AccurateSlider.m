//
//  AccurateSlider.m
//  exMixer
//
//  Created by Junfeng Shen on 16/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "AccurateSlider.h"

@implementation AccurateSlider

@synthesize value;

static double minimumValue = 0;
static double maximumValue = 1;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _ThumbOn = NO;
        _padding = 17;
        value = 0;
        CGRect fr;
        _trackBackground = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video play_time background.png"]] autorelease];
        fr = _trackBackground.frame;
        fr.size.width = frame.size.width;
        _trackBackground.frame = fr;
        _trackBackground.center = self.center;
        [self addSubview:_trackBackground];
        
        _Thumb = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video play_time button.png"] highlightedImage:[UIImage imageNamed:@"video play_time button.png"]] autorelease];
        _Thumb.frame = CGRectMake(0,0, self.frame.size.height,self.frame.size.height);
        _Thumb.contentMode = UIViewContentModeCenter;
        [self addSubview:_Thumb];
    }
    
    return self;
}


-(void)layoutSubviews{
    _Thumb.center = CGPointMake([self xForValue:value], self.center.y);
}

-(float)xForValue:(float)theValue{
    return (self.frame.size.width-(_padding*2))*((theValue - minimumValue) / (maximumValue - minimumValue))+_padding;
}

-(float) valueForX:(float)x{
    return minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (maximumValue - minimumValue);
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if(!_ThumbOn){
        return YES;
    }
    
    CGPoint touchPoint = [touch locationInView:self];
    _Thumb.center = CGPointMake(MAX([self xForValue:minimumValue],MIN(touchPoint.x, [self xForValue:maximumValue])), _Thumb.center.y);
    value = [self valueForX:_Thumb.center.x];
    [self setNeedsLayout];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touch locationInView:self];
    if(CGRectContainsPoint(_Thumb.frame, touchPoint)){
        _ThumbOn = true;
    }
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    _ThumbOn = NO;
}


@end
