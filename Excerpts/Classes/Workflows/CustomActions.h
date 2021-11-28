//
//  CustomActions.h
//   Renote
//
//  Created by M Raheel Sayeed on 23/05/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Workflows.h"

static NSString const * kURLString = @"url";
static NSString const * kActionTitle = @"title";
static NSString const * kActionEnabled = @"enabled";

static NSString  * kActionsCountKey = @"customActionsCount";

@interface CustomActions : NSObject

@property (nonatomic, strong, readonly) NSMutableArray * actions;

- (NSArray *)enabledActions;
- (void)removeActionAtIndex:(NSUInteger)index;
- (void)addActionWithTitle:(NSString *)title url:(NSString *)urlStr;
- (void)saveActions;
- (void)moveItemFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex;
- (void)editActionAtIndex:(NSUInteger)index title:(NSString *)title url:(NSString *)urlStr;
- (void)enableAction:(BOOL)enable atIndex:(NSUInteger)idx;
@end
