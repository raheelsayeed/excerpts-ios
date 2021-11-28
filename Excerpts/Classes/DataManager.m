//
//  DataManager.m
//  vignettes
//
//  Created by Raheel Sayeed on 17/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "DataManager.h"
#include <Dropbox/Dropbox.h>
#import "EXOperationQueue.h"

NSString * const DataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const DataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";
NSString * const kDataManagerBundleName = @"EModel";
NSString * const kDataManagerModelName = @"EModel";
NSString * const kDataManagerSQLiteName = @"EModel.sqlite";

@interface DataManager ()
@property (nonatomic, strong, readwrite) NSManagedObjectModel *objectModel;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (NSString*)sharedDocumentsPath;


@end

@implementation DataManager



@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize objectModel = _objectModel;



+ (DataManager*)sharedInstance {
    static DataManager *sharedInstance = nil;
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
    }
    return self;
}
- (NSManagedObjectContext *)privateContext
{
    NSManagedObjectContext * moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:[_managedObjectContext persistentStoreCoordinator]];
    [moc setUndoManager:nil];
    return moc;

}
- (void)deleteAllObjectsForEntityName:(NSArray *)entityNames useMainContextForSync:(BOOL)useMainContext
{
    
    
    
    if([_managedObjectContext hasChanges])
    {
        [_managedObjectContext save:nil];
    }
    
    NSManagedObjectContext * moc;
    if(useMainContext)
    {
        moc = _managedObjectContext;
    }
    else
    {
        moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [moc setPersistentStoreCoordinator:[_managedObjectContext persistentStoreCoordinator]];
        [moc setUndoManager:nil];
    }
    
    
    for(NSString *entityName in entityNames)
    {
        NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
        [allCars setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc
                        ]];
        //[allCars setIncludesPropertyValues:NO];
        //[allCars    setIncludesSubentities:NO];
        
    
        NSError * error = nil;
        NSArray * cars = [moc executeFetchRequest:allCars error:&error];
        for (NSManagedObject * car in cars)
        {
            [moc deleteObject:car];
        }
    }


    if ([moc hasChanges]) {

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveContextToMainOnly:) name:NSManagedObjectContextDidSaveNotification object:moc];
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Error saving managed object context: %@", error);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:moc];
    }
    
}

- (void)saveContextToMainOnly:(NSNotification *)notification
{
    if(notification.object == _managedObjectContext)
    {
        
        return;
    }
    
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}


- (NSManagedObjectModel*)objectModel {
	if (_objectModel)
		return _objectModel;
    
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *modelPath = [bundle pathForResource:kDataManagerModelName ofType:@"momd"];
	_objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    
	return _objectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
	if (_persistentStoreCoordinator)
		return _persistentStoreCoordinator;
    
	NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:kDataManagerSQLiteName];
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
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
    
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(managedObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return _managedObjectContext;
	}
    
	_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return _managedObjectContext;
}
- (void)deleteAndReset{
    
    
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
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *appGroupName = @"group.com.renoteapp.ios.shared";
    
    NSURL *groupContainerURL = [fm containerURLForSecurityApplicationGroupIdentifier:appGroupName];
    
    libraryPath = [groupContainerURL path];
    
    SharedDocumentsPath = [libraryPath stringByAppendingPathComponent:@"Database"];


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
- (NSString *)syncStatus
{
    return _datastoreSyncManager.syncStatus;
}



-(BOOL)isSyncEnabled
{
    if(_datastoreSyncManager && [_datastoreSyncManager isSyncEnabled]) return YES;
    
    return NO;
}

- (void)setSyncEnabled:(BOOL)enable
{
    if(!_datastoreSyncManager && enable)
    {
        self.datastoreSyncManager = [[DatastoreSyncManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    }
    
    [_datastoreSyncManager setSyncEnabled:enable];
    
    if(!enable) self.datastoreSyncManager = nil;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(enable) forKey:kSettings_DatastoreSyncEnabled];
}

- (NSUInteger)unsyncedNoteCount
{
    return [Note unsyncedObjectCountWithMOC:self.managedObjectContext];
}
- (NSUInteger)unsyncedTagCount
{
    return [Tag unsyncedObjectCountWithMOC:self.managedObjectContext];
}

#pragma mark - Dropbox AutoImport Methods

- (BOOL)newNote:(NSString *)note tags:(NSArray *)tags
{
    Note * n = [Note entityWithText:note moc:self.managedObjectContext];
    
    if(tags)
    {
        NSSet * t = [Tag exp_fetchOrCreateTags:tags context:self.managedObjectContext];
        n.tags = t;
    }
    
    return (n) ? YES : NO ;
}

- (BOOL)startDbxFolderSync
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * tag = [defaults objectForKey:kSettings_AutoImportFilenameTag];
    NSString * syncFolderPath  = [defaults objectForKey:kSettings_AutoImportFolderPath];
    
    if((!tag || !syncFolderPath))
    {
        [self stopDbxFolderSync];
        return NO;
    }
    
    if(!_dbxFolderSyncManager)
    {
        if(![[DBAccountManager sharedManager] linkedAccount])
        {
            DLog(@"NO Dbx Account Linked");
            return NO;
        }
        self.dbxFolderSyncManager = [[DbxFolderSyncManager alloc] initWithSyncPath:syncFolderPath
                                                                     dbxFilesystem:nil
                                                                           nameTag:tag];
        if(nil == _dbxFolderSyncManager)
        {
            return NO;
        }

    }
    else
    {
        [_dbxFolderSyncManager disableAutoImport];
        [_dbxFolderSyncManager setNameTag:tag];
        [_dbxFolderSyncManager setSyncPath:syncFolderPath];
    }
    [_dbxFolderSyncManager enableAutoImport];
    return YES;
}
- (void)stopDbxFolderSync
{
    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:kSettings_AutoImport];
    [_dbxFolderSyncManager disableAutoImport];
    _dbxFolderSyncManager = nil;
    
}



@end