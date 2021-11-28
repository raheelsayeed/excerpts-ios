//
//  DdxFolderSyncManager.m
//   Renote
//
//  Created by M Raheel Sayeed on 05/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "DbxFolderSyncManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "DataManager.h"
#import "Note.h"
#import "Tag.h"


NSString * const kAutoImportLastUpdatedKey = @"dbxAutoImportLastUpdated";



@interface DbxFolderSyncManager ()
@property (nonatomic) DBFile * currentFile;
@property (nonatomic) DBPath * folderPath;
@property (nonatomic, strong) DBFilesystem * filesystem;
@property (nonatomic, assign, readwrite, getter = isPaused) BOOL paused;
@property (nonatomic, strong) NSMutableArray * changedFileInfos;
@property (nonatomic, strong) NSMutableDictionary  * importedFileContentDictionary;

@end
@implementation DbxFolderSyncManager

- (instancetype)initWithDefaults
{

    NSString * syncPath = [[NSUserDefaults standardUserDefaults] objectForKey:kSettings_AutoImportFolderPath];
    NSString * tag = [[NSUserDefaults standardUserDefaults] objectForKey:kSettings_AutoImportFilenameTag];
    DBAccount * account  = [[DBAccountManager sharedManager] linkedAccount];
    if(!account || syncPath || tag) return nil;
    
    self = [self initWithSyncPath:syncPath dbxFilesystem:nil nameTag:tag];
    if(self)
    {
        
    }
    return self;
}
- (instancetype)initWithSyncPath:(NSString *)syncPath dbxFilesystem:(DBFilesystem *)fs nameTag:(NSString *)filenameTag
{
    self = [super init];
    if(self)
    {
        if(syncPath.length == 0 || filenameTag.length == 0) return nil;
        self.syncPath = syncPath;
        self.nameTag = filenameTag;
        self.autoImportEnabled = [[[NSUserDefaults standardUserDefaults] objectForKey:kSettings_AutoImport] boolValue];
        self.filesystem = fs;
    }
    return self;
}



- (void)enableAutoImport
{
    if(self.isAutoImportEnabled)
    {
        [self disableAutoImport];
    }
    
    self.autoImportEnabled = YES;
    [self startAutoImportAtFolderPath:_syncPath];
}

- (void)observeFolderChanges
{
    __weak typeof (self) weakSelf = self;
    
    _filesystem = [DBFilesystem sharedFilesystem];
    
    
    if(!_filesystem)
    {
        self.filesystem = [[DBFilesystem alloc] initWithAccount:[[DBAccountManager sharedManager] linkedAccount]];
        [DBFilesystem setSharedFilesystem:self.filesystem];
    }

    [_filesystem addObserver:self forPathAndChildren:_folderPath block:^{
        typeof(self) strongSelf = weakSelf;
        if(!strongSelf) return;
        if(![strongSelf isAutoImportEnabled] ) return;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSDate * lastSynced  = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:kAutoImportLastUpdatedKey];
            
            
            DBError *error = nil;
            NSArray *lstContents = [[DBFilesystem sharedFilesystem] listFolder:[strongSelf folderPath] error:&error];
            if(error)
            {
                DLog(@"%@", error.description);
                return;
            }
            
            NSPredicate * notesPredicate;
            
            if(lastSynced)
            {
                notesPredicate = [NSPredicate predicateWithFormat:@"(self.iconName = 'page_white_text') AND (self.path.stringValue CONTAINS %@) AND (self.modifiedTime >=  %@)", strongSelf.nameTag, lastSynced];
            }
            else
            {
                notesPredicate = [NSPredicate predicateWithFormat:@"(self.iconName = 'page_white_text') AND (self.path.stringValue CONTAINS %@)", strongSelf.nameTag];
            }
            
            lstContents = [lstContents filteredArrayUsingPredicate:notesPredicate];
            
     
            
            if(lstContents && lstContents.count > 0)
            {
                [strongSelf readSortedFiles:[lstContents copy]];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kAutoImportLastUpdatedKey];
            }
            
        });
    }];
}

