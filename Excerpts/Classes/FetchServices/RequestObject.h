//
//  SearchObject.h
//   Renote
//
//  Created by M Raheel Sayeed on 10/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIServices.h"


@class RequestObject;

@protocol RequestObjectLinkedDelegate <NSObject>
@optional
- (void)cacheData:(id)cache requestObject:(RequestObject *)ro;
- (id)cachedDataForRequestObject:(RequestObject *)ro;
- (void)requestObjectDidChange:(RequestObject *)ro;
@end


@class AFJSONRequestOperation;

typedef NS_ENUM(NSUInteger, ROFetchStatus)
{
    FetchIdle,
    FetchSuccessful,
	FetchFailed,
	FetchingInProgress,
    FetchRedirected,
    FetchFromCache
};

typedef NS_ENUM(NSUInteger, REQUEST_OBJECT_TYPE)
{
    REQUEST_OBJECT_TYPE_SEARCH,
    REQUEST_OBJECT_TYPE_FETCH,
    REQUEST_OBJECT_TYPE_WEBURL
};

extern NSString * const imgURLKey;
extern NSString * const titleKey;
extern NSString * const fetchedDataKey;

@interface RequestObject : NSObject

@property (nonatomic, readonly) NSArray * resultsArray;
@property (nonatomic) NSString * identifier;
@property (nonatomic) NSString * title;
@property (nonatomic, assign) API_SERVICE_TYPE serviceType;
@property (nonatomic, assign) REQUEST_OBJECT_TYPE requestType;
@property (nonatomic, copy) NSString * serviceKey;
@property (nonatomic) NSURL * primaryURL;
@property (nonatomic, readonly) NSURL * resolvedURL;
@property (nonatomic, readonly) float downloadProgress;
@property (nonatomic, assign, readonly) ROFetchStatus fetchStatus;
@property (nonatomic, weak) id<RequestObjectLinkedDelegate> linkedObject;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL cacheEnabled;



-(instancetype)initWithIdentifier:(NSString *)iden title:(NSString *)ntitle serviceKey:(NSString *)serviceKey;
- (instancetype)initWithURLString:(NSString *)urlString forDefinedServicesOnly:(BOOL)definedServicesOnly;


+ (NSDictionary *)linkIdentifierAndServiceKeyForURLString:(NSString *)urlstring;
+ (NSDictionary *)linkIdentifierAndServiceKeyForURLStrings:(NSArray *)urlstrings;

- (AFJSONRequestOperation *)initiateOperation;

- (void)resetDownloadStatus:(id)sender;
- (void)resetFetchStatus;
- (void)setStatusToFail;

+ (BOOL)canProcessImage:(NSURL *)imgURL;
- (void)cacheData:(id)data;
- (BOOL)assignCachedData:(id)cachedData;
- (BOOL)assignCachedDataFromLinkedObject;
- (NSURL *)urlForViewingLink;

@end
