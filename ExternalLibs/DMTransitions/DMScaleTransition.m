//
//  DMScaleTransition.m
//  DMCustomTransition
//
//  Created by Thomas Ricouard on 26/11/13.
//  Copyright (c) 2013 Thomas Ricouard. All rights reserved.
//

#import "DMScaleTransition.h"

@implementation DMScaleTransition


#pragma mark - UIViewControllerAnimatedTransitioning


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    if (self.isPresenting) {
        
        
        containerView.bounds  = fromVC.view.frame;
        containerView.frame = fromVC.view.frame;
        toVC.view.bounds = fromVC.view.bounds;
        toVC.view.frame = fromVC.view.frame;
        
        
        [containerView addSubview:toVC.view];
        [toVC.view setAlpha:0];
        //CGRect fromVCFrame = fromVC.view.frame;
        //toVC.view.frame = fromVCFrame;

        CGAffineTransform xForm = toVC.view.transform;
        toVC.view.transform = CGAffineTransformScale(xForm, 1.1f, 1.1f);
        
      

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             [toVC.view setAlpha:1];
                             toVC.view.transform =
                             CGAffineTransformScale(xForm, 1.0f, 1.0f);

                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];

                         }];
    }
    else {
        
        //[containerView addSubview:toVC.view];
        [containerView addSubview:fromVC.view];
        
        CGAffineTransform xForm = fromVC.view.transform;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             [fromVC.view setAlpha:0];
                             fromVC.view.transform =
                             CGAffineTransformScale(xForm, 1.1f, 1.1f);
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];

                         }];
    }
}

@end
