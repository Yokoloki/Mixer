//
//  RangeSlider.m
//  exMixer
//
//  Created by Junfeng Shen on 19/5/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "RangeSlider.h"

@interface RangeSlider (PrivateMethods)
-(float)xForValue:(float)value;
-(float)valueForX:(float)x;
- (void)updateTrackHighlight;
@end

@implementation RangeSlider

@synthesize minimumValue, maximumValue, minimumRange, selectedMinimumValue, selectedMaximumValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _minThumbOn = false;
        _maxThumbOn = false;
        _padding = 15;
        CGRect fr;
        _trackBackground = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_time bar2.png"]] autorelease];
        fr = _trackBackground.frame;
        fr.size.width = frame.size.width;
        fr.size.height = 32;
        _trackBackground.frame = fr;
        _trackBackground.center = self.center;
        [self addSubview:_trackBackground];
        NSLog(@"frame height = %f", fr.size.height);
        
        _track = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_time bar（70%Transparency）.png"]] autorelease];
        fr = _track.frame;
        fr.size.width = frame.size.width - 2*_padding;
        _track.frame = fr;
        _track.center = self.center;
        [self addSubview:_track];
        
        _minThumb = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video cut_time button.png"] highlightedImage:[UIImage imageNamed:@"video cut_time button.png"]] autorelease];
        _minThumb.frame = CGRectMake(0,0, self.frame.size.height,self.frame.size.height);
        _minThumb.contentMode = UIViewContentModeCenter;
        [self addSubview:_minThumb];
        
        _maxThumb = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video cut_time button.png"] highlightedImage:[UIImage imageNamed:@"video cut_time button.png"]] autorelease];
        _maxThumb.frame = CGRectMake(0,0, self.frame.size.height,self.frame.size.height);
        _maxThumb.contentMode = UIViewContentModeCenter;
        [self addSubview:_maxThumb];
    }
    
    return self;
}


-(void)layoutSubviews
{
    NSLog(@"... %f - %f", self.selectedMinimumValue, self.selectedMaximumValue);
    // Set the initial state
    _minThumb.center = CGPointMake([self xForValue:selectedMinimumValue], self.center.y);
    _maxThumb.center = CGPointMake([self xForValue:selectedMaximumValue], self.center.y);
    //NSLog(@"Tapable size %f", _minThumb.bounds.size.width); 
    [self updateTrackHighlight];
}

-(float)xForValue:(float)value{
    return (self.frame.size.width-(_padding*2))*((value - minimumValue) / (maximumValue - minimumValue))+_padding;
}

-(float) valueForX:(float)x{
    return minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (maximumValue - minimumValue);
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if(!_minThumbOn && !_maxThumbOn){
        return YES;
    }
    
    CGPoint touchPoint = [touch locationInView:self];
    if(_minThumbOn){
        _minThumb.center = CGPointMake(MAX([self xForValue:minimumValue],MIN(touchPoint.x - distanceFromCenter, [self xForValue:selectedMaximumValue - minimumRange])), _minThumb.center.y);
        selectedMinimumValue = [self valueForX:_minThumb.center.x];
        
    }
    if(_maxThumbOn){
        _maxThumb.center = CGPointMake(MIN([self xForValue:maximumValue], MAX(touchPoint.x - distanceFromCenter, [self xForValue:selectedMinimumValue + minimumRange])), _maxThumb.center.y);
        selectedMaximumValue = [self valueForX:_maxThumb.center.x];
    }
    [self updateTrackHighlight];
    [self setNeedsLayout];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touch locationInView:self];
    
    if(CGRectContainsPoint(_minThumb.frame, touchPoint)){
        _minThumbOn = true;
        distanceFromCenter = touchPoint.x - _minThumb.center.x;
    }
    else if(CGRectContainsPoint(_maxThumb.frame, touchPoint)){
        _maxThumbOn = true;
        distanceFromCenter = touchPoint.x - _maxThumb.center.x;
        
    }
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    _minThumbOn = false;
    _maxThumbOn = false;
}

-(void)updateTrackHighlight{
	_track.frame = CGRectMake(
                              _minThumb.center.x,
                              _track.center.y - (_track.frame.size.height/2),
                              _maxThumb.center.x - _minThumb.center.x,
                              _track.frame.size.height
                              );
}
@end
