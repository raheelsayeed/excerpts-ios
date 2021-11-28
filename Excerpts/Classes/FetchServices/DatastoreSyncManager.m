//
//  DatastoreSyncManager.m
//   Renote
//
//  Created by M Raheel Sayeed on 25/07/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "DatastoreSyncManager.h"
#import <CoreData/CoreData.h>
#import "EXOperationQueue.h"
#import "DataManager.h"
#import "MRModalAlertView.h"

NSString * const kTagEntityName  = @"Tag";
NSString * const kNoteEntityName = @"Note";
NSString * const kSyncAttributeIdentifier = @"syncID";
NSString * const noteStoreID = @"notestore";
NSString * const tagStoreID  = @"tagstore";
NSUInteger const DSMDatastoreBuffer = 524228;
NSUInteger const DSB_ONE_MB          = 1048576;





@interface DatastoreSyncManager () <UIAlertViewDelegate>
{
    NSManagedObjectContext * _backgroundContext;
    UIAlertController *_alertController;
}
@property (nonatomic, strong, readwrite) NSString * syncStatus;
@property (nonatomic, assign) BOOL finishCheckingForEmptyDatastores;
@property (nonatomic) UIViewController * pleaseWaitController;

@end

@implementation DatastoreSyncManager

#pragma mark - Initialiasers

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.syncStatus = @"Inactive";
        self.finishCheckingForEmptyDatastores = NO;
        
    }
    return self;
}
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self = [self init];
    if(self)
    {
        self.managedObjectContext = managedObjectContext;
    }
    return self;
}

- (void)setSyncEnabled:(BOOL)syncEnabled
{
    if(syncEnabled && self.isSyncEnabled) return;
    
    static NSString * noteStoreName = @"Note";
    static NSString * tagStoreName  = @"Tag";
    _syncEnabled = syncEnabled;
    DBAccountManager *accountManager = [DBAccountManager sharedManager];
    if(syncEnabled)
    {
        self.finishCheckingForEmptyDatastores = NO;
        self.noteDatastores = nil;
        self.noteDatastores = [NSMutableArray new];
        DBAccount *account = [accountManager linkedAccount];
        if (account)
        {
            __weak typeof(self) weakSelf = self;
            [accountManager addObserver:self block:^(DBAccount *account)
             {
                 typeof(self) strongSelf = weakSelf; if (!strongSelf) return;
                 if (![account isLinked])
                 {
                     [strongSelf setSyncEnabled:NO];
                     NSLog(@"Unlinked account: %@", account);
                 }
             }];
            DBDatastoreManager * dsManager = [DBDatastoreManager managerForAccount:account];
            [DBDatastoreManager setSharedManager:dsManager];
            [dsManager addObserver:self block:^{
               [weakSelf  observeDatastoreManagerForChanges];
            }];
            
            DBError *dberror = nil;
            if(![self continueAfterError:dberror]) {[self setSyncEnabled:NO];return;}
            
            //tag store
            self.tagDatastore = [dsManager openOrCreateDatastore:tagStoreID error:&dberror];
            if(!_tagDatastore.title) _tagDatastore.title = tagStoreName;
            
            if(![self continueAfterError:dberror]) {[self setSyncEnabled:NO];return;}
            
            

            
            NSArray * allnotestores = [[dsManager listDatastores:&dberror] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"datastoreId CONTAINS 'notestore'"]];
            
            if(!allnotestores || allnotestores.count == 0)
            {
                //Always Grab the first store.
                DBDatastore * noteStore = [dsManager openOrCreateDatastore:[self noteStoreNameFromCount:0] error:&dberror];
                if(!noteStore.title) noteStore.title = noteStoreName;
                if(![self continueAfterError:dberror]) {[self setSyncEnabled:NO];return;}
                [self addNoteDatastoresObject:noteStore];
            }
            else
            {
                [allnotestores enumerateObjectsUsingBlock:^(DBDatastoreInfo * storeInfo, NSUInteger idx, BOOL *stop) {

                    DBError * error = nil;
                    DBDatastore * notestore  = [dsManager openDatastore:storeInfo.datastoreId error:&error];
                    if(!notestore.title) notestore.title = noteStoreName;
                    [self addNoteDatastoresObject:notestore];
                }];
            }
            
//            NSLog(@"Allstore Count = %lu", (unsigned long)self.noteDatastores.count);
            
            BOOL shouldCreateNew = [self shouldCreateNewNotestore];
            if(shouldCreateNew)
            {
//                NSLog(@"CREATING A NEW NOTESTORE");
                DBDatastore * notestoreNew = [dsManager openOrCreateDatastore:[self noteStoreNameFromCount:self.noteDatastores.count]
                                                                        error:&dberror];
                notestoreNew.title = noteStoreName;
                [self addNoteDatastoresObject:notestoreNew];
            }
            

            
            
            [self initialCheckAndUpload];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextWillSave:) name:NSManagedObjectContextWillSaveNotification object:self.managedObjectContext];
        }
        else
        {
            DLog(@"NO DROPBOX ACCOUNT");
        }

    }
    else
    {
        [EXOperationQueue cancelAllOperations];
        [_noteDatastores makeObjectsPerformSelector:@selector(removeObserver:) withObject:self];
        [_tagDatastore removeObserver:self];
        _tagDatastore = nil;
        [_noteDatastores removeAllObjects];
        _noteDatastores = nil;

        [[DBDatastoreManager sharedManager] removeObserver:self];
        [[DBDatastoreManager sharedManager] shutDown];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:self.managedObjectContext];
        [accountManager removeObserver:self];
        _finishCheckingForEmptyDatastores = NO;
    }
    
}
- (NSString *)noteStoreNameFromCount:(NSUInteger)count
{
    return [noteStoreID stringByAppendingFormat:@"_%lu", (unsigned long)count+1];
}
- (void)observeDatastoreManagerForChanges
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        
        DBError *dberror = nil;
        NSArray * allnotestores = [[[DBDatastoreManager sharedManager] listDatastores:&dberror] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"datastoreId CONTAINS 'notestore'"]];
        for(DBDatastoreInfo * storeInfo in allnotestores)
        {
            DBError * error = nil;
            DBDatastore * notestore = [[DBDatastoreManager sharedManager] openDatastore:storeInfo.datastoreId
                                                                                  error:&error];
            

            if(error.dbErrorCode == DBErrorAlreadyOpen) continue;
            
            if(notestore && !error)
            {
                [weakSelf addNoteDatastoresObject:notestore];
                [weakSelf beginObservingDatastore:notestore];
            }
            
        }
    });
}




