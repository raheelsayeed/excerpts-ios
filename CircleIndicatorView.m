//
//  CircleIndicatorView.m
//  Renote
//
//  Created by M Raheel Sayeed on 29/01/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import "CircleIndicatorView.h"

@interface CircleIndicatorView()
{
    CAShapeLayer *_circle;
    BOOL _hasInitialized;
}
@end

@implementation CircleIndicatorView
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (!_hasInitialized && !CGRectEqualToRect(frame, CGRectZero))
        [self initializeControl];
    else if (_hasInitialized && !CGRectEqualToRect(frame, CGRectZero))
    {
        int radius = self.bounds.size.width / 2;
        _circle.path = [self generateCirclePathWithRadius:radius];
        _circle.position = CGPointMake(CGRectGetMidX(self.bounds) - radius, CGRectGetMidY(self.bounds) - radius);
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if (!_hasInitialized && !CGRectEqualToRect(frame, CGRectZero))
            [self initializeControl];
    }
    
    return self;
}
-(void)initializeControl
{
    int radius = self.bounds.size.width / 2;
    
    _circle = [CAShapeLayer layer];
    _circle.path = [self generateCirclePathWithRadius:radius];
    _circle.position = CGPointMake(CGRectGetMidX(self.bounds) - radius, CGRectGetMidY(self.bounds) - radius);
    _circle.fillColor = [UIColor redColor].CGColor;
    //_circle.strokeColor = [UIColor colorWithRed:0.75 green:0.0 blue:0.0 alpha:1.0].CGColor;
    _circle.lineWidth = self.bounds.size.width * 0.05;
    [self.layer addSublayer:_circle];
    
    self.userInteractionEnabled = NO;
    _hasInitialized = YES;
}

-(CGPathRef)generateCirclePathWithRadius:(CGFloat)radius
{
    return [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0 * radius, 2.0 * radius) cornerRadius:radius].CGPath;
}

-(void)toggleOnOff
{
    self.on = !self.on;
}
- (void)setOn:(BOOL)on
{
    _on = on;
    if (_on)
    {
        _circle.fillColor = [UIColor greenColor].CGColor;
        //_circle.strokeColor = [UIColor colorWithRed:0.0 green:0.75 blue:0.0 alpha:1.0].CGColor;
    }
    else
    {
        _circle.fillColor = [UIColor redColor].CGColor;
        //_circle.strokeColor = [UIColor colorWithRed:0.75 green:0.0 blue:0.0 alpha:1.0].CGColor;
    }
}
@end
