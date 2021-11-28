//
//  KeyboardAccessoryBar.m
//   Renote
//
//  Created by M Raheel Sayeed on 28/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "KeyboardAccessoryBar.h"
#import <AudioToolbox/AudioToolbox.h>

#define systemSoundID    1104
static NSString * const kBackText = @"Back"; //◀︎
static NSString * const kSaveText = @"Save";
static NSString * const kMoveCaretForward = @"▶︎";
static NSString * const kMoveCaretBackword = @"◀︎";


@interface KeyboardAccessoryBar ()

@property (nonatomic, strong) UIToolbar * toolbar;
@property (nonatomic, strong) UIBarButtonItem * flexibleSpace;
@property (nonatomic, strong) NSArray * buttons;
@property (nonatomic, strong) UIBarButtonItem * leftItem;
@property (nonatomic, strong) UIBarButtonItem * rightItem;
@property (nonatomic) UIImage * darkBtnImage;
@property (nonatomic) UIImage * lightBtnImage;

@end
@implementation KeyboardAccessoryBar

- (instancetype)initWithButtonTitles:(NSArray *)titles frame:(CGRect)frame inputViewStyle:(UIInputViewStyle)style
{
    
    self = [self initWithFrame:frame inputViewStyle:UIInputViewStyleKeyboard];
    if(self)
    {
        _buttonTitles = titles;
    }
    return self;
}





- (id)initWithFrame:(CGRect)frame textInputDelegate:(id<UITextInput>)textInputDelegate
{
    self = [super initWithFrame:frame inputViewStyle:UIInputViewStyleKeyboard];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.toolbar = [[UIToolbar alloc] initWithFrame:frame];
        self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _toolbar.barStyle = UIBarStyleBlack;
        [_toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
        [self addSubview:_toolbar];

        _rightButtonVisible = YES;
        _leftButtonVisible   = YES;
        self.opaque = YES;
        self.textInputDelegate = textInputDelegate;
    }
    return self;
}
- (void)layoutSubviews
{
    self.keyboardMode = _keyboardMode;
}

- (UIBarButtonItem *)flexibleSpace
{
    if(!_flexibleSpace)
    {
        self.flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    }
    
    return _flexibleSpace;
}

- (UIBarButtonItem *)leftItem
{
    if(!_leftItem)
    {        
        self.leftItem = [[UIBarButtonItem alloc] initWithTitle:kSaveText style:UIBarButtonItemStylePlain target:self action:@selector(leftKeyboardAccessoryBarAction:)];
        [_leftItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18],
                                    NSForegroundColorAttributeName: kColor_Dark_Content_tint}
                         forState:UIControlStateNormal];
    }
    return _leftItem;
}
- (UIBarButtonItem *)rightItem
{
    if(!_rightItem)
    {
        
        self.rightItem = [[UIBarButtonItem alloc] initWithTitle:@"X" style:UIBarButtonItemStylePlain target:self action:@selector(rightKeyboardAccessoryBarAction:)];
        [_rightItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18],
                                            NSForegroundColorAttributeName: [UIColor whiteColor]}
                                 forState:UIControlStateNormal];
    }
    return _rightItem;
}

- (NSArray *)buttons
{
    if(!_buttons)
    {
        if(_rightButtonVisible && _leftButtonVisible)
            self.buttons = @[self.leftItem, _flexibleSpace, self.rightItem];
        else if (_rightButtonVisible)
            self.buttons = @[_flexibleSpace, self.rightItem];
        else if (_leftButtonVisible)
            self.buttons = @[self.leftItem, _flexibleSpace];
    }
    
    return _buttons;
}






- (void)setLeftButtonTitle:(NSString *)title
{
    if(title)
    {
        _leftItem.title = title;
    }
}
- (void)setRightButtonTitle:(NSString *)title
{
    if(title) [_rightItem setTitle:title];
}

- (void)setButtonTitles:(NSArray *)buttonTitles
{
    [self setButtonTitles:buttonTitles animated:YES];
}
- (void)setTextInputDelegate:(id<UITextInput>)textInputDelegate
{
    _textInputDelegate = textInputDelegate;
    self.keyboardAppearance = [textInputDelegate keyboardAppearance];
}

