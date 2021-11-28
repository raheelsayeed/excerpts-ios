//
//  ContainerViewController.m
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import "ContainerController.h"
#import "PanGestureRecognizer.h"

static const CGFloat ParallaxScalar = 0.25f;
static const CGFloat TransitionDuration = 0.4f;
static const CGFloat PanCompletionThreshold = 0.5f;
static const CGFloat VelocityThreshold = 500.0f;
static const CGFloat minTransitionDuration = 0.1;
static const CGFloat kSwipeMaxFadeOpacity = 0.5f;




@interface ContainerController () <UIGestureRecognizerDelegate>

//@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, weak, readwrite) UIViewController *currentViewController;
@property (weak, nonatomic) UIViewController * weakStatusbarUpdater;
@property (weak, nonatomic) UIViewController * weakToBePresentedViewController;
@property (nonatomic)     UIView *fadeView;

@end

@implementation ContainerController

- (void)dealloc
{
    _datasource = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _parallaxEnabled = YES;
        _wrappingEnabled = NO;
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pan = [[PanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    _pan.maximumNumberOfTouches = 1;
    _pan.minimumNumberOfTouches = 1;
    _pan.delegate = self;
    [self.view addGestureRecognizer:_pan];
    
    //self.view.layer.contents = (id)[UIImage imageNamed:@"wallpaper"].CGImage;
//    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    self.fadeView = [[UIView alloc] initWithFrame:self.view.bounds];
    _fadeView.backgroundColor = [UIColor blackColor];
    _fadeView.alpha = 0.f;
    _fadeView.hidden = YES;
    

}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return _weakStatusbarUpdater;
}
- (UIViewController *)childViewControllerForStatusBarStyle
{
    return _weakStatusbarUpdater;
}

 
#pragma mark - Setup


- (void)setViewControllers:(NSMutableArray *)viewControllers
{
    NSAssert(YES, @"method not defined");
    /*
    
    NSAssert(viewControllers != nil, @"viewControllers argument must be non nil");

  //  _viewControllers = [viewControllers mutableCopy];
    
    
    UIViewController *viewController = viewControllers[0];
    viewController.view.frame = self.view.bounds;
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    self.currentViewController = viewController;
    _weakStatusbarUpdater = _currentViewController;
     */

}

- (void)setInitialViewController:(UIViewController *)viewController
{
    NSAssert(viewController != nil, @"viewController argument must be non nil");
    
    
    viewController.view.frame = self.view.bounds;
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    self.currentViewController = viewController;
    
    [self.view addSubview:_fadeView];

    _weakStatusbarUpdater = _currentViewController;
}

#pragma mark - Tap Navigation



- (void)transitionToPrevious
{
    UIViewController * previous = [self previousViewController];
    if (!previous) return;

        previous.view.frame = [self frameForDirection:PanDirectionBack obeyParallax:NO];
        [self addChildViewController:previous];
        _weakStatusbarUpdater = previous;
        [self.currentViewController willMoveToParentViewController:nil];
        _fadeView.frame = _currentViewController.view.frame;

        [self transitionFromViewController:self.currentViewController toViewController:previous duration:TransitionDuration options:0 animations:^{
            
            [self setNeedsStatusBarAppearanceUpdate];
            CGRect oldFrame = [self frameForDirection:PanDirectionForward obeyParallax:YES];
            self.currentViewController.view.frame = oldFrame;
            previous.view.frame = self.view.bounds;
            
        } completion:^(BOOL finished) {
            
            [previous didMoveToParentViewController:self];
                [self.currentViewController removeFromParentViewController];
                self.currentViewController = previous;
            
            [self animationTransitionEnded];
        }];
}

- (void)transitionToNext
{

    UIViewController *next = [self nextViewController];
    if (!next) return;
    
        _fadeView.hidden = NO;
        next.view.frame = [self frameForDirection:PanDirectionForward obeyParallax:NO];
        [self addChildViewController:next];
        [self.currentViewController willMoveToParentViewController:nil];
        _weakStatusbarUpdater  = next;
        _fadeView.frame = _currentViewController.view.frame;

        CGRect oldFrame = [self frameForDirection:PanDirectionBack obeyParallax:YES];
    

    /*
    
    
    CGFloat duration = (_weakStatusbarUpdater.view.tag == 0) ? 0.2 : 0.4;
    [UIView animateWithDuration:duration animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
    */

        [self transitionFromViewController:self.currentViewController toViewController:next duration:TransitionDuration options:0 animations:^
         {
             [self setNeedsStatusBarAppearanceUpdate];

            self.currentViewController.view.frame = oldFrame;
            next.view.frame = self.view.bounds;
            _fadeView.alpha = kSwipeMaxFadeOpacity;
            
        } completion:^(BOOL finished) {
            
            
            [next didMoveToParentViewController:self];
            [self.currentViewController removeFromParentViewController];
            self.currentViewController = next;
            
            _fadeView.alpha = 0.f;
            _fadeView.hidden = YES;
            
            [self animationTransitionEnded];
    
        
        }];
}

#pragma mark - Pan Navigation
- (BOOL)gestureRecognizerShouldBegin:(PanGestureRecognizer *)gestureRecognizer
{
    if([_currentViewController respondsToSelector:@selector(gestureRecognizerShouldBegin:)])
    {
        BOOL begin = (BOOL )[_currentViewController performSelector:@selector(gestureRecognizerShouldBegin:) withObject:gestureRecognizer];
        
         return begin;
    }
    return  YES;
}

- (UIViewController *)viewControllerBasedOnRecognizer:(PanGestureRecognizer *)gestureRecognizer
{
    if(_weakToBePresentedViewController) return _weakToBePresentedViewController;
    
    if(gestureRecognizer.panDirection == PanDirectionNone)
    {
        return nil;
    }
    
    if (gestureRecognizer.panDirection == PanDirectionBack)
    {
        _weakToBePresentedViewController  = [self previousViewController];
    }
    else if (gestureRecognizer.panDirection == PanDirectionForward)
    {
        _weakToBePresentedViewController = [self nextViewController];
    }
    
    if(nil == _weakToBePresentedViewController)
    {
;
        gestureRecognizer.enabled = NO;
        gestureRecognizer.enabled = YES;
//        NSLog(@"containerViewController: Panned CANCELLED");
        return nil;
    }
    
    return _weakToBePresentedViewController;
    
}

- (void)pan:(PanGestureRecognizer *)recognizer
{
    
    CGFloat containerWidth = self.view.frame.size.width;
    //NSLog(@"containerViewController: Panned %@", [recognizer description]);
    
    if([self viewControllerBasedOnRecognizer:recognizer] == nil)
    {
        return;
    }
    
    if(recognizer.state == UIGestureRecognizerStateFailed)
    {
    }
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
       
        _weakToBePresentedViewController.view.frame = [self frameForDirection:recognizer.panDirection obeyParallax:NO];
        [self addChildViewController:_weakToBePresentedViewController];
        _fadeView.hidden = NO;
        _fadeView.frame = _currentViewController.view.frame;

        if(recognizer.panDirection == PanDirectionForward)
        {

            [_currentViewController.view addSubview:_fadeView];
            [self.view addSubview:_weakToBePresentedViewController.view];
        }
        else
        {
            _fadeView.alpha = kSwipeMaxFadeOpacity;
            [_weakToBePresentedViewController.view addSubview:_fadeView];
            [self.view insertSubview:_weakToBePresentedViewController.view belowSubview:_currentViewController.view];

        }

        
        
        
        return;

    }
    
    
    
    
    if (recognizer.panDidChangeDirection)
    {
        if ((recognizer.panDirection == PanDirectionBack && self.currentViewController.view.frame.origin.x <= 0.0f) || (recognizer.panDirection == PanDirectionForward && self.currentViewController.view.frame.origin.x >= 0.0f))
        {
            [self updateStatusBarAppearanceObeyingViewController:_currentViewController];
            self.currentViewController.view.frame = (CGRect){0.0f, 0.0f, self.currentViewController.view.bounds.size};
            if (recognizer.state == UIGestureRecognizerStateEnded)
            {
                [_weakToBePresentedViewController.view removeFromSuperview];
                [_weakToBePresentedViewController removeFromParentViewController];
            }
            return;
        }
    }

    CGPoint translation = [recognizer translationInView:self.view];
    CGFloat adjustedTranslation = (self.parallaxEnabled) ? translation.x * ParallaxScalar : translation.x;
    CGFloat originX = (recognizer.panDirection == PanDirectionForward) ? self.view.bounds.size.width : 0 - self.view.bounds.size.width;

    if(recognizer.panDirection == PanDirectionForward)
    {
        CGFloat alpha = kSwipeMaxFadeOpacity * (translation.x / (CGFloat)containerWidth);

        if (alpha > kSwipeMaxFadeOpacity) alpha = kSwipeMaxFadeOpacity;

        _fadeView.alpha = -1 * alpha;

        
        self.currentViewController.view.frame = (CGRect){adjustedTranslation, 0, self.currentViewController.view.bounds.size};
        _weakToBePresentedViewController.view.frame = (CGRect){originX + translation.x, 0, _weakToBePresentedViewController.view.bounds.size};
        
        

    }else
    {
        
        

        
        CGFloat alpha =  ((containerWidth-translation.x)/containerWidth) * kSwipeMaxFadeOpacity;
        
        
        _fadeView.alpha = alpha;

        
        
        self.currentViewController.view.frame = (CGRect){translation.x, 0, self.currentViewController.view.bounds.size};
        originX = (self.parallaxEnabled) ? originX * ParallaxScalar : originX;

        _weakToBePresentedViewController.view.frame = (CGRect){(originX + adjustedTranslation), 0, _weakToBePresentedViewController.view.bounds.size};

    }
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
     
        
        CGPoint velocity = [recognizer velocityInView:self.view];
//        NSLog(@"ISForward=%@; newIsForward=%@",   (recognizer.panDirection == PanDirectionForward) ? @"YES": @"NO",rectionForward) ? @"YES": @"NO");
        BOOL backToOld = (recognizer.panDirection != recognizer.newDirection);

        
        //Passed Mark: Should Finish It.
        if((ABS(translation.x) > self.view.bounds.size.width * PanCompletionThreshold || ABS(velocity.x) > VelocityThreshold))
        {
            
            
            //Back To the Old Direction:

            
            if(!backToOld)
                
            [self finishPanInDirection:recognizer.newDirection withVelocity:velocity toViewController:_weakToBePresentedViewController];
            else [self cancelPanInDirection:recognizer.panDirection toViewController:_weakToBePresentedViewController];
        }
        else
        {
            //No have way Mark: Go back

            [self cancelPanInDirection:recognizer.panDirection toViewController:_weakToBePresentedViewController];
        }
        

        
        
    }
}



