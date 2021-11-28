//
//  RSParentSliderViewController.m
//  Slider
//
//  Created by M Raheel Sayeed on 02/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "RSParentSliderViewController.h"
#import "RNDirectionPanGestureRecognizer.h"
#import "UIView+Sizes.h"

@interface RSParentSliderViewController () <UIGestureRecognizerDelegate>
{
    RNDirection  _swipeDirection;
    CGPoint _centerLastPoint;
    BOOL _abortGuesture;
    
    CGRect newVC_OriginRect;
    

}
@property (nonatomic, strong) RNDirectionPanGestureRecognizer * panGesture;
@end

@implementation RSParentSliderViewController

- (instancetype)initWithBaseViewController:(UIViewController *)baseVC
{
    self = [super init];
    if(self)
    {
        _baseViewController = baseVC;
        _enableGestures = YES;
        
    }
    return self;
}
-(void)loadView
{
    [super loadView];
    _panGesture = [[RNDirectionPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    _panGesture.minimumNumberOfTouches = 1;
    _panGesture.maximumNumberOfTouches = 1;
    _panGesture.delegate = self;
    [self.view addGestureRecognizer:_panGesture];
    

}
-(void)viewDidLoad
{
    [super viewDidLoad];

    [self baseViewPlacement];
}
- (void)baseViewPlacement
{
    
    [self addChildViewController:_baseViewController];
    
    _baseViewController.view.frame = self.view.frame;
    
    
    [self.view addSubview:_baseViewController.view];
    
    
    //temp
    _baseViewController.view.backgroundColor = [UIColor redColor];
    
}
-(void)handlePanGesture:(RNDirectionPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _swipeDirection = recognizer.direction;
        
        [self _handleBegin:recognizer];
    }
    
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        if(_abortGuesture) return;

        [self _handleChanged:recognizer];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if(_abortGuesture) return;

        [self _handleEnded:recognizer];
        
        NSLog(@"TotalSubviews: %d", [[self.view subviews] count]);
    }
}
- (void)_handleBegin:(RNDirectionPanGestureRecognizer *)recognizer
{
    [self assignViewControllerFromSwipeDirection:recognizer.direction];
    
    
    
}
-(void)_handleChanged:(RNDirectionPanGestureRecognizer *)recognizer
{
    CGPoint translate = [recognizer translationInView:_baseViewController.view];
    
    switch (recognizer.direction) {
        case RNDirectionLeft:
        {
            CGFloat left = 0;
            left = [self _filterLeft:translate.x];
            _baseViewController.view.left = left;
            _toNewViewController.view.left = _baseViewController.view.right;
        }
            break;
            case RNDirectionRight:
        {
            CGFloat left = 0;
            left = [self _filterRight:translate.x];
            _baseViewController.view.left = left;
            _toNewViewController.view.right = _baseViewController.view.left;
        }
            break;
            
            
        default:
            break;
    }

    
}
- (CGFloat)_remainingDuration:(CGFloat)position threshold:(CGFloat)threshold {
    CGFloat maxDuration = kSwipeDefaultDuration;
    threshold /= 2.f;
    CGFloat suggestedDuration = maxDuration * (position / (CGFloat)threshold);
    if (suggestedDuration < 0.05f) {
        return 0.05f;
    }
    if (suggestedDuration < maxDuration) {
        return suggestedDuration;
    }
    return maxDuration;
}
- (CGFloat)_filterRight:(CGFloat)translation {

    CGFloat visibleWidthOfNewController = 320.f;
    //CGPoint centerLastPoint = CGPointZero;
    
    CGFloat translationTotal = translation;
    if (translationTotal > visibleWidthOfNewController) {
        CGFloat offset = translationTotal - visibleWidthOfNewController;
        translationTotal = visibleWidthOfNewController + offset / 15;
    }
    
    return translationTotal;
}
- (CGFloat)_filterLeft:(CGFloat)translation {

    CGFloat visibleWidthOfNewController = 320.f;
    
    CGFloat translationTotal = translation;
    if (translationTotal < -visibleWidthOfNewController) {
        CGFloat offset = translationTotal + visibleWidthOfNewController;
        translationTotal = visibleWidthOfNewController - offset / 15;
        translationTotal *= -1;
    }
    
    return translationTotal;
}
-(void)setBaseViewController:(UIViewController *)baseViewController
{
    if (_baseViewController != baseViewController) {
        _baseViewController = baseViewController;
    
        //[self addChildViewController:_baseViewController];
    }

}
-(void)_handleEnded:(RNDirectionPanGestureRecognizer *)recognizer
{
    CGFloat newViewWidth = _toNewViewController.view.width;
    
    if(_baseViewController.view.left > newViewWidth / 2.f){
        
        CGFloat duration = [self _remainingDuration:abs(_baseViewController.view.left) threshold:newViewWidth];
        [self _sendCenterToPoint:CGPointMake(newViewWidth, 0) panel:_toNewViewController.view toPoint:CGPointZero duration:duration];
    }
    else if(_baseViewController.view.left < (newViewWidth / -2.f))
    { //RIGHT WILL BE SHOWN
        CGFloat duration = [self _remainingDuration:abs(_baseViewController.view.left) threshold:newViewWidth];
        [self _sendCenterToPoint:CGPointMake(-1*newViewWidth, 0) panel:_toNewViewController.view toPoint:CGPointZero duration:duration];
    }
    else
    {
        CGFloat bottomVisibleHeight = 0.0;
        CGFloat position = _baseViewController.view.left == 0.f ? abs(_baseViewController.view.top) : abs(_baseViewController.view.left);
        CGFloat threshold = _baseViewController.view.left == 0.f ? bottomVisibleHeight : newViewWidth;
        CGFloat duration = [self _remainingDuration:position threshold:threshold];

        [self _layoutContainersAnimated:YES duration:duration];
    }
}

