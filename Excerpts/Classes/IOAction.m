//
//  IOActions.m
//   Renote
//
//  Created by M Raheel Sayeed on 29/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "IOAction.h"
#import "SSZipArchive.h"
#import "Note.h"
#import "Tag.h"
#import "Link.h"
#import "DataManager.h"
#import "MRModalAlertView.h"
#import "NSString+RSParser.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "APIServices.h"
#import "NSString+QSKit.h"
#import "RequestObject.h"


#define kAlertTagExportCompleted 2

static NSString * const kMetadataTag = @"@RENOTE\n---------\n";
static NSString * const kTags        = @"tags";

@interface IOAction ()
@property (nonatomic, strong) EICompletionBlock ioCompletionBlock;
@property (nonatomic, strong) NSString * exportIdentifier;
@property (nonatomic, strong) id io_object;
@property (nonatomic, assign) BOOL syncableObjects;
@end


@implementation IOAction

-(instancetype)init{
    self = [super init];
    if(self)
    {
        self.syncableObjects = YES;
        
    }
    return self;
}


- (instancetype)initWithExportObject:(id)exportObject exportActionKey:(NSString *)exportActionKey
{    self = [self init];
    if(self)
    {
        self.io_object = exportObject;
        self.exportIdentifier = exportActionKey;
    }
    return self;
}
- (NSString *)fileMIMEType:(NSString *)file {
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[file pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    return (__bridge_transfer  NSString *)MIMEType;
}

+ (NSString*) mimeTypeForFileAtPath: (NSString *) path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
    // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    }
    return CFBridgingRelease(mimeType);
}


