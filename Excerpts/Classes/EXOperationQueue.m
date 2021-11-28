//
//  EXOperationQueue.m
//   Renote
//
//  Created by M Raheel Sayeed on 15/07/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "EXOperationQueue.h"
#import <Dropbox/DBRecord.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Excerpts.h"
#import "JDStatusBarNotification.h"
#import "Workflows.h"
#import "DataManager.h"




@implementation EXOperationQueue


+ (EXOperationQueue*)shared {
    static EXOperationQueue *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [[EXOperationQueue alloc] init];
    });
    return sharedInstance;
    
}
+ (void)cancelAllOperations
{
    [[[EXOperationQueue shared] syncOperationQueue] cancelAllOperations];

}
- (void)setPauseOperationExecution:(BOOL)pauseOperationExecution
{
    _pauseOperationExecution = pauseOperationExecution;
    [_syncOperationQueue setSuspended:pauseOperationExecution];
}
- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.syncOperationQueue.name = @"syncOperationQueue";
        self.syncOperationQueue = [NSOperationQueue new];
        [self.syncOperationQueue setMaxConcurrentOperationCount:1];
        self.syncOperationQueue.qualityOfService = NSQualityOfServiceBackground;
        [self.syncOperationQueue addObserver:self forKeyPath:@"operationCount" options:0 context:NULL];

    }
    return self;
}
- (void)dealloc
{
    [self.syncOperationQueue removeObserver:self forKeyPath:@"operationCount"];
}

+ (BOOL)idle
{
    return  ([EXOperationQueue shared].syncOperationQueue.operationCount == 0);
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == _syncOperationQueue && [keyPath isEqualToString:@"operationCount"]) {
        if (_syncOperationQueue.operationCount == 0) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 [JDStatusBarNotification dismissAnimated:YES];
             }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}

+ (NSBlockOperation *)operationEndedStatus
{
    NSBlockOperation *endOp = [NSBlockOperation blockOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [JDStatusBarNotification dismissAnimated:YES];
         }];
    }];
    endOp.qualityOfService = NSQualityOfServiceBackground;
    return endOp;
}



+ (EXOperation *)fullOutgoingForService:(EXTargetService)service mapTable:(NSMapTable *)table userInfo:(NSDictionary *)info moc:(NSManagedObjectContext *)moc
{
    EXOperation * op = [[EXOperation alloc] initWithOperation:EXOperationTypeOutgoingFull service:service mapTable:table userInfo:info moc:moc];
    return op;
}

+ (EXOperation *)outgoingOperationForService:(EXTargetService)service mapTable:(NSMapTable*)table userInfo:(NSDictionary *)info moc:(NSManagedObjectContext *)moc
{
    EXOperation * op = [[EXOperation alloc] initWithOperation:EXOperationTypeOutgoing service:service mapTable:table userInfo:info moc:moc];
    [op start];
    return op;
}


+ (EXOperation *)incomingOperationForService:(EXTargetService)target mapTable:(NSMapTable *)table userInfo:(NSDictionary *)info moc:(NSManagedObjectContext *)moc
{
    EXOperation *op = [[EXOperation alloc] initWithOperation:EXOperationTypeIncoming service:target mapTable:table userInfo:info moc:moc];
    [[[EXOperationQueue shared] syncOperationQueue] addOperation:op];
    return op;
}

+ (NSInvocationOperation *)uploadOperationToFilePath:(NSString *)filePath writeData:(id)data service:(EXTargetService)service
{
    NSDictionary * userInfo = @{kWF_FILENAME_VARIABLE: filePath,
                                kWF_NOTE_VARIABLE: data};
    
    NSInvocationOperation * op = [[NSInvocationOperation alloc] initWithTarget:[EXOperationQueue shared] selector:@selector(uploadFileToDropboxWithUserInfo:) object:userInfo];
    [[[[self class] shared] syncOperationQueue] addOperation:op];
//    [[NSOperationQueue mainQueue] addOperation:op];
    return op;
}

