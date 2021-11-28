//
//  MRTextInputView.h
//   Renote
//
//  Created by M Raheel Sayeed on 24/05/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "MRInputAlertView.h"

@interface MRTextInputView : MRInputAlertView
@property (nonatomic) UITextView * textView;
@property (nonatomic, copy) NSString * text;
@property (nonatomic, copy) NSAttributedString * attributedString;
@property (nonatomic, assign) BOOL editable;

@end
