//
//  WorkflowActionActivity.m
//   Renote
//
//  Created by M Raheel Sayeed on 01/12/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "WorkflowActionActivity.h"
#import "Workflows.h"
#import "NSString+RSParser.h"

@interface WorkflowActionActivity ()
{
    id shareItem;
}
@property (nonatomic) WorkflowAction * wfAction;
@end
@implementation WorkflowActionActivity

- (instancetype)initWithWorkflowAction:(WorkflowAction *)action
{
    self = [super init];
    if(self)
    {
        self.wfAction = action;
    }
    return self;
}

- (NSString *)activityTitle
{
    return _wfAction.title;
}
- (NSString *)activityType
{
    return _wfAction.identifier;
}
- (UIImage *)activityImage
{
    return [UIImage imageNamed:_wfAction.scheme];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return [_wfAction canPerformAction];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    _wfAction.shareActivityItems = activityItems;
}

- (void)performActivity
{
    [[Workflows shared] startWorkflows:@[_wfAction] completion:nil];
    [self activityDidFinish:YES];
}




@end
