//
//  SyncManager.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 08/12/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "SyncManager.h"
#import <Dropbox/Dropbox.h>
#import "Excerpt.h"
#import "Tag.h"
#import "Link.h"
#import "NSManagedObject+Excerpts.h"
#import "NSString+RSParser.h"
#import "DataManager.h"

NSString * const kDefaultSyncAttributeName =      @"syncID";
NSString * const kSyncManagerDatastoreStatusDidChangeNotification = @"SyncManagerDatastoreStatusDidChange";
NSString * const kSyncManagerDatastoreStatusKey = @"status";
NSString * const kSyncManagerDatastoreIncomingChangesNotification = @"SyncManagerDatastoreIncomingChanges";
NSString * const kSyncManagerDatastoreIncomingChangesKey = @"changes";
NSString * const kSyncManagerAutoImportLastUpdatedKey = @"syncMLastUpdated";

static NSUInteger const kFetchRequestBatchSize = 25;



@interface SyncManager ()
{
    NSArray *entitiesToSync;
}
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readwrite) DBDatastore *datastore;
@property (nonatomic, strong) NSMutableDictionary *tablesKeyedByEntityName;
@property (nonatomic) BOOL observing;


@property (nonatomic, retain) DBFile *file;
@property (nonatomic, strong) NSMutableArray * importedDBFilesArray;
@property (nonatomic, strong) NSMutableArray * importedDBDataArray;
@property (nonatomic) BOOL autoImporting;
@end

@implementation SyncManager

+ (NSString *)syncID
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    NSString *uuid = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuidRef));
    return [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
}
- (id)init
{
    self = [super init];
    if (self) {
        _autoImporting = NO;
        _tablesKeyedByEntityName = [[NSMutableDictionary alloc] init];
        _syncAttributeName = kDefaultSyncAttributeName;
        _syncBatchSize = 20;
        entitiesToSync = @[@"Excerpt", @"Tag"];
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:kSettings_AutoImport options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext datastore:(DBDatastore *)datastore
{
    self = [self init];
    if (self) {
        
        _managedObjectContext = managedObjectContext;
        _datastore = datastore;
    }
    return self;
}

#pragma mark - Auto Import Methods
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:kSettings_AutoImport])
    {
        BOOL autoImport = [change[@"new"] boolValue];
        DLog(@"%@ %@", @(autoImport), change.description);
        [self toggleAutoImport:autoImport];
        
    }
}
- (void)toggleAutoImport:(BOOL)start{
    
    if(start)
    {
        [self startAutoImportAtFolderPath:[[NSUserDefaults standardUserDefaults] objectForKey:kSettings_AutoImportFolderPath]];
    }
    else
    {
        [self stopAutoImport];
    }
}
-(BOOL)isAutoImporting
{
    return self.autoImporting;
}

- (void)startAutoImportAtFolderPath:(NSString *)dbFolderPath{
    
    dbFolderPath = [[NSUserDefaults standardUserDefaults] objectForKey:kSettings_AutoImportFolderPath];
  

    if(!dbFolderPath)
    {
        DLog(@"folderPath not found");
        return;
    }
    
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if(!account) return;
    
    
    DBFilesystem * fileSystem = [DBFilesystem sharedFilesystem];
    DBPath *dbPath = [[DBPath root] childPath:dbFolderPath];
    
    NSLog(@"%@", dbPath.stringValue);
    
    if([self autoImporting]) return;
    self.autoImporting = YES;
    
    
    __weak typeof (self) weakSelf = self;

    [fileSystem addObserver:self forPathAndChildren:dbPath block:^{
        typeof(self) strongSelf = weakSelf;
        if(!strongSelf) return;
        if(![strongSelf isAutoImporting]) return;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
             NSDate * lastSynced  = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:kSyncManagerAutoImportLastUpdatedKey];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kSyncManagerAutoImportLastUpdatedKey];
            
            
        DBError *error = nil;
        NSArray *lstContents = [[DBFilesystem sharedFilesystem] listFolder:dbPath error:&error];
        if(error)
        {
            DLog(@"%@", error.description);
            return;
        }

            NSPredicate * excerptsPredicate;
            
            if(lastSynced)
            {
                
                excerptsPredicate = [NSPredicate predicateWithFormat:@"(self.path.stringValue CONTAINS '@excerpt') AND (self.modifiedTime >=  %@)", lastSynced];

            }
            else
            {
                return;
                excerptsPredicate = [NSPredicate predicateWithFormat:@"self.path.stringValue CONTAINS '@excerpt'"];
            }
            
            lstContents = [lstContents filteredArrayUsingPredicate:excerptsPredicate];
            
            if(lstContents && lstContents.count > 0)
            {
                //No file found yet.
                [self readExcerptDBFileInfos:[lstContents copy]];
                
            }

        });
    }];
    

}

