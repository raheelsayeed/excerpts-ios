//
//  MROverlayManager.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 28/02/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "MROverlayManager.h"
#import "UIView+MotionEffect.h"

static const CGFloat __density = 1.0f;				//1.0			// relative mass density applied to the image's dynamic item behavior
static const CGFloat __velocityFactor = 0.5f; //1.0
static const CGFloat __resistance = 0.0f;						// linear resistance applied to the image’s dynamic item behavior
static const CGFloat __overlayAlpha = 0.7f;						// opacity of the black overlay displayed below the focused image
static const CGFloat __animationDuration = 0.18f;				// the base duration for present/dismiss animations (except physics-related ones)
static const CGFloat __maximumDismissDelay = 0.5f;				// maximum time of delay (in seconds) between when image view is push out and dismissal animations begin
static const CGFloat __angularVelocityFactor = 1.0f;			// adjusts the amount of spin applied to the view during a push force, increases towards the view bounds
static const CGFloat __minimumVelocityRequiredForPush = 70.0f;
static const CGFloat __maximumTransparencyBackground = 0.5;

@interface MROverlayManager ()
{
    CGPoint lastCenter;
    NSInteger motionEffectFactor;
}

@property (nonatomic, strong) UIView *fromView;
@property (nonatomic, assign) CGRect fromRect;


@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UISnapBehavior *snapBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *panAttachmentBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

@property (nonatomic, weak) UIView * referenceView;
@property (nonatomic, weak) UIView * presentedView;
@property (nonatomic, weak) UIView * willPresentInView;

@property (nonatomic, assign) CGPoint originPoint;


@end

@implementation MROverlayManager
@synthesize referenceView, presentedView, originPoint, willPresentInView, alignOnScreen, delegate, useParallex;



- (id) initWithFrame:(CGRect)aFrame
{
	if ((self = [super initWithFrame:aFrame])) {
		self.opaque = NO;
		self.backgroundColor = [UIColor blackColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
        motionEffectFactor = 20;
        
		alignOnScreen = YES;
        useParallex   = YES;
		[self addTarget:self action:@selector(hideFromOverlay:) forControlEvents:UIControlEventTouchUpInside];
		
		// subscribe to rotation notifications
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceDidRotate:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
	}
	return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.presentedView = nil;
}

-(CGPoint)centerForView:(UIView *)view
{
    return CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
}

static MROverlayManager *overlayManager = nil;
+ (MROverlayManager *) sharedManager
{
	@synchronized(self) {
		if (!overlayManager) {
			overlayManager = [[MROverlayManager alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 100.f)];
		}
		return overlayManager;
	}
}


- (void)setupDynamicsForOverlay:(UIView *)overlayView originCenter:(CGPoint)origin inView:(UIView *)refView
{
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panRecognizer.delegate = self;
    [overlayView addGestureRecognizer:self.panRecognizer];
    
    /* UIDynamics stuff */

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:refView];
    self.animator.delegate = self;
    
    // snap behavior to keep image view in the center as needed
    self.snapBehavior = [[UISnapBehavior alloc] initWithItem:overlayView snapToPoint:origin];
    self.snapBehavior.damping = 0.7f;
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[overlayView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.angle = 0.2f;
    self.pushBehavior.magnitude = 0.2f;
    
    self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[overlayView]];
    self.itemBehavior.elasticity = 0.3f;
    self.itemBehavior.friction = 0.2f;
    self.itemBehavior.allowsRotation = YES;
    self.itemBehavior.density = __density;
    self.itemBehavior.resistance = __resistance;
}

- (void) overlay:(UIView *)aView withCenter:(CGPoint)atOrigin inView:(UIView *)refView
{
    if(self.presentedView)
    {
        [self.presentedView removeFromSuperview];
        self.presentedView = nil;
        [self removeFromSuperview];
    }
    
    self.referenceView = refView;
    self.presentedView = aView;
    self.originPoint = atOrigin;
    
    BOOL responder = [presentedView canBecomeFirstResponder];
    if(responder) [referenceView resignFirstResponder];
    
    referenceView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    presentedView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    
    if (![self superview])
    {
		self.willPresentInView = [self overlayViewFor:refView];
		[willPresentInView addSubview:self];
	}
    
    [self adjustFrame];
	[self positionViewAnimated:YES];

    if(useParallex)
    {
        [self.presentedView addMotionEffectsForX_Max:@(motionEffectFactor) X_Min:@(-motionEffectFactor) Y_Max:@(motionEffectFactor) Y_Min:@(-motionEffectFactor)];
    }
    
    [presentedView becomeFirstResponder];

}

