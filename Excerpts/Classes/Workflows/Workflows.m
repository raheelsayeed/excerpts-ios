//
//  Workflows.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 05/02/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "Workflows.h"
#import "NSURL+SBRXCallbackURL.h"
#import "NSString+SBRXCallbackURL.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "IOAction.h"
#import "SVModalWebViewController.h"
#import "CustomActions.h"


#import "DMSlideTransition.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ActionMethods.h"
#import "CustomURLActionActivity.h"

static NSString *const kWFRequiredParams = @"params";
static NSString *const kWFOptionalParams = @"optional";
static NSString *const kWFActionKeyPath  = @"key";
static NSString *const kWFReplacements   = @"replacements";
static NSString *const kWFActionTitle    = @"actionTitle";
static NSString *const kWFAppTitle       = @"title";
static NSString *const kWFAppActionList  = @"actionList";
static NSString *const kWFAppActions     = @"actions";
static NSString *const kWFApplicableKey  = @"applicableForType";
static NSString *const kWFGenericKey     = @"isGeneric";
static NSString *const kWF_EXPORT_FILENAME_KEY = @"expFileName";
static NSString *const kWF_EXPORT_CONTENT_KEY = @"expContent";
NSString * const kWF_FILENAME_KEY = @"filename";
NSString * const kWF_FILENAME_VARIABLE = @"[[filename]]";
NSString * const kWF_NOTE_VARIABLE = @"[[note]]";




@interface Workflows () <MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate>
{
    UIDocumentInteractionController * _documentInteractionController;
    IOAction * _exportAction;
    DMSlideTransition * modalSLideAnimator;
}
@property (nonatomic) NSDictionary * defaultDefinitions;
@property (nonatomic, strong) NSArray * genericSchemeNames;
@property (nonatomic) NSString * xcallbackSourceName;

@end


@implementation Workflows
@synthesize actionInterval, abortOnXError, askForContinueOnXError, currentWFIndex, currentWorkFlows, delegate, completionBlock = _completionBlock;


+ (Workflows *)shared
{
    static Workflows *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[Workflows alloc] initWithURLScheme:@"w-renote"];
        // Do any other initialisation stuff here
    });
    return shared;
}
- (instancetype)initWithURLScheme:(NSString *)URLScheme {
    self = [super init];
    if (self)
    {
        self.URLScheme = [URLScheme copy];
        self.xcallbackSourceName = kApp_Display_title;
    }
    return self;
}

/*
+ (NSArray *)actionList
{
    return [[[self class] defaultWorkflows] allKeys];
}
*/
- (NSArray *)actionList
{
    NSMutableArray * array = [NSMutableArray new];
    
    for(NSString * title in [_workflowDirectory allKeys])
    {
        NSDictionary * actiond= _workflowDirectory[title];
        NSString * actionKeyPath = actiond[kWFActionKeyPath];
        actionKeyPath = [actionKeyPath componentsSeparatedByString:@"."][0];
        
        [array addObject:@{@"title"  : title,
                           @"scheme" : actionKeyPath}];
        
    }
    return [array copy];
}


- (void)startWorkflows:(NSArray *)workflowsArray completion:(CompletionBlock)completionBlock
{
    _completionBlock = completionBlock;

    if(!self.currentWorkFlows)
    {
        self.currentWorkFlows = [NSMutableArray new];
    }
    [currentWorkFlows removeAllObjects];
    
    [currentWorkFlows addObjectsFromArray:workflowsArray];
    
    [self startWorkflows];
    
}

- (NSDictionary *)defaultDefinitions
{
    if(_defaultDefinitions) return _defaultDefinitions;
    
    self.defaultDefinitions = [self schemesDirectory];
    
    return _defaultDefinitions;
}
- (WorkflowAction *)workFlowActionWithScheme:(NSString *)scheme actionKey:(NSString *)actionKey
{
    
    NSDictionary * definition = self.defaultDefinitions[scheme];
    
    if(!definition) return nil;
    
    NSString * workFlowTitle = definition[kWFAppTitle];
    
    NSDictionary * actionDefinition = definition[kWFAppActions][actionKey];
    
    if(!actionDefinition) return nil;
    
    WorkflowAction * wfAction = [[WorkflowAction alloc] initWithIdentifier:workFlowTitle
                                                                    scheme:scheme
                                                                    action:actionKey
                                                                    params:actionDefinition[kWFRequiredParams]];
    wfAction.xCallBack = [definition[WFXCallBack] boolValue];
    wfAction.actionTitle = (actionDefinition[kWFActionTitle]) ? actionDefinition[kWFActionTitle] : workFlowTitle;
    wfAction.optionalParameters = actionDefinition[kWFOptionalParams];
    wfAction.replacements =  actionDefinition[kWFReplacements];
    
    return wfAction;
}
- (NSArray *)workflowsAvailableForObjectClasses:(NSArray *)classNames
{
    NSMutableArray * workflowArray = [NSMutableArray new];
    NSArray * presents = [[self class] presetWorkflowDefinitions];
    NSDictionary * baseDefinitions = self.defaultDefinitions;
    
    NSMutableArray * generics = [NSMutableArray new];
    for(NSDictionary * preset in presents)
    {
        NSString * keyPath = preset[kWFActionKeyPath];

        NSArray * keyComponents  =  [keyPath componentsSeparatedByString:@"."];
        NSString * scheme  = keyComponents[0];
        
        NSArray * applicableClassNames = baseDefinitions[scheme][kWFApplicableKey];
        
        BOOL isApplicableToDataType = YES;
        
        for(id class in classNames)
        {
            if(![applicableClassNames containsObject:[class description] ])
            {
                isApplicableToDataType = NO;
                break;
            }
        }
        if(!isApplicableToDataType) continue;
        
        NSString * appTitle = baseDefinitions[scheme][kWFAppTitle];
        
        
        NSDictionary * actionDict = [baseDefinitions valueForKeyPath:keyPath];
        

    
 
        WorkflowAction * wfAction = [[WorkflowAction alloc] initWithIdentifier:appTitle
                                                                        scheme:scheme
                                                                        action:keyComponents[2]
                                                                        params:actionDict[kWFRequiredParams]];
        
        wfAction.xCallBack = [baseDefinitions[scheme][WFXCallBack] boolValue];
        wfAction.actionTitle = (preset[kWFActionTitle]) ? preset[kWFActionTitle] : actionDict[kWFActionTitle];
        wfAction.optionalParameters = actionDict[kWFOptionalParams];
        wfAction.replacements =  preset[kWFReplacements];
        
        if(wfAction.isXCallBack == NO)
        {
            [generics addObject:wfAction.scheme];
        }
        [workflowArray addObject:wfAction];
    }
    _genericSchemeNames = [generics copy];
    return [workflowArray copy];
}

