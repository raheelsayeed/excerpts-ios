//
//  KeyboardAccessoryBar.h
//   Renote
//
//  Created by M Raheel Sayeed on 28/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EXCERPT_KEYBOARD_MODE){
    EXCERPT_KEYBOARD_TEXT,
    EXCERPT_KEYBOARD_TAG,
    EXCERPT_KEYBOARD_LINKS
};



@interface KeyboardAccessoryBar : UIInputView

@property (nonatomic, strong) NSArray * buttonTitles;
@property (nonatomic, strong) UIFont * buttonFont;
@property (nonatomic, assign, getter = isLeftButtonVisible) BOOL leftButtonVisible;
@property (nonatomic, assign, getter = isRightButtonVisile) BOOL rightButtonVisible;
@property (nonatomic, assign) EXCERPT_KEYBOARD_MODE keyboardMode;
@property (nonatomic, weak) id keyboardAccessoryButtonActionDelegate;
@property (nonatomic, weak) id<UITextInput> textInputDelegate;
@property (nonatomic, assign) UIKeyboardAppearance keyboardAppearance;



- (void)setProgress:(CGFloat)progress;

- (instancetype)initWithFrame:(CGRect)frame textInputDelegate:(id<UITextInput>)textInputDelegate;

- (void)setButtonTitles:(NSArray *)buttonTitles animated:(BOOL)animated;
- (void)setRightButtonTitle:(NSString *)title;
- (void)setLeftButtonTitle:(NSString *)title;


- (void)darkMode:(BOOL)dark;
- (void)lightMode;
@end
