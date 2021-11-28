//
//  MRTextInputView.m
//   Renote
//
//  Created by M Raheel Sayeed on 24/05/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "MRTextInputView.h"
#import "ActionMethods.h"
@interface MRTextInputView () 
@end
@implementation MRTextInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.buttonTitles = @[@"OK", @"Cancel", @"Help"];
        self.destructiveButtonIndex = 1;
        self.autoresizeContainerView = NO;
        self.title = nil;
        self.editableTitle = YES;
        self.viewPosition = MRVIEWPOSITIONTOP;
        self.editable = YES;
        

    }
    return self;
}

-(void)mrInputAlertViewButtonTouchUpInside:(id)sender
{
    if([sender tag] != 2)
    {
        [super mrInputAlertViewButtonTouchUpInside:sender];
    }
    else
    {
        NSString * paste = [ActionMethods lastObjectFromPasteboard];
        if(paste)
        {
            [_textView insertText:paste];
        }
    }
    
}
- (UIView *)containerView
{
    if(!_textView)
    {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 100)];
        self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
        [[self.textView layer] setCornerRadius:3];
        self.textView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        if(_editable)self.textView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        else self.textView.backgroundColor = [UIColor clearColor];
        self.textView.clipsToBounds = YES;
        self.textView.editable = _editable;
        if(_attributedString)
        {
            self.textView.attributedText = _attributedString;
        }
        else
            self.textView.text = _text;
    }
    return _textView;
}
- (id)resultObject
{
    return self;
}
- (BOOL)canBecomeFirstResponder
{
    return _editable;
}

- (BOOL) becomeFirstResponder
{
    return [self.titleTextField becomeFirstResponder];
}


@end