- (BOOL)identifyFile:(NSString*)filePath
{
//    DLog(@"1.%@", filePath);
//    DLog(@"2.%@", [[self class] mimeTypeForFileAtPath:filePath]);
//    DLog(@"3.%@", [self fileMIMEType:filePath]);
    
    CFStringRef fileExtension = (__bridge CFStringRef) [filePath pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    if (UTTypeConformsTo(fileUTI, kUTTypeImage))
    {
         DLog(@"4.It's an image");
    }
    else if (UTTypeConformsTo(fileUTI, kUTTypeMovie))
    {
        DLog(@"4.It's a movie");
    }
    else if (UTTypeConformsTo(fileUTI, kUTTypeText))
    {
        DLog(@"4.text");
    }
    else if(UTTypeConformsTo(fileUTI, (__bridge CFStringRef) @"renoteArchive"))
    {
        DLog(@"4. zip file");
    }
        
    
    CFRelease(fileUTI);
    
    return YES;
}


#pragma mark - Import Operation

bool isTextFile(NSURL *fileURL)
{
    
    CFStringRef fileExtension = (__bridge CFStringRef) [fileURL.path pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    return (UTTypeConformsTo(fileUTI, kUTTypeText));
}
bool isZipFile(NSURL *fileURL)
{
    
    CFStringRef fileExtension = (__bridge CFStringRef) [fileURL.path pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    return (UTTypeConformsTo(fileUTI, kUTTypeZipArchive));
}


+ (void)importOperationWithFileURL:(NSURL *)fileURL completion:(EICompletionBlock)completion
{
    IOAction * import = [[IOAction alloc] init];
    import.ioCompletionBlock = completion;
    import.io_object = fileURL;
    import.io_object       = fileURL;
    [import startImportWithCompletion:completion];
}
+ (BOOL)importSampleDataFromBundleFolder:(NSString *)bundleFolder completion:(EICompletionBlock)completion
{
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString * documentsPath = [resourcePath stringByAppendingPathComponent:bundleFolder];
    NSError * error;
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    
        NSMutableArray * filePaths = [[NSMutableArray alloc] initWithCapacity:directoryContents.count];
        
    for(NSString *filename in directoryContents)
    {
        [filePaths addObject:[documentsPath stringByAppendingPathComponent:filename]];
    }
        
        IOAction * import = [[IOAction alloc] init];
        import.io_object = filePaths;
        import.syncableObjects = NO;
        [import startImportWithCompletion:completion];
    
    
    return YES;

}
- (void)startImportWithCompletion:(EICompletionBlock)completion
{
    self.ioCompletionBlock = completion;
    
    if([self.io_object isKindOfClass:[NSArray class]])
    {
        //array of TextFilePaths
        NSArray * contentsArray = [self contentsArrayFromFiles:self.io_object
                                                        prefixPath:nil
                                                       filemanager:[NSFileManager defaultManager]];
        [self importContents:[contentsArray copy]];
        [self finishImportOperationWithSuccess:YES];
    }

    else if([self.io_object isKindOfClass:[NSURL class]])
    {
        if(isTextFile(self.io_object))
        {
            [self importTextFile];
        }
        else if(isZipFile(self.io_object))
        {
            [self importZipFile];
        }
        else
        {
            [self finishImportOperationWithSuccess:NO];
        }
    }
    
}

- (void)finishImportOperationWithSuccess:(BOOL)success
{
    if(_ioCompletionBlock)
    {
        _ioCompletionBlock(nil, success);
        _ioCompletionBlock = nil;
    }
}

- (NSArray *)contentsArrayFromFiles:(NSArray *)files prefixPath:(NSString *)prefixPathComponent filemanager:(NSFileManager *)fileManager
{
    NSMutableArray * contentsArray = [NSMutableArray arrayWithCapacity:files.count];
    for(NSString * filename in files)
    {
//        DLog(@"%@", filename);
        if(![[filename pathExtension] isEqualToString:@"txt"]) continue;
        NSString * filepath = filename;
        if(prefixPathComponent)
        {
            filepath = [prefixPathComponent stringByAppendingPathComponent:filename];
        }
        
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:filepath error:NULL];
        NSError * error = nil;
        NSString * contents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
        if(error)
        {
            DLog(@"%@", error.description);
            continue;
        }
        if(!contents) continue;
        [contentsArray addObject:@{@"cdate": [attributes fileCreationDate],
                                   @"mdate": [attributes fileModificationDate],
                                   @"text" : contents
                                   }];
    }
    return (contentsArray.count>0) ? [contentsArray copy] : nil;
}
+ (NSString *)importedFileCollectionFolderPath
{
    static NSString *FolderName_import = @"Imported Files";
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [docPath stringByAppendingPathComponent:FolderName_import];
    
}
- (void)importZipFile
{
    __weak __typeof(&*self)weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;

        NSFileManager * fileManager = [[NSFileManager alloc] init];
        NSString *FolderPath_import =  [IOAction importedFileCollectionFolderPath];// [docPath stringByAppendingPathComponent:FolderName_import];
        NSError *error;
        
        if(![fileManager createDirectoryAtPath:FolderPath_import withIntermediateDirectories:YES attributes:nil error:&error])
        {
            DLog(@"%@", error.description);
        }
        BOOL successZIP = [SSZipArchive unzipFileAtPath:[(NSURL *)strongSelf.io_object path] toDestination:FolderPath_import overwrite:YES password:nil error:&error];
        [fileManager removeItemAtPath:[(NSURL *)strongSelf.io_object path] error:&error];
        NSArray * results;
        if(successZIP)
        {
            NSArray *files = [fileManager contentsOfDirectoryAtPath:FolderPath_import error:NULL];
            NSArray * contentsArray = [strongSelf contentsArrayFromFiles:files
                                                            prefixPath:FolderPath_import
                                                           filemanager:fileManager];
            files = nil;
            results = [strongSelf importContents:[contentsArray copy]];
        }
        [fileManager removeItemAtPath:FolderPath_import error:nil];
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           if(_ioCompletionBlock)
                           {
                               _ioCompletionBlock(results, successZIP);
                               _ioCompletionBlock = nil;
                           }
                       });

    });
}
- (void)importTextFile
{
    __weak __typeof(&*self)weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue,^{
    
        NSFileManager * fileManager = [[NSFileManager alloc] init];
        NSArray * contentsArray = [weakSelf contentsArrayFromFiles:@[[(NSURL *)weakSelf.io_object path]]
                                                        prefixPath:nil
                                                       filemanager:fileManager];
        
        if(contentsArray || contentsArray.count > 0)
        {
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            NSFileManager * fileManagerNew = [[NSFileManager alloc] init];
            NSArray * createdNotes = [strongSelf importContents:[contentsArray copy]];
            [fileManagerNew removeItemAtPath:[(NSURL  *)[strongSelf io_object] path] error:nil];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_ioCompletionBlock)
                {
                    _ioCompletionBlock(createdNotes, YES);
                    _ioCompletionBlock = nil;
                }
            });
        }
        else
        {
            [fileManager removeItemAtPath:[(NSURL *)[weakSelf io_object] path] error:nil];
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               if(_ioCompletionBlock)
                               {
                                   _ioCompletionBlock(nil, NO);
                                   _ioCompletionBlock = nil;
                               }
                           });
            
        }
        
    });
    
}
-(NSArray *)importContents:(NSArray *)contentArray;
{
    NSManagedObjectContext * moc = [[DataManager sharedInstance] privateContext];
    
    NSMutableArray * createdObjects = [NSMutableArray new];
    
    for(NSDictionary * attr in contentArray)
    {
        Note * new    =  [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:moc];
        new.text         = [attr[@"text"] stringByStrippingExcerptMetadata];
        //:::Duplicated Entries
//        new.syncID       = [Note syncIDderivedFromString:new.text];
        new.modifiedDate = attr[@"mdate"];
        new.creationDate = attr[@"cdate"];
        new.lastAccessedDate = nil;
        
//        NSLog(@"Text=%@", attr[@"text"]);
        
        
        NSString      * metadata = [attr[@"text"] excerptMetadataWithTag:kMetadataTag];
        NSArray       * links    = [metadata qs_links];
        NSDictionary  * Tagsdict = [metadata keyValueDictionary];
        
        
        if(links.count > 0)
        {
            NSDictionary * linksDictionary = [RequestObject linkIdentifierAndServiceKeyForURLStrings:links];
            if(linksDictionary)
            {
                NSSet * linkSet = [Link fetchOrCreateLinksforIdentifiers:[linksDictionary allKeys] context:moc];
                //Add remaining attributes
                for(Link * newLink in linkSet)
                {
                    NSString * serviceKey = linksDictionary[newLink.identifier];
                    newLink.serviceKey = serviceKey;
                    NSLog(@"LinkId=%@, Service=%@", newLink.identifier, newLink.serviceKey);
                }
                
                [new setLinks:linkSet];
            }
        }
        
        if(Tagsdict[kTags])
        {
            NSMutableArray * tags = [[Tagsdict[kTags] componentsSeparatedByString:@","] mutableCopy];
            [tags enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop)
            {
                [tags replaceObjectAtIndex:idx withObject:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }];
            [tags removeObject:@""];
            
            NSSet * tagSet = [Tag exp_fetchOrCreateTags:[tags copy] context:moc];
            //::: remove
            //for(Tag * tt in tagSet) NSLog(@"=>%@", tt.title);
            
            [new setTags:tagSet];
            
        }
        
        if(Tagsdict[@"archived"])
        {
            NSString * archived = Tagsdict[@"archived"];
            if(archived.length == 1)
            {
                new.archived = @([archived integerValue]);
            }
        }
        
        
        [createdObjects addObject: new];
        
        
    }
    
    
    
    
    
    if ([moc hasChanges]) {
        
        

        if(self.syncableObjects)
        [[NSNotificationCenter defaultCenter] addObserver:[[DataManager sharedInstance] datastoreSyncManager]
                                                  selector:@selector(managedObjectContextWillSave:)
                                                      name:NSManagedObjectContextWillSaveNotification
                                                    object:moc];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextHasChanged:) name:NSManagedObjectContextDidSaveNotification object:moc];
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"Error saving managed object context: %@", error);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:moc];
        
        if(self.syncableObjects)
        [[NSNotificationCenter defaultCenter] removeObserver:[[DataManager sharedInstance] datastoreSyncManager] name:NSManagedObjectContextWillSaveNotification object:moc];
    }
    
    return (createdObjects.count > 0) ? createdObjects.copy : nil;
}