- (void)uploadFileToDropboxWithUserInfo:(NSDictionary *)userInfo
{

    
    
    if(![[DBAccountManager sharedManager] linkedAccount]) return;
    
    
    DBPath *newPath = [[DBPath root] childPath:userInfo[kWF_FILENAME_VARIABLE]];
    DBError *error = nil;
    DBFilesystem * fileSystem = [DBFilesystem sharedFilesystem];
    if(!fileSystem) return;
    
    DBFile * dbFile  = [fileSystem openFile:newPath error:&error];
    if(dbFile)
    {
        [self writeToDropboxFile:dbFile data:userInfo[kWF_NOTE_VARIABLE]];
        [dbFile update:&error];
        
    }
    else
    {
//        DLog(@"Error when creating file %@ in Dropbox, error description: %@", newPath.stringValue, error);
        if(error.code == DBErrorNotFound)
        {
            dbFile = [fileSystem createFile:newPath error:&error];
            
            if(dbFile)
            {
                [self writeToDropboxFile:dbFile data:userInfo[kWF_NOTE_VARIABLE]];
                
            }
            else
            {
                DLog(@"Failed Creating File");
            }
        }
    }


}
- (void)dropboxFileOperationStatus:(DBFileState)state
{
    DLog(@" %u", state);
    if(state == DBFileStateIdle)
    DLog(@"DONE");
}
- (void)writeToDropboxFile:(DBFile *)file data:(id)data
{
    
    
    
    DBError *error = nil;
    if ([file writeString:data error:&error])
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [JDStatusBarNotification showWithStatus:@"Saved To Dropbox" styleName:JDStatusBarStyleSuccess];
             [JDStatusBarNotification dismissAfter:1.0];
         }];
     
        [file close];


    }
    else
    {
        DLog(@"Error when writing file %@ in Dropbox, error description: %@", file.description, error);
        [file close];


    }
    return;


    
}



@end

//#############################################################################################//

 NSString * const kSyncEntitiesKey = @"entities";
 NSString * const kIncomingDataKey = @"incomingData";
 NSString * const kActiveDatastoreIdKey = @"activeDatastoreId";
 NSString * const kOutgoingDataKey = @"outgoingData";
static NSString * const kSyncAttributeName = @"syncID";



@interface EXOperation ()
{
    NSUInteger countOfObjectsToChange;
}
@end


@implementation EXOperation

- (instancetype)initWithOperation:(EXOperationType)type service:(EXTargetService)service mapTable:(NSMapTable*)table userInfo:(NSDictionary *)info moc:(NSManagedObjectContext *)moc
{
    self = [super init];
    if(self)
    {
        countOfObjectsToChange = 0;
        self.operationType = type;
        self.map = table;
        self.userInfo = info;
        self.targetService = service;
        self.managedObjectContext = moc;
    }
    return self;
}




- (void)main {
    
    if ([self isCancelled]) return;
    
    switch (_operationType) {
            
        case EXOperationTypeIncoming:
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 [JDStatusBarNotification showWithStatus:@"updating.." styleName:JDStatusBarStyleDark];
             }];
            [self handleIncomingOperation];
        }
            break;
            
            
        case EXOperationTypeOutgoing:
        
            
            [self handleOutgoingOperation];
            
            break;
            
            
        case EXOperationTypeOutgoingFull:
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 [JDStatusBarNotification showWithStatus:@"sending.." styleName:JDStatusBarStyleDark];
             }];
         
            NSError *error = nil;
            [self outgoingFull:&error];
        }
            break;
            
            
        default:
            break;
    }
    
    
    
     
    if ([self isCancelled]) return;

}




- (void)incomingDataFromDatastore
{
    NSDictionary * changes = _userInfo[kIncomingDataKey];
    NSString * datastoreID = _userInfo[kActiveDatastoreIdKey];
    
    [self updateCoreDataWithDatastoreChanges:changes fromDatastoreID:datastoreID];
}



