//
//  DataManager.m
//  vignettes
//
//  Created by Raheel Sayeed on 17/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "DataManager.h"
#include <Dropbox/Dropbox.h>
#include  "SyncManager.h"
#include  "Excerpt.h"
#import   "Tag.h"
#include "NSManagedObject+Excerpts.h"
NSString * const DataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const DataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";

@interface DataManager ()

- (NSString*)sharedDocumentsPath;

@end

@implementation DataManager
NSString * const kDataManagerBundleName = @"EModel";
NSString * const kDataManagerModelName = @"EModel";
NSString * const kDataManagerSQLiteName = @"EModel.sqlite";

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize objectModel = _objectModel;
@synthesize is_ipad;

static DataManager *sharedInstance = nil;


+ (DataManager*)sharedInstance {
    
       static dispatch_once_t onceToken;
       dispatch_once(&onceToken, ^{ sharedInstance = [[DataManager alloc] init]; });
    return sharedInstance;

}

- (void)dealloc {
	[self save];
}
-(id)init{
    
    if([super init])
    {
        is_ipad = isIPad;
    }
    return self;
}
- (void)deleteAllObjectsForEntityName:(NSArray *)entityNames
{
    /*
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:[_managedObjectContext persistentStoreCoordinator]];
    [moc setUndoManager:nil];
    */
    
    for(NSString *entityName in entityNames)
    {
        NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
        [allCars setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:_managedObjectContext
                        ]];
        [allCars setIncludesPropertyValues:NO];
    
        NSError * error = nil;
        NSArray * cars = [_managedObjectContext executeFetchRequest:allCars error:&error];
        for (NSManagedObject * car in cars)
        {
            [_managedObjectContext deleteObject:car];
        }
    }


    if ([_managedObjectContext hasChanges]) {
        NSError *error = nil;
        if (![_managedObjectContext save:&error]) {
            NSLog(@"Error saving managed object context: %@", error);
        }
    }
    
    
    
    /*
     NSManagedObjectContext *deleteContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
     // Get a new PSC for the same store
     deleteContext.persistentStoreCoordinator = getInstanceOfPersistentStoreCoordinator();
     
     // Each call to performBlock executes in its own autoreleasepool, so we don't
     // need to explicitly use one if each chunk is done in a separate performBlock
     __block void (^block)(void) = ^{
     NSFetchRequest *fetchRequest =  [[NSFetchRequest alloc] initWithEntityName:@"Tag"];//
     // Only fetch the number of objects to delete this iteration
     fetchRequest.fetchLimit = 20;
     // Prefetch all the relationships
     fetchRequest.relationshipKeyPathsForPrefetching = prefetchRelationships;
     // Don't need all the properties
     fetchRequest.includesPropertyValues = NO;
     NSArray *results = [deleteContext executeFetchRequest:fetchRequest error:&error];
     if (results.count == 0) {
     // Didn't get any objects for this fetch
     if (nil == results) {
     // Handle error
     }
     return;
     }
     for (MyEntity *entity in results) {
     [deleteContext deleteObject:entity];
     }
     [deleteContext save:&error];
     [deleteContext reset];
     
     // Keep deleting objects until they are all gone
     [deleteContext performBlock:block];
     };
     
     [deleteContext preformBlock:block];
     */
    
}