- (void)setButtonTitles:(NSArray *)buttonTitles animated:(BOOL)animated
{
    _buttonTitles = buttonTitles;
    
    NSMutableArray * b = [@[] mutableCopy];
    
    
    if(_rightButtonVisible)
    {
        [b addObject:self.leftItem];
        [b addObject:self.flexibleSpace];
    }

    for(id btn in _buttonTitles)
    {
        if([btn isKindOfClass:[UIBarButtonItem class]]) [b addObject:btn]; else
        [b addObject:[self barButtonWithTitle:btn target:self selector:@selector(buttonAction:)]];
        [b addObject:self.flexibleSpace];
    }
    
    if(_rightButtonVisible) [b addObject:self.rightItem];
    
    [_toolbar setItems:b.copy animated:animated];
}
/*
- (void)setButtonTitles:(NSArray *)buttonTitles animated:(BOOL)animated
{

   // self.keyboardAppearance = [self.textInputDelegate keyboardAppearance];

    _buttonTitles = buttonTitles;
    

    NSMutableArray * mbuttons = [NSMutableArray new];
    
    UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSeparator.width = -16;
    [mbuttons addObject:negativeSeparator];
    
    if(_leftButtonVisible)
    {
        [mbuttons addObject:self.leftItem];
        [mbuttons addObject:self.flexibleSpace];
        
    }
    
    
    
    NSInteger i = 0;
    for(id  obj in _buttonTitles)
    {
        if([obj isKindOfClass:[UIBarButtonItem class]])
        {
            [mbuttons addObject:obj];
        }
        else
        {
            [mbuttons addObject:[self barButtonWithTitle:obj target:self selector:@selector(buttonAction:)]];
            i++;
        }
        
        if(i <= _buttonTitles.count)
            [mbuttons addObject:self.flexibleSpace];
        
        
        
    }
    
    
    if(_rightButtonVisible)
    {
        
       // [mbuttons addObject:negativeSeparator];
        
        [mbuttons addObject:self.rightItem];
        
    }
    [mbuttons addObject:negativeSeparator];

    _buttons = [mbuttons copy];
    

    [_toolbar setItems:_buttons animated:animated];
    


    [_toolbar setNeedsDisplay];
    [_toolbar setNeedsLayout];
}
*/
- (void)leftKeyboardAccessoryBarAction:(id)sender
{
    AudioServicesPlaySystemSound (systemSoundID);

    if(_keyboardAccessoryButtonActionDelegate && [_keyboardAccessoryButtonActionDelegate respondsToSelector:@selector(leftKeyboardAccessoryBarAction:)])
    {
        [_keyboardAccessoryButtonActionDelegate performSelector:@selector(leftKeyboardAccessoryBarAction:) withObject:self];
    }
}
-(void)rightKeyboardAccessoryBarAction:(id)sender
{
    AudioServicesPlaySystemSound (systemSoundID);

    if(_keyboardAccessoryButtonActionDelegate && [_keyboardAccessoryButtonActionDelegate respondsToSelector:@selector(rightKeyboardAccessoryBarAction:)])
    {
        [_keyboardAccessoryButtonActionDelegate performSelector:@selector(rightKeyboardAccessoryBarAction:) withObject:self];
    }
}

- (void)buttonAction:(id)sender
{
    AudioServicesPlaySystemSound (systemSoundID);
    
    if(_keyboardAccessoryButtonActionDelegate && [_keyboardAccessoryButtonActionDelegate respondsToSelector:@selector(buttonAction:)])
    {
        [_keyboardAccessoryButtonActionDelegate performSelector:@selector(buttonAction:) withObject:sender];

        return;
    }
    
    
    if([sender isKindOfClass:[UIButton class]])
    {
        sender = [[(UIButton *)sender titleLabel] text];
    }
    else
    {
        sender = [sender title];
    }
    
    
    if(_textInputDelegate)
    {
           [_textInputDelegate insertText:sender];
    }
}



