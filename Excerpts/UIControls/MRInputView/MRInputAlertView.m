//
//  MRAlertView.m
//  MRAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import "MRInputAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "MROverlayManager.h"



const static CGFloat kMRAlertViewDefaultButtonHeight       = 50;
const static CGFloat kMRAlertViewDefaultButtonSpacerHeight = 1;
const static CGFloat kMRAlertViewCornerRadius              = 7;
const static CGFloat kMRMotionEffectExtent                 = 10.0;
const static CGFloat kMRAlertView_TitleHeight                       = 40.0;
static CGFloat const MRInputAlertViewSeparatorThickness = 1;
CGFloat MRInputAlertViewGetSeparatorThickness() {
	return MRInputAlertViewSeparatorThickness / [[UIScreen mainScreen] scale];
}




@interface MRInputAlertView ()
@end
@implementation MRInputAlertView

CGFloat buttonHeight = 0;
CGFloat buttonSpacerHeight = 0;

@synthesize  containerView, buttonView, buttonCompletionBlock = _buttonCompletionBlock, destructiveButtonIndex;
@synthesize delegate;
@synthesize buttonTitles, title;


- (id)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
        
        self.title = @"Alert";
        delegate = self;
        destructiveButtonIndex = -1;
        _selectedButtonIndex = -1;
        buttonTitles = @[@"Close"];
        _autoresizeContainerView = YES;
        _editableTitle = NO;
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        self.viewPosition = MRVIEWPOSITIONCENTER;
    
    }
    return self;
}


- (id)init
{
   
    if(self = [self initWithFrame:CGRectMake(0, 0, 300, 150)])
    {
      
    }
    return self;
}

#define CGRECT_POSITIONING_H

#define __CENTER_X (__ofRect.origin.x + (__ofRect.size.width - __rect.size.width)/2.0f)
#define __CENTER_Y (__ofRect.origin.y + (__ofRect.size.height - __rect.size.height)/2.0f)
#define __POSITION_WITH_ORIGIN(rect, ofRect, padding, x, y) ({ CGRect __rect = (rect); CGRect __ofRect = (ofRect); CGFloat __padding = (padding); (CGRect){.size=__rect.size, .origin=CGPointMake((x), (y))}; })

#define CGRectInsideTop(rect, ofRect, padding) __POSITION_WITH_ORIGIN(rect, ofRect, padding, __CENTER_X, __ofRect.origin.y + __padding)


// Create the dialog view, and animate opening the dialog
- (void)showForView:(UIView *)referenceView dismissCompletionBlock:(onButtonTouchUpInside)buttonTouchBlock
{
    if(buttonTouchBlock)
    {
        _buttonCompletionBlock = buttonTouchBlock;
    }
    
    [self createContainerView];
    
    CGRect selfBounds = self.frame;
    selfBounds.size.height = CGRectGetMaxY(self.containerView.frame) + 1 + buttonSpacerHeight + buttonHeight;
    self.frame = selfBounds;
    
    
    [self addButtonsToView:self];
    
    [self createBackgroundUI];
    
    
//    self.layer.shouldRasterize = YES;
//    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    
    /*
    self.layer.cornerRadius = kMRAlertViewCornerRadius;
    self.opaque = NO;
    self.layer.masksToBounds = YES;
     */


    
    
    CGPoint position;
//    CGRect top = CGRectInsideTop(self.frame, referenceView.frame, 55.f);
//    NSLog(@"%@", NSStringFromCGRect(top));

//    position = CGPointMake(CGRectGetMidX(top), CGRectGetMidY(top));
//    position = referenceView.center;
    
    MROverlayManager * manager = [MROverlayManager sharedManager];

  
    if(self.viewPosition == MRVIEWPOSITIONCENTER)
    {
        position = [manager centerForView:referenceView];
    }else
    {
        CGRect top = CGRectInsideTop(self.frame, referenceView.frame, 55.f);
        position = CGPointMake(CGRectGetMidX(top), CGRectGetMidY(top));
    }
    
    [manager overlay:self withCenter:position inView:referenceView];
   
}


- (void)setEditableTitle:(BOOL)editableTitle
{
    _editableTitle = editableTitle;
    [_titleTextField setUserInteractionEnabled:editableTitle];
    [_titleTextField setClearButtonMode:(editableTitle)?UITextFieldViewModeAlways:UITextFieldViewModeNever];
    
}
- (void)close
{
    [[MROverlayManager sharedManager] hideFromOverlay:nil];
    
}



// Button has been touched
- (void)mrInputAlertViewButtonTouchUpInside:(id)sender
{
    if (delegate != NULL)
    {
        [delegate mrInputAlertViewButtonTouchUpInside:self clickedButtonAtIndex:[sender tag]];
    }

    if(_buttonCompletionBlock != NULL)
    {
                _buttonCompletionBlock([self resultObject], [sender tag]);
        _buttonCompletionBlock = nil;
    }
    [[MROverlayManager sharedManager] hideFromOverlay:self];
}

-(void)dealloc
{
    
}

- (id)resultObject
{
    return @"TEST";
}


// Default button behaviour
- (void)mrInputAlertViewButtonTouchUpInside: (MRInputAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}