-(BOOL)readExcerptDBFileInfos:(NSArray *)filesArray{
    
    [self stopAutoImport];
    
    _importedDBFilesArray = [filesArray mutableCopy];
    
    [self continueImport];
    
    return YES;
}
-(void)continueImport
{
    DBFileInfo * last = [_importedDBFilesArray lastObject];
    
    if(!last)
    {
        _importedDBFilesArray = nil;
        [_file close];
        _file = nil;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self addImportedDataIntoLocaldatabase];
            [self startAutoImportAtFolderPath:nil];
        });

    }else
        
        [self openDropboxFile:last];
}
-(BOOL)openDropboxFile:(DBFileInfo *)fileInfo
{

    DBPath *existingPath = [[DBPath root] childPath:fileInfo.path.stringValue];
    DBError * error;
    _file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:&error];
    if(error)
    {
        DLog(@"ERROR OpeningFile: %@", [error description]);
        return NO;
    }
    __weak typeof (self) weakSelf = self;
    [_file addObserver:self block:^{
        [weakSelf readDropboxFile];
    }];
    return YES;
}

-(void)readDropboxFile
{

    if(_file.newerStatus && DBFileStateIdle)
    {
        [_file update:nil];
    }
    if(!_file.newerStatus && DBFileStateIdle)
    {
        [_file removeObserver:self];
        [self handleDropboxFile];
    }
}

-(void)handleDropboxFile{
    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

    NSString * contents = [_file readString:nil];
    if([contents length] == 0)
    {
        [_importedDBFilesArray removeLastObject];
        [_file close];
        _file = nil;
        [self continueImport];
        return;
    }
    
    if(!_importedDBDataArray)
        _importedDBDataArray = [NSMutableArray new];
    [_importedDBDataArray addObject:@{@"importIdentifier" : _file.info.path.stringValue,
                                      @"modifiedDate"      : _file.info.modifiedTime,
                                      @"rawData"  : contents,
                                      kDefaultSyncAttributeName  : [[_file.info.path.stringValue lastPathComponent] md5]
                               }];
    NSLog(@"%@" , _importedDBDataArray.description);
        
    [_importedDBFilesArray removeLastObject];
    [_file close];
    _file = nil;
    
    [self continueImport];
    });
    
}

- (void)addImportedDataIntoLocaldatabase
{
    
    for(NSDictionary * d in _importedDBDataArray)
    {
        Excerpt * v = (Excerpt *)[Excerpt getOrCreateObjectWithIdentifier:d[kDefaultSyncAttributeName] attribute:kDefaultSyncAttributeName moc:_managedObjectContext propertiesDict:d];
        [v setType:@1];
        
    }
    [[DataManager sharedInstance] save];
    _importedDBDataArray = nil;
    
}


                 


- (void)stopAutoImport{
    
    [_file close];
    _file = nil;
    [[DBFilesystem sharedFilesystem] removeObserver:self];
    self.autoImporting = NO;
    
}

#pragma mark - Observing methods
- (BOOL)isObserving
{
    return self.observing;
}
- (void)startObserving
{
    if ([self isObserving]) return;
    self.observing = YES;
    
    __weak typeof(self) weakSelf = self;
    [self.datastore addObserver:self block:^ {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (![strongSelf isObserving]) return;
        
        DBDatastoreStatus status = strongSelf.datastore.status;
        if (status & DBDatastoreIncoming) {
            [strongSelf syncDatastore];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kSyncManagerDatastoreStatusDidChangeNotification
                                                                object:strongSelf
                                                              userInfo:@{kSyncManagerDatastoreStatusKey:@(status)}];
        });
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextWillSave:) name:NSManagedObjectContextWillSaveNotification object:self.managedObjectContext];
}

