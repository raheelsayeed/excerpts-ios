//
//  MRModalAlertView.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 09/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "MRModalAlertView.h"

@interface MRModalAlertView ()
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation MRModalAlertView
@synthesize message = _message;
@synthesize messageLabel=_messageLabel;


+ (void)showMessage:(NSString *)msg title:(NSString *)title overView:(UIView *)overView
{
    MRModalAlertView * alertView = [[MRModalAlertView alloc] initWithTitle:title mesage:msg];
    [alertView showForView:overView selectorBlock:nil];
}

- (instancetype) initWithTitle:(NSString *)title mesage:(NSString *)msg
{
    self = [super initWithFrame:CGRectMake(0, 0, 300, 200)];
    if(self)
    {
        self.title = title;
        _message = msg;
        self.buttonTitles = @[@"No", @"Yes"];
        self.destructiveButtonIndex = 1;
    }
    return self;
    
}

-(UIView *)containerView
{
    if(!_messageLabel)
    {
        CGRect frame = CGRectMake(0, 0, self.bounds.size.width, 20);
        self.messageLabel = [[UILabel alloc] initWithFrame:frame];
        self.messageLabel.text = _message;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.textColor = [UIColor darkGrayColor];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.frame = frame;
    }
    return _messageLabel;
}


- (void)showForView:(UIView *)referenceView selectorBlock:(void (^) (BOOL result))result
{
    onButtonTouchUpInside completionBlock = nil;
    if(result)
    {
        completionBlock = ^(id alertView, int buttonIndex){
            if(buttonIndex == 1)
            {
                result(YES);
            }
            else
            {
                result(NO);
            }
        };
    } else
    {
        self.buttonTitles = @[@"OK"];
    }
    [self showForView:referenceView dismissCompletionBlock:completionBlock];
}



@end
