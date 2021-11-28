//
//  APIServices.h
//   Renote
//
//  Created by M Raheel Sayeed on 11/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFJSONRequestOperation;

typedef NS_ENUM(NSUInteger, API_SERVICE_TYPE)
{
    API_SERVICE_TYPE_REDIRECTED,
    API_SERVICE_TYPE_WIKI,
    API_SERVICE_TYPE_YOUTUBE,
    API_SERVICE_TYPE_WIKIPHOTO,
    API_SERVICE_TYPE_TWITTER,
    API_SERVICE_TYPE_INSTAGRAM,
    API_SERVICE_TYPE_PUBMED,
    API_SERVICE_TYPE_WEBLINK,
    API_SERVICE_TYPE_WEBIMAGE,
    API_SERVICE_TYPE_WORDNIK,
    API_SERVICE_TYPE_VIMEO,
    API_SERVICE_TYPE_DROPBOX_IMAGE
};

static NSString * const kAPI_CODE_Wikipedia = @"wiki";
static NSString * const kAPI_CODE_Youtube   = @"ytube";
static NSString * const kAPI_CODE_PubMed    = @"pubmed";
static NSString * const kAPI_CODE_Wordnik   = @"wordnik";
static NSString * const kAPI_CODE_VIMEO     = @"vimeo";
static NSString * const kAPI_CODE_TWITTER     = @"twitter";
static NSString * const kAPI_CODE_DropboxImage = @"DropboxImage";
static NSString * const kAPI_CODE_Instagram = @"instagram";
static NSString * const kAPI_CODE_WebLink   = @"web";
static NSString * const kAPI_CODE_WebImage   = @"webImage";
static NSString * const kAPI_Title_PubMed = @"PubMed";
static NSString * const kAPI_Title_Wiki = @"Wikipedia";
static NSString * const kAPI_Title_Youtube = @"YouTube";
static NSString * const kAPI_Title_Instagram = @"Instagram";
static NSString * const kAPI_Title_Wordnik = @"Wordnik";
static NSString * const kAPI_Title_InternetLink = @"Web";
static NSString * const kAPI_Title_TwitterLink = @"twitter.com";
static NSString * const kAPI_Title_WikipediaImage = @"Wikipedia Photo";
static NSString * const kAPI_Title_WebImage = @"Photo";

static NSString * title = @"title";
static NSString * getAPI = @"getAPI";
static NSString * searchAPI = @"searchAPI";
static NSString * fetchKeyPath = @"fetchKeyPath";
static NSString * searchKeyPath = @"searchKeyPath";
static NSString * publicURL = @"publicURL";
static NSString * publicSearchURL = @"publicSearchURL";



@interface APIServices : NSObject
@property (nonatomic, strong, readonly) NSDictionary * apiDefinitions;
@property (nonatomic, strong) NSString * twitterBearerToken;

+ (instancetype)shared;
- (NSString *)searchKeyPathForServiceType:(API_SERVICE_TYPE)type;
- (NSString *)searchKeyPathForServiceKey:(NSString *)key;


- (NSString *)fetchKeyPathForServiceType:(API_SERVICE_TYPE)type;
- (NSString *)fetchKeyPathForServiceKey:(NSString *)key;

- (NSString *)fetchKP:(NSString*)serviceKey;
- (NSString *)searchKP:(NSString*)serviceKey;
- (NSString *)getURLString:(NSString*)serviceKey;
- (NSString *)searchURLString:(NSString*)serviceKey;
- (NSString *)publicURLString:(NSString *)serviceKey;
- (NSString *)completePublicURL:(NSString *)serviceKey identifier:(NSString *)identifier;
- (NSString *)completePublicURL:(NSString *)serviceKey identifier:(NSString *)identifier publicSearchLink:(BOOL)searchLink;
- (NSString *)titleForService:(NSString *)serviceKey;
- (NSString *)titleForService:(NSString *)serviceKey identifier:(NSString *)identifier;

- (NSDictionary *)captureDataFromJSON:(id)jsonObject forSearchServiceIdentifier:(NSString *)searchKey;
+ (NSArray *)mergeAllArraysInObjectsOfDictionary:(NSDictionary *)dictionary;
+ (NSArray *)mergeAllArraysInObjectsOfDictionary :(NSDictionary *)dictionary addKeyValueDict:(NSDictionary *)keyValDict;
- (AFJSONRequestOperation *)searchOperationForService:(NSString *)serviceKey
                                          searchTerm:(NSString *)searchTerm
                                             success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                             failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
@end