- (void)finishPanInDirection:(PanDirection)direction withVelocity:(CGPoint)velocity toViewController:(UIViewController *)new
{
  
//    NSLog(@"Finished to %@", (direction == PanDirectionForward) ? @"YES": @"NO");

    
    
    [_currentViewController willMoveToParentViewController:nil];
    
    PanDirection oppositeDirection = direction == PanDirectionBack ? PanDirectionForward : PanDirectionBack;
    CGRect oldFrame = [self frameForDirection:oppositeDirection obeyParallax:YES];
    __block CGFloat destinationOpacity = (direction == PanDirectionForward) ? kSwipeMaxFadeOpacity : 0.f;

    float duration = TransitionDuration;
    if (ABS(velocity.x) > VelocityThreshold)
    {
        
        CGFloat xFactor = 0.f;
        
        if(direction == PanDirectionForward)
        {
            
            xFactor = ABS(_currentViewController.view.frame.origin.x);
        }
        else
        {
                xFactor = ABS(new.view.frame.origin.x);
        }
        float temp  = TransitionDuration * (xFactor / new.view.frame.size.width);
        duration = MAX(temp, minTransitionDuration);

    }
    

    
    _weakStatusbarUpdater = new;
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [self setNeedsStatusBarAppearanceUpdate];
        _currentViewController.view.frame = oldFrame;
        new.view.frame = self.view.bounds;
        _fadeView.alpha = destinationOpacity;
        
    } completion:^(BOOL finished) {
        
            [_currentViewController.view removeFromSuperview];
            [_currentViewController removeFromParentViewController];
            [new didMoveToParentViewController:self];
            self.currentViewController = new;
            _fadeView.alpha = 0.f;
            _fadeView.hidden = YES;
            [self animationTransitionEnded];

    
    }];
}

