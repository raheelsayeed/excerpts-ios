//
//  DMSlideTransition.m
//  DMCustomTransition
//
//  Created by Thomas Ricouard on 26/11/13.
//  Copyright (c) 2013 Thomas Ricouard. All rights reserved.
//

#import "DMSlideTransition.h"

@implementation DMSlideTransition


#pragma mark - UIViewControllerAnimatedTransitioning


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.50f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect frame = [containerView bounds];
    toVC.view.frame = containerView.bounds;
    fromVC.view.frame = containerView.bounds;
    [containerView addSubview:fromVC.view];
    [containerView addSubview:toVC.view];

    

    
    if(toVC.isBeingPresented)
    {
        CGRect toVCFrame_beforePresentation = CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
        toVC.view.frame = toVCFrame_beforePresentation;
        CGRect toVCFrame_after = toVCFrame_beforePresentation;
        CGRect fromVC_Final_Presentation = CGRectMake(0, -(CGRectGetHeight(frame)/2), frame.size.width, frame.size.height);
        toVCFrame_after.origin = CGPointZero;
        
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.92f
              initialSpringVelocity:17
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             toVC.view.frame = toVCFrame_after;
                             fromVC.view.frame = fromVC_Final_Presentation;
                             
                         } completion:^(BOOL finished) {
                             [fromVC.view removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
        
        
        
    }
    else
    {
        CGRect toVCFrame_beforePresentation = CGRectMake(0, -(CGRectGetHeight(frame)), CGRectGetWidth(frame), CGRectGetHeight(frame));
        toVC.view.frame = toVCFrame_beforePresentation;
        CGRect fromVC_Final_Presentation = CGRectMake(0, CGRectGetHeight(frame)/2, CGRectGetWidth(frame), CGRectGetHeight(frame));
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.92f
              initialSpringVelocity:17
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             toVC.view.frame = frame;
                             fromVC.view.frame = fromVC_Final_Presentation;
                             
                         } completion:^(BOOL finished) {
                             [fromVC.view removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
        

        
        
    }
    
    
}
@end