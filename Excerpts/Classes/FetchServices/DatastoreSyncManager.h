//
//  DatastoreSyncManager.h
//   Renote
//
//  Created by M Raheel Sayeed on 25/07/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>

static NSString * const kDatastoreSyncManagerStatusDidChangeNotification = @"DSManagerStatusDidChangeNotification";
static NSString * const kDatastoreSyncManagerIncomingChangeCountNotification = @"DSManagerIncomingChangeCountNotification";
static NSString * const kDatastoreSyncManagerStatusKey = @"status";

@interface DatastoreSyncManager : NSObject

@property (nonatomic) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, assign, getter = isSyncEnabled) BOOL syncEnabled;
@property (nonatomic) DBDatastore * tagDatastore;
@property (nonatomic, weak) DBDatastore * activeNoteStore;
@property (nonatomic) NSMutableArray * noteDatastores;

@property (nonatomic, strong, readonly) NSString * syncStatus;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)deleteDatastores;
- (void)cleanUpTags;



-(void)checkDatastores_Data_state;
@end