- (void)startAutoImportAtFolderPath:(NSString *)dbFolderPath{

    if(!dbFolderPath || ![[DBAccountManager sharedManager] linkedAccount])
    {
        [self disableAutoImport];
        return;
    }
    
    self.folderPath = [[DBPath root] childPath:dbFolderPath];
    
    if(!_folderPath)
    {
        [self disableAutoImport];
        return;
    }
    
    
    [self observeFolderChanges];

}
-(BOOL)readSortedFiles:(NSArray *)filesArray{
    

   self.paused = YES;

    _changedFileInfos = [filesArray mutableCopy];
    
    [self continueImport];
    
    return YES;
}
-(void)continueImport
{

    DBFileInfo * last = [_changedFileInfos lastObject];
    
    if(!last)
    {
        self.changedFileInfos = nil;
        [_currentFile close];
        _currentFile = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kAutoImportLastUpdatedKey];
            [self addImportedDataIntoLocaldatabase];
            self.paused = NO; //Continue
        });
        
    }else
    {
        [self openDropboxFile:last];
    }
}
-(BOOL)openDropboxFile:(DBFileInfo *)fileInfo
{


    DBPath *existingPath = [[DBPath root] childPath:fileInfo.path.stringValue];
    DBError * error;
    self.currentFile = [_filesystem openFile:existingPath error:&error];
    if(error)
    {
        DLog(@"ERROR OpeningFile: %@", [error description]);
        return NO;
    }
    __weak typeof (self) weakSelf = self;
    [self.currentFile addObserver:self block:^{

        typeof(self) strongSelf = weakSelf;
        [strongSelf latestVersion];
    }];
    return YES;
}

-(void)latestVersion
{


    if(_currentFile.newerStatus && DBFileStateIdle)
    {
        [_currentFile update:nil];
    }
    if(!_currentFile.newerStatus && DBFileStateIdle)
    {
        [_currentFile removeObserver:self];
        [self handleDropboxFile];
        return;
    }
}

- (void)proceedToNextDropboxFile
{


    [_changedFileInfos removeLastObject];
    [_currentFile removeObserver:self];
    [_currentFile close];
    _currentFile = nil;
    [self continueImport];
}

-(void)handleDropboxFile{
    


    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSString * contents = [_currentFile readString:nil];
        if([contents length] == 0)
        {
            [self proceedToNextDropboxFile];
            return;
        }
        if(!_importedFileContentDictionary)
        {
            _importedFileContentDictionary = [NSMutableDictionary new];
        }
        
        NSString * currentFilePath = _currentFile.info.path.stringValue;
        
        NSDictionary *contentDict =  @{@"importIdentifier": currentFilePath,
                                       @"modifiedDate":    _currentFile.info.modifiedTime,
                                       @"text"         :   contents,
                                       @"type"          :  @(EX_TYPE_DROPBOX)};
        
        [_importedFileContentDictionary setObject:contentDict forKey:[self md5ForString:[currentFilePath lastPathComponent]]];
        
        [self proceedToNextDropboxFile];
    });
    
}

- (void)addImportedDataIntoLocaldatabase
{
    if(self.importedFileContentDictionary.count  == 0)
    {
        self.importedFileContentDictionary = nil;
        return;
    }

    NSManagedObjectContext * moc = [[DataManager sharedInstance] managedObjectContext];
    
    NSSet * notes = [Note exp_fetchOrCreateObjectsWithIDs:_importedFileContentDictionary.allKeys
                                                    ofAttribute:kDefaultSyncAttributeName
                                                       inEntity:@"Note"
                                                        context:moc
                                         setAttributeProperties:_importedFileContentDictionary];
    if(notes)
    {
        NSSet * tagSet = [Tag exp_fetchOrCreateTags:@[kDropboxAutoImportTagName]
                                            context:moc];
        
        
        
        Tag * dropboxTag = [[tagSet allObjects] firstObject];
        dropboxTag.type = @(EX_TYPE_DROPBOX);
        [notes makeObjectsPerformSelector:@selector(addTagsObject:) withObject:dropboxTag];
    }
    
    self.importedFileContentDictionary = nil;

    if ([moc hasChanges])
    {
        NSError *error = nil;
        if (![moc save:&error])
        {
            NSLog(@"Error saving managed object context: %@", error);
        }
    }
    
}


- (void)contextHasChanged:(NSNotification*)notification
{
    NSManagedObjectContext * moc = [[DataManager sharedInstance] managedObjectContext];
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(contextHasChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    [moc mergeChangesFromContextDidSaveNotification:notification];
}


- (void)setPaused:(BOOL)paused
{
    _paused = paused;
    
    if(paused)
    {
        [_currentFile close];
        _currentFile = nil;
        [_filesystem removeObserver:self];
    }
    else
    {
        [self observeFolderChanges];
        
    }
    
}

- (void)disableAutoImport
{
    _autoImportEnabled = NO;
    
    if(_currentFile || _currentFile.isOpen)
    {
        [_currentFile removeObserver:self];
        [_currentFile close];
        _currentFile = nil;
    }
    [_filesystem removeObserver:self];
    [DBFilesystem setSharedFilesystem:nil];
    
    
}

- (void)dealloc
{
    _currentFile = nil;
    [_filesystem removeObserver:self];
}

         
- (NSString *)md5ForString:(NSString *)string
{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}
@end
