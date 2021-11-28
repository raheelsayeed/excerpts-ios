//
//  IOActions.h
//   Renote
//
//  Created by M Raheel Sayeed on 29/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNoteExtension @"note"


@class IOAction;


typedef void (^EICompletionBlock)(id  exportedObject, BOOL success);

@protocol IOActionDelegate

@optional
- (void)finishedIOActionWithSuccess:(BOOL)success finalExportObject:(id)exportedObject exportAction:(IOAction *)exportAction;
@end

@interface IOAction : NSObject

- (instancetype)initWithExportObject:(id)exportObject exportActionKey:(NSString *)exportActionKey;

- (void)startExportWithCompletion:(EICompletionBlock)completion;
- (void)startImportWithCompletion:(EICompletionBlock)completion;
+ (void)importOperationWithFileURL:(NSURL *)fileURL completion:(EICompletionBlock)completion;
- (void)abort;
+ (BOOL)importSampleDataFromBundleFolder:(NSString *)bundleFolder completion:(EICompletionBlock)completion;


@end