- (NSManagedObjectModel*)objectModel {
	if (_objectModel)
		return _objectModel;
    
	NSBundle *bundle = [NSBundle mainBundle];
	//if (kDataManagerBundleName) {
	//	NSString *bundlePath = [[NSBundle mainBundle] pathForResource:kDataManagerBundleName ofType:@"bundle"];
	//	bundle = [NSBundle bundleWithPath:bundlePath];
	//}
	NSString *modelPath = [bundle pathForResource:kDataManagerModelName ofType:@"momd"];
	_objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    
	return _objectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
	if (_persistentStoreCoordinator)
		return _persistentStoreCoordinator;
    
	// Get the paths to the SQLite file
	NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:kDataManagerSQLiteName];
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
	// Define the Core Data version migration options
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    
	// Attempt to load the persistent store
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
		NSLog(@"Fatal error while creating persistent store: %@", error);
		abort();
	}
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext*)managedObjectContext {
	if (_managedObjectContext)
		return _managedObjectContext;
    
	// Create the main context only on the main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(managedObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return _managedObjectContext;
	}
    
	_managedObjectContext = [[NSManagedObjectContext alloc] init];
	[_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return _managedObjectContext;
}
- (void)deleteAndReset{
    NSError * error = nil;
    // retrieve the store URL
    NSURL * storeURL = [[_managedObjectContext persistentStoreCoordinator] URLForPersistentStore:[[[_managedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    [_managedObjectContext lock];
    [_managedObjectContext reset];//to drop pending changes
    //delete the store from the current managedObjectContext
    if ([[_managedObjectContext persistentStoreCoordinator] removePersistentStore:[[[_managedObjectContext persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        [[_managedObjectContext persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
    }
    [_managedObjectContext unlock];
}

- (BOOL)save {
	if (![self.managedObjectContext hasChanges])
		return YES;
    
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
		[[NSNotificationCenter defaultCenter] postNotificationName:DataManagerDidSaveFailedNotification
                                                            object:error];
		return NO;
	}
    
	[[NSNotificationCenter defaultCenter] postNotificationName:DataManagerDidSaveNotification object:nil];
	return YES;
}

- (NSString*)sharedDocumentsPath {
	static NSString *SharedDocumentsPath = nil;
	if (SharedDocumentsPath)
		return SharedDocumentsPath;
    
	// Compose a path to the <Library>/Database directory
	NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	SharedDocumentsPath = [libraryPath stringByAppendingPathComponent:@"Database"];
    
	// Ensure the database directory exists
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL isDirectory;
	if (![manager fileExistsAtPath:SharedDocumentsPath isDirectory:&isDirectory] || !isDirectory) {
		NSError *error = nil;
		NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
		[manager createDirectoryAtPath:SharedDocumentsPath
		   withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
		if (error)
			NSLog(@"Error creating directory path: %@", [error localizedDescription]);
	}
    
	return SharedDocumentsPath;
}

-(BOOL)isSyncEnabled
{
    return (nil != self.syncManager);
}

- (void)setSyncEnabled:(BOOL)enabled
{
    DBAccountManager *accountManager = [DBAccountManager sharedManager];
    
    if (enabled) {
        DLog(@"Enabled");
        if (!self.syncManager) {
            DBAccount *account = [accountManager linkedAccount];
            
            if (account) {
                DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
                [DBFilesystem setSharedFilesystem:filesystem];

                __weak typeof(self) weakSelf = self;
                [accountManager addObserver:self block:^(DBAccount *account) {
                 

                    typeof(self) strongSelf = weakSelf; if (!strongSelf) return;
                    if (![account isLinked]) {
                        [strongSelf setSyncEnabled:NO];
                        NSLog(@"Unlinked account: %@", account);
                    }
                }];
                
                DBError *dberror = nil;
                DBDatastore *datastore = [DBDatastore openDefaultStoreForAccount:account error:&dberror];
                if (datastore) {
                    self.syncManager = [[SyncManager alloc] initWithManagedObjectContext:self.managedObjectContext datastore:datastore];
                    NSError *error = nil;
                        if ([[datastore getTables:nil] count] == 0) {
                        if (![self updateDropboxFromCoreData:&error]) {
                            NSLog(@"Error updating Dropbox from Core Data: %@", error);
                        }else{
                            DLog(@"sending.. to dropbox");
                        }
                    }
                } else {
                    NSLog(@"Error opening default datastore: %@", dberror);
                }
            }
        }
       
        [self.syncManager startObserving];
    } else {
        [[DBFilesystem sharedFilesystem] removeObserver:self];
        [self.syncManager stopObserving];
        self.syncManager = nil;
        [accountManager removeObserver:self];
    }
}


- (BOOL)updateDropboxFromCoreData:(NSError **)error
{
    __block BOOL result = YES;
    NSManagedObjectContext *managedObjectContext = self.syncManager.managedObjectContext;
    DBDatastore *datastore = self.syncManager.datastore;
    NSString *syncAttributeName = self.syncManager.syncAttributeName;
    
    NSDictionary *tablesByEntityName = @{@"Excerpt": @"Excerpt", @"Tag" : @"Tag"};
    [tablesByEntityName enumerateKeysAndObjectsUsingBlock:^(NSString *entityName, NSString *tableId, BOOL *stop) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        [fetchRequest setFetchBatchSize:25];
        
        NSArray *managedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:error];
        if (managedObjects) {
            for (NSManagedObject *managedObject in managedObjects) {
      
                //:::
                if(![managedObject canSyncToDropboxDatastore])
                {
                    DLog(@"canSyncToDB=NO = %@", [[managedObject entity] name]);
                    continue;
                }
                /*
                if([managedObject isKindOfClass:[Tag class]] && ![(Tag *)managedObject canSyncToDropboxDatastore])
                    
                     continue;
                */
       
                DLog(@"SENDING>>>>");
                DBTable *table = [datastore getTable:tableId];
                DBError *dberror = nil;
                DBRecord *record = [table getOrInsertRecord:[managedObject valueForKey:syncAttributeName] fields:nil inserted:NULL error:&dberror];
                if (record) {
                    [managedObject updateDBRecord:record];
                } else {
                    if (error) {
                        *error = [NSError errorWithDomain:[dberror domain] code:[dberror code] userInfo:[dberror userInfo]];
                    }
                    result = NO;
                    *stop = YES;
                }
            }
        } else {
            *stop = YES;
        }
    }];
    
    if (result) {
        DBError *dberror = nil;
        if ([datastore sync:&dberror]) {
            return YES;
        } else {
            if (error) *error = [NSError errorWithDomain:[dberror domain] code:[dberror code] userInfo:[dberror userInfo]];
            return NO;
        }
    } else {
        return NO;
    }
}


@end