//
//  DataManager.h
//  vignettes
//
//  Created by Raheel Sayeed on 17/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SyncManager.h"


extern NSString * const DataManagerDidSaveNotification;
extern NSString * const DataManagerDidSaveFailedNotification;

@interface DataManager : NSObject
@property (nonatomic) BOOL is_ipad;
@property (nonatomic, strong)  SyncManager *syncManager;
@property (nonatomic, strong, readonly) NSManagedObjectModel *objectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DataManager*)sharedInstance;
- (BOOL)save;
- (void)deleteAndReset;
- (NSManagedObjectContext*)managedObjectContext;
- (NSString*)sharedDocumentsPath;
- (void)deleteAllObjectsForEntityName:(NSArray *)entityNames;
- (void)setSyncEnabled:(BOOL)enabled;
- (BOOL)isSyncEnabled;
@end
