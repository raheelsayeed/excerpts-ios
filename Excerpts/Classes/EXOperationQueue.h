//
//  EXOperationQueue.h
//   Renote
//
//  Created by M Raheel Sayeed on 15/07/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EXOperation;

typedef NS_ENUM(NSUInteger, EXOperationType) {
    EXOperationTypeIncoming,
    EXOperationTypeOutgoing,
    EXOperationTypeOutgoingFull,
};
typedef NS_ENUM(NSUInteger, EXTargetService) {
    EX_DROPBOX = 0,
    EX_EVERNOTE,
};

extern NSString * const kSyncEntitiesKey;
extern NSString * const kIncomingDataKey;
extern NSString * const kActiveDatastoreIdKey;
extern NSString * const kOutgoingDataKey;

@interface EXOperationQueue : NSObject

@property (nonatomic) NSOperationQueue *syncOperationQueue;
@property (nonatomic, assign, getter = isPausedOperationExecution) BOOL pauseOperationExecution;
+ (EXOperation *)operationEndedStatus;

+ (void)cancelAllOperations;
+ (EXOperationQueue*)shared;

+ (BOOL)idle;



+ (NSInvocationOperation *)uploadOperationToFilePath:(NSString *)filePath writeData:(id)data service:(EXTargetService)service;

+ (EXOperation *)fullOutgoingForService:(EXTargetService)service mapTable:(NSMapTable *)table userInfo:(NSDictionary *)info moc:(NSManagedObjectContext *)moc;



+ (EXOperation *)outgoingOperationForService:(EXTargetService)service mapTable:(NSMapTable*)table userInfo:(NSDictionary *)info moc:(NSManagedObjectContext *)moc;
+ (EXOperation *)incomingOperationForService:(EXTargetService)service mapTable:(NSMapTable *)table userInfo:(NSDictionary *)info moc:(NSManagedObjectContext *)moc;

@end

@interface EXOperation : NSOperation

@property (nonatomic, assign) EXOperationType operationType;
@property (nonatomic, assign) EXTargetService targetService;
@property (nonatomic, weak) id syncDelegate;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, weak) NSManagedObjectContext * managedContext;
@property (nonatomic, weak) id serviceHandler;
@property (nonatomic) NSDictionary * userInfo;
@property (nonatomic) NSMapTable * map;

- (instancetype)initWithOperation:(EXOperationType)type service:(EXTargetService)service mapTable:(NSMapTable*)table userInfo:(NSDictionary *)info moc:(NSManagedObjectContext *)moc;


@end