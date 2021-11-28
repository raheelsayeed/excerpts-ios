//
//  CustomURLActionActivity.m
//   Renote
//
//  Created by M Raheel Sayeed on 30/11/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "CustomURLActionActivity.h"
#import "Workflows.h"
#import "NSString+RSParser.h"

@interface CustomURLActionActivity () <WorkflowsDelegate>
@property (nonatomic) NSString * noteText;
@property (nonatomic) WorkflowAction * wfAction;
@end

@implementation CustomURLActionActivity

- (instancetype)initWithTitle:(NSString *)title URLString:(NSString*)urlString
{
    self = [super init];
    if(self)
    {
        self.dataDict = @{@"title" : title, @"urlstring" : urlString};
    }
    return self;
}

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}

- (NSString *)activityTitle
{
    return  _dataDict[@"title"];
}
- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"customAction"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSURL * url = [NSURL URLWithString:_dataDict[@"url"]];
    BOOL canOpenCustomURL =  [[UIApplication sharedApplication] canOpenURL:url];
    
    return canOpenCustomURL;
    
    
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    _noteText = activityItems[0];
    
//    [[Workflows shared] setDelegate:self];
    self.wfAction = [[WorkflowAction alloc] initWithIdentifier:_dataDict[@"title"] url_string:_dataDict[@"url"]];
    _wfAction.actionTitle = _dataDict[@"title"];
    
}

- (void)performActivity
{
    [[Workflows shared] startWorkflows:@[self.wfAction] completion:nil];
    [self activityDidFinish:YES];
}


#pragma mark - WorkFlowDelegate
-(id)dataObjectForWorkflow:(WorkflowAction *)workflow{
    
    NSMutableDictionary * reps;
    
    if ([workflow replacements]) {
        reps = [[workflow replacements] mutableCopy];
    }
    else
    {
        reps = [[workflow requiredParameters] mutableCopy];
//        DLog(@"%@", [[workflow optionalParameters] description]);
        [reps addEntriesFromDictionary:[workflow optionalParameters]];
    }
    
//    DLog(@"%@", reps.description);
    
    for(NSString * key in reps.allKeys)
    {
        id value = reps[key];
        if([value isKindOfClass:[NSString class]])
        {
            
            if([value isEqualToString:@"[[note]]"])
            {
                [reps setObject:_noteText forKey:key];
                
            }else if ([value rangeOfString:@"[[title]]"].location != NSNotFound)
            {
                NSString * topLine = [_noteText topLine];
                if(topLine)
                {
                    reps[key] = [value stringByReplacingOccurrencesOfString:@"[[title]]" withString:topLine];
                    
                }else
                {
                    [reps removeObjectForKey:key];
                }
                
                
                
            }else if([value isEqualToString:@"[[markdown-text]]"])
            {
                [reps setObject:_noteText forKey:key];
            }
            else if ([value isEqualToString:@"[[url]]"])
            {
                [reps setObject:_noteText forKey:key];
            }
            else if ([value isEqualToString:@"[[filename]]"])
            {
                reps[key] = [_noteText rs_sanitizeFileNameStringWithExtension:@"txt"];
            }
            
            
        }
    }
//    DLog(@"%@", reps.description);
    return [reps copy];
}

-(void)workflowDidEnd:(WorkflowAction *)wfAction withSuccessParam:(NSString *)successURLParam
{
//    DLog(@"%@ %@ %@ %@", successURLParam, wfAction.identifier, wfAction.scheme, wfAction.action);
}
-(void)finishedExecutingAllWorkflows{
//    DLog(@"doine..");
}
-(void)workflowWillStart:(WorkflowAction *)workflow
{
//    DLog(@"%@", workflow.scheme);
    
}




@end