- (UIView *) overlayViewFor:(UIView *)refView
{
    
    return refView;
    
	UIView *child = refView;
	UIView *parent = nil;
	UIView *attachToView = nil;
	
	while ((parent = [child superview])) {
		NSString *parentClass = NSStringFromClass([parent class]);
		if ([parentClass isEqualToString:@"UILayoutContainerView"]) {		// iPad popover
			attachToView = parent;
			break;
		}
		else if ([UIWindow class] == [parent class]) {						// first UIWindow subview
			attachToView = child;
			break;
		}
		child = parent;
	}
	
	if (!attachToView) {
		attachToView = child;
	}
	
	return attachToView;
}

- (void) adjustFrame
{
	// subtract status bar rect from our possible rect
	CGRect attachFrame = [self superview].bounds;
	CGRect statusFrame = [[self superview] convertRect:[UIApplication sharedApplication].statusBarFrame fromView:self.window];
	statusFrame = CGRectZero;
    if (CGRectIntersectsRect(statusFrame, attachFrame)) {
		if (statusFrame.origin.y < 1.f) {
			attachFrame.origin.y = statusFrame.size.height;
		}
		attachFrame.size.height -= statusFrame.size.height;
	}
	
	// adjust ourselves
	self.frame = attachFrame;
	[[self superview] bringSubviewToFront:self];
}
- (void) positionViewAnimated:(BOOL)animated
{
	if (!presentedView || !referenceView) {
		return;
	}
	
	// check whether we're in bounds
	CGPoint atOrigin = [self convertPoint:originPoint fromView:self.referenceView];
	lastCenter = atOrigin;
	
	if (alignOnScreen) {
		CGSize fitSize = [presentedView bounds].size;
		CGSize attachSize = [[self superview] bounds].size;
		
		if ((atOrigin.x - (fitSize.width / 2)) < 0.f) {
			atOrigin.x = roundf(fitSize.width / 2);
		}
		else if ((atOrigin.x + (fitSize.width / 2)) > attachSize.width) {
			atOrigin.x = attachSize.width - roundf(fitSize.width / 2);
		}
		
		if ((atOrigin.y - (fitSize.height / 2)) < 0.f) {
			atOrigin.y = roundf(fitSize.height / 2);
		}
		else if ((atOrigin.y + (fitSize.height / 2)) > attachSize.height) {
			atOrigin.y = attachSize.height - roundf(fitSize.height / 2);
		}
	}
	
    

    
    
	// not yet there - position correctly
	if (![presentedView superview])
    {
        presentedView.transform = CGAffineTransformMakeScale(0.8,0.8);
        presentedView.alpha = 0;
        self.backgroundColor = [UIColor clearColor];
		presentedView.center = atOrigin;
		[self addSubview:presentedView];
	}
    
//    NSLog(@"%@", NSStringFromCGPoint(atOrigin));
    
    
    if(animated)
    {
        //[self attachPopUpAnimation];
        
        [UIView animateWithDuration:0.3
                              delay:0.0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:__maximumTransparencyBackground];
                             presentedView.alpha = 1.0;
                             presentedView.transform = CGAffineTransformIdentity;

                         } completion:nil];


        
        
    }else
    {
	

	
	presentedView.center = atOrigin;
	presentedView.alpha = 1.f;
	presentedView.transform = CGAffineTransformIdentity;
    }
    
    
    [self setupDynamicsForOverlay:presentedView originCenter:atOrigin inView:referenceView];

}

- (void) attachPopUpAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    animation.duration = .2;
    
    [self.presentedView.layer addAnimation:animation forKey:@"popup"];
}






- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {

	UIView *view = gestureRecognizer.view;
	CGPoint location = [gestureRecognizer locationInView:self];
	CGPoint boxLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    static CGPoint               startCenter;
    /*
     
     _weakReferenceView = gestureRecognizer.view;
     UIView *view = gestureRecognizer.view;
     CGPoint location = [gestureRecognizer locationInView:self.view];
     CGPoint boxLocation = [gestureRecognizer locationInView:_weakReferenceView];
     static CGPoint               startCenter;
     */
     
	
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        startCenter = gestureRecognizer.view.center;
		[self.animator removeBehavior:self.snapBehavior];
		[self.animator removeBehavior:self.pushBehavior];
		
		UIOffset centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(gestureRecognizer.view.bounds), boxLocation.y - CGRectGetMidY(gestureRecognizer.view.bounds));
		self.panAttachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:gestureRecognizer.view offsetFromCenter:centerOffset attachedToAnchor:location];
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
		CGPoint velocity = [gestureRecognizer velocityInView:self.referenceView];
		CGFloat velocityAdjust = 10.0f * deviceVelocityScale;
		
		if (fabs(velocity.x / velocityAdjust) > __minimumVelocityRequiredForPush || fabs(velocity.y / velocityAdjust) > __minimumVelocityRequiredForPush) {
			UIOffset offsetFromCenter = UIOffsetMake(boxLocation.x - CGRectGetMidX(gestureRecognizer.view.bounds), boxLocation.y - CGRectGetMidY(gestureRecognizer.view.bounds));
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
			CGFloat xRatioFromCenter = fabsf(offsetFromCenter.horizontal) / (CGRectGetWidth(gestureRecognizer.view.frame) / 2.0f);
			CGFloat yRatioFromCetner = fabsf(offsetFromCenter.vertical) / (CGRectGetHeight(gestureRecognizer.view.frame) / 2.0f);
            
			// apply device scale to angular velocity
			angularVelocity *= deviceAngularScale;
			// adjust angular velocity based on distance from center, force applied farther towards the edges gets more spin
			angularVelocity *= ((xRatioFromCenter + yRatioFromCetner) / 2.0f);
			
			[self.itemBehavior addAngularVelocity:angularVelocity * __angularVelocityFactor * direction forItem:gestureRecognizer.view];
			[self.animator addBehavior:self.pushBehavior];
			self.pushBehavior.pushDirection = CGVectorMake((velocity.x / velocityAdjust) * __velocityFactor, (velocity.y / velocityAdjust) * __velocityFactor);
			self.pushBehavior.active = YES;
            
            
			
			// delay for dismissing is based on push velocity also
            CGFloat delay = __maximumDismissDelay - (pushVelocity / 10000.0f);
			
            //delay * device * _velocityFactor
            [self performSelector:@selector(hideFromOverlay:) withObject:nil afterDelay:(delay * deviceDismissDelay) * __velocityFactor];
		}
		else {
            
        
            [self.animator addBehavior:self.snapBehavior];
            

        }
	}
}







#pragma mark Overlay

#pragma mark Remove from Overlay
- (void) hideFromOverlayAnimated:(BOOL)animated
{

    [presentedView resignFirstResponder];
    
    referenceView.tintAdjustmentMode = presentedView.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;

    if (delegate && [delegate respondsToSelector:@selector(willDismissOverlay:)])
    {
        [delegate willDismissOverlay:self];
    }
    
    CGAffineTransform xForm = self.presentedView.transform;
    
    if(animated)
    {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.backgroundColor = [UIColor clearColor];
                             self.presentedView.transform =
                             CGAffineTransformScale(xForm, 0.8f, 0.8f);
                             self.presentedView.alpha = 0.f;
                         }
                         completion:^(BOOL finished) {

                             [self.presentedView removeFromSuperview];
                             [referenceView becomeFirstResponder];
                             self.referenceView = nil;
                             self.presentedView = nil;
                             self.willPresentInView = nil;
                             [self removeFromSuperview];
                         }];
    }else
    {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.backgroundColor = [UIColor clearColor];
                             self.presentedView.alpha = 0.f;
                         }
                         completion:^(BOOL finished){
                             
                                 [self.presentedView removeFromSuperview];
                                 [referenceView becomeFirstResponder];
                                 referenceView = nil;
                                 self.presentedView = nil;
                                 [self removeFromSuperview];
                         }];
    }

    
}



- (void) hideFromOverlay:(id)sender
{
	[self hideFromOverlayAnimated:(nil != sender)];
}



#pragma mark Rotation Handling
- (void) deviceDidRotate:(NSNotification *)aNotification
{
	if (![delegate respondsToSelector:@selector(overlayShouldReposition:)]
		|| [delegate overlayShouldReposition:self]) {
		if ([delegate respondsToSelector:@selector(overlayWillMoveToNewPosition:)]) {
			[delegate overlayWillMoveToNewPosition:self];
		}
		
		[self positionViewAnimated:NO];
		
		if ([delegate respondsToSelector:@selector(overlayDidMoveToNewPosition:)]) {
			[delegate overlayDidMoveToNewPosition:self];
		}
	}
}
#pragma mark -

@end