+ (NSArray *)presetWorkflowDefinitions
{
    return @[
             @{kWFActionKeyPath: @"openin.actions.text"},
             @{kWFActionKeyPath: @"saveInDocumentPicker.actions.text"},
             //@{kWFActionKeyPath: @"clipboard.actions.copytext"},
             @{kWFActionKeyPath: @"clipboard.actions.copylinks"},
             @{kWFActionKeyPath: @"text.actions.arrangeparas"},
             @{kWFActionKeyPath: @"markdown.actions.preview"},
             //@{kWFActionKeyPath : @"export.actions.zip"},
             //@{kWFActionKeyPath : @"export.actions.text"},
             @{kWFActionKeyPath: @"email.actions.send"},

             @{kWFActionKeyPath : @"safari.actions.open"},
             //@{kWFActionKeyPath : @"safari.actions.readinglist"},
             //@{kWFActionKeyPath : @"drafts.actions.create"},
             //@{kWFActionKeyPath :  @"labgear.actions.notes"},
             
             
             /*
             @{kWFActionKeyPath  : @"byword.actions.new",
                kWFReplacements : @{@"text": @"[[note]]",
                                      @"name": @"[[title]].txt",
                                      @"location" : @"dropbox"}},
             
             @{kWFActionKeyPath  :   @"dropbox.actions.new"},
               kWFReplacements   :   @{@"text":   @"[[note]]",
                                      @"creation": @"new",
                                      @"filename":@"[[filename]]"}},*/
             
             @{kWFActionKeyPath : @"googlechrome-x-callback.actions.open/"},
             //@{kWFActionKeyPath : @"x-callback-instapaper.actions.open"},
             //@{kWFActionKeyPath : @"tumblr.actions.text"},
             //@{kWFActionKeyPath : @"upword.actions.new"},
             //@{kWFActionKeyPath : @"whatsapp.actions.send"}

             
              
            ];
    
}






