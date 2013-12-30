//
//  TrackSlider.m
//  exMixer
//
//  Created by Junfeng Shen on 12/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "TrackSlider.h"
@interface TrackSlider(PrivateMethods)
-(float)xForValue:(float)value;
-(float)valueForX:(float)x;
- (void)updateTrackHighlight;
@end

@implementation TrackSlider

@synthesize startValue, rangeValue, objID;
double minimumValue = 0;
double maximumValue = 1;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tapped = NO;
        _padding = 15;
        self.startValue = self.rangeValue = 0;
        
        CGRect fr;
        _trackBackground = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tracks_background(50%Transparency when hide).png"]] autorelease];
        fr = _trackBackground.frame;
        fr.size.width = frame.size.width - 2*_padding;
        _trackBackground.frame = fr;
        _trackBackground.center = self.center;
        [self addSubview:_trackBackground];
        
        _track = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tracks(50%Transparency when hide).png"]] autorelease];
        fr = _track.frame;
        fr.size.width = frame.size.width - 2*_padding + 2;
        _track.frame = fr;
        _track.center = self.center;
        [self addSubview:_track];
        
        _minThumb = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tracks-head.png"] highlightedImage:[UIImage imageNamed:@"handle-hover.png"]] autorelease];
        _minThumb.frame = CGRectMake(0,0, self.frame.size.height,self.frame.size.height);
        _minThumb.contentMode = UIViewContentModeCenter;
        [self addSubview:_minThumb];
        
        _maxThumb = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tracks-end.png"] highlightedImage:[UIImage imageNamed:@"handle-hover.png"]] autorelease];
        _maxThumb.frame = CGRectMake(0,0, self.frame.size.height,self.frame.size.height);
        _maxThumb.contentMode = UIViewContentModeCenter;
        [self addSubview:_maxThumb];
        self.startValue = 0;
        self.rangeValue = 0;
    }
    
    return self;
}


-(void)layoutSubviews
{
    // Set the initial state
    _minThumb.center = CGPointMake([self xForValue:startValue], self.center.y);
    _maxThumb.center = CGPointMake([self xForValue:startValue+rangeValue], self.center.y);
    [self updateTrackHighlight];
}
//Return the position for input value
-(float)xForValue:(float)value{
    return (self.frame.size.width-(_padding*2))*((value - minimumValue) / (maximumValue - minimumValue))+_padding;
}
//Return the value for input position
-(float) valueForX:(float)x{
    return minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (maximumValue - minimumValue);
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if(!_tapped){
        return YES;
    }
    CGPoint touchPoint = [touch locationInView:self];
    CGFloat x = MAX([self xForValue:minimumValue], touchPoint.x + tapStartPosition);
    x = MIN([self xForValue:maximumValue-rangeValue], x );
    _minThumb.center = CGPointMake(x, _minThumb.center.y);
    startValue = [self valueForX:_minThumb.center.x];
    _maxThumb.center = CGPointMake([self xForValue:startValue+rangeValue], self.center.y);
    [self updateTrackHighlight];
    [self setNeedsLayout];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touch locationInView:self];
    CGRect fr = _minThumb.frame;
    fr.size.width += (_maxThumb.frame.origin.x - fr.origin.x);
    if(CGRectContainsPoint(fr, touchPoint)){
        _tapped = true;
        tapStartPosition = _minThumb.center.x - touchPoint.x;
    }
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    _tapped = false;
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
