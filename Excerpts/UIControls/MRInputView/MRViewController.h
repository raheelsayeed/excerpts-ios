//
//  UIViewController+MRModalViewController.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 27/02/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MRViewController;

@protocol MRModalViewControllerDelegate <NSObject>
@optional
- (void)modalViewControllerDidAppear:(UIViewController *)modalViewController;



@end
@interface MRViewController :UIViewController  <UIDynamicAnimatorDelegate, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL parallaxEnabled;
@property (nonatomic, weak) id<MRModalViewControllerDelegate> delegate;
@property (nonatomic, weak) UIView *weakReferenceView;




@property (strong, nonatomic) UIPercentDrivenInteractiveTransition *myInteractiveTransition;
@property (assign, nonatomic) BOOL interactive;


-(void)setupDynamicBehaviorsForView:(UIView *)view;
- (void)mr_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;

@end
