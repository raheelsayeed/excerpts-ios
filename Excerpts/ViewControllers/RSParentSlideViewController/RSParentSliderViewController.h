//
//  RSParentSliderViewController.h
//  Slider
//
//  Created by M Raheel Sayeed on 02/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNDirectionPanGestureRecognizer.h"

@protocol RSParentSliderViewControllerDelegate <NSObject>
@optional
-(BOOL)canPushFromSide:(NSInteger)sideIndex;
@end
@protocol RSParentSliderViewControllerDatasource <NSObject>
@optional
- (UIViewController *)viewController:(UIViewController *)viewController toPushFromSide:(NSInteger)pushFromSide;
- (UIViewController *)viewControllerFromBase:(UIViewController *)baseVC FromSwipedDirection:(RNDirection)direction;
@end



@interface RSParentSliderViewController : UIViewController

@property (nonatomic, assign) id<RSParentSliderViewControllerDatasource> datasource;
@property (nonatomic, assign) id<RSParentSliderViewControllerDelegate> delegate;
@property (nonatomic, weak) UIViewController *baseViewController;
@property (nonatomic, weak) UIViewController *toNewViewController;
@property (nonatomic, assign) BOOL enableGestures;

- (instancetype)initWithBaseViewController:(UIViewController *)baseVC;
@end