- (NSDictionary *)schemesDirectory{
    //website
    
    //parameters dictionary format:
    /*
        requiredKeyName : objectType
                        : objectType: NSString / Presents:NSArray(Choices)
     replace any NSString if equal to [[output]] to some text.
     
     valueforkeypath- byword.new.
     scheme: {Dictionary}
            title: appname
            action: @{dictinary of actions}
                    @{actionName: @""
                      params:
     */
    
    NSString * stringClass = NSStringFromClass([NSString class]);
    NSString * zipClass =   @"zip";
    NSString * arrayClass = NSStringFromClass([NSArray class]);
    NSString * urlClass     = NSStringFromClass([NSURL class]);
    NSString * imgClass     = NSStringFromClass([UIImage class]);
    NSString * fileClass    = @"fileURL";
    

    
    NSDictionary * saveInDocumentPicker = [self dictForScheme:@"saveInDocumentPicker"
                                                        title:@"Save file In .."
                                                   isCallBack:NO
                                                  actionsDict:@{@"text": @{kWFActionTitle  : @"Save as file In..",
                                                                           kWFRequiredParams:    @{kWF_EXPORT_FILENAME_KEY :kWF_FILENAME_VARIABLE,
                                                                                                   kWF_EXPORT_CONTENT_KEY: @"[[note]]"},
                                                                           
                                                                           },
                                                                @"fileurls": @{kWFActionTitle  : @"Open files In..",
                                                                               kWFRequiredParams:@{kWF_EXPORT_FILENAME_KEY : kWF_FILENAME_VARIABLE,
                                                                                                       kWF_EXPORT_CONTENT_KEY: @"[[note]]"}
                                                                               }
                                                                }
                                          applicableDataTypes:@[stringClass, fileClass]];
    //GENERIC
    NSDictionary * copyItem = [self dictForScheme:@"clipboard"
                                            title:@"Clipboard"
                                       isCallBack:NO
                                      actionsDict:@{@"copytext": @{kWFActionTitle: @"Copy"},
                                                    @"copylinks": @{kWFActionTitle: @"Copy link(s) in note"}}
                              applicableDataTypes:@[stringClass, urlClass, fileClass, zipClass, imgClass]];
    

    
    NSDictionary *bw = [self dictForScheme:@"byword"
                                     title:@"Byword"
                                isCallBack:YES
                               actionsDict:@{@"new":
                                                 @{kWFActionTitle : @"Byword New",
                                                   kWFRequiredParams       : @{@"text"    : @"[[note]]"},
                                                   kWFOptionalParams     : @{@"location" : @[@"dropbox", @"local", @"icloud"],
                                                                       @"name" : @"[[title]].txt"}
                                                   },
                                             @"open":
                                                 @{kWFActionTitle : @"Open",
                                                   kWFRequiredParams   :  @{@"location" : @[@"dropbox", @"local", @"icloud"],
                                                                    @"name"     : @"str"}
                                                   }
                                             }
                       applicableDataTypes:@[stringClass]];

    
    
    NSDictionary *lg = [self dictForScheme:@"labgear"
                                     title:@"LabGear"
                                isCallBack:YES
                               actionsDict:@{@"notes":
                                                 @{kWFActionTitle : @"Save as Notes to Lab(s)",
                                                   kWFRequiredParams      :    @{@"text" : @"[[note]]"}
                                                   }
                                             }
                       applicableDataTypes:@[stringClass]];

    
    NSDictionary * db = [self dictForScheme:@"dropbox"
                                      title:@"Dropbox"
                                 isCallBack:NO
                                actionsDict:@{@"new":
                                                  @{kWFActionTitle   : @"Save In Dropbox",
                                                    kWFRequiredParams:  @{@"[[note]]": @"[[note]]",
                                                                          @"[[filename]]":@"[[filename]]"},
                                                    }
                                              }
                        applicableDataTypes:@[fileClass, zipClass, stringClass]];

    
    NSDictionary * email = [self dictForScheme:@"email"
                                         title:@"Send Email"
                                    isCallBack:NO
                                   actionsDict:@{@"send":
                                                     @{kWFActionTitle: @"Send Email",
                                                       kWFRequiredParams:   @{@"body": @"[[note]]"},
                                                       kWFOptionalParams: @{@"subject": @"[[title]]"}
                                                       }
                                                 }
                           applicableDataTypes:@[stringClass, zipClass, urlClass]];

    
    NSDictionary * draftsApp = [self dictForScheme:@"drafts"
                                             title:@"Drafts"
                                        isCallBack:YES
                                       actionsDict:@{@"create": @{kWFRequiredParams:    @{@"text" : @"[[note]]"}}
                                                     }
                               applicableDataTypes:@[stringClass]];

    

    NSDictionary * share = [ self dictForScheme:@"share" title:@"Share" isCallBack:NO
                                    actionsDict:@{@"text":@{kWFRequiredParams: @{kWF_EXPORT_CONTENT_KEY:@"[[note]]"}}}
                                                                                 applicableDataTypes:@[urlClass, stringClass]];
    
    NSDictionary * openIN = [self dictForScheme:@"openin"
                                          title:@"Open In ..."
                                     isCallBack:NO
                                    actionsDict:@{@"text": @{kWFActionTitle  : @"Open txt file In..",
                                                            kWFRequiredParams:    @{kWF_EXPORT_FILENAME_KEY : @"[[filename]]",
                                                                                       kWF_EXPORT_CONTENT_KEY: @"[[note]]"},
                                                             
                                                               },
                                                  @"fileurls": @{kWFActionTitle  : @"Open files In..",
                                                             kWFRequiredParams:    @{kWF_EXPORT_FILENAME_KEY : @"[[filename]]",
                                                                                     kWF_EXPORT_CONTENT_KEY: @"[[note]]"}
                                                                 }
                                                  }
                            applicableDataTypes:@[stringClass]];

    
    NSDictionary * zipArchive = [self dictForScheme:@"export" title:@"Export" isCallBack:NO
                                        actionsDict:@{@"zip": @{kWFActionTitle: @"Archive"},
                                                      @"text": @{kWFActionTitle: @"Export Note..."},
                                                      @"documentPicker": @{kWFActionTitle : @"Export File too.."}
                                                      }
                                applicableDataTypes:@[stringClass, arrayClass]];

    
    NSDictionary * markdownPreview = [self dictForScheme:@"markdown"
                                                   title:@"Markdown"
                                              isCallBack:NO
                                             actionsDict:@{@"preview":
                                                               @{kWFActionTitle: @"Markdown Preview",
                                                                 kWFRequiredParams: @{@"text": @"[[note]]"}
                                                                 }
                                                           }
                                     applicableDataTypes:@[stringClass]];
    

    
    
    
    NSDictionary * unarchiver     = [self dictForScheme:@"unarchive" title:@"Unarchive" isCallBack:NO
                                            actionsDict:@{@"zip": @{kWFActionTitle: @"Unarchive"},
                                                          @"renoteArchive":@{kWFActionTitle: @"Unarchive"}
                                                          }
                                    applicableDataTypes:@[fileClass]];
    
    NSDictionary * chrome           = [self dictForScheme:@"googlechrome-x-callback" title:@"Open in Chrome" isCallBack:YES
                                              actionsDict:@{@"open/" :@{kWFRequiredParams : @{@"url": @"[[url]]"}}}
                                      applicableDataTypes:@[urlClass]];
    
    NSDictionary * instapaper   =   [self dictForScheme:@"x-callback-instapaper"
                                                  title:@"Instapaper"
                                             isCallBack:YES
                                            actionsDict:@{@"add":
                                                              @{kWFRequiredParams: @{@"url": @"[[url]]"}}
                                                          }
                                    applicableDataTypes:@[urlClass]];
    
    NSDictionary * safariHTTP    = [self dictForScheme:@"safari"
                                                 title:@"Safari"
                                            isCallBack:NO
                                           actionsDict:@{@"open":
                                                            @{kWFRequiredParams : @{@"url": @"[[url]]"},
                                                              kWFActionTitle:@"Open in Safari"
                                                              
                                                              },
                                                         @"readinglist":
                                                             @{kWFActionTitle: @"Add to Reading List",
                                                               kWFRequiredParams: @{@"url": @"[[url]]"}}}
                                   applicableDataTypes:@[urlClass]];
    
    
    NSDictionary *tumblr        = [self dictForScheme:@"tumblr"
                                                title:@"Tumblr"
                                           isCallBack:YES
                                          actionsDict:@{@"text":
                                                            @{kWFRequiredParams: @{@"title": @"[[title]]",
                                                                                   @"body" : @"[[note]]"}}
                                                        }
                                  applicableDataTypes:@[stringClass]];
    
    
    NSDictionary * upword       = [self dictForScheme:@"upword"
                                                title:@"UpWord"
                                           isCallBack:YES
                                          actionsDict:@{@"new":
                                                            @{kWFRequiredParams: @{@"name": @"[[filename]].txt",
                                                                                   @"text": @"[[note]]"}}
                                                        }
                                  applicableDataTypes:@[stringClass]];
    
    NSDictionary * text    = [self dictForScheme:@"text"
                                                title:@"Text Handling"
                                           isCallBack:NO
                                          actionsDict:@{@"arrangeparas":
                                                            @{kWFRequiredParams: @{@"text": @"[[note]]"},
                                                              kWFActionTitle : @"Arrange Paragraphs"}
                                                        }
                                  applicableDataTypes:@[stringClass]];
    
    
    NSDictionary * whatsapp = [self dictForScheme:@"whatsapp"
                                            title:@"Send to WhatsApp"
                                       isCallBack:YES
                                      actionsDict:@{@"send":
                                                        @{kWFRequiredParams:@{@"text":@"[[note]]"}
                                                          }
                                                    }applicableDataTypes:@[stringClass]];
    
    
    
                                                                                                          

    
    
    
    
    NSMutableDictionary * mdict = [NSMutableDictionary new];
    [mdict addEntriesFromDictionary:copyItem];
    [mdict addEntriesFromDictionary:saveInDocumentPicker];
    [mdict addEntriesFromDictionary:text];
                                                                               

//    [mdict addEntriesFromDictionary:bw];
//    [mdict addEntriesFromDictionary:lg];
    [mdict addEntriesFromDictionary:db];
    [mdict addEntriesFromDictionary:share];
//    [mdict addEntriesFromDictionary:email];
//    [mdict addEntriesFromDictionary:draftsApp];
    [mdict addEntriesFromDictionary:openIN];
    [mdict addEntriesFromDictionary:zipArchive];
    [mdict addEntriesFromDictionary:markdownPreview];
    [mdict addEntriesFromDictionary:unarchiver];
    [mdict addEntriesFromDictionary:chrome];
//    [mdict addEntriesFromDictionary:instapaper];
    [mdict addEntriesFromDictionary:safariHTTP];
//    [mdict addEntriesFromDictionary:tumblr];
//    [mdict addEntriesFromDictionary:upword];
//    [mdict addEntriesFromDictionary:whatsapp];

    return [mdict copy];
}

