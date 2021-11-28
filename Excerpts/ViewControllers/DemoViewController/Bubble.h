//
//  Bubble.h
//  Renote
//
//  Created by M Raheel Sayeed on 29/01/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Bubble : UIView

- (void)startAnimatingLeftoToRight:(BOOL)LeftToRight atPoint:(CGPoint)point;
- (void)startAnimating:(BOOL)left;
- (void)stopAnimating;

- (void)startTopAnimationAtPoint:(CGPoint)point;
@end
