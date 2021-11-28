//
//  PanGestureInteractiveTransition.m
//  Container Transitions
//
//  Created by Alek Astrom on 2014-05-11.
//
//

#import "PanGestureInteractiveTransition.h"

@implementation PanGestureInteractiveTransition {
    BOOL _leftToRightTransition;
}

- (id)initWithGestureRecognizerInView:(UIView *)view recognizedBlock:(void (^)(UIPanGestureRecognizer *recognizer))gestureRecognizedBlock {
    
    self = [super init];
    if (self) {
        _gestureRecognizedBlock = [gestureRecognizedBlock copy];
        _recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [view addGestureRecognizer:_recognizer];
    }
    return self;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super startInteractiveTransition:transitionContext];
    
    _leftToRightTransition = [_recognizer velocityInView:_recognizer.view].x > 0;
}

- (void)pan:(UIPanGestureRecognizer*)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.gestureRecognizedBlock(recognizer);
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        CGFloat d = translation.x / CGRectGetWidth(recognizer.view.bounds);
        if (!_leftToRightTransition) d *= -1;
        [self updateInteractiveTransition:d];
    } else if (recognizer.state >= UIGestureRecognizerStateEnded) {
        if (self.percentComplete > 0.2) {
            [self finishInteractiveTransition];
        } else {
            [self cancelInteractiveTransition];
        }
    }
}

@end