- (void)initialCheckAndUpload
{
    [self startObserving_TagDatastore];
    [self startObserving_NoteDatastores];
}



- (NSString *)description
{

    NSMutableString * str = [NSMutableString new];
    
    [str appendFormat:@"%@ title=%@ size=%lu status=%@\n\n", _tagDatastore.datastoreId, _tagDatastore.title, (unsigned long)_tagDatastore.size , _tagDatastore.status.description ];
    
    
    for(DBDatastore *ds in _noteDatastores)
    {
        [str appendFormat:@"%@ title=%@ size=%lu status=%@\n\n", ds.datastoreId, ds.title, (unsigned long)ds.size, ds.status.description];
    }
    
    [str appendFormat:@"ActiveNoteStore = %@ title=%@", _activeNoteStore.datastoreId, _activeNoteStore.title];
    
    return [str copy];
    
}

- (void)startObserving_NoteDatastores
{
    __weak typeof (self)  weakS = self;
    [_noteDatastores enumerateObjectsUsingBlock:^(DBDatastore *store, NSUInteger idx, BOOL *stop)
    {
        [weakS beginObservingDatastore:store];
    }];
}
- (void)checkstatus:(DBDatastore *) store
{
    
    DBDatastoreStatus * status = store.status;
    NSLog(@"================= %@: ==================\n", store.datastoreId);
    NSLog(@"         connected  =%@\n", status.connected ? @"YES" : @"NO" ) ;
    NSLog(@"         downloading=%@\n", status.downloading ? @"YES" : @"NO" ) ;
    NSLog(@"         uploading  =%@\n", status.uploading ? @"YES" : @"NO" ) ;
    NSLog(@"         incoming   =%@\n", status.incoming ? @"YES" : @"NO" ) ;
    NSLog(@"         outgoing   =%@\n", status.outgoing ? @"YES" : @"NO" ) ;
    NSLog(@"         needsReset =%@\n", status.needsReset ? @"YES" : @"NO" ) ;
    NSLog(@"==============================\n");
    
    
}
- (BOOL)datastoreIsIdle:(DBDatastore *)store
{
    DBDatastoreStatus * status = store.status;
    BOOL isIdle = (status.connected &&
                   !status.downloading &&
                   !status.uploading &&
                   !status.incoming &&
                   !status.needsReset);

    return isIdle;
}
- (void)beginObservingDatastore:(DBDatastore *)datastore
{
    if([datastore observationInfo]) return;
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(datastore) weakStore = datastore;
    [datastore addObserver:self block:^
     {
         typeof(weakStore) strongStore = weakStore;
         typeof(self) strongSelf = weakSelf;
         
//         [strongSelf checkstatus:strongStore];
         if(!strongStore)
         {
             DLog(@"CANNOT OBSERVE DATASTORE/STRONGSELF FAILED");
             return;
         }
         
         if(strongStore.status.incoming)
         {
             DLog(@"STATE: Incoming");
             [strongSelf syncDatastore:strongStore];
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [[NSNotificationCenter defaultCenter]
              postNotificationName:kDatastoreSyncManagerStatusDidChangeNotification
              object:strongStore.datastoreId
              userInfo:@{kDatastoreSyncManagerStatusKey:strongStore.status}];
         });
     }];
}