- (NSDictionary *)dictForScheme:(NSString *)scheme title:(NSString *)title isCallBack:(BOOL)callback  actionsDict:(NSDictionary *)actionsDict applicableDataTypes:(NSArray *)applicableClassList
{

        return @{scheme:
                     @{kWFAppTitle: title,
                       kWFAppActionList: [actionsDict allKeys],
                       kWFAppActions:  actionsDict,
                       WFXCallBack:     @(callback),
                       kWFApplicableKey: applicableClassList
                       }
                 };
        

 
}

- (void)addWorkFlow:(WorkflowAction *)workflow{
    [currentWorkFlows addObject:workflow];
}
- (void)startWorkflows:(id)sender
{
    self.senderObject = sender;
    [self startWorkflows];
    
}
- (void)startWorkflows{
    
    if(!self.currentWorkFlows || self.currentWorkFlows.count == 0)
    {
        return;
    }
    WorkflowAction * wf = [self.currentWorkFlows firstObject];
    currentWFIndex = 0;
    [self executeWorkFlow:wf];
}


- (void)handleURL:(NSURL *)presult{
    
    
    
    if(presult && self.delegate && [self.delegate respondsToSelector:@selector(workflowDidEnd:withSuccessParam:)])
    {
        [self.delegate workflowDidEnd:self.currentWorkFlows[currentWFIndex] withSuccessParam:[presult query]];
    }
    
    //Workflow Routine Complete.
    if(currentWorkFlows.count == 0 || currentWFIndex == currentWorkFlows.count-1)
    {
        self.senderObject = nil;
        
        currentWFIndex = 0;
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(finishedExecutingAllWorkflows)])
        {
            [self.delegate finishedExecutingAllWorkflows];
        }
        self.currentWorkFlows = nil;
        
        if(_completionBlock)
        {
            _completionBlock(nil, YES);
            _completionBlock = nil;
        }
        
    }
    else
    {
        currentWFIndex += 1;
        WorkflowAction * wf = self.currentWorkFlows[currentWFIndex];
        [self executeWorkFlow:wf];
    }
    
}
- (BOOL)handleGenericAction:(WorkflowAction *)workFlowAction
{
    BOOL completed = YES;
    if([workFlowAction.scheme isEqualToString:@"export"])
    {
        [self handleExportOperationForAcion:workFlowAction];
    }
    else if([workFlowAction.scheme isEqualToString:@"email"])
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(dataObjectForWorkflow:)])
        {
            NSDictionary * replacements = [self.delegate performSelector:@selector(dataObjectForWorkflow:) withObject:workFlowAction];
            if(!replacements || ![replacements isKindOfClass:[NSDictionary class]])
            {
                return NO;
            }
            [self actionEmail:replacements];

        }
        
    }
    else if([workFlowAction.scheme isEqualToString:@"markdown"])
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(dataObjectForWorkflow:)])
        {
            NSDictionary * replacements = [self.delegate performSelector:@selector(dataObjectForWorkflow:) withObject:workFlowAction];
            if(!replacements || ![replacements isKindOfClass:[NSDictionary class]])
            {
                return NO;
            }
            [self previewMarkdown:replacements[@"text"]];
            
        }
    }
    else if([workFlowAction.scheme isEqualToString:@"clipboard"])
    {
        [self clipboardActionForWorkflow:workFlowAction];
    }
    else if ([workFlowAction.scheme isEqualToString:@"share"])
    {
        return [self activityViewControllerForWorkflowAction:workFlowAction];
    }
    else if([workFlowAction.scheme isEqualToString:@"openin"])
    {
        return [self openInForWorkflowAction:workFlowAction];
    }
    else if ([workFlowAction.scheme isEqualToString:@"safari"])
    {
        NSDictionary * replacements = [self.delegate performSelector:@selector(dataObjectForWorkflow:) withObject:workFlowAction];
        if(!replacements || ![replacements isKindOfClass:[NSDictionary class]])
        {
            return NO;
        }
        
        if([workFlowAction.action isEqualToString:@"open"])
        {
            return [self openURLString:replacements[@"url"]];
        }
        else if([workFlowAction.action isEqualToString:@"readinglist"])
        {
            return [ActionMethods action_AddURLTOReadingList:[NSURL URLWithString:replacements[@"url"]]];
        }
    }
    else if([workFlowAction.scheme isEqualToString:@"dropbox"])
    {
        [self handleDropboxAction:workFlowAction];
    }
    else if([workFlowAction.scheme isEqualToString:@"text"])
    {
        [self openViewControllerToRearrange:workFlowAction];
    }
    else if([workFlowAction.scheme isEqualToString:@"saveInDocumentPicker"])
    {
        [self saveInDocumentPicker_WorkflowAction:workFlowAction];
    }
    
    
 
    return completed;
}
- (BOOL)handleDropboxAction:(WorkflowAction*)wfAction
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(dataObjectForWorkflow:)])
    {
        NSDictionary * reps = [self.delegate dataObjectForWorkflow:wfAction];
        
        NSString * filename = reps[kWF_FILENAME_VARIABLE];
        NSString * note     = reps[kWF_NOTE_VARIABLE];
        
        if(!note || !filename) return NO;
        
        NSString * filePath = [[[NSUserDefaults standardUserDefaults] objectForKey:kSettings_DBFolderPath] stringByAppendingPathComponent:filename];

        [ActionMethods uploadFileAtPath:filePath data:note];
        return YES;
    }
    
    return NO;
}

