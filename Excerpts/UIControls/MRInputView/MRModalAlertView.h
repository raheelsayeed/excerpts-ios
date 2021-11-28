//
//  MRModalAlertView.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 09/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "MRInputAlertView.h"

@interface MRModalAlertView : MRInputAlertView

@property (nonatomic, copy) NSString *message;

- (instancetype) initWithTitle:(NSString *)title mesage:(NSString *)msg;
- (void)showForView:(UIView *)referenceView selectorBlock:(void (^) (BOOL result))result;
+ (void)showMessage:(NSString *)msg title:(NSString *)title overView:(UIView *)overView;
@end