- (void)resetDatastore:(DBDatastore *)datastore
{
    [datastore removeObserver:self];
    [datastore close];
    DBError * error = nil;
    BOOL uncached = [[DBDatastoreManager sharedManager] uncacheDatastore:datastore.datastoreId error:&error];
    
    if(uncached)
    {
        
    }
    
    
}

- (void)startObserving_TagDatastore
{
    if([_tagDatastore observationInfo]) return;
    
    __weak typeof(self) weakSelf = self;
    __weak DBDatastore * weaktagStore = _tagDatastore;
    

    [self.tagDatastore addObserver:self
                         block:^
     {
         typeof(self) strongSelf = weakSelf;
         if (!strongSelf) return;
         
         
         if(strongSelf.tagDatastore.status.needsReset)
         {
             [strongSelf resetDatastore:weaktagStore];
         }
         else if(strongSelf.tagDatastore.status.incoming)
         {
             [strongSelf syncDatastore:weaktagStore];
         }
         else
         {
             [strongSelf checkDatastores_Data_state];
         }
         
         
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [[NSNotificationCenter defaultCenter]
              postNotificationName:kDatastoreSyncManagerStatusDidChangeNotification
              object:strongSelf.tagDatastore.datastoreId
              userInfo:@{kDatastoreSyncManagerStatusKey:strongSelf.tagDatastore.status}];
         });
     }];
    
}

- (void)checkDatastores_Data_state
{
    if(_finishCheckingForEmptyDatastores) return;
    
    if(![self datastoreIsIdle:self.activeNoteStore] && ![self datastoreIsIdle:self.tagDatastore]) return;
    
    self.finishCheckingForEmptyDatastores = YES;

//    BOOL emptyTags = (self.tagDatastore.recordCount <= 1);
//    BOOL emptyNotes = ([self noteStoresRecordCount] < 1);
    
    NSUInteger noteCount = [[DataManager sharedInstance] unsyncedNoteCount];
    NSUInteger tagCount  = [[DataManager sharedInstance] unsyncedTagCount];
    
    
    DLog(@"%lu==%lu || %lu==%lu",(unsigned long) noteCount, (unsigned long)[self noteStoresRecordCount], (unsigned long)tagCount, (unsigned long)_tagDatastore.recordCount-1);
  
    //:::
    //empty Notes and or Tags.
    //would you like to send all data to this new store?
    // Abandoned this plan cuz of two reasons:
    // 1. Need to check for current Notes and Tags count.
    // 2. Need to Check for Duplication of Data, incase it sends all that to another device that already
    //    was updated. Need a method here.
    
    /*
    if(emptyNotes || emptyTags)
    {

        [self promptMessageForNotes:emptyTags tags:emptyTags];
        return;
    }*/
    
    
    [self sendAllDataToDropbox:(noteCount > 0) tags:(tagCount > 0) objects:nil];

    
}

- (void)syncDatastore:(DBDatastore *)store
{

    DBError *error = nil;
    NSDictionary *changes = [store sync:&error];
    
    [self continueAfterError:error];
    
    if(changes)
    {

        if ([changes count] > 1)
        {
            [EXOperationQueue incomingOperationForService:EX_DROPBOX
                                                 mapTable:nil
                                                 userInfo:@{kActiveDatastoreIdKey: store.datastoreId,
                                                            kIncomingDataKey: changes,
                                                            @"storeTitle":store.title}
                                                      moc:self.managedObjectContext];
            
            
        }
    }
    else
    {
        NSLog(@"Error syncing with Dropbox: %@", error);
    }
}


