//
//  RSPullToAction.m
//  SCUnreadMenu
//
//  Created by M Raheel Sayeed on 03/05/14.
//  Copyright (c) 2014 Subjective-C. All rights reserved.
//

#import "RSPullToAction.h"
#import "UIColor+LightDark.h"

#define RSVIEWTAG 98789

@implementation UIScrollView (RSPullToAction)
- (RSPullToAction *)addPullToActionPosition:(RSPullToActionPostition)position actionHandler:(void (^)(RSPullToAction *v))handler
{
    RSPullToAction *view = [[RSPullToAction alloc] initWithText:@"Tags" position:position];
    CGRect frame = CGRectMake(0, 0, 45, 45);
    
    view.layer.cornerRadius = 45/2;
    view.layer.masksToBounds = YES;
    view.fontSize  = 12;
    
    [view setFrame:frame];
    
    view.pullToRefreshHandler = handler;
    view.scrollView = self;
    view.originalInsetTop = self.contentInset.top;
    view.originalInsetBottom = self.contentInset.bottom;
    view.enablePullToAction = YES;
    view.tag = RSVIEWTAG;
    view.backgroundColor = self.backgroundColor;
    
    [view assignFramePositionForScrollView];

    [self addSubview:view];
    
    return view;
}


- (void)enableAllRSViewPullActionViews:(BOOL)enable
{
    for(UIView * view in [self subviews])
    {
        if(view.tag == RSVIEWTAG)
        {
            [(RSPullToAction *)view setEnablePullToAction:enable];
        }
        
    }
}
@end


@interface RSPullToAction ()
@property (nonatomic, assign) BOOL isUserAction;
@property (nonatomic, assign, getter=isObserving) BOOL observing;
@property (nonatomic, assign) RSPullToActionState state;
@property (nonatomic, assign, readonly) BOOL isSidePosition;
@property (nonatomic, assign) double prevProgress;


@end
@implementation RSPullToAction