- (BOOL)becomeFirstResponder
{
    return [[self containerView] becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{

    if(_buttonCompletionBlock)
    {
        _buttonCompletionBlock(nil, -1);
        _buttonCompletionBlock = nil;
    }
    return [[self  containerView] resignFirstResponder];
}



- (void)setSubView: (UIView *)subView
{
    containerView = subView;
}


- (void)createBackgroundUI
{
    CGFloat cornerRadius = kMRAlertViewCornerRadius;
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0f] CGColor],
                       nil];
    
    gradient.cornerRadius = cornerRadius;
    gradient.contentsScale = [[UIScreen mainScreen] scale];
    
    [self.layer insertSublayer:gradient atIndex:0];
    
    
    
    //self.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:0.97];
    self.layer.cornerRadius = cornerRadius;
    //self.layer.borderColor = [[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f] CGColor];
    //self.layer.borderWidth = 1;
    self.layer.shadowRadius = cornerRadius + 5;
    self.layer.shadowOpacity = 0.1f;
    self.layer.shadowOffset = CGSizeMake(0 - (cornerRadius+5)/2, 0 - (cornerRadius+5)/2);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;

    
}

// Creates the container view here: create the dialog, then add the custom content and buttons
- (void)createContainerView
{
    if ([self containerView] == NULL) {
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 100)];
    }

    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];

    
    
    
    self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, self.bounds.size.width - 20.f, kMRAlertView_TitleHeight)];
    self.titleTextField.font = [UIFont boldSystemFontOfSize:15];
    self.titleTextField.textAlignment = NSTextAlignmentCenter;
    self.titleTextField.userInteractionEnabled = _editableTitle;
    self.titleTextField.borderStyle = UITextBorderStyleNone;
    self.titleTextField.placeholder = @"title";
    //self.titleTextField.backgroundColor = [UIColor redColor];
    if(_editableTitle)
    self.titleTextField.clearButtonMode = UITextFieldViewModeAlways;

    self.titleTextField.text = self.title;
    [self addSubview:self.titleTextField];
    
    
    
    
    
    
    CGRect containerFrame = [self containerView].frame;
    containerFrame.origin.y = kMRAlertView_TitleHeight + 5;
    containerFrame.origin.x = 10;
    containerFrame.size.width -= 20;
    if(_autoresizeContainerView)
    {
        containerFrame.size.height = [self.containerView sizeThatFits:containerFrame.size].height;
    }
    self.containerView.frame = containerFrame;
    self.containerView.contentScaleFactor = [[UIScreen mainScreen] scale];
    [self addSubview:[self containerView]];
}

// Helper function: add buttons to container
- (void)addButtonsToView: (UIView *)container
{
    if (buttonTitles==NULL) { return; }
    
    CGFloat lineOriginY = CGRectGetMaxY(self.containerView.frame)  +5;
    
    
    //CGFloat lineOriginY = self.bounds.size.height - buttonHeight - buttonSpacerHeight;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, lineOriginY , self.bounds.size.width, MRInputAlertViewGetSeparatorThickness())];
    lineView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.4];
    
    
    [self addSubview:lineView];
    

    CGFloat buttonWidth = container.bounds.size.width / [buttonTitles count];
    
    CGFloat btnFontSize = [UIFont buttonFontSize];
    

    for (int i=0; i<[buttonTitles count]; i++) {

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];

        [closeButton setFrame:CGRectMake(i * buttonWidth, lineOriginY, buttonWidth, buttonHeight)];

        [closeButton addTarget:self action:@selector(mrInputAlertViewButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag:i];
        [closeButton setTitle:buttonTitles[i] forState:UIControlStateNormal];
        [closeButton.titleLabel setFont:[UIFont systemFontOfSize:btnFontSize]];
        if(i == destructiveButtonIndex)
        {
            //[closeButton setTitleColor:[UIColor colorWithRed:1.00 green:0.15 blue:0.15 alpha:1.00] forState:UIControlStateNormal];
            [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:btnFontSize]];
        }
        [closeButton setSelected:(i == _selectedButtonIndex)];
        [closeButton.layer setCornerRadius:kMRAlertViewCornerRadius];
        [container addSubview:closeButton];
        
        if(i!=0  || i!=[buttonTitles count]-1 )
        {
            UIView * separator  = [self buttonSeparatorView];
            separator.frame = CGRectMake(i * buttonWidth, lineOriginY , MRInputAlertViewGetSeparatorThickness(), buttonHeight);
            [self addSubview:separator];
        }
    }
}

- (UIView *)buttonSeparatorView
{
    CGRect frame = CGRectMake(0, 0, MRInputAlertViewGetSeparatorThickness(), buttonHeight);
    UIView * view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    return view;
}

// Helper function: count and return the dialog's size
- (CGSize)countDialogSize
{
    CGFloat dialogWidth = containerView.frame.size.width;
    CGFloat dialogHeight = containerView.frame.size.height + buttonHeight + buttonSpacerHeight;

    return CGSizeMake(dialogWidth, dialogHeight);
}

// Helper function: count and return the screen's size
- (CGSize)countScreenSize
{
    if (buttonTitles!=NULL && [buttonTitles count] > 0) {
        buttonHeight       = kMRAlertViewDefaultButtonHeight;
        buttonSpacerHeight = kMRAlertViewDefaultButtonSpacerHeight;
    } else {
        buttonHeight = 0;
        buttonSpacerHeight = 0;
    }

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        CGFloat tmp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = tmp;
    }

    return CGSizeMake(screenWidth, screenHeight);
}
@end