- (void)contextHasChanged:(NSNotification*)notification
{
    NSManagedObjectContext * moc = [[DataManager sharedInstance] managedObjectContext];
    
    if ([notification object] == moc)
    {
        return;
    }
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextHasChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    [moc mergeChangesFromContextDidSaveNotification:notification];
    
}

#pragma mark - Export Operation

- (void)startExportWithCompletion:(EICompletionBlock)completion;
{
    _ioCompletionBlock = completion;
    
    if([_exportIdentifier hasPrefix:@"zip"])
    {
        [self doExport];
    }
    else
    {
        [self exportExcerpt];
    }
    
}
-(void)exportExcerpt
{
    
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString *exportFolderName = [self folderNameForExporting:nil];
	NSString *exportFolderPath = [docPath stringByAppendingPathComponent:exportFolderName];
    __block NSString *createdFilePath = nil;
    double delayInSeconds = 0.25;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
		[[NSFileManager defaultManager] createDirectoryAtPath:exportFolderPath withIntermediateDirectories:YES attributes:nil error:NULL];
        
    exportBlock(_io_object, exportFolderPath, &createdFilePath);
        


    if(createdFilePath)
    {
        _ioCompletionBlock(createdFilePath, YES);
    }
    else
    {
        _ioCompletionBlock(nil, NO);
    }
    });
    
}