- (UIBarButtonItem *)barButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector
{
    
    BOOL isDarkMode = _keyboardAppearance == UIKeyboardAppearanceDark;
    
    UIColor * titleColor = (isDarkMode) ? [self darkModeButtonTitleColor] : [self lightModeButtonTitleColor];
    UIImage *stretchableImage = (isDarkMode) ? [self darkBtnImage] : [self lightBtnImage];

    
    UIFont * font = [UIFont systemFontOfSize:24];

//    UIImage *originalImage = [UIImage imageNamed:bgName];
//    UIImage *stretchableImage = [originalImage stretchableImageWithLeftCapWidth:18 topCapHeight:10];
    
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
//    button.layer.cornerRadius = 6;
//    button.clipsToBounds = YES;
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setBackgroundImage:stretchableImage forState:UIControlStateNormal];

    [button .titleLabel setFont: font];
    [button setFrame:CGRectMake(0, 0, 40,32)];
    [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    //[button setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem*btnItem= [[UIBarButtonItem alloc] initWithCustomView:button];
 
   
    return btnItem;
}


#pragma mark CUSTOM MODES

+ (NSArray *)charaters
{
    static NSArray *_chars = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _chars = @[@"#", @"*", @">", @",", @"`",@"-", @"(", @")", @"[", @"]", @".", @"_"];
    });
    return _chars;
}
-(void)setKeyboardMode:(EXCERPT_KEYBOARD_MODE)keyboardMode
{
    
    //if(_keyboardMode == keyboardMode && self.toolbar.items > 0) return;
    
    _keyboardMode = keyboardMode;
    
    NSArray * buttons;
    switch (keyboardMode) {
        case EXCERPT_KEYBOARD_TAG:
        {
            buttons = nil;
            [self setRightButtonTitle:@"Links"];
            [self setLeftButtonTitle:kBackText];
            [self setButtonTitles:buttons animated:YES];

        }
            break;
            
        case EXCERPT_KEYBOARD_TEXT:
        {
            
            NSUInteger n = (int)roundf((self.frame.size.width - 80)/40.f);
            
            buttons = [[[self class] charaters] objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN(n, [self.class charaters].count))]];
            
            [self setLeftButtonTitle:kSaveText];
            [self setRightButtonTitle:@"⇊"];
            [self setButtonTitles:buttons animated:YES];

        }
            break;
            
            default:
            break;
    }
}

- (UIColor *)darkModeButtonTitleColor
{
    return [UIColor whiteColor];
}
- (UIColor *)lightModeButtonTitleColor
{
    return [UIColor blackColor];
}


- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance
{
    _keyboardAppearance = keyboardAppearance;
    [self darkMode:(_keyboardAppearance == UIKeyboardAppearanceDark)];
}

- (UIImage *)lightBtnImage
{
    if(_lightBtnImage) return _lightBtnImage;
    
    UIImage * bgImg = [UIImage imageNamed:@"keyboard-btn-light"];
    self.lightBtnImage = [bgImg stretchableImageWithLeftCapWidth:18 topCapHeight:10];
    
    return _lightBtnImage;
}
- (UIImage *)darkBtnImage
{
    if(_darkBtnImage) return _darkBtnImage;
    
    UIImage * bgImg = [UIImage imageNamed:@"keyboard-btn-dark"];
    self.darkBtnImage = [bgImg stretchableImageWithLeftCapWidth:18 topCapHeight:10];
    
    return _darkBtnImage;
}

- (void)darkMode:(BOOL)dark
{

    UIColor * titleColor = (dark) ? [self darkModeButtonTitleColor] : [self lightModeButtonTitleColor];
    UIImage *stretchableImage = (dark) ? nil : [self lightBtnImage];

    UIButton * btn = (UIButton *)self.leftItem.customView;
    [btn setBackgroundImage:stretchableImage forState:UIControlStateNormal];
    [btn setTitleColor:(dark)?[UIColor colorWithRed:0.20 green:0.66 blue:0.86 alpha:1.00]:nil forState:UIControlStateNormal];
    
    btn = (UIButton *)self.rightItem.customView;
    [btn setBackgroundImage:stretchableImage forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];

    
    return;

    for(UIBarButtonItem *item in self.toolbar.items)
    {
        if([item.customView isKindOfClass:[UIButton class]])
        {
            UIButton * btn  = (UIButton *)item.customView;
            [btn setBackgroundImage:stretchableImage forState:UIControlStateNormal];
            
            //if([item isEqual:self.leftItem] || [item isEqual:self.rightItem]) continue;
            [btn setTitleColor:titleColor forState:UIControlStateNormal];
            
        }
    }
}

@end