- (void)openViewControllerToRearrange:(WorkflowAction *)wfAction
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(dataObjectForWorkflow:)])
    {
        NSDictionary * replacements = [self.delegate performSelector:@selector(dataObjectForWorkflow:) withObject:wfAction];

        UINavigationController * n = [ActionMethods reorderParagraphsInText:replacements[@"text"]];
        
        __weak typeof(self) weakSelf = self;
        __weak WorkflowAction * weakAction = wfAction;
        
        [(ReorderViewController *)n.topViewController  setCompletionBlock:^(id inputObject, BOOL success)
         {
             if(success)
             {
                 if(weakSelf.delegate && [ weakSelf.delegate respondsToSelector:@selector(workflowAction:didReturn:)])
                 {
             [weakSelf.delegate workflowAction:weakAction didReturn:inputObject];
                 }
             }
         }];
        
        if(!modalSLideAnimator) modalSLideAnimator = [[DMSlideTransition alloc] init];
        n.modalPresentationCapturesStatusBarAppearance = YES;
        n.transitioningDelegate = modalSLideAnimator;
        n.title = wfAction.actionTitle;
        [(UIViewController *)self.delegate  presentViewController:n animated:YES completion:nil];
    }
    
}


- (BOOL)openURLString:(NSString *)urlstring
{
    NSURL * url = [NSURL URLWithString:urlstring];
    return [[UIApplication sharedApplication] openURL:url];
}
- (BOOL)saveInDocumentPicker_WorkflowAction:(WorkflowAction*)workflow
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(dataObjectForWorkflow:)])
    {
        NSDictionary * replacements = [self.delegate performSelector:@selector(dataObjectForWorkflow:) withObject:workflow];
        
        NSURL* target;
        if([workflow.action isEqualToString:@"text"])
        {
            NSString *fileName = replacements[kWF_EXPORT_FILENAME_KEY];
            NSString *content  = replacements[kWF_EXPORT_CONTENT_KEY];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            target = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName]];
            
            if(![[content dataUsingEncoding:NSUTF8StringEncoding] writeToURL:target atomically:NO])
            {
                DLog(@"AbortedOpenIn");
                return NO;
            }
        }
        else if([workflow.action isEqualToString:@"fileURL"])
        {
            target = [NSURL fileURLWithPath:replacements[@"fileURL"]];
        }
        
        if([target isFileURL])
        {
            return [self openDocumentPickerForFileExportURL:target];
        }
        
    }
    
    return NO;
    
}