- (instancetype)initWithText:(NSString *)text position:(RSPullToActionPostition)position
{
    self = [self initWithFrame:CGRectMake(0, 0, 0, 0)];
    if(self)
    {
        _text = text;
        _position = position;
        

    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _fontSize = 15;
        _showPullActionIndicator = NO;
        _effectiveChangeStateInset = 20.f;
        _indicatorInset = 8.f;
    }
    return self;
}
- (void)assignFramePositionForScrollView
{
    CGFloat width = self.frame.size.width;
    CGFloat ht    = self.frame.size.height;
    CGFloat svWidth = self.scrollView.bounds.size.width;
    CGFloat Top  = 10.f;
    
    switch (self.position) {
        case RSPullActionPositionTop:
            
            self.effectiveChangeStateInset = self.scrollView.contentInset.top  + 8;
            _indicatorInset = _effectiveChangeStateInset;
            self.frame = CGRectMake((self.scrollView.bounds.size.width - width)/2,-(+ht), width, ht);
            break;
        case RSPullActionPositionBottom:
            self.frame = CGRectMake((self.scrollView.bounds.size.width - self.bounds.size.width)/2,
                                    -self.scrollView.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
            break;
        case RSPullActionPositionLeft:
            self.frame = CGRectMake(-width, Top, width, ht);
            break;
        case RSPullActionPositionRight:
            self.frame = CGRectMake(svWidth, Top, width, ht);
            break;
        default:
            break;
    }
}

- (void)setShowPullActionIndicator:(BOOL)showPullActionIndicator animated:(BOOL)animated
{
    if(animated)
    {
        [UIView animateWithDuration:0.2 animations:^{
            [self setShowPullActionIndicator:showPullActionIndicator];
        }];
    }else
    {
        [self setShowPullActionIndicator:showPullActionIndicator];
    }
    
}

- (void)setShowPullActionIndicator:(BOOL)showPullActionIndicator
{
    _showPullActionIndicator = showPullActionIndicator;
    CGRect fr = self.frame;
    
    if(_showPullActionIndicator)
    {
        switch (self.position) {
            case RSPullActionPositionLeft:
                fr.origin.x = - (fr.size.width - _indicatorInset);
                break;
            case RSPullActionPositionRight:
                fr.origin.x = self.scrollView.bounds.size.width - _indicatorInset ;
                break;
            case RSPullActionPositionTop:
                fr.origin.y = -(fr.size.height - _indicatorInset);
                break;
                
            default:
                break;
        }
    }else
    {
        _indicatorInset = 0.f;
        switch (self.position) {
                
            case RSPullActionPositionLeft:
                fr.origin.x = - (fr.size.width);
                break;
            case RSPullActionPositionRight:
                fr.origin.x = self.scrollView.bounds.size.width;
                break;
            case RSPullActionPositionTop:
                fr.origin.y = - fr.size.height;
                break;
                
            default:
                break;
        }
    }
    
    self.frame = fr;
    
}


- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set up environment.
    CGSize size = [self bounds].size;
    


    UIColor *preTransformColor  =  [self.scrollView.backgroundColor colorWithAlphaComponent:0.9];
    UIColor * transformColor =     [UIColor colorWithWhite:0.3 alpha:0.4];
    
    CGFloat progressX = 0.0;
    CGRect remainingProgressRect;
    
    
    switch (_position) {
        case RSPullActionPositionLeft:
            progressX  = ceil((1-self.progress) * size.width);
            remainingProgressRect = CGRectMake(progressX, 0.0,  ((1-size.width)-(progressX))  , size.height);
            break;
        case RSPullActionPositionRight:
            progressX  = ceil(self.progress * size.width);
            remainingProgressRect = CGRectMake(progressX, 0.0,  size.width-progressX  , size.height);
            break;
        case RSPullActionPositionTop:
            progressX  = ceil((1-self.progress) * size.height);
            remainingProgressRect = CGRectMake(self.bounds.origin.x, progressX, size.width, ((1-size.height) - (progressX)));
            break;
        default:
            break;
    }
    
    
    if(_progress >= 1.f)
    {
        transformColor = [self tintColor];
    }

    UIColor *foregroundColor = [UIColor whiteColor];
    UIFont *font = [UIFont systemFontOfSize:_fontSize];
    
    // Prepare progress as a string.
    NSString *progress = [NSString stringWithFormat:@"%d%%", (int)round([self progress] * 100)];
   // progress = _text;
    NSMutableDictionary *attributes = [@{ NSFontAttributeName : font } mutableCopy];
    CGSize textSize = [_text sizeWithAttributes:attributes];
    CGPoint textPoint = CGPointMake(ceil((size.width - textSize.width) / 2.0) , ceil((size.height - textSize.height) / 2.0));
    
    // Draw background + foreground text
    [transformColor setFill];
    CGContextFillRect(context, [self bounds]);
    attributes[NSForegroundColorAttributeName] = foregroundColor;
    [_text drawAtPoint:textPoint withAttributes:attributes];
    
    // Clip the drawing that follows to the remaining progress' frame.
    
    //NSLog(@">>%f=%f point=%@ rem=%f %@", progressX, 1-(size.width - progressX), NSStringFromCGPoint(textPoint), size.width-progressX,progress);
    
    
    CGContextSaveGState(context);
    CGContextAddRect(context, remainingProgressRect);
    CGContextClip(context);
    
    
    // Draw again with inverted colors.
    [preTransformColor setFill];
    CGContextFillRect(context, [self bounds]);
    attributes[NSForegroundColorAttributeName] = foregroundColor;
    [_text drawAtPoint:textPoint withAttributes:attributes];
    
    CGContextRestoreGState(context);
    

}

- (void)setupScrollViewContentInsetForLoadingIndicator:(actionHandler)handler
{
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    if (self.position == RSPullActionPositionTop)
    {
        CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
        currentInsets.top = MIN(offset, self.originalInsetTop + self.bounds.size.height + 20.0f);
    }
    else
    {
        //CGFloat overBottomOffsetY = self.scrollView.contentOffset.y - self.scrollView.contentSize.height + self.scrollView.frame.size.height;
        //currentInsets.bottom = MIN(overBottomOffsetY, self.originalInsetBottom + self.bounds.size.height + 40.0);
        currentInsets.bottom = MIN(self.threshold, self.originalInsetBottom + self.bounds.size.height + 30);
    }
    [self setScrollViewContentInset:currentInsets handler:handler];
}

- (void)resetScrollViewContentInset:(actionHandler)handler
{
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalInsetTop;
    currentInsets.bottom = self.originalInsetBottom;
    //[self setScrollViewContentInset:currentInsets handler:handler];
}
- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset handler:(actionHandler)handler
{
    self.state = RSPullActionStateNormal;

    self.scrollView.contentInset = contentInset;
    
    if (handler)  handler();
    
}

- (void)dealloc
{
    if(self.isObserving) self.observing = NO;
}