#pragma mark - Note Datastore Managing
- (void)addNoteDatastoresObject:(DBDatastore *)object
{
    [_noteDatastores addObject:object];
    [self sortNoteStoresArray];
}
- (void)sortNoteStoresArray
{
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"size" ascending:YES];
    [_noteDatastores sortUsingDescriptors:@[descriptor]];
    _activeNoteStore = nil;
}
- (DBDatastore *)activeNoteStore
{
    if(!_activeNoteStore)
    {
        self.activeNoteStore = [_noteDatastores firstObject];
    }
    return _activeNoteStore;
}
- (NSUInteger)noteStoresRecordCount
{
    NSUInteger count = 0;
    for(DBDatastore * store in self.noteDatastores)
    {
        count += (store.recordCount - 1);
    }
    return count;
}
- (DBDatastore *)activeNoteDatastoreForOutgoingData
{
    return [_noteDatastores firstObject];
}
- (DBDatastore *)notestore_largestSize
{
    return [_noteDatastores lastObject];
}

- (BOOL)shouldCreateNewNotestore
{
    
    NSUInteger size = [self.activeNoteStore size];
    NSUInteger unsyncedSize  = [self.activeNoteStore unsyncedChangesSize];
    NSUInteger bufferFactor = DSB_ONE_MB * 0.5;
    NSUInteger bufferRecordCount = 1000;
    
    NSUInteger recordCount = [self.activeNoteStore recordCount];
    
    BOOL isExceeding = (size + unsyncedSize > (DBDatastoreSizeLimit - bufferFactor));
    if  (isExceeding) return YES;
    
    isExceeding = (recordCount > DBDatastoreRecordCountLimit - bufferRecordCount);
    
    if(isExceeding) return YES;
    
    return NO;

}
- (void)constants
{
    DLog(@"DBDatastoreSizeLimit=%lu,\nDBDatastoreUnsyncedChangesSizeLimit=%lu\n,DBDatastoreRecordCountLimit=%lu\n,DBDatastoreBaseSize=%lu\n,DBDatastoreBaseChangeSize=%lu\n,DBDatastoreBaseUnsyncedChangesSize=%lu\n,DBRecordBaseSize=%lu\nDBRecordSizeLimit=%lu",
         (unsigned long)DBDatastoreSizeLimit,
         (unsigned long)DBDatastoreUnsyncedChangesSizeLimit,
         (unsigned long)DBDatastoreRecordCountLimit,
         (unsigned long)DBDatastoreBaseSize,
         (unsigned long)DBDatastoreBaseChangeSize,
         (unsigned long)DBDatastoreBaseUnsyncedChangesSize,
         (unsigned long)DBRecordBaseSize,
         (unsigned long)DBRecordSizeLimit);
}

#pragma  mark - Error handling
- (BOOL)continueAfterError:(DBError *)error
{
    if(error)
    {
        self.syncStatus = [NSString stringWithFormat:@"%ld: %@", (long)error.code, error.debugDescription];
        DLog(@"%@", error.description);
        
        DBErrorCode code = [error code];
        switch (code) {
            case DBErrorQuota:
                return NO;
                break;
            case DBErrorShutdown:
                return NO;
            default:
                return YES;
                break;
        }
        
        
    }
    else
    {
        self.syncStatus = @"Syncing is active";
    }
    return YES;
}
#pragma mark - Outgoing Changes:
- (void)managedObjectContextWillSave:(NSNotification *)notification
{
    if (![self isSyncEnabled]) return;
    
    NSManagedObjectContext *managedObjectContext = notification.object;
    if (self.managedObjectContext != managedObjectContext)
    {
        DLog(@"Not the same");
        //return;
    }
    
        
    __weak DBDatastore * weakNotestore  = self.activeNoteStore;
    __weak DBDatastore * weakTagStore   = self.tagDatastore;
    
    
    
    NSMapTable *mapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                                 valueOptions:NSMapTableWeakMemory];
    [mapTable setObject:weakTagStore  forKey:kTagEntityName];
    [mapTable setObject:weakNotestore forKey:kNoteEntityName];
    
    for(DBDatastore * store in self.noteDatastores)
    {
        __weak DBDatastore * weakStore = store;
        [mapTable setObject:weakStore forKey:store.datastoreId];
    }
    
    [EXOperationQueue outgoingOperationForService:EX_DROPBOX mapTable:mapTable userInfo:@{kTagEntityName: tagStoreID, kNoteEntityName: noteStoreID} moc:managedObjectContext];
    
}



