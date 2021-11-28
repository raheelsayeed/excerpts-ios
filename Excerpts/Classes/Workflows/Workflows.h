//
//  Workflows.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 05/02/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WorkflowActionActivity.h"
static const NSString * WFXCallBack = @"WFxCallBack";
static const NSString * WFType = @"WFType";

extern NSString * const kWF_FILENAME_KEY;
extern NSString * const kWF_FILENAME_VARIABLE;
extern NSString * const kWF_NOTE_VARIABLE;


typedef void (^CompletionBlock)(id  inputObject, BOOL success);

typedef NS_ENUM(NSUInteger, WF_SHARED_OBJECT_CLASS_TYPE) {
    WF_SHARED_OBJECT_CLASS_TYPE_STRING,
    WF_SHARED_OBJECT_CLASS_TYPE_URL,
    WF_SHARED_OBJECT_CLASS_TYPE_ARRAY_OF_FILES,
    WF_SHARED_OBJECT_CLASS_TYPE_ARRAY_OF_STRINGS,
    WF_SHARED_OBJECT_CLASS_TYPE_CUSTOM
};

@class WorkflowAction;
@protocol WorkflowsDelegate <NSObject>
@optional
-(id)dataObjectForWorkflow:(WorkflowAction *)workflow;
-(id)exportObjectForWorkflowAction:(WorkflowAction *)workflowAction;
-(void)workflowWillStart:(WorkflowAction *)workflow;
-(void)workflowDidEnd:(WorkflowAction *)workflow withSuccessParam:(NSString *)successURLParam;
-(void)finishedExecutingAllWorkflows;
-(void)workflowAction:(WorkflowAction *)wfaction didReturn:(id)returnValue;

@end


@interface Workflows : NSObject
@property (nonatomic, assign) NSUInteger actionInterval;
@property (nonatomic, assign) BOOL abortOnCannotOpenURLError;
@property (nonatomic, assign) BOOL abortOnXError;
@property (nonatomic, assign) BOOL askForContinueOnXError;
@property (nonatomic, assign) NSUInteger currentWFIndex;
@property (nonatomic, strong) NSMutableArray * currentWorkFlows;
@property (nonatomic, copy) NSString *URLScheme;
@property (nonatomic, assign) id<WorkflowsDelegate> delegate;
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, strong) NSDictionary * workflowDirectory;
@property (weak, nonatomic) id senderObject;


//+ (NSArray *)actionList;
//- (NSArray *)actionList;
+ (Workflows *)shared;
- (void)startWorkflows;
- (void)startWorkflows:(id)sender;
- (void)startWorkflows:(NSArray *)workflowsArray completion:(CompletionBlock)completionBlock;
- (void)handleURL:(NSURL *)presult;
- (instancetype)initWithURLScheme:(NSString *)URLScheme;


- (WorkflowAction *)workFlowActionWithScheme:(NSString *)scheme actionKey:(NSString *)actionKey;
- (NSArray *)workflowsAvailableForObjectClasses:(NSArray *)classNames;

@end


@interface WorkflowAction : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong)   NSString * actionTitle;
@property (nonatomic, assign, getter = isXCallBack) BOOL  xCallBack;
@property (nonatomic, strong) NSDictionary   *requiredParameters;
@property (nonatomic, strong) NSDictionary *replacements;
@property (nonatomic, strong) NSDictionary * optionalParameters;
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, assign, getter = isCustomURL) BOOL customURL;
@property (nonatomic, strong)   NSArray *shareActivityItems;

- (instancetype)initWithIdentifier:(NSString *)iden
                            scheme:(NSString *)scheme
                            action:(NSString *)action
                            params:(NSDictionary *)params;
- (instancetype)initWithIdentifier:(NSString *)identifier url_string:(NSString *)url_string;


- (instancetype) initWithIdentifier:(NSString *)iden  Variables:(NSDictionary *)v;
- (BOOL)canOpenURL;
- (BOOL)canPerformAction;
- (NSString *)title;

- (BOOL)executeForCallBackScheme:(NSString *)schme replacements:(NSDictionary *)replacements;

- (BOOL)handleCustomURLWorkflowWithURLString:(NSString *)urlstr;

@end