-(void)updateCoreDataWithDatastoreChanges:(NSDictionary *)changes fromDatastoreID:(NSString *)datastoreID
{
//    static NSString * const UpdateManagedObjectKey = @"object";
//    static NSString * const UpdateRecordKey = @"record";

    if ([changes count] == 0) return;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [JDStatusBarNotification showWithStatus:@"updating.." styleName:JDStatusBarStyleDark];
     }];
    
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
    [moc setUndoManager:nil];
    
    __weak typeof(self) weakSelf = self;
    
    
    
    
    [changes enumerateKeysAndObjectsUsingBlock:^(NSString *tableID, NSArray *records, BOOL *stop)
    {
        
        if ([self isCancelled]) return;
        if(![[[self class] syncable_Coredata_Entities] containsObject:tableID]) return;

        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        NSInteger currentRecord = 0;
        NSInteger  recCount = records.count;
        NSNumber *datastoreNumber = [weakSelf datastoreNumberFromDatastoreId:datastoreID];
        
        
        
        countOfObjectsToChange += recCount;

        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:tableID];
        //[fetchRequest setIncludesSubentities:NO];
        //[fetchRequest setIncludesPropertyValues:NO];
        [fetchRequest setFetchLimit:1];
        
        for (DBRecord *record in records)
        {
            currentRecord++;

            if ([self isCancelled]) return;

            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", kSyncAttributeName, record.recordId]];
            NSError *error = nil;
            NSArray *existingObjects = [moc executeFetchRequest:fetchRequest error:&error];
            
            
            if(existingObjects)
            {
                NSManagedObject *managedObject = [existingObjects lastObject];
                
                if ([record isDeleted] && managedObject)
                {
                        [moc deleteObject:managedObject];
                }
                else
                {
                    if (!managedObject)
                    {
                        managedObject = [NSEntityDescription insertNewObjectForEntityForName:tableID inManagedObjectContext:moc];
                        [managedObject setValue:record.recordId forKey:kSyncAttributeName];
                    }
                    
                    [managedObject updateFromDBRecord:record];
                    [managedObject assignDatastoreIdentifier:datastoreNumber];
                    [managedObject synced];

                    [[NSOperationQueue mainQueue] addOperationWithBlock:^
                     {
                         [JDStatusBarNotification showProgress:((float)(float)currentRecord/(float)recCount)];
                     }];

                 
                }
            } else
            {
                NSLog(@"Error executing fetch request: %@", error);
            }

        }
    }];
    
    if ([moc hasChanges])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncManagedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
        NSError *error = nil;
        if (![moc save:&error])
        {
            NSLog(@"Error saving managed object context: %@", error);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:moc];
        
    }
    
}


- (void)refreshObjects:(NSSet *)objects
{
    for(NSManagedObject *object in objects) {
        [[self.managedObjectContext objectWithID:[object objectID]] willAccessValueForKey:nil];
    }
}
- (void)syncManagedObjectContextDidSave:(NSNotification *)notification
{
    if(self.operationType == EXOperationTypeIncoming)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kDatastoreSyncManagerIncomingChangeCountNotification object:@(countOfObjectsToChange) userInfo:@{@"storeTitle":_userInfo[@"storeTitle"]}];
        }];
        
    }
    NSSet * updated = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    [self performSelectorOnMainThread:@selector(refreshObjects:) withObject:updated waitUntilDone:NO];
    
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
}
- (void)mergeContextsDidSaveWithoutObjectRefresh:(NSNotification *)note
{
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:note waitUntilDone:YES];
}



- (void)handleIncomingOperation
{
    if(_targetService == EX_DROPBOX)
    {
        [self incomingDataFromDatastore];
    }
}
- (void)handleOutgoingOperation
{
    if(_targetService == EX_DROPBOX)
    {
        [self sendToDropboxDatastores];
    }
}