- (BOOL)openInForWorkflowAction:(WorkflowAction *)workflow
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(dataObjectForWorkflow:)])
    {
        NSDictionary * replacements = [self.delegate performSelector:@selector(dataObjectForWorkflow:) withObject:workflow];
        
        NSURL* target;
        if([workflow.action isEqualToString:@"text"])
        {
            NSString *fileName = replacements[kWF_EXPORT_FILENAME_KEY];
            NSString *content  = replacements[kWF_EXPORT_CONTENT_KEY];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            target = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName]];
            if(![[content dataUsingEncoding:NSUTF8StringEncoding] writeToURL:target atomically:NO])
            {
                DLog(@"AbortedOpenIn");
                return NO;
            }
        }
        else if([workflow.action isEqualToString:@"fileURL"])
        {
            target = [NSURL fileURLWithPath:replacements[@"fileURL"]];
        }
        
        if([target isFileURL])
        {
            return [self openDocumentInteractiveController:target];
        }
        
    }
    
    return NO;

    
    
}


- (BOOL )activityViewControllerForWorkflowAction:(WorkflowAction *)workflow
{
    
    NSDictionary * replacements = [self.delegate performSelector:@selector(dataObjectForWorkflow:) withObject:workflow];

    NSArray * items = @[replacements[kWF_EXPORT_CONTENT_KEY]];
    
    NSMutableArray *m = [NSMutableArray new];
    
    NSArray * wfAs  = [ self workflowsAvailableForObjectClasses:@[NSStringFromClass([NSString class])]];

    for(WorkflowAction *wfa in wfAs)
    {
        WorkflowActionActivity *act = [[WorkflowActionActivity alloc] initWithWorkflowAction:wfa];
        [m addObject:act];
    }
    CustomActions * customs = [[CustomActions alloc] init];
    for(NSDictionary * dict in [customs enabledActions])
    {
        CustomURLActionActivity * activity = [[CustomURLActionActivity alloc] init];
        activity.dataDict = dict;
        [m addObject:activity];
    }


    
    
    

    
        UIActivityViewController * activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                                              applicationActivities:[m  copy]];
        activityViewController.popoverPresentationController.sourceView = _senderObject;
    
    [(UIViewController *)self.delegate presentViewController:activityViewController animated:YES completion:nil];
    return YES;
}


#pragma mark - Document Handling
- (BOOL)openDocumentPickerForFileExportURL:(NSURL*)fileURL
{
    UIDocumentMenuViewController * menu = [[UIDocumentMenuViewController alloc] initWithURL:fileURL inMode:UIDocumentPickerModeExportToService];
    menu.delegate = self;
    menu.popoverPresentationController.sourceView = _senderObject;
    [(UIViewController *)self.delegate presentViewController:menu animated:YES completion:nil];
    
    return YES;
    
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    documentPicker.delegate = self;
    [documentMenu dismissViewControllerAnimated:YES completion:nil];
    documentPicker.popoverPresentationController.sourceView = _senderObject;
    [(UIViewController *)self.delegate presentViewController:documentPicker animated:YES completion:nil];
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{

}
- (BOOL)openDocumentInteractiveController:(NSURL *)fileURL
{
    
    
    _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    _documentInteractionController.delegate = self;
    [_documentInteractionController setUTI:@"public.plain-text"];
   
    
        return [_documentInteractionController  presentOpenInMenuFromRect:CGRectMake(1, 1, 0, 0) inView:[self.delegate performSelector:@selector(view)] animated:YES];
}
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
     return (UIViewController *)self.delegate;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
  
}
- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
}
- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
}
- (void)documentInteractionControllerWillPresentOptionsMenu:(UIDocumentInteractionController *)controller
{
    
}
- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller
{
    if([[NSFileManager defaultManager] removeItemAtURL:controller.URL error:nil])
    {
        _documentInteractionController = nil;
    }
}

-(void)executeWorkFlow:(WorkflowAction *)wf
{
    if(self.delegate && [delegate respondsToSelector:@selector(workflowWillStart:)])
    {
        [self.delegate workflowWillStart:wf];
    }
    
    if(!wf.isXCallBack && !wf.customURL)
    {
        [self handleGenericAction:wf];
        return;
    }
    
    id replacements;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(dataObjectForWorkflow:)])
    {
        replacements = [self.delegate performSelector:@selector(dataObjectForWorkflow:) withObject:wf];
    }

    if(wf.isCustomURL)
    {
        [wf handleCustomURLWorkflowWithURLString:replacements];

    }
    else if (![wf executeForCallBackScheme:_URLScheme replacements:replacements])
    {
        if(!self.abortOnCannotOpenURLError)
        {
            [self handleURL:nil];
        }
    }
}



-(BOOL)abortOnCannotOpenURLError{
    return NO;
}

#pragma mark - Actions - EXPORT OPERATIONS
- (void)handleExportOperationForAcion:(WorkflowAction *)wfAction
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(exportObjectForWorkflowAction:)])
    {
        id exportObject = [self.delegate exportObjectForWorkflowAction:wfAction];
        if(!exportObject)
        {
            NSAssert(exportObject == nil, @"exportObjectForWorkflowAction cannot be nil");
            
        }
        __block id xportedObject;
        _exportAction = [[IOAction alloc] initWithExportObject:exportObject exportActionKey:wfAction.action];
        [_exportAction startExportWithCompletion:^(id exportedObject, BOOL success){
            if(success)
            {
                xportedObject = exportedObject;
                [self openDocumentInteractiveController:[NSURL fileURLWithPath:exportedObject]];
            }
        }];
//        NSLog(@"%@" , xportedObject);
        
    }else
    {
        NSAssert1(nil, nil, @"exportObjectForWorkflowAction cannot be nil");
    }
}

