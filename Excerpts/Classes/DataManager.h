//
//  DataManager.h
//  vignettes
//
//  Created by Raheel Sayeed on 17/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DbxFolderSyncManager.h"
#import "DatastoreSyncManager.h"
#import "Tag.h"
#import "Note.h"
#import "Link.h"
#import "CachedLinkData.h"


extern NSString * const DataManagerDidSaveNotification;
extern NSString * const DataManagerDidSaveFailedNotification;

@class DbxFolderSyncManager, DatastoreSyncManager;
@interface DataManager : NSObject
@property (nonatomic, strong, readonly) NSManagedObjectModel *objectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, weak) NSFetchedResultsController * tagsFetchController;
@property (nonatomic, strong) DbxFolderSyncManager * dbxFolderSyncManager;
@property (nonatomic, strong) DatastoreSyncManager * datastoreSyncManager;

- (NSString *)syncStatus;


+ (DataManager*)sharedInstance;
- (NSManagedObjectContext *)privateContext;
- (BOOL)save;
- (void)deleteAndReset;
- (void)deleteAllObjectsForEntityName:(NSArray *)entityNames useMainContextForSync:(BOOL)useMainContext;
- (BOOL)newNote:(NSString *)note tags:(NSArray *)tags;
- (NSString*)sharedDocumentsPath;

- (void)setSyncEnabled:(BOOL)enabled;
- (BOOL)isSyncEnabled;

- (BOOL)startDbxFolderSync;
- (void)stopDbxFolderSync;

- (NSUInteger)unsyncedNoteCount;
- (NSUInteger)unsyncedTagCount;


@end