- (BOOL)outgoingFull:(NSError **)error
{
    
    __block BOOL result = YES;
    
 
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
    [moc setUndoManager:nil];
    
    
    NSArray * tablesByEntityName = [[_map  keyEnumerator] allObjects];
    
    [tablesByEntityName enumerateObjectsUsingBlock:^(NSString *entityName , NSUInteger idx, BOOL *stop)
    {

        static NSString *  const kLastSyncedAttribute = @"lastSynced";

        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == %@",kLastSyncedAttribute ,@(NO)]];
        NSArray *managedObjects = [moc executeFetchRequest:fetchRequest error:error];
        if(!managedObjects) //stop enumeration, somethingswrong.
        {
            result = NO;
            *stop = YES;
            return;
        }
        NSInteger count = managedObjects.count;
        NSInteger index = 0;
        for (NSManagedObject *managedObject in managedObjects)
        {

            DBDatastore * store =  [_map objectForKey:entityName];
            DBTable *table = [store getTable:entityName];
            DBError *dberror = nil;
            BOOL new = NO;
            DBRecord *record = [table getOrInsertRecord:[managedObject valueForKey:kSyncAttributeName] fields:nil inserted:&new error:&dberror];
            if(record)
            {                
                [managedObject updateDBRecord:record empty:YES]; //sending everything, so dont bother check if dbrecord is new.
                [managedObject assignDatastoreIdentifier:[self datastoreNumberFromDatastoreId:store.datastoreId]];
                [managedObject setValue:@YES forKey:kLastSyncedAttribute];
            }
            else
            {
                if (error)
                {
                    *error = [NSError errorWithDomain:[dberror domain] code:[dberror code] userInfo:[dberror userInfo]];
                }
                result = NO;
                *stop = YES;
            }
            
            index += 1;
            
            if (index % 20 == 0)
            {
                [self syncDatastoresInMapTable:_map];
            }

            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 [JDStatusBarNotification showProgress:((float)(float)index/(float)count)];
             }];
        
            

            
        }
    }];
    
    
    if(result)
    {
        DBError * dberror = nil;
        for(DBDatastore * store in [[_map objectEnumerator] allObjects])
        {
            if(!store.unsyncedChangesSize==0)[store sync:&dberror];
        }

        if(dberror)
        {
            if (error) *error = [NSError errorWithDomain:[dberror domain] code:[dberror code] userInfo:[dberror userInfo]];
            return NO;
        }
        
        
        if ([moc hasChanges])
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeContextsDidSaveWithoutObjectRefresh:) name:NSManagedObjectContextDidSaveNotification object:moc];
            NSError *error = nil;
            if (![moc save:&error])
            {
                NSLog(@"Error saving managed object context: %@", error);
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:moc];
        }
        
        
        
    }else
    {
        return NO;
    }
    return YES;
    
}



- (BOOL)sendToDropboxDatastores
{
    if(!_map) return NO;
    
    
    NSManagedObjectContext * moc = self.managedObjectContext;
    
    NSMutableSet *managedObjects = [[NSMutableSet alloc] init];
    
    
    [managedObjects unionSet:[moc insertedObjects]];
    [managedObjects unionSet:[moc updatedObjects]];
    [managedObjects unionSet:[moc deletedObjects]];
    
    
    
    
    
    NSSet * syncableObjects = [managedObjects objectsPassingTest:^BOOL(NSManagedObject * obj, BOOL *stop) {
        return ([[self.class syncable_Coredata_Entities] containsObject:obj.entity.name]);
    }];
    
    
    
    
    [managedObjects removeAllObjects];
    managedObjects = nil;
    
    
    NSUInteger index = 0;
    
    
    for(NSManagedObject * managedObject in syncableObjects)
    {
//        NSLog(@"Entity: %@", managedObject.entity.name );

        if(managedObject.isDeleted)         [self sendDeletedObject:managedObject];
        else if(managedObject.isUpdated)    [self sendUpdatedObject:managedObject];
        else                                [self sendNewObject:managedObject];
        index++;
        
        if (index % 20 == 0)
        {
            [self syncDatastoresInMapTable:_map];
        }
        [managedObject synced];
        
    }
    for(DBDatastore * store in [[_map objectEnumerator] allObjects])
    {
          if(!store.unsyncedChangesSize==0)[store sync:nil];
    }
    
    return YES;
    
}

