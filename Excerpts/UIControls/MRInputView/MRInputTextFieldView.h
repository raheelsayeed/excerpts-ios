//
//  PromptView.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 01/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRInputAlertView.h"


@interface MRInputTextFieldView : MRInputAlertView

@property (nonatomic,strong) UITextField * textField;
@property (nonatomic, copy) NSString * fieldText;


- (id)initWithTitle:(NSString *)title fieldText:(NSString *)text;







@end