-(void)_layoutContainersAnimated:(BOOL)animate duration:(NSTimeInterval)duration {
    
    
    [_toNewViewController willMoveToParentViewController:nil];
    
    void (^block)(void) = [self _toResetContainers];
    
    if (animate) {
        [UIView animateWithDuration:duration
                              delay:0
                            options:kNilOptions
                         animations:block
                         completion:^(BOOL finished){
                             [_toNewViewController removeFromParentViewController];
                             [_toNewViewController.view removeFromSuperview];
                             _toNewViewController = nil;

                         }];
    }
    else
    {
        block();
    }
    
    
}
- (void (^)(void))_toResetContainers {
    return ^{
  
        _baseViewController.view.frame = self.view.frame;
        _toNewViewController.view.frame = newVC_OriginRect;
        _toNewViewController.view.layer.shadowOpacity = 0.f;
        
    };
    
    
}


- (BOOL)gestureRecognizerShouldBegin:(RNDirectionPanGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)assignViewControllerFromSwipeDirection:(RNDirection)direction
{
    _abortGuesture = NO;
    _toNewViewController = [self.datasource viewControllerFromBase:_baseViewController FromSwipedDirection:direction];

    NSLog(@"%@ %@", _toNewViewController, _baseViewController);
    
    if(!_toNewViewController)
    {
        _abortGuesture = YES;
        return NO;
    }
    
    CGRect frame = _baseViewController.view.frame;
    
    switch (direction) {
        case RNDirectionLeft:
            frame.origin.x = frame.size.width;
            break;
        case RNDirectionRight:
            frame.origin.x = -1 * frame.size.width;
            break;
        default:
            break;
    }
    
    newVC_OriginRect = frame;
    _toNewViewController.view.frame = frame;


    [self.view insertSubview:_toNewViewController.view atIndex:1];
    
    return YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
static CGFloat kSwipeMaxFadeOpacity = 0.5f;
static CGFloat kSwipeDefaultDuration = 0.2f;

- (void)_sendCenterToPoint:(CGPoint)centerPoint panel:(UIView*)container toPoint:(CGPoint)containerPoint duration:(NSTimeInterval)duration {
    
    [_baseViewController willMoveToParentViewController:nil];
    [self addChildViewController:_toNewViewController];
    
    [self transitionFromViewController:_baseViewController toViewController:_toNewViewController duration:kSwipeDefaultDuration
                               options:kNilOptions
     
                            animations:^{
                                
                                _baseViewController.view.origin = centerPoint;
                                _toNewViewController.view.origin = containerPoint;
                                
                                //_toNewViewController.view.left = _baseViewController.view.right;
                            
                                
                            }
							completion:^(BOOL finished) {
                               
                                [_toNewViewController
                                 didMoveToParentViewController:self];
                                
                                
								[_baseViewController removeFromParentViewController];
                                
                                [_baseViewController.view removeFromSuperview];
                                
                                [self setBaseViewController:_toNewViewController];
                                _toNewViewController = nil;
                                
                                
                                
							}];
    
    
    
    
    
}

@end
