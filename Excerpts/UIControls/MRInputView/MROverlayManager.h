//
//  MROverlayManager.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 28/02/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
	MRAnimationTypeFadeInOut = 1,
	MRAnimationTypeZoomFromToCenter
} MRAnimationType;

@class MROverlayManager;

@protocol MROverlayManagerDelegate <NSObject>
@optional
- (void) willDismissOverlay:(MROverlayManager *)overlay;
- (BOOL) overlayShouldReposition:(MROverlayManager *)overlay;
- (void) overlayWillMoveToNewPosition:(MROverlayManager *)overlay;
- (void) overlayDidMoveToNewPosition:(MROverlayManager *)overlay;
@end




@interface MROverlayManager : UIControl  <UIDynamicAnimatorDelegate, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <MROverlayManagerDelegate> delegate;
@property (nonatomic, readonly, retain) UIView *willPresentInView;
@property (nonatomic, assign) BOOL alignOnScreen;
@property (nonatomic, assign) BOOL useParallex;



-(CGPoint)centerForView:(UIView *)view;
+ (MROverlayManager *) sharedManager;
- (void) hideFromOverlay:(id)sender;
- (void) overlay:(UIView *)aView withCenter:(CGPoint)atOrigin inView:(UIView *)refView;


@end



