- (void)stopObserving
{
    if (![self isObserving]) return;
    self.observing = NO;
    
    [self.datastore removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:self.managedObjectContext];
}


#pragma mark - Updating Core Data Campaign

-(void)updateCoreDataWithDatastoreChanges:(NSDictionary *)changes{
 
    NSLog(@"DataStore changes: %d", changes.allValues.count);
    static NSString * const UpdateManagedObjectKey = @"object";
    static NSString * const UpdateRecordKey = @"record";
    
    if ([changes count] == 0) return;
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
    [moc setUndoManager:nil];
    
    __block NSMutableArray *updates = [[NSMutableArray alloc] init];
    __weak typeof(self) weakSelf = self;
    
    [changes enumerateKeysAndObjectsUsingBlock:^(NSString *tableID, NSArray *records, BOOL *stop){
        
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:tableID];
        [fetchRequest setFetchLimit:1];
        
        for (DBRecord *record in records)
        {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", strongSelf.syncAttributeName, record.recordId]];
            NSError *error = nil;
            NSArray *existingObjects = [moc executeFetchRequest:fetchRequest error:&error];
            
            if(existingObjects)
            {
                NSManagedObject *managedObject = [existingObjects lastObject];
                if ([record isDeleted]) {
                    if (managedObject) {
                        [moc deleteObject:managedObject];
                    }
                } else {
                    if (!managedObject) {
                        managedObject = [NSEntityDescription insertNewObjectForEntityForName:tableID inManagedObjectContext:moc];
                        [managedObject setValue:record.recordId forKey:strongSelf.syncAttributeName];
                    }
                    
                    [updates addObject:@{UpdateManagedObjectKey: managedObject, UpdateRecordKey: record}];
                }
            } else {
                NSLog(@"Error executing fetch request: %@", error);
            }
        }
    }];
    
    for (NSDictionary *update in updates) {
        DLog(@"updates: %d", updates.count);
        NSManagedObject *managedObject = update[UpdateManagedObjectKey];
        DBRecord *record = update[UpdateRecordKey];
        [managedObject updateFromDBRecord:record];
        DLog(@"ENTITY:%@ mo: %@\n\nrecord: %@", [[managedObject entity] name ], [managedObject valueForKey:self.syncAttributeName], record.recordId);
    }
    if ([moc hasChanges]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncManagedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Error saving managed object context: %@", error);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:moc];
    }

    
    
}
- (void)syncManagedObjectContextDidSave:(NSNotification *)notification
{
    
    DLog(@"%@", notification.description);
    
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}


#pragma mark - Updating Datastore
- (void)managedObjectContextWillSave:(NSNotification *)notification
{

    
    
    if (![self isObserving]) return;

    NSManagedObjectContext *managedObjectContext = notification.object;
    if (self.managedObjectContext != managedObjectContext)
    {
        DLog(@"Not the same");
        return;
    }
    
    NSSet *deletedObjects = [managedObjectContext deletedObjects];
    for (NSManagedObject *managedObject in deletedObjects)
    {

        if(![entitiesToSync containsObject:[[managedObject entity] name]])
        {
            DLog(@"NOT Saving. Its :%@", [[managedObject entity] name]);
            continue;
        }
        
        DBTable *table = [self.datastore getTable:[[managedObject entity] name]];
        DBError *error = nil;
        DBRecord *record = [table getRecord:[managedObject primitiveValueForKey:self.syncAttributeName] error:&error];
        if (record) {
            [record deleteRecord];
        } else if (error) {
            DLog(@"Error getting datastore record: %@", error);
        }
    };
    
    
    NSMutableSet *managedObjects = [[NSMutableSet alloc] init];
    [managedObjects unionSet:[managedObjectContext insertedObjects]];
    [managedObjects unionSet:[managedObjectContext updatedObjects]];
    
   NSUInteger index = 0;
    for (NSManagedObject *managedObject in managedObjects) {
        
        
        if(![self isSyncableObject:managedObject])
        {
            continue;
        }
        
        DLog(@"Shall Continue updating %d: %@", index, [[managedObject entity] name]);
        
        [self updateDatastoreWithManagedObject:managedObject];
        
        index++;
        
        if (index % self.syncBatchSize == 0)
        {
            [self syncDatastore];
        }
    }
    
    [self syncDatastore];
}
- (void)updateDatastoreWithManagedObject:(NSManagedObject *)managedObject
{
    NSString *tableID =  [[managedObject entity] name];
    
    DBTable *table = [self.datastore getTable:tableID];
    DBError *error = nil;
    DBRecord *record = [table getOrInsertRecord:[managedObject valueForKey:self.syncAttributeName] fields:nil inserted:NULL error:&error];

    if (record) {
            [managedObject updateDBRecord:record];
    } else {
        DLog(@"Error getting or inserting datatore record: %@", error);
    }
}


