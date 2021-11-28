//
//  ShowTransition.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 27/02/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "ShowTransition.h"

@implementation ShowTransition

- (NSTimeInterval) transitionDuration:(id)transitionContext
{
    return 0.7f;
}
- (void) animateTransition:(id)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[transitionContext containerView] addSubview:toViewController.view];
    
    CGRect fullFrame = [transitionContext initialFrameForViewController:fromViewController];
    //CGFloat height_fromVC = CGRectGetHeight(fullFrame);
    
    /*
    toViewController.view.frame = CGRectMake(
                                       fullFrame.origin.x,
                                       height_fromVC + 16,
                                       CGRectGetWidth(fullFrame),
                                       height_fromVC
                                       );
    */
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.6f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         toViewController.view.frame = fullFrame;
                         
//                         toViewController.view.frame = CGRectMake(20, 20, CGRectGetWidth(fullFrame) - 100, height_fromVC );
                         
                     } completion:^(BOOL finished) {
                         

                         [transitionContext completeTransition:YES];
                         
                     }];
    
    
    
    
}

/*
 - (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
 {
 UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
 UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
 CGRect sourceRect = [transitionContext initialFrameForViewController:fromVC];
 
 fromVC.view.frame = sourceRect;
 
 UIGraphicsBeginImageContextWithOptions(fromVC.view.frame.size, NO, 0);
 [fromVC.view drawViewHierarchyInRect:fromVC.view.bounds afterScreenUpdates:YES];
 UIImage *fromVCImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 UIView *container = [transitionContext containerView];
 [container setBackgroundColor:[UIColor colorWithPatternImage:fromVCImage]];
 
 [container insertSubview:toVC.view belowSubview:fromVC.view];
 
 CGRect fromVCFrame = fromVC.view.frame;
 
 __block CGRect toVCFrame = toVC.view.frame;
 toVCFrame.origin.y = fromVCFrame.origin.y + fromVCFrame.size.height;
 [toVC.view setFrame:toVCFrame];
 [toVC.view setAlpha:0.0];
 [toVC.view setBackgroundColor:[UIColor colorWithPatternImage:fromVCImage]];
 
 [transitionContext finalFrameForViewController:toVC];
 
 //3.Perform the animation...............................
 [UIView animateWithDuration:1.0
 animations:^{
 toVCFrame.origin.y = fromVCFrame.origin.y;
 toVC.view.frame = toVCFrame;
 
 [toVC.view setAlpha:1.0];
 }
 completion:^(BOOL finished) {
 //When the animation is completed call completeTransition
 [transitionContext completeTransition:YES];
 }];
 }
 */

@end
