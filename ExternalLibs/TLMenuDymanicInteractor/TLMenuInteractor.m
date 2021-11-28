//
//  TLMenuInteractor.m
//  UIViewController-Transitions-Example
//
//  Created by Ash Furrow on 2013-07-18.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLMenuInteractor.h"
#import "PanGestureRecognizer.h"

@interface TLMenuInteractor () <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning>{
    
    
}

@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation TLMenuInteractor

#pragma mark - Public Methods

-(id)initWithParentViewController:(UIViewController *)viewController {
    if (!(self = [super init])) return nil;
    
    _parentViewController = viewController;
    
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(PanGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer class] == [PanGestureRecognizer class]) {
        PanGestureRecognizer *panGestureRec = (PanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panGestureRec velocityInView:self.parentViewController.view];
        
        if(velocity.x > 0.0)
        {
            if(![[self modalController] isViewLoaded])
            {//TagV not ready
                return NO;
            }
            return YES;
        }
    }
    return NO;
}

- (UIViewController *)modalController
{
    AppDelegate * appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if( !appD.tagViewController)
    {
        appD.tagViewController = [[TagViewController alloc] initWithPanTarget:self];
        appD.tagViewController.modalPresentationStyle = UIModalPresentationCustom;
        appD.tagViewController.transitioningDelegate = self;
        appD.tagViewController.modalPresentationCapturesStatusBarAppearance = YES;
    }
    
    return appD.tagViewController;
}



-(void)userDidPan:(PanGestureRecognizer *)recognizer
{
    
    
    
    //CGPoint location = [recognizer locationInView:self.parentViewController.view];
    CGPoint velocity = [recognizer velocityInView:self.parentViewController.view];
    CGPoint translation = [recognizer translationInView:self.parentViewController.view];
    

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        UIViewController * modalController = [self modalController];
        if(modalController.isBeingDismissed || modalController.isBeingPresented)
        {
            return;
        }
        self.interactive = YES;

        
        if(recognizer.panDirection == PanDirectionBack)
        {
            self.presenting = YES;
            [self.parentViewController presentViewController:modalController animated:YES completion:nil];
        }
        else if(recognizer.panDirection == PanDirectionForward)
        {
            [modalController dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            return;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        
        // Determine our ratio between the left edge and the right edge. This means our dismissal will go from 1...0.
        CGFloat width = CGRectGetWidth(self.parentViewController.view.bounds);
        CGFloat ratio = translation.x / width;
        if(ratio > 1.0 || (!self.isPresenting &&  ratio > 0.01))
        {
//            NSLog(@"%f, %f", width, ratio);
            return;
        }
        [self updateInteractiveTransition:ratio];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        
        
        
        // Depending on our state and the velocity, determine whether to cancel or complete the transition.
       // NSLog(@"x=%f, y=%f, velx=%f", location.x, location.y, velocity.x);

        if (self.isPresenting)
        {
//            DLog(@"PRESENTING..");
            if (velocity.x > 0)
            {
                
                
                
                
                [self finishInteractiveTransition];
            }
            else
            {
                [self cancelInteractiveTransition];
            }
        }
        else
        {
//            NSLog(@"NOT PRESENTNG..");
            if (velocity.x < 0)
            {
                [self finishInteractiveTransition];
            }
            else
            {
                [self cancelInteractiveTransition];
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateFailed)
    {
//        DLog(@"tag show failed");
    }

}

-(void)presentMenu
{
    if([self modalController].isBeingDismissed || [self modalController].isBeingPresented) return;
    self.interactive    = NO;
    self.presenting     = YES;
    [self.parentViewController presentViewController:[self modalController] animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    // Return nil if we are not interactive
    if (self.interactive) {
        return self;
    }
    
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    // Return nil if we are not interactive
    if (self.interactive) {
        return self;
    }
    
    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (void)animationEnded:(BOOL)transitionCompleted {
    // Reset to our default state
    self.interactive = NO;
    self.presenting = NO;
    self.transitionContext = nil;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Used only in non-interactive transitions, despite the documentation
    return 0.2f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.interactive) {
        // nop as per documentation
        return;
    }
    else {
        // This code is lifted wholesale from the TLTransitionAnimator class
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        CGRect endFrame = [[transitionContext containerView] bounds];
        
        if (self.presenting) {
            // The order of these matters – determines the view hierarchy order.
            //[transitionContext.containerView addSubview:fromViewController.view];
            [transitionContext.containerView addSubview:toViewController.view];
            
            
            CGRect startFrame = endFrame;
            
                startFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);

            
            
//            NSLog(@"start=%@\nend=%@", NSStringFromCGRect(startFrame), NSStringFromCGRect(endFrame));
            
            toViewController.view.frame = startFrame;
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toViewController.view.frame = endFrame;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
        else {
            //[transitionContext.containerView addSubview:toViewController.view];
            //[transitionContext.containerView addSubview:fromViewController.view];
            
          
            
            
            endFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromViewController.view.frame = endFrame;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
    }
}

#pragma mark - UIViewControllerInteractiveTransitioning Methods

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    
  
    
    self.transitionContext = transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = [[transitionContext containerView] bounds];
    
    if (self.presenting)
    {
        // The order of these matters – determines the view hierarchy order.
        //[transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        endFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);
//        NSLog(@"w=%f, o=%@", CGRectGetHeight([[transitionContext containerView] bounds]), NSStringFromCGPoint(endFrame.origin));


    }
    else
    {
        //[transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
    }
    
    toViewController.view.frame = endFrame;
    
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods

- (void)updateInteractiveTransition:(CGFloat)percentComplete {

    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Presenting goes from 0...1 and dismissing goes from 1...0
    CGRect frame;
   
        CGFloat width = CGRectGetWidth([[transitionContext containerView] bounds]);
        CGFloat xoffset = percentComplete-1;
        
        if(!self.isPresenting)
        {
            width *= -1;
            xoffset = -percentComplete;

        }
        
        
        frame = CGRectOffset([[transitionContext containerView] bounds],width *  xoffset, 0);
        
    
    
        
    
    
    if (self.presenting)
    {
        
        toViewController.view.frame = frame;
    }
    else
    {
        fromViewController.view.frame = frame;
    }
}

- (void)finishInteractiveTransition {
    
    if(!_transitionContext) return;
    

    
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    
    if (self.presenting)
    {
        CGRect endFrame = [[transitionContext containerView] bounds];
        
        [UIView animateWithDuration:0.2f
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             toViewController.view.frame = endFrame;
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
   
        
    }
    else {
        CGRect endFrame;
        
        endFrame = CGRectOffset([[transitionContext containerView] bounds], -CGRectGetWidth([[self.transitionContext containerView] bounds]), 0);

        
        [UIView animateWithDuration:0.2f animations:^{
            fromViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            
            [transitionContext completeTransition:YES];
    
                
        }];
    }
    
}

- (void)cancelInteractiveTransition {
    
    if(!_transitionContext) return;

    

    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.isPresenting)
    {
//        the Presentation is CANCELLED. go back!
        
        CGRect endFrame;
        
            
            endFrame = CGRectOffset([[transitionContext containerView] bounds], -CGRectGetWidth([[self.transitionContext containerView] bounds]), 0);
        [UIView animateWithDuration:0.2f
                         animations:^{
            toViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:NO];
        }];
    }
    else
    {
        CGRect endF = [[transitionContext containerView] bounds];
        CGRect endFrame = endF;
        [UIView animateWithDuration:0.2f animations:^{
            fromViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:NO];
        }];
    }
}

@end
