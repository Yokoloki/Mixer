//
//  DashLine.m
//  exMixer
//
//  Created by Junfeng Shen on 14/6/12.
//  Copyright (c) 2012 SYSU. All rights reserved.
//

#import "DashLine.h"

@implementation DashLine
@synthesize value, width;

float lengths[] = {10,10};
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        value = 0;
        width = 0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context =UIGraphicsGetCurrentContext();  
    CGContextBeginPath(context);  
    CGContextSetLineWidth(context, 0.8);  
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineDash(context, 0, lengths, 2);  
    CGContextMoveToPoint(context, 2 + value*width, 0);  
    CGContextAddLineToPoint(context, 2 + value*width, 400);  
    CGContextStrokePath(context);  
}

@end
