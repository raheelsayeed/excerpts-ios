//
//  ActionMethods.h
//   Renote
//
//  Created by M Raheel Sayeed on 03/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EXOperationQueue.h"
#import "ReorderViewController.h"
#import "IOTableViewController.h"
#import "SVWebViewController.h"

@interface ActionMethods : NSObject

//Markdown
+ (NSString *)parseMarkdownToHTML:(NSString *)markdown;
+ (UIViewController *)webControllerForMarkdownFilename:(NSString *)resourceFileName cssFileName:(NSString *)cssFileName varReplacements:(NSDictionary *)replacements;


+ (BOOL)action_AddURLTOReadingList:(NSURL *)url;


//Pasteboard
+ (NSString *)lastObjectFromPasteboard;
+ (void)addToClipboard:(id)object;


+ (NSString *)linksForString:(NSString *)string;
+ (NSArray *)linksFromString:(NSString *)string;


+ (void)uploadFileAtPath:(NSString *)path data:(id)data;

//Reorder
+ (UINavigationController *)reorderParagraphsInText:(NSString *)text;
@end