- (void)setObserving:(BOOL)observing
{
    _observing = observing;
    
    if(_observing)
    {
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        [self.scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    else
    {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
        [self.scrollView removeObserver:self forKeyPath:@"frame"];
    }
    
    
}
- (void)setEnablePullToAction:(BOOL)enablePullToAction
{
    self.hidden = !enablePullToAction;
    if(enablePullToAction != self.isObserving) self.observing = enablePullToAction;
}

- (BOOL)enablePullToAction
{
    return !self.hidden;
}
- (BOOL)isSidePosition
{
    return (self.position == RSPullActionPositionLeft || self.position == RSPullActionPositionRight);
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {

        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
        
    } else if ([keyPath isEqualToString:@"contentSize"]) {


    } else if ([keyPath isEqualToString:@"frame"]) {
        
        [self assignFramePositionForScrollView];


    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset
{
   
   
    CGFloat yOffset = contentOffset.y;
    CGFloat xOffset = contentOffset.x;
    CGFloat centerX;
    CGFloat centerY;
    
    switch (self.position) {
        case RSPullActionPositionTop:
        {
            CGFloat prg;
            prg = -(self.originalInsetTop+yOffset+_effectiveChangeStateInset) / (CGRectGetHeight(self.scrollView.bounds) / 6);
            
            
            //prg = (-(yOffset) /  CGRectGetHeight(self.bounds));
            self.progress = prg ;
            centerX = self.scrollView.center.x + xOffset;
            centerY = ((yOffset + -self.originalInsetTop)-(CGRectGetHeight(self.bounds)-_indicatorInset)) / 2.f;
            //NSLog(@"<<<offset=%f %f %f", yOffset,self.scrollView.scrollIndicatorInsets.top, self.scrollView.contentInset.top);
            self.center = CGPointMake(centerX, centerY);
            
            
        }
            break;
        case RSPullActionPositionBottom:
            break;
        case RSPullActionPositionLeft:
        {
            
            CGRect frame = self.frame;
            frame.origin.y = yOffset + 10.f;
            self.frame = frame;

                self.progress = (-xOffset - (_effectiveChangeStateInset)) / CGRectGetWidth(self.bounds);
                [self.alphaView setAlpha:1.f - self.progress];

        }
            break;
            
        case RSPullActionPositionRight: {
            

            CGRect frame = self.frame;
            frame.origin.y = yOffset + 10.f;
            self.frame = frame;

           
            
              //  if (xOffset >= _effectiveChangeStateInset)
                //{
                    self.progress = (xOffset - (_effectiveChangeStateInset)) / CGRectGetWidth(self.bounds);
                    [self.alphaView setAlpha:1.f - self.progress];

               // }
               // else if (xOffset == 0)
               // {
                   // self.progress = 0.f;
                //    [self.alphaView setAlpha:1];

              //  }
          

        }
        default:
            break;
    }
    
    switch (self.state) {
        case RSPullActionStateNormal: //detect action
            if (self.isUserAction && !self.scrollView.dragging && !self.scrollView.isZooming && self.progress > 0.99f) {
                [self actionTriggeredState];
            }
            break;
        case RSPullActionStateStopped: // finish
        case RSPullActionStateLoading: // wait until stopIndicatorAnimation
            break;
        default:
            break;
    }
    
    self.isUserAction = (self.scrollView.dragging) ? YES : NO;
}

- (void)actionTriggeredState
{
  //  self.state = RSPullActionStateLoading;
    

  //  [self setupScrollViewContentInsetForLoadingIndicator:nil];
    
    if (self.pullToRefreshHandler)
        self.pullToRefreshHandler(self);
}


-(void)setEffectiveChangeStateInset:(CGFloat)effectiveChangeStateInset
{
    _effectiveChangeStateInset = effectiveChangeStateInset;
    CGRect frame = self.frame;
    
    if(_showPullActionIndicator)
    {
        
    }

    switch (self.position) {
            
        case RSPullActionPositionRight:
        {
            CGFloat xOffset = 10.f;
            
            if(_showPullActionIndicator)
            {
                xOffset = -xOffset;
            }
            
            frame.origin.x = xOffset;
        }
            break;
            
        case RSPullActionPositionLeft:
        {
            CGFloat xOffset = 10.f;
            
            if(_showPullActionIndicator)
            {
                xOffset = -xOffset;
            }
            
            frame.size.width = xOffset;
        }
            
        default:
            break;
    }
    frame = self.frame;

}

- (void)setProgress:(CGFloat)progress {
    _progress = fminf(1.0, fmaxf(progress, 0.0));
    CGSize size = self.bounds.size;
    CGFloat progressX;
    
    switch (_position) {
        case RSPullActionPositionLeft:
            progressX  = ceil((1-progress) * size.width);
            break;
        case RSPullActionPositionRight:
            progressX = ceil(progress * size.width);
            break;

        default:
            break;
    }
    [self setNeedsDisplay];


}

@end



// This was omitted from the SO code snippet.



