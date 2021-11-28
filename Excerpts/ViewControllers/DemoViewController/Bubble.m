//
//  Bubble.m
//  Renote
//
//  Created by M Raheel Sayeed on 29/01/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import "Bubble.h"

@implementation Bubble


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        
        self.backgroundColor = [UIColor redColor];
        self.layer.cornerRadius = frame.size.height/2;
        self.alpha = 0.0;
        self.userInteractionEnabled = NO;
        
        
    }
    return self;
}

- (void)startAnimatingLeftoToRight:(BOOL)LeftToRight atPoint:(CGPoint)point
{
    self.center  = point;
    
    [self startAnimating:LeftToRight];
    
}


- (void)startAnimating:(BOOL)LeftToRight
{
    self.alpha = 0.0;
    
    CGRect sframe = [[self superview] bounds];
    CGPoint selfC;
    if(LeftToRight)
    {
        self.center = CGPointMake(sframe.size.width * 0.2, self.center.y);
        selfC = self.center;
        
    }
    else
    {
        CGPoint cen = CGPointMake(sframe.size.width * 0.85, self.center.y);
        self.center = selfC = cen;
    }
    
    [UIView animateKeyframesWithDuration:1.5
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear|UIViewKeyframeAnimationOptionRepeat
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:0.5/2.0
                                                                animations:^{
                                                                    self.alpha = 0.8;
                                                                }];
                                  /*

                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:1/3.0
                                                                animations:^{
                                                                    
                                                                    CGFloat p = (LeftToRight) ? 0.3 : 0.8;
                                                                    
                                                                    self.center = CGPointMake(sframe.size.width * p , selfC.y);
                                                                    
                                                                }];
                                  */
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:1/2.0
                                                                animations:^{
                                                                    self.center = CGPointMake(sframe.size.width * 0.5, selfC.y);
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:1.0/2.0
                                                          relativeDuration:1/2.0
                                                                animations:^{
                                                                    
                                                                    CGFloat p = (LeftToRight) ? 0.8 : 0.2;

                                                                    self.center = CGPointMake(sframe.size.width * p, selfC.y);
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:2.9/3.0
                                                          relativeDuration:0.1/3.0
                                                                animations:^{
                                                                    self.alpha = 0.0;
                                                                }];
                                  
                              }
                              completion:^(BOOL finished) {
                                  self.center = selfC;

                              }];
    
}

- (void)startTopAnimationAtPoint:(CGPoint)point
{
    self.center =    CGPointMake( self.superview.frame.size.width/2 , self.superview.frame.size.height/2);

    

    [UIView animateKeyframesWithDuration:1.0
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear|UIViewKeyframeAnimationOptionRepeat
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:0.5/2.0
                                                                animations:^{

                                                                    self.alpha = 0.5;
                                                                }];

                                  
                                  
                                  
                                  self.transform = CGAffineTransformMakeScale(1.2, 1.2);
                                  
                                  

                                  [UIView addKeyframeWithRelativeStartTime:2.9/3.0
                                                          relativeDuration:0.1/3.0
                                                                animations:^{
                                                                    self.alpha = 0.0;
                                                                }];
                                  
                              }
     completion:^(BOOL finished) {
         

         self.transform = CGAffineTransformMakeScale(1, 1);

     }];

    
    
    
}

- (void)stopAnimating
{
    [self removeFromSuperview];
    [self.layer removeAllAnimations];
}


@end