#pragma mark - Actions - EMAIL
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(becomeFirstResponder)])
    {
        [self.delegate performSelector:@selector(becomeFirstResponder)];
    }
    
    [controller dismissViewControllerAnimated:YES completion:^{
     
    }];
}
- (NSDictionary *)paramsEmail
{
    return @{@"subject": @"[[title]]",
             @"messageBody" : @"[[note]]",
             };
}
- (void)actionEmail:(NSDictionary *)data
{
    //NSString *displayAppName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    //NSString *versionNumber  = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    [controller setSubject:data[@"subject"]];
    [controller setMessageBody:data[@"body"] isHTML:NO];
    [controller setToRecipients:data[@"toRecipients"]];
    [controller setMailComposeDelegate:self];
    if(!modalSLideAnimator)
        modalSLideAnimator = [[DMSlideTransition alloc] init];
    
    controller.modalPresentationCapturesStatusBarAppearance = YES;
    controller.transitioningDelegate = modalSLideAnimator;
    [(UIViewController *)self.delegate presentViewController:controller animated:YES completion:nil];
}
#pragma mark - Actions - PASTEBOARD
- (void)clipboardActionForWorkflow:(WorkflowAction *)clipboardAction
{

    id Object = [[clipboardAction shareActivityItems] firstObject];
    
        NSMutableArray * pasteboardArray = [NSMutableArray new];
        if([Object isKindOfClass:[NSArray class]])
        {
            for(id itemInObject in Object)
            {
                [self addPasteboardItem:itemInObject marray:pasteboardArray];
            }
        }
        else
        {
            if([clipboardAction.action isEqualToString:@"copytext"])
            {
                [self addPasteboardItem:Object marray:pasteboardArray];
            }
            else if([clipboardAction.action isEqualToString:@"copylinks"])
            {
                NSString * urls = [ActionMethods linksForString:Object];
                if(urls) [self addPasteboardItem:urls marray:pasteboardArray];
            }
        }
        
        [[UIPasteboard generalPasteboard] setItems:[pasteboardArray copy]];
}
- (void)addPasteboardItem:(id)item marray:(NSMutableArray *)mutableArray
{
    if([item isKindOfClass:[NSString class]])
    {
        [mutableArray addObject:@{(NSString *)kUTTypeText: item}];
    }
    else if([item isKindOfClass:[UIImage class]])
    {
        [mutableArray addObject:@{(NSString *)kUTTypeImage: item}];

    }
    else if ([item isKindOfClass:[NSURL class]])
    {
        [mutableArray addObject:@{(NSString *)kUTTypeURL: item}];
    }
}

- (void)previewMarkdown:(NSString *)markdownText
{
    
    if(!markdownText) return;
    

    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    BOOL isDarkTheme  =  [[defaults objectForKey:kSettings_ThemeName] isEqualToString:@"Dark"];
    NSString * fontName = [defaults objectForKey:@"editorFontName"];
    
    fontName = @"Verdana";
    
    NSString *raw1  = [ActionMethods parseMarkdownToHTML:markdownText];
    NSString * cssFile = (isDarkTheme) ? @"markdown-blackbg" : @"markdown-whitebg";
    NSString *csspath = [[NSBundle mainBundle] pathForResource:cssFile ofType:@"css"];

    NSString *style = [NSString stringWithContentsOfFile:csspath encoding:NSUTF8StringEncoding error:nil];
    style = [style stringByReplacingOccurrencesOfString:@"[[editorFontName]]" withString:fontName];
    NSString * final  = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\"width=device-width; minimum-scale=1.0; maximum-scale=1.0; user-scalable=no\"><style>%@</style>%@", style, raw1];
    
    SVModalWebViewController * web = [[SVModalWebViewController alloc] initWithHtml:final];
    web.webController.showHTMLActionButton = YES;

    if(!modalSLideAnimator)  modalSLideAnimator = [[DMSlideTransition alloc] init];
    
  

    web.navigationBar.BarStyle=UIBarStyleBlack;
    web.navigationBar.translucent = YES;
    web.navigationBar.tintColor = kColor_Dark_Content_tint;
    web.topViewController.view.backgroundColor = kColor_SVT;
    web.modalPresentationCapturesStatusBarAppearance = YES;
    web.transitioningDelegate = modalSLideAnimator;
    web.title = @"Markdown Preview";
    [(UIViewController *)self.delegate  presentViewController:web animated:YES completion:nil];
}
@end


@interface WorkflowAction () {
    NSArray * specialSchemes;
}
@property (nonatomic, strong) NSDictionary * variables;
@end
@implementation WorkflowAction
@synthesize type;

-(instancetype)init{
    self = [super init];
    if(self)
    {
        type = 0;
        specialSchemes = @[@"dropbox", @"evernote", @"markdown", @"email", @"safari", @"saveInDocumentPicker"];
    }
    return self;
}
- (instancetype)initWithIdentifier:(NSString *)identifier url_string:(NSString *)url_string
{
    self = [self init];
    if(self)
    {
        NSURL *url = [NSURL URLWithString:url_string];
        if(!url) return nil;
        self.identifier = url_string;
        self.scheme = url.scheme;
        self.customURL = YES;
        [self assignReplacementDictionary];
    }
    return self;
}

