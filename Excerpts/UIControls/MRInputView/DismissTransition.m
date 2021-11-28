//
//  DismissTransition.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 27/02/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "DismissTransition.h"

@implementation DismissTransition
- (NSTimeInterval) transitionDuration:(id)transitionContext
{
    return 1.0f;
}
- (void) animateTransition:(id)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
    __block CGRect presentedFrame = [transitionContext initialFrameForViewController:fromVC];
    
    [UIView animateKeyframesWithDuration:1.0f delay:0.0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.8 animations:^{
            fromVC.view.frame = CGRectMake(
                                           presentedFrame.origin.x,
                                           -20,
                                           presentedFrame.size.width,
                                           presentedFrame.size.height
                                           );}];
        [UIView  addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
            
            presentedFrame.origin.y += CGRectGetHeight(presentedFrame) + 20;
            fromVC.view.frame = presentedFrame;
            fromVC.view.transform = CGAffineTransformMakeRotation(0.2);
        }];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
}
@end
