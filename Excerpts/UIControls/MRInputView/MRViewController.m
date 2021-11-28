//
//  UIViewController+MRModalViewController.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 27/02/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "MRViewController.h"
#import "ShowTransition.h"
#import "DismissTransition.h"


@interface MRViewController ()
@property (nonatomic, strong) UIView *fromView;
@property (nonatomic, assign) CGRect fromRect;


@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UISnapBehavior *snapBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *panAttachmentBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;




@end

@implementation MRViewController{
    CGRect _originalFrame;

}
@dynamic parallaxEnabled;
@synthesize weakReferenceView = _weakReferenceView;

 



static const CGFloat __density = 1.0f;							// relative mass density applied to the image's dynamic item behavior
static const CGFloat __velocityFactor = 1.0f;
static const CGFloat __resistance = 0.0f;						// linear resistance applied to the image’s dynamic item behavior

-(void)setupDynamicBehaviorsForView:(UIView *)view
{
    _weakReferenceView = view;
    _originalFrame = _weakReferenceView.frame;
    
	self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panRecognizer.delegate = self;
    [view addGestureRecognizer:self.panRecognizer];
    
    /* UIDynamics stuff */
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.presentedViewController.view];
    self.animator.delegate = self;
    
    // snap behavior to keep image view in the center as needed
    self.snapBehavior = [[UISnapBehavior alloc] initWithItem:view snapToPoint:_weakReferenceView.center];
    self.snapBehavior.damping = 0.7f;
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[view] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.angle = 0.2f;
    self.pushBehavior.magnitude = 0.2f;
    
    self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[view]];
    self.itemBehavior.elasticity = 0.3f;
    self.itemBehavior.friction = 0.2f;
    self.itemBehavior.allowsRotation = YES;
    self.itemBehavior.density = __density;
    self.itemBehavior.resistance = __resistance;

}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    static UIAttachmentBehavior *attachment;
    static CGPoint               startCenter;
    
    // variables for calculating angular velocity
    
    static CFAbsoluteTime        lastTime;
    static CGFloat               lastAngle;
    static CGFloat               angularVelocity;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [self.animator removeAllBehaviors];
        
        startCenter = gesture.view.center;
        
        // calculate the center offset and anchor point
        
        CGPoint pointWithinAnimatedView = [gesture locationInView:gesture.view];
        
        UIOffset offset = UIOffsetMake(pointWithinAnimatedView.x - gesture.view.bounds.size.width / 2.0,
                                       pointWithinAnimatedView.y - gesture.view.bounds.size.height / 2.0);
        
        CGPoint anchor = [gesture locationInView:gesture.view.superview];
        
        // create attachment behavior
        
        attachment = [[UIAttachmentBehavior alloc] initWithItem:gesture.view
                                               offsetFromCenter:offset
                                               attachedToAnchor:anchor];
        
        // code to calculate angular velocity (seems curious that I have to calculate this myself, but I can if I have to)
        
        lastTime = CFAbsoluteTimeGetCurrent();
        lastAngle = [self angleOfView:gesture.view];
        
        attachment.action = ^{
            CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
            CGFloat angle = [self angleOfView:gesture.view];
            if (time > lastTime) {
                angularVelocity = (angle - lastAngle) / (time - lastTime);
                lastTime = time;
                lastAngle = angle;
            }
        };
        
        // add attachment behavior
        
        [self.animator addBehavior:attachment];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        // as user makes gesture, update attachment behavior's anchor point, achieving drag 'n' rotate
        
        CGPoint anchor = [gesture locationInView:gesture.view.superview];
        attachment.anchorPoint = anchor;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self.animator removeAllBehaviors];
        
        CGPoint velocity = [gesture velocityInView:gesture.view.superview];
        
        // if we aren't dragging it down, just snap it back and quit
        
        if (fabs(atan2(velocity.y, velocity.x) - M_PI_2) > M_PI_4) {
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
            [self.animator addBehavior:snap];
            
            return;
        }
        
        // otherwise, create UIDynamicItemBehavior that carries on animation from where the gesture left off (notably linear and angular velocity)
        
        UIDynamicItemBehavior *dynamic = [[UIDynamicItemBehavior alloc] initWithItems:@[gesture.view]];
        [dynamic addLinearVelocity:velocity forItem:gesture.view];
        [dynamic addAngularVelocity:angularVelocity forItem:gesture.view];
        [dynamic setAngularResistance:2];
        
        // when the view no longer intersects with its superview, go ahead and remove it
        
        dynamic.action = ^{
            if (!CGRectIntersectsRect(gesture.view.superview.bounds, gesture.view.frame)) {
                [self.animator removeAllBehaviors];
                [gesture.view removeFromSuperview];
                [self cleanup];
                
                [[[UIAlertView alloc] initWithTitle:nil message:@"View is gone!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        };
        [self.animator addBehavior:dynamic];
        
        // add a little gravity so it accelerates off the screen (in case user gesture was slow)
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[gesture.view]];
        gravity.magnitude = 0.7;
        [self.animator addBehavior:gravity];
    }
}

- (CGFloat)angleOfView:(UIView *)view
{
    // http://stackoverflow.com/a/2051861/1271826
    
    return atan2(view.transform.b, view.transform.a);
}


static const CGFloat __overlayAlpha = 0.7f;						// opacity of the black overlay displayed below the focused image
static const CGFloat __animationDuration = 0.18f;				// the base duration for present/dismiss animations (except physics-related ones)
static const CGFloat __maximumDismissDelay = 0.5f;				// maximum time of delay (in seconds) between when image view is push out and dismissal animations begin
static const CGFloat __angularVelocityFactor = 0.6f;			// adjusts the amount of spin applied to the view during a push force, increases towards the view bounds
static const CGFloat __minimumVelocityRequiredForPush = 70.0f;




- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    _weakReferenceView = gestureRecognizer.view;
	UIView *view = gestureRecognizer.view;
	CGPoint location = [gestureRecognizer locationInView:self.view];
	CGPoint boxLocation = [gestureRecognizer locationInView:_weakReferenceView];
    static CGPoint               startCenter;

	
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        startCenter = gestureRecognizer.view.center;
		[self.animator removeBehavior:self.snapBehavior];
		[self.animator removeBehavior:self.pushBehavior];
		
		UIOffset centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(_weakReferenceView.bounds), boxLocation.y - CGRectGetMidY(_weakReferenceView.bounds));
		self.panAttachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:_weakReferenceView offsetFromCenter:centerOffset attachedToAnchor:location];
		//self.panAttachmentBehavior.frequency = 0.0f;
		[self.animator addBehavior:self.panAttachmentBehavior];
		[self.animator addBehavior:self.itemBehavior];
	}
	else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
		self.panAttachmentBehavior.anchorPoint = location;
	}
	else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		[self.animator removeBehavior:self.panAttachmentBehavior];
		
		// need to scale velocity values to tame down physics on the iPad
		CGFloat deviceVelocityScale = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 0.2f : 1.0f;
		CGFloat deviceAngularScale = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 0.7f : 1.0f;
		// factor to increase delay before `dismissAfterPush` is called on iPad to account for more area to cover to disappear
		CGFloat deviceDismissDelay = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 1.8f : 1.0f;
		CGPoint velocity = [gestureRecognizer velocityInView:self.presentedViewController.view];
		CGFloat velocityAdjust = 10.0f * deviceVelocityScale;
		
		if (fabs(velocity.x / velocityAdjust) > __minimumVelocityRequiredForPush || fabs(velocity.y / velocityAdjust) > __minimumVelocityRequiredForPush) {
			UIOffset offsetFromCenter = UIOffsetMake(boxLocation.x - CGRectGetMidX(_weakReferenceView.bounds), boxLocation.y - CGRectGetMidY(_weakReferenceView.bounds));
			CGFloat radius = sqrtf(powf(offsetFromCenter.horizontal, 2.0f) + powf(offsetFromCenter.vertical, 2.0f));
			CGFloat pushVelocity = sqrtf(powf(velocity.x, 2.0f) + powf(velocity.y, 2.0f));
			
			// calculate angles needed for angular velocity formula
			CGFloat velocityAngle = atan2f(velocity.y, velocity.x);
			CGFloat locationAngle = atan2f(offsetFromCenter.vertical, offsetFromCenter.horizontal);
			if (locationAngle > 0) {
				locationAngle -= M_PI * 2;
			}
			
			// angle (θ) is the angle between the push vector (V) and vector component parallel to radius, so it should always be positive
			CGFloat angle = fabsf(fabsf(velocityAngle) - fabsf(locationAngle));
			// angular velocity formula: w = (abs(V) * sin(θ)) / abs(r)
			CGFloat angularVelocity = fabsf((fabsf(pushVelocity) * sinf(angle)) / fabsf(radius));
			
			// rotation direction is dependent upon which corner was pushed relative to the center of the view
			// when velocity.y is positive, pushes to the right of center rotate clockwise, left is counterclockwise
			CGFloat direction = (location.x < view.center.x) ? -1.0f : 1.0f;
			// when y component of velocity is negative, reverse direction
			if (velocity.y < 0) { direction *= -1; }
			
			// amount of angular velocity should be relative to how close to the edge of the view the force originated
			// angular velocity is reduced the closer to the center the force is applied
			// for angular velocity: positive = clockwise, negative = counterclockwise
			CGFloat xRatioFromCenter = fabsf(offsetFromCenter.horizontal) / (CGRectGetWidth(_weakReferenceView.frame) / 2.0f);
			CGFloat yRatioFromCetner = fabsf(offsetFromCenter.vertical) / (CGRectGetHeight(_weakReferenceView.frame) / 2.0f);
            
			// apply device scale to angular velocity
			angularVelocity *= deviceAngularScale;
			// adjust angular velocity based on distance from center, force applied farther towards the edges gets more spin
			angularVelocity *= ((xRatioFromCenter + yRatioFromCetner) / 2.0f);
			
			[self.itemBehavior addAngularVelocity:angularVelocity * __angularVelocityFactor * direction forItem:_weakReferenceView];
			[self.animator addBehavior:self.pushBehavior];
			self.pushBehavior.pushDirection = CGVectorMake((velocity.x / velocityAdjust) * __velocityFactor, (velocity.y / velocityAdjust) * __velocityFactor);
			self.pushBehavior.active = YES;
            
            
			
			// delay for dismissing is based on push velocity also
			CGFloat delay = __maximumDismissDelay - (pushVelocity / 10000.0f);
			[self performSelector:@selector(dismissAfterPush) withObject:nil afterDelay:(delay * deviceDismissDelay) * __velocityFactor];
		}
		else {
            
            
            // if we aren't dragging it down, just snap it back and quit
            
           // if (fabs(atan2(velocity.y, velocity.x) - M_PI_2) > M_PI_4) {
            [self.animator addBehavior:self.snapBehavior];
                
           //     return;
//}
			//[self returnToCenter];
		}
	}
}

- (void)returnToCenter {
	if (self.animator) {
		[self.animator removeAllBehaviors];
	}
	[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		_weakReferenceView.transform = CGAffineTransformIdentity;
		_weakReferenceView.frame = _originalFrame;
        
	} completion:nil];
}
- (void)dismissAfterPush {

	[UIView animateWithDuration:__animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		//self.backgroundView.alpha = 0.0f;
	} completion:^(BOOL finished) {
		[self cleanup];
	}];
}
-(void)cleanup
{
    [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    _weakReferenceView = nil;
    
}




- (void)mr_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    viewControllerToPresent.modalPresentationStyle = UIModalPresentationCustom;
    viewControllerToPresent.transitioningDelegate = self;
    [self presentViewController:viewControllerToPresent animated:flag completion:^{

        
        //[self setupDynamicBehaviorsForView:viewControllerToPresent.view];
        
        completion();
        
    }];

}





#pragma mark DelegateTransition
- (id <UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *)presented  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
	ShowTransition *transition = [[ShowTransition alloc] init];

	return transition;
    
}
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    DismissTransition *transition = [[DismissTransition alloc] init];
	return transition;
}

@end
