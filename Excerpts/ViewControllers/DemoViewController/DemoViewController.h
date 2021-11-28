//
//  DemoViewController.h
//  Renote
//
//  Created by M Raheel Sayeed on 29/01/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import "ContainerController.h"
#import "Bubble.h"
#import "MRModalAlertView.h"



@class Bubble;
@interface DemoViewController : ContainerController

@property (nonatomic) Bubble *bubble;
- (void)stopAllAnimatedIndications;
- (void)dismissSelf:(id)sender;
@end
