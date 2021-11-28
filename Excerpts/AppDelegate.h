//
//  AppDelegate.h
//   Renote
//
//  Created by M Raheel Sayeed on 22/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBRCallbackParser.h"
#import "ExcerptViewController.h"

@class RWebViewController, RNWebController;
NSString *SMTEExpansionEnabled;

@class RSCollectionViewController, TagViewController, ExcerptViewController, ContainerController;
@interface AppDelegate : UIResponder <UIApplicationDelegate, SBRCallbackParserDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) RSCollectionViewController *mainViewController;
@property (nonatomic, strong) TagViewController *tagViewController;
@property (nonatomic, strong) ExcerptViewController * excerptViewController;
@property (nonatomic, strong) RWebViewController *webViewController;
@property (nonatomic)         ContainerController *containerViewController;


-(void)showEditorViewControllerWithObject:(id)object from:(id)fromController  completionBlock:(EditingCompletionBlock)completion startEditing:(BOOL)startEditing;
- (void)showGlobalWebViewWithURL:(NSURL *)url;
- (void)addSettingsObserver:(BOOL)observe;


- (UIViewController *)demo;
@end