- (void)assignReplacementDictionary
{
    NSMutableDictionary * reps = [NSMutableDictionary new];
    
    if([self.identifier rangeOfString:@"[[note]]"].location !=NSNotFound)
    {
        reps[@"[[note]]"] = @"[[note]]";
    }
    if([self.identifier rangeOfString:@"[[text]]"].location !=NSNotFound)
    {
        reps[@"[[text]]"] = @"[[text]]";
    }
    if([self.identifier rangeOfString:@"[[title]]"].location !=NSNotFound)
    {
        reps[@"[[title]]"] = @"[[title]]";
    }
    self.replacements = [reps copy];
}
- (instancetype) initWithIdentifier:(NSString *)iden  Variables:(NSDictionary *)v{
    self = [self init];
    {
        if(!iden || !v[@"scheme"])
        {
            NSAssert(@"scheme = nil", @"scheme cannot be nil. pass some arguements");
            return nil;
        }
        self.identifier = iden;
        self.scheme     = v[@"scheme"];
        self.requiredParameters = v[kWFRequiredParams];
        self.action             = v[@"action"];
        self.variables          = v;
    }
    return self;
}


- (instancetype)initWithIdentifier:(NSString *)iden
                            scheme:(NSString *)scheme
                            action:(NSString *)action
                            params:(NSDictionary *)requiredParams{
    
    self = [self init];
    if(self)
    {
        if( !scheme)
        {
            NSAssert(@"scheme = nil", @"scheme cannot be nil. pass some arguements");
            return nil;
        }
        self.identifier = iden;
        self.scheme = scheme;
        self.action = action;
        self.requiredParameters = requiredParams;
    }
    return self;
}
- (NSString *)title
{
    return (self.actionTitle) ? self.actionTitle : self.identifier;
}
- (NSArray *)requiredParams
{
    return [_requiredParameters allKeys];
}
- (BOOL)canPerformAction
{
    return (!_xCallBack && !_customURL) ? YES : [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", _scheme]]];
}
- (BOOL)canOpenURL
{
    return (!_xCallBack && !_customURL) ? YES : [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", _scheme]]];
}


- (NSString *)queryWFStringWithReplacements:(NSDictionary *)replacements{
    
    BOOL requiredKeysPresent = YES;
    if(_requiredParameters){
        for(NSString * key in _requiredParameters.allKeys)
        {
            if(![[replacements allKeys] containsObject:key])
            {
                requiredKeysPresent = NO;
                break;
            }
        }
    }
    
    if(!requiredKeysPresent)
    {
//        NSLog(@"Required Keys are not in the replacements, aborting URL Creating...");
        return nil;
    }
    
        NSMutableArray *queryParameters = [[NSMutableArray alloc] initWithCapacity:[replacements count]];
        [replacements enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            NSString *escapedValue = [obj sbr_URLEncode];
            NSString *queryParam = [NSString stringWithFormat:@"%@=%@", key, escapedValue];
            [queryParameters addObject:queryParam];
            
        }];
        
        NSString *queryString = [queryParameters componentsJoinedByString:@"&"];
        NSString *prefix = [_action rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
        NSString * actionString = [NSString stringWithFormat:@"%@%@%@", _action,prefix, queryString];
    
//        NSLog(@"actionString = %@",  actionString);
    return actionString;
}



-(NSString *)callBackNotifierWithScheme:(NSString *)scheme cmd:(NSString *)query{
    NSString * ret = [NSString stringWithFormat:@"%@://?%@=%@", scheme, query,
             [self.identifier sbr_URLEncode]];
    return [ret sbr_URLEncode];
}


- (BOOL)executeForCallBackScheme:(NSString *)schme replacements:(NSDictionary *)replacements{

    

    if(!schme && self.isXCallBack)
    {
//        NSLog(@"missing callback Scheme");
        return NO;
    }
    
    NSString * actionString = [self queryWFStringWithReplacements:replacements];

    
    NSURL *actionURL;
    if(!self.isXCallBack)
    {
        actionURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", _scheme, actionString]];
    }else
    {
        NSString *xsuccess = [self callBackNotifierWithScheme:schme cmd:@"success"];
        NSString *xcancel = [self callBackNotifierWithScheme:schme cmd:@"cancelled"];
        NSString *xerror = [self callBackNotifierWithScheme:schme cmd:@"error"]  ;
        actionURL = [NSURL  v_xCallBackURLWithScheme:_scheme
                                              urlStr:actionString
                                            x_source:kApp_Display_title
                                           x_success:xsuccess
                                            x_cancel:xcancel
                                             x_error:xerror
                                        shouldEncode:NO];
    }
    
    

    
    if(!actionURL)
    {
//        NSLog(@"Cannot execute, NO URL");
        return NO;
    }
    

    if ([[UIApplication sharedApplication] canOpenURL:actionURL])
    {
//        NSLog(@"%@", actionURL.description);
        [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:actionURL afterDelay:1.0];
        
        return YES;
    }
    else
    {
//        NSLog(@"Cannot Open URL: %@", [actionURL description]);
        return NO;
    }
    return YES;
}


- (BOOL)isSame:(NSString *)one two:(NSString *)two
{
    return [[one lowercaseString] isEqualToString:[two lowercaseString]];
}
- (BOOL)handleCustomURLWorkflowWithURLString:(NSDictionary *)replacements
{
    NSString * urlString = self.identifier;
    
    for(NSString * key in [replacements allKeys])
    {
        NSString * data = [replacements[key] sbr_URLEncode];
        urlString = [urlString stringByReplacingOccurrencesOfString:key withString:data];
    }
    
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    if(!url) return NO;
    
    if(![[UIApplication sharedApplication] canOpenURL:url])
    {
        return NO;
    }
    
    return [[UIApplication sharedApplication] openURL:url];
}


@end