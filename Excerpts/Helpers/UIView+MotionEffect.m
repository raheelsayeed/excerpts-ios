//
//  UIView+MotionEffect.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 28/02/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "UIView+MotionEffect.h"

NSString *const centerX = @"center.x";
NSString *const centerY = @"center.y";

@implementation UIView (MotionEffect)


- (void)removeMotionEffects{
    for (UIMotionEffect *effect in self.motionEffects) {
        [self removeMotionEffect:effect];
    }
}

- (void)addMotionEffectsForX_Max:(id)x_max X_Min:(id)x_min Y_Max:(id)y_max Y_Min:(id)y_min
{
    [self removeMotionEffects];

        UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:centerX type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    interpolationHorizontal.minimumRelativeValue =  x_min;
    interpolationHorizontal.maximumRelativeValue = x_max;
    
        UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:centerY type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    interpolationVertical.minimumRelativeValue = y_min;
    interpolationVertical.maximumRelativeValue = y_max;
    
        [self addMotionEffect:interpolationHorizontal];
        [self addMotionEffect:interpolationVertical];
        
        
}



@end