- (void)syncDatastore
{
    DBError *error = nil;
    NSDictionary *changes = [self.datastore sync:&error];
    if (changes) {
          [[NSNotificationCenter defaultCenter] postNotificationName:kSyncManagerDatastoreIncomingChangesNotification object:self userInfo:@{kSyncManagerDatastoreIncomingChangesKey: changes}];
        [self updateCoreDataWithDatastoreChanges:changes];
    } else {
        NSLog(@"Error syncing with Dropbox: %@", error);
    }
}

- (BOOL) isSyncableObject:(NSManagedObject *)mobject
{
    if(![entitiesToSync containsObject:[[mobject entity] name]])
    {
        NSLog(@"NOT SYNCED: %@", [[mobject entity] name]);
        return NO;
    }

    if(![mobject canSyncToDB])
    {
        NSLog(@"NOT SYNCED: %@", [[mobject entity] name]);
        mobject.canSyncToDropboxDatastore = @(YES);
        return  NO;
    }
    
    return YES;
}
















-(void)importVignettesFromLocalFiles:(NSArray *)fileList
{
    
    /*
     NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
     [managedObjectContext setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
     [managedObjectContext setUndoManager:nil];
     */
    NSManagedObjectContext *managedObjectContext = [[DataManager sharedInstance] managedObjectContext];
    NSUInteger p = 0;
    
    for(p=0; p< 535; p++)
    {
        NSString *txtFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", p]  ofType: @"txt"];
        NSString *vFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_v", p]  ofType: @"txt"];
        NSString *vignette = [NSString stringWithContentsOfFile:vFilePath encoding:NSUTF8StringEncoding error:NULL];
        
        NSString *txtFileContents = [NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:NULL];
        
        //NSLog(@"%d-%@", p, txtFileContents);
        NSDictionary *dict = [NSString parseIntoDictionaryForString:txtFileContents];
        NSDictionary *info = [dict[@"info"] keyValueDictionary];
        NSArray *links = [dict[@"links"] arrayDictionaryForLinks];
        //NSLog(@"%@", links.description);
        NSLog(@"DONE: %d", p);
        
        
        Excerpt *vig = [NSEntityDescription insertNewObjectForEntityForName:@"Excerpt" inManagedObjectContext:managedObjectContext];
        vig.syncID = [Excerpt syncID];
        vig.text = vignette;
        vig.creationDate = [NSDate dateWithTimeIntervalSince1970:[info[@"creationdate"] doubleValue]];
        vig.modifiedDate = [NSDate dateWithTimeIntervalSince1970:[info[@"modifieddate"] doubleValue]];
        if([info[@"tags"] length] > 5)
        {
            NSArray *tagsArray = [[info[@"tags"] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
            [vig checkAndAddTags:tagsArray attribute:@"title"];
        }
        if(links.count > 0)
        {
            for(NSDictionary *ld in links)
            {
                Link *link  = [NSEntityDescription insertNewObjectForEntityForName:@"Link" inManagedObjectContext:managedObjectContext];
                link.type = ld.allKeys[0];
                NSDictionary *linkD = ld[link.type];
                if(ld[@"title"])
                    link.title = linkD[@"title"];
                link.identifier = linkD[@"link"];
                [vig addLinksObject:link];
            }
            
        }
        
        
        
        
    }
    
    
    if ([managedObjectContext hasChanges]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncManagedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Error saving managed object context: %@", error);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
    }
}

@end
