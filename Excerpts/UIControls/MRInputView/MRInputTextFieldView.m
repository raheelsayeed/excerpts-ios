//
//  PromptView.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 01/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "MRInputTextFieldView.h"
#import "MROverlayManager.h"
#import "UIView+MotionEffect.h"
#import "MRInputAlertView.h"

@interface MRInputTextFieldView ()

@end
@implementation MRInputTextFieldView


@synthesize textField = _textField;


- (id)initWithTitle:(NSString *)title fieldText:(NSString *)text
{
    self = [super initWithFrame:CGRectMake(0, 0, 250, 130)];
    if(self)
    {
        self.title = title;
        _fieldText = text;
        self.viewPosition = MRVIEWPOSITIONTOP;

    }
    return self;
}

- (UIView *)containerView
{
    if(!_textField)
    {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
        [_textField setClearButtonMode:UITextFieldViewModeAlways];
        _textField.placeholder = _fieldText;
        [_textField setBorderStyle:UITextBorderStyleRoundedRect];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.keyboardAppearance = UIKeyboardAppearanceDark;
        _textField.text = _fieldText;
    }
    return _textField;
}

- (void)showForView:(UIView *)referenceView dismissCompletionBlock:(onButtonTouchUpInside)buttonTouchBlock
{
    [super showForView:referenceView dismissCompletionBlock:buttonTouchBlock];
}

- (id)resultObject
{
    return [_textField text];
}


- (BOOL) becomeFirstResponder
{
    
    [_textField becomeFirstResponder];
    return [super becomeFirstResponder];
}
























@end