-(void)abort
{
    
}


static NSCharacterSet *_illegalFileNameCharacters = nil;

+ (NSCharacterSet *)illegalFileNameCharacters
{
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
        _illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
	});
    return _illegalFileNameCharacters;
}


void (^exportBlock)(Note *note, NSString * toFolderPath, NSString **resultFilePath) = ^ (Note *note, NSString * toFolderPath, NSString **resultFilePath) {
    NSString * filename;
    filename = [note.syncID stringByAppendingPathExtension:@"txt"];
    
    NSString *exportPath = [toFolderPath stringByAppendingPathComponent:filename];
    
    NSError *error = nil;
    
    if([note.exportString writeToFile:exportPath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        
        if(note.creationDate)
        {
            NSDictionary *fileAttr = @{NSFileCreationDate: note.creationDate};
            [[NSFileManager defaultManager] setAttributes:fileAttr ofItemAtPath:exportPath error:NULL];
            
//            NSDictionary *ch = [[NSFileManager defaultManager] attributesOfItemAtPath:exportPath error:NULL];
//            DLog(@"cd: %@//%@", ch.fileCreationDate, excerpt.creationDate);
            
        }
        if(note.modifiedDate)
        {
            NSDictionary * fileAttr = @{NSFileModificationDate: note.modifiedDate};
            [[NSFileManager defaultManager] setAttributes:fileAttr ofItemAtPath:exportPath error:NULL];
            
//            NSDictionary *ch = [[NSFileManager defaultManager] attributesOfItemAtPath:exportPath error:NULL];
//            DLog(@"cd: %@// %@", ch.fileModificationDate, note.modifiedDate);
            
        }
        
        if(resultFilePath != NULL)
            *resultFilePath = exportPath;
        
        
    }
    else
    {
        DLog(@"%@", error);
    }
};


//##################### ZIP
#pragma mark Zip Action
- (void)doExport
{
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString *exportFolderName = [self folderNameForExporting:nil];
	NSString *exportFolderPath = [docPath stringByAppendingPathComponent:exportFolderName];
	
	double delayInSeconds = 0.25;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
		[[NSFileManager defaultManager] createDirectoryAtPath:exportFolderPath withIntermediateDirectories:YES attributes:nil error:NULL];
		
        if([_io_object isKindOfClass:[NSArray class]])
        {
            for(Note * note in _io_object)
            {
                exportBlock(note, exportFolderPath, nil);
            }
        }
        else
        {
            exportBlock(_io_object, exportFolderPath, nil);
        }
            
            NSString *zippedPath =  [exportFolderPath stringByAppendingPathExtension:@"zip"];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:exportFolderPath error:NULL];
            NSMutableArray * inputPaths = [NSMutableArray arrayWithCapacity:files.count];
            for(NSString *filename in files)
            {
                NSString *path = [exportFolderPath stringByAppendingPathComponent:filename];

                [inputPaths addObject:path];
            }
        

        if([SSZipArchive createZipFileAtPath:zippedPath withContentsOfDirectory:exportFolderPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:exportFolderPath error:nil];
            _ioCompletionBlock(zippedPath, YES);
            
        }
        else
        {
            _ioCompletionBlock(nil, NO);
        }
	});
}

-(NSString *)folderNameForExporting:(NSString *)exportID
{
    return @"Renote Archive";
}

-(void)dealloc
{
    _io_object = nil;
    _exportIdentifier = nil;
    _ioCompletionBlock = nil;
}

@end





