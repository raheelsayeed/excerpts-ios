//
//  ContainerViewController.h
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContainerViewControllerDatasource <NSObject>

@required
- (UIViewController *)containerViewController:(UIViewController *)container viewControllerBeforeViewController:(UIViewController *)vc;
- (UIViewController *)containerViewController:(UIViewController *)container viewControllerAfterViewController:(UIViewController *)vc;
- (void)containerViewController:(UIViewController *)container viewControllerWillTransitionToNewTraits:(UITraitCollection *)traitCollection coordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

@end

@interface ContainerController : UIViewController

@property (nonatomic, assign) BOOL parallaxEnabled; // default = ON
@property (nonatomic, assign) BOOL wrappingEnabled; // default = OFF, Only applicable when initializing with setViewControllers:

@property (nonatomic, weak) id<ContainerViewControllerDatasource> datasource;

@property (nonatomic, weak, readonly) UIViewController *currentViewController;

@property (nonatomic, strong) UIPanGestureRecognizer * pan;

- (void)setInitialViewController:(UIViewController *)vc;
- (void)setViewControllers:(NSMutableArray *)viewControllers;

- (void)transitionToNext;
- (void)transitionToPrevious;

- (void)animationTransitionEnded;
@end