- (void)promptMessageForNotes:(BOOL)shouldSendNotes tags:(BOOL)shouldSendTags
{
    __weak typeof(self) weakSelf = self;

    if(!shouldSendNotes && !shouldSendTags) return;
    

    
    NSString * msg = @"A syncing update action is required. This will resolve some unsynced issues.";
    
    UIAlertController * ask = [UIAlertController alertControllerWithTitle:@"Sync Action Required" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *send = [UIAlertAction actionWithTitle:@"Send Unsynced notes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [weakSelf sendAllDataToDropbox:shouldSendNotes tags:shouldSendTags objects:nil];
        
    }];
    
    UIAlertAction *nope = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    //UIAlertAction *dont = [UIAlertAction actionWithTitle:@"Don't Ask again" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
      //  [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"DontAskForSync"];
        
    //}];
    [ask addAction:send];
    [ask addAction:nope];
    //[ask addAction:dont];
    
    [[self topViewController] presentViewController:ask animated:YES completion:nil];
}

- (UIViewController *)topViewController
{
    UIViewController * vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    while (vc.presentedViewController)
    {
        vc = vc.presentedViewController;
    }
    return vc;
}

- (void)saveContextToMainOnly:(NSNotification *)notification
{
    if(notification.object == _managedObjectContext)
    {
        return;
    }
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    
    _backgroundContext = nil;
}

- (void)sendAllDataToDropbox:(BOOL)notes tags:(BOOL)tags objects:(NSSet *)managedObjects
{
    if(!notes && !tags) return;
    
    [[self tagDatastore] removeObserver:self];
    [[self noteDatastores] makeObjectsPerformSelector:@selector(removeObserver:) withObject:self];
    
    NSString * msg = @"Syncing Notes and Tags with Dropbox, please wait...";
    
    _alertController = [UIAlertController alertControllerWithTitle:msg message:@"do not close the app" preferredStyle:UIAlertControllerStyleAlert];
    [[self topViewController] presentViewController:_alertController animated:YES completion:nil];
    
    __weak typeof(self) weakSelf = self;
//    __weak typeof(_alertController) weakAlert = _alertController;

    
    NSMapTable *mapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                                 valueOptions:NSMapTableWeakMemory];
    if(tags)[mapTable setObject:self.tagDatastore forKey:kTagEntityName];
    if(notes)[mapTable setObject:self.activeNoteStore  forKey:kNoteEntityName];
    EXOperation * notOp = [EXOperationQueue fullOutgoingForService:EX_DROPBOX mapTable:mapTable userInfo:nil moc:self.managedObjectContext];
    [notOp setCompletionBlock:^{
        typeof(self) strongself = weakSelf;
        [strongself startObserving_NoteDatastores];
        [strongself startObserving_TagDatastore];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //[MRModalAlertView showMessage:@"Sync completed" title:@"Success" overView:weakAlert.presentingViewController.view];
            [weakSelf performSelector:@selector(dismissPleaseWaitController) withObject:nil afterDelay:0.5];
//            [weakAlert dismissViewControllerAnimated:NO completion:nil];
        }];
    }];

    [[[EXOperationQueue shared] syncOperationQueue] addOperation:notOp];
}
- (void)dismissPleaseWaitController
{
    
    [_alertController dismissViewControllerAnimated:YES completion:nil];
    _alertController = nil;
    
}







- (void)checkForUnsyncedManagedObjects
{
    
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"lastSynced == %@", @NO]];
    
    NSPersistentStoreAsynchronousFetchResultCompletionBlock resultBlock = ^(NSAsynchronousFetchResult *result) {
        NSLog(@"Number of Unread Items: %ld", (long)result.finalResult.count);
        
    };
    NSAsynchronousFetchRequest *asyncFetch = [[NSAsynchronousFetchRequest alloc]
                                              initWithFetchRequest:fetchRequest
                                              completionBlock:resultBlock];
    
    [self.managedObjectContext executeRequest:asyncFetch error:nil];

}


@end