- (void)cancelPanInDirection:(PanDirection)direction toViewController:(UIViewController *)new
{
    
//    NSLog(@"Cancel to %@", (direction == PanDirectionForward) ? @"YES": @"NO");
    
    __block CGFloat destinationOpacity = (direction == PanDirectionForward) ? 0.f : kSwipeMaxFadeOpacity;

    
    _weakStatusbarUpdater = _currentViewController;
    

    
    [UIView animateWithDuration:TransitionDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [self setNeedsStatusBarAppearanceUpdate];
        new.view.frame =  [self frameForDirection:direction obeyParallax:YES];
        _currentViewController.view.frame = self.view.bounds;
        _fadeView.alpha = destinationOpacity;
        
    }
                     completion:^(BOOL finished)
    {
        
        _weakToBePresentedViewController = nil;
            [new.view removeFromSuperview];
            [new removeFromParentViewController];
            _fadeView.alpha = 0.f;
            _fadeView.hidden = YES;
    }];
}

- (void)updateStatusBarAppearanceObeyingViewController:(UIViewController *)viewController
{
    _weakStatusbarUpdater = viewController;
    
    
    CGFloat duration = (_weakStatusbarUpdater.view.tag == 0) ? 0.2 : 0.4;
    [UIView animateWithDuration:duration animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)animationTransitionEnded
{
    _weakToBePresentedViewController = nil;
    
    
//    DLog(@"Number of children: %@", @(self.childViewControllers.count) );
}

#pragma mark - Page Accessors
- (UIViewController *)previousViewController
{
    UIViewController * previous = [self.datasource containerViewController:self viewControllerBeforeViewController:self.currentViewController];
    
    return previous;

}
- (UIViewController *)nextViewController
{
   UIViewController * next = [self.datasource containerViewController:self viewControllerAfterViewController:self.currentViewController];
    
    return next;
    
}

#pragma mark - Frames

- (CGRect)frameForDirection:(PanDirection)direction obeyParallax:(BOOL)obeyParallax
{
    CGRect rect = CGRectZero;
    
    if (direction == PanDirectionBack)
    {
        rect = [self previousFrame:obeyParallax];
    }
    else
    {
 
        rect = [self nextFrame:obeyParallax];
    }
    
    return rect;
}

- (CGRect)nextFrame:(BOOL)obeyParallax
{
    CGRect rect = CGRectZero;
    
    if (self.parallaxEnabled && obeyParallax)
    {
        //:::
        rect = (CGRect){self.view.bounds.size.width , 0, self.view.bounds.size};
//        rect = (CGRect){self.view.bounds.size.width * ParallaxScalar, 0, self.view.bounds.size};
    }
    else
    {
        rect = (CGRect){self.view.bounds.size.width, 0, self.view.bounds.size};
    }
    
    return rect;
}

- (CGRect)previousFrame:(BOOL)obeyParallax
{
    CGRect rect = CGRectZero;
    
    if (self.parallaxEnabled && obeyParallax)
    {

        rect = (CGRect){0 - (self.view.bounds.size.width * ParallaxScalar), 0, self.view.bounds.size};
    }
    else
    {
        rect = (CGRect){0 - self.view.bounds.size.width, 0, self.view.bounds.size};;
    }
    
    return rect;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
//    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    if([self.datasource respondsToSelector:@selector(containerViewController:viewControllerWillTransitionToNewTraits:coordinator:)])
    {
        [self.datasource containerViewController:self viewControllerWillTransitionToNewTraits:newCollection coordinator:coordinator];
    }
}


@end
