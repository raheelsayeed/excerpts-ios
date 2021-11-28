//
//  TLMenuInteractor.h
//  UIViewController-Transitions-Example
//
//  Created by Ash Furrow on 2013-07-18.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagViewController.h"
#import "AppDelegate.h"
@interface TLMenuInteractor : UIPercentDrivenInteractiveTransition <TagViewControllerPanTarget>

-(id)initWithParentViewController:(UIViewController *)viewController;

@property (nonatomic, readonly) UIViewController *parentViewController;

-(void)presentMenu; // Presents the menu non-interactively
-(UIViewController *)modalController;

@end