- (BOOL)sendDeletedObject:(NSManagedObject*)deletedObject
{
//    NSLog(@" DELETING: %@", [[deletedObject entity] name]);

    
    DBDatastore * datastore = [self datastoreForObject:deletedObject];
    
    DBTable *table = [datastore getTable:[[deletedObject entity] name]];
    DBError *error = nil;
    NSString * syncID = [deletedObject primitiveValueForKey:kSyncAttributeName];
    if(!syncID)
    {
        return NO;
    }
    DBRecord *record = [table getRecord:syncID error:&error];
    if (record)
    {
        [record deleteRecord];
    }
    else if (error)
    {
        NSLog(@"Error getting datastore record: %@", error);
    }
    
    return YES;
}
- (BOOL)sendNewObject:(NSManagedObject*)newObject
{
//    NSLog(@" NEW_ADDING: %@", [[newObject entity] name]);

    DBDatastore * ds = [_map objectForKey:[[newObject entity] name]];
    
    NSArray * params = [ds.datastoreId componentsSeparatedByString:@"_"];
    if(params.count > 1)
    {
        NSString * dbxIdentifier = params[1];
        [newObject assignDatastoreIdentifier:@([dbxIdentifier integerValue])];
    }
    else
    {
        [newObject assignDatastoreIdentifier:@0];
    }
    
    [self updateDatastoreWithManagedObject:newObject inDatastore:ds];
    
    return YES;
}



- (BOOL)sendUpdatedObject:(NSManagedObject *)updatedObject
{
//    NSLog(@" UPDATING: %@", [[updatedObject entity] name]);
    
    [self updateDatastoreWithManagedObject:updatedObject inDatastore:[self datastoreForObject:updatedObject]];
    return YES;
}

- (DBDatastore *)datastoreForObject:(NSManagedObject *)object
{
    NSString * datastoreID = [self datastoreIDForObject:object];
    if(!datastoreID) return nil;
    
    DBDatastore * datastore = [_map objectForKey:datastoreID];
    
    if(!datastore)
    {
        NSString * entityName =   [[object entity] name];

        datastore = [_map objectForKey:entityName];
        NSArray * params = [datastore.datastoreId componentsSeparatedByString:@"_"];
        if(params.count > 1)
        {
            NSString * dbxIdentifier = params[1];
            [object assignDatastoreIdentifier:@([dbxIdentifier integerValue])];
        }
    }
    
    return datastore;
    
}
- (NSString *)datastoreIDForObject:(NSManagedObject *)object
{
    NSString * entity = [[object entity] name];
    
    NSString * datastoreID = _userInfo[entity];
    
    if(!datastoreID) return nil;

    NSUInteger cloudLoc = [[object dataStoreIdentifier] integerValue];
    
    if(cloudLoc > 0) datastoreID = [datastoreID stringByAppendingFormat:@"_%lu", (unsigned long)cloudLoc];
    
    return datastoreID;

}
- (NSNumber *)datastoreNumberFromDatastoreId:(NSString *)dsID
{
    NSArray * arr = [dsID componentsSeparatedByString:@"_"];
    if(arr.count > 1)
    {
        NSNumber * number =   [NSNumber numberWithInteger:[arr[1] integerValue]];
        return number;
    }
    return nil;
}


- (void)syncDatastoresInMapTable:(id)map
{
    NSMapTable * m = (NSMapTable *)map;
    
    for(NSString * entityName in [[self class] syncable_Coredata_Entities])
    {
        DBDatastore * store = [m objectForKey:entityName];
        
        if(store.unsyncedChangesSize > (DBDatastoreUnsyncedChangesSizeLimit * 0.90))
        {
            DBError * error = nil;
            [store sync:&error];
            if(error)
            {
                DLog(@"%@", error.description);
            }
        }
        
        
        if(!store.unsyncedChangesSize == 0)
        {
        }
        
    }

    
}

+ (NSArray *)syncable_Coredata_Entities
{
    static NSArray *_syncable_Coredata_Entities;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _syncable_Coredata_Entities = @[@"Tag",@"Note"];
    });
    return _syncable_Coredata_Entities;
}



- (void)updateDatastoreWithManagedObject:(NSManagedObject *)managedObject inDatastore:(DBDatastore *)datastore
{
    NSString *tableID =  [[managedObject entity] name];
    DBTable *table = [datastore getTable:tableID];
    DBError *error = nil;
    BOOL inserted = NO;
    DBRecord *record = [table getOrInsertRecord:[managedObject valueForKey:kSyncAttributeName] fields:nil inserted:&inserted error:&error];
    if (record)
    {
        [managedObject updateDBRecord:record empty:inserted];
    }
    else
    {
        DLog(@"Error getting or inserting datatore record: %@", error);
    }
}


@end
