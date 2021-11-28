//
//  SyncManager.h
//  Vignettes
///Users/raheelsayeed/Downloads/ParcelKit-master/ParcelKit/PKSyncManager.m
//  Created by M Raheel Sayeed on 08/12/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>

@interface SyncManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) DBDatastore *datastore;
@property (nonatomic, copy) NSString *syncAttributeName;
@property (nonatomic) NSUInteger syncBatchSize;


+ (NSString *)syncID;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext datastore:(DBDatastore *)datastore;


-(void)importVignettesFromLocalFiles:(NSArray *)fileList;

- (BOOL)isObserving;

- (void)startObserving;
- (void)stopObserving;


- (void)startAutoImportAtFolderPath:(NSString *)dbFolderPath;
- (void)stopAutoImport;
- (void)toggleAutoImport:(BOOL)start;

@end
