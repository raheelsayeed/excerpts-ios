//
//  UIView+MotionEffect.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 28/02/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MotionEffect)

- (void)removeMotionEffects;
- (void)addMotionEffectsForX_Max:(id)x_max X_Min:(id)x_min Y_Max:(id)y_max Y_Min:(id)y_min;

@end
