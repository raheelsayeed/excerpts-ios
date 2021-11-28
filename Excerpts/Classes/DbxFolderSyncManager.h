//
//  DdxFolderSyncManager.h
//   Renote
//
//  Created by M Raheel Sayeed on 05/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>


static  NSString  const *  kDropboxAutoImportTagName = @"Dropbox AutoImport Files";


@interface DbxFolderSyncManager : NSObject

@property (nonatomic, assign, getter = isAutoImportEnabled) BOOL autoImportEnabled;
@property (nonatomic, readonly, getter = isPaused) BOOL paused;
@property (nonatomic) NSString * nameTag;
@property (nonatomic) NSString * syncPath;


- (instancetype)initWithDefaults;
- (instancetype)initWithSyncPath:(NSString *)syncPath dbxFilesystem:(DBFilesystem *)fs nameTag:(NSString *)filenameTag;


- (void)disableAutoImport;
- (void)enableAutoImport;

@end
