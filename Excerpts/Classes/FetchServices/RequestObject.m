//
//  SearchObject.m
//   Renote
//
//  Created by M Raheel Sayeed on 10/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "RequestObject.h"
#import "AFJSONRequestOperation.h"
#import "APIServices.h"
#import "NSAttributedString+Excerpts.h"
#import "NSString+QSKit.h"
#import "NSURL+XCallBackURL.h"
#import "AshtonHTMLReader.h"



@implementation NSString (RequestObject)

-(NSString *)ro_urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}
- (NSString *)ro_URLEncode {
    NSString *encodedString = (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                     (__bridge CFStringRef)self,
                                                                                                     NULL,
                                                                                                     (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                                                     kCFStringEncodingUTF8);
    return encodedString;
}

- (NSString *)ro_URLDecode {
    NSString *decodedString = (__bridge_transfer NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)self,
                                                                                                                     CFSTR(""),
                                                                                                                     kCFStringEncodingUTF8);
    return decodedString;
}

@end


 NSString * const imgURLKey = @"imgURL";
 NSString * const titleKey = @"title";
 NSString * const fetchedDataKey = @"fetchedData";

@interface RequestObject ()
@property (nonatomic, strong, readwrite) NSArray * resultsArray;
@property (nonatomic, weak) APIServices *apiServices;
@property (nonatomic, strong, readwrite) NSURL * resolvedURL;
@property (nonatomic, readwrite) float downloadProgress;
@property (nonatomic, assign, readwrite) ROFetchStatus fetchStatus;

@end
@implementation RequestObject

+ (BOOL)canProcessImage:(NSURL *)imgURL {
    static NSSet * _acceptablePathExtension = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _acceptablePathExtension = [[NSSet alloc] initWithObjects:@"tif", @"tiff", @"jpg", @"jpeg", @"gif", @"png", @"ico", @"bmp", @"cur", nil];
    });
    return [_acceptablePathExtension containsObject:[[imgURL pathExtension] lowercaseString]];
}

- (instancetype)initWithURLString:(NSString *)urlString forDefinedServicesOnly:(BOOL)definedServicesOnly
{
    self = [self init];
    if(self)
    {
        NSURL * url = [NSURL URLWithString:urlString];
        
        if(!url || (url.host.length + 8 >= urlString.length)) return nil;
        
        self.requestType = REQUEST_OBJECT_TYPE_FETCH;
        self.primaryURL = url;

        if([[self class] canProcessImage:url])
        {
            self.identifier = urlString;
            self.serviceType = API_SERVICE_TYPE_WEBIMAGE;
            self.resultsArray =@[@{imgURLKey: _primaryURL.absoluteString,
                                   titleKey : _primaryURL.lastPathComponent}];
        }else
        {

  
                BOOL definable = [self checkAndConfigureURLForDefinedServices:url];
                
                if(!definable)
                {
                    return nil;
                    self.identifier = urlString;
                    self.serviceType = API_SERVICE_TYPE_WEBLINK;
                }
         
        }
        
    }
    return self;
}
-(instancetype)initWithIdentifier:(NSString *)iden title:(NSString *)ntitle serviceKey:(NSString *)serviceKey
{
    if(self = [super init])
    {
        self.identifier = iden;
        self.title = ntitle;
        self.serviceKey = serviceKey;
        self.apiServices = [APIServices shared];
        self.requestType = REQUEST_OBJECT_TYPE_FETCH;
        self.cacheEnabled = NO;
        self.fetchStatus = FetchIdle;

    }
    return self;
}

- (void)setIdentifier:(NSString *)identifier
{
    _identifier = identifier;
    
    if([identifier rangeOfString:@" "].location != NSNotFound)
    {
        // ::: WIKI Breakout.
        _identifier = [identifier stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    }
}

- (void)setServiceType:(API_SERVICE_TYPE)serviceType
{
    _serviceType = serviceType;
    
    switch (serviceType) {
        case API_SERVICE_TYPE_YOUTUBE:
            self.serviceKey = kAPI_CODE_Youtube;
            break;
        case API_SERVICE_TYPE_INSTAGRAM:
            self.serviceKey = kAPI_CODE_Instagram;
            break;
        case API_SERVICE_TYPE_PUBMED:
            self.serviceKey = kAPI_CODE_PubMed;
            break;
        case API_SERVICE_TYPE_TWITTER:
            self.serviceKey = kAPI_CODE_TWITTER;
            break;
        case API_SERVICE_TYPE_VIMEO:
            self.serviceKey = kAPI_CODE_VIMEO;
            break;
        case API_SERVICE_TYPE_WEBLINK:
            self.serviceKey = kAPI_CODE_WebLink;
            break;
        case API_SERVICE_TYPE_WORDNIK:
            self.serviceKey = kAPI_CODE_Wordnik;
            break;
        case API_SERVICE_TYPE_DROPBOX_IMAGE:
            self.serviceKey = kAPI_CODE_DropboxImage;
            break;
        case API_SERVICE_TYPE_WEBIMAGE:
            self.serviceKey = kAPI_CODE_WebImage;
            break;
        case API_SERVICE_TYPE_WIKI:
            self.serviceKey = kAPI_CODE_Wikipedia;
            break;
        default:
            break;
    }
    [self setTitle:[[APIServices shared] titleForService:_serviceKey]];
    
}


- (void)setServiceKey:(NSString *)serviceKey
{
    _serviceKey = serviceKey;
    
    if([serviceKey isEqualToString:kAPI_CODE_Wikipedia])
    {
        _serviceType = API_SERVICE_TYPE_WIKI;
    }
    else if([serviceKey isEqualToString:kAPI_CODE_Youtube])
    {
        _serviceType = API_SERVICE_TYPE_YOUTUBE;
    }
    else if ([serviceKey isEqualToString:kAPI_CODE_PubMed])
    {
        _serviceType = API_SERVICE_TYPE_PUBMED;
    }
    else if ([serviceKey isEqualToString:kAPI_CODE_WebLink])
    {
        _serviceType = API_SERVICE_TYPE_WEBLINK;
    }
    else if ([serviceKey isEqualToString:kAPI_CODE_Instagram])
    {
        _serviceType = API_SERVICE_TYPE_INSTAGRAM;
    }
    else if ([serviceKey isEqualToString:kAPI_CODE_Wordnik])
    {
        _serviceType = API_SERVICE_TYPE_WORDNIK;
    }
    else if ([serviceKey isEqualToString:kAPI_CODE_WebImage])
    {
        _serviceType = API_SERVICE_TYPE_WEBIMAGE;
    }
    else if([serviceKey isEqualToString:kAPI_CODE_VIMEO])
    {
        _serviceType = API_SERVICE_TYPE_VIMEO;
    }
    
    [self setTitle:[[APIServices shared] titleForService:_serviceKey]];
}

- (BOOL)assignCachedData:(id)cachedData
{
    return NO;
}

- (BOOL)assignCachedDataFromLinkedObject
{
    if(!_cacheEnabled) return NO;
    
    if(_linkedObject && [_linkedObject respondsToSelector:@selector(cachedDataForRequestObject:)])
    {
        id results = [_linkedObject cachedDataForRequestObject:self];
        
        if(results && [results isKindOfClass:[NSArray class]] && [results count] > 0)
        {
            self.resultsArray = results;
            self.fetchStatus = FetchFromCache;
            if(!_title) _title = [[_primaryURL absoluteString] uppercaseString];
            return YES;
        }
    }
    
    return NO;
}


- (void)cacheData:(id)data
{
    if(!_cacheEnabled || _requestType == REQUEST_OBJECT_TYPE_SEARCH || _fetchStatus == FetchFailed) return;
    
    if(_linkedObject && [_linkedObject respondsToSelector:@selector(cacheData:requestObject:)])
    {
        [_linkedObject cacheData:data requestObject:self];
    }
    
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    if(_linkedObject && [_linkedObject respondsToSelector:@selector(requestObjectDidChange:)])
    {
        [_linkedObject requestObjectDidChange:self];
    }
}

- (void)setDownloadProgress:(float)downloadProgress
{
    _downloadProgress = downloadProgress;
    
    if(_linkedObject && [_linkedObject respondsToSelector:@selector(requestObjectDidChange:)])
    {
        [_linkedObject requestObjectDidChange:self];
    }
}

- (void)setFetchStatus:(ROFetchStatus)fetchStatus
{
    _fetchStatus = fetchStatus;
    
    
    if(fetchStatus == FetchSuccessful)
    {
        if(_linkedObject && [_linkedObject respondsToSelector:@selector(requestObjectDidChange:)])
        {
            [_linkedObject requestObjectDidChange:self];
        }
    }
    
}



- (NSURL *)resolvedURL
{
    if(_resolvedURL) return _resolvedURL;
    
    if(self.requestType == REQUEST_OBJECT_TYPE_SEARCH)
    {
        self.resolvedURL = [self buildSearchURL];
        return _resolvedURL;
    }
    
    else if (self.requestType == REQUEST_OBJECT_TYPE_FETCH)
    {
        if(!_identifier)
        {
            if(![self checkAndConfigureURLForDefinedServices:_primaryURL])
            {
                self.identifier = _primaryURL.absoluteString;
                self.serviceType = API_SERVICE_TYPE_WEBLINK;
            }
        }
        
        self.resolvedURL = [self buildFetchURL];
        
        return _resolvedURL;
        
    }
    else
    {
        if(_primaryURL) return _primaryURL;
    }
    return nil;
}
+ (NSDictionary *)linkIdentifierAndServiceKeyForURLStrings:(NSArray *)urlstrings
{
    NSMutableDictionary * mdict = [NSMutableDictionary new];
    
    for(NSString * urlString in urlstrings)
    {
        NSDictionary * dict = [[self class] linkIdentifierAndServiceKeyForURLString:urlString];
        if(dict)
        {
            [mdict addEntriesFromDictionary:dict];
        }
    }
    
    return (mdict.count > 0) ? [mdict copy] : nil;
    
}
+ (NSDictionary *)linkIdentifierAndServiceKeyForURLString:(NSString *)urlstring
{
    
    NSRange range;
    
    range = [urlstring rangeOfString:kHOST_WIKIPEDIA_V2];
    if(range.location != NSNotFound)
    {
        NSString *identifier = [urlstring substringFromIndex:range.location+range.length];
        return (identifier) ?  @{[identifier stringByRemovingPercentEncoding]: kAPI_CODE_Wikipedia} : nil;
    }
    
    range = [urlstring rangeOfString:kHOST_YOUTUBE_V2];
    if(range.location != NSNotFound)
    {
         NSString *identifier = [urlstring substringFromIndex:range.location+range.length];
        return (identifier) ?  @{[identifier stringByRemovingPercentEncoding]: kAPI_CODE_Youtube} : nil;
    }
    
    range = [urlstring rangeOfString:kHOST_YOUTUBE_SHORT_V2];
    if(range.location != NSNotFound)
    {
         NSString *identifier = [urlstring substringFromIndex:range.location+range.length];
        return (identifier) ?  @{[identifier stringByRemovingPercentEncoding]: kAPI_CODE_Youtube} : nil;
    }
    return nil;
}



- (BOOL)checkAndConfigureURLForDefinedServices:(NSURL *)pURL
{
    BOOL defined = NO;
    
    NSString * urlString = pURL.absoluteString;
    
    //redirected
    if([pURL.host isEqualToString:kHOST_TCO])
    {
        self.serviceType = API_SERVICE_TYPE_REDIRECTED;
        defined = YES;
        
    }
    else if([urlString rangeOfString:kHOST_WIKIPEDIA].location != NSNotFound)
    {
        if([pURL pathComponents].count == 3)
        {
            self.serviceType = API_SERVICE_TYPE_WIKI;
            _identifier = [pURL pathComponents][[[pURL pathComponents] count]-1];
            defined = YES;
        }
    }
    
    else if([urlString rangeOfString:kHOST_INSTAGRAM].location != NSNotFound)
    {
        
        NSRange range = [urlString rangeOfString:kHOST_INSTAGRAM];
        NSString *iden = [urlString substringFromIndex:range.location+range.length];
        if(iden)
        {
            self.serviceType = API_SERVICE_TYPE_INSTAGRAM;
            self.identifier = iden;
            defined = YES;
        }
    }
    else if ([urlString rangeOfString:kHOST_INSTGRAM_SHORT].location != NSNotFound)
    {
        NSRange range = [urlString rangeOfString:kHOST_INSTGRAM_SHORT];
        NSString *iden = [urlString substringFromIndex:range.location+range.length];
        if(iden)
        {
            self.serviceType = API_SERVICE_TYPE_INSTAGRAM;
            self.identifier = iden;
            defined = YES;
        }
        
    }
    else if([pURL.absoluteString rangeOfString:kHOST_YOUTUBE].location != NSNotFound)
    {
        self.serviceType = API_SERVICE_TYPE_YOUTUBE;
        
        NSDictionary * paras = [pURL xCallbackURL_queryParameters];
        _identifier = paras[@"v"];
        defined = YES;
        
    }
    else if([pURL.absoluteString rangeOfString:kHOST_YOUTUBE_SHORT].location != NSNotFound)
    {
        self.serviceType = API_SERVICE_TYPE_YOUTUBE;
        _identifier = [pURL pathComponents][1];
        defined = YES;

        
    }
    else if(([pURL.absoluteString rangeOfString:kHOST_PUBMED].location != NSNotFound) || [pURL.absoluteString rangeOfString:kHOST_PUBMED_M].location != NSNotFound)
    {
        self.serviceType = API_SERVICE_TYPE_PUBMED;
        _identifier = [pURL pathComponents][[[pURL pathComponents] count]-1];
        defined = YES;

    }
    
    else if([urlString rangeOfString:kHOST_VIMEO_1].location == 0)
    {
        self.serviceType = API_SERVICE_TYPE_VIMEO;
        self.identifier = [urlString  lastPathComponent];
        defined = YES;

    }
    else if([urlString rangeOfString:kHOST_TWITTER_STATUS].location != NSNotFound && [urlString rangeOfString:kHOST_TWITTER_STATUS_2].location != NSNotFound)
    {
        NSRange range = [urlString rangeOfString:kHOST_TWITTER_STATUS_2];
        
        NSString * iden = [[[urlString substringFromIndex:range.location+range.length] pathComponents] firstObject];
        if(iden)
        {
            self.identifier = iden;
            self.serviceType = API_SERVICE_TYPE_TWITTER;
            defined = YES;
        }
    }
    
    return defined;
}


- (NSURL *)buildFetchURLAfterFilteringKnownServicesFromURL:(NSURL *)pURL
{
    if(![self checkAndConfigureURLForDefinedServices:pURL])
    {
        self.serviceType = API_SERVICE_TYPE_WEBLINK;
        self.identifier = pURL.absoluteString;
    }
    
    return [self buildFetchURL];
}



- (NSURL *)buildSearchURL
{
    if(!_identifier) return nil;
    

    
    NSString * searchURLString  = [[APIServices shared] searchURLString:_serviceKey];
    
    if(!searchURLString) return nil;
    
    searchURLString = [NSString stringWithFormat:searchURLString, [_identifier ro_urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL * url = [NSURL URLWithString:searchURLString];
    
    return url;
}
- (NSURL *)buildFetchURL
{
    if(_serviceType ==  API_SERVICE_TYPE_WEBIMAGE) return nil;
    
    if(_serviceType == API_SERVICE_TYPE_REDIRECTED) return _primaryURL;
        
    NSString * getURLString  = [[APIServices shared] getURLString:_serviceKey];
    
    if(!getURLString) return nil;
    
    
    getURLString = [NSString stringWithFormat:getURLString,_identifier];
    getURLString = [getURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    
    NSURL * url = [NSURL URLWithString:getURLString];
    
    
    return url;
    
}
- (void)setStatusToFail
{
    self.fetchStatus = FetchFailed;
}
- (void)resetFetchStatus
{
    if(_fetchStatus == FetchingInProgress || _fetchStatus == FetchRedirected)
    {
        self.fetchStatus = FetchIdle;
    }
}
- (void)resetDownloadStatus:(id)sender
{
    if(_downloadProgress < 1.0) _downloadProgress = 0.0;
}
- (NSURL *)filterRedirectedURL:(NSURL *)redirectedURL
{
    
    if(([redirectedURL.host isEqualToString:kHOST_TCO] || [redirectedURL.host length] < 6))
    {
        return redirectedURL;
    }
    else
    {
        self.resolvedURL = [self buildFetchURLAfterFilteringKnownServicesFromURL:redirectedURL];
        return _resolvedURL;
    }
    
}
- (NSURL *)urlForViewingLink
{
    if(_requestType == REQUEST_OBJECT_TYPE_SEARCH)
    {
        NSString * visitingURL  = [[APIServices shared] apiDefinitions][_serviceKey][publicSearchURL];
        visitingURL = [NSString stringWithFormat:visitingURL, [_identifier ro_URLEncode]];
        NSURL * url = [NSURL URLWithString:visitingURL];
        return url;
        
    }
    
    if(_primaryURL) return _primaryURL;
    

    /*
    if(_serviceType == API_SERVICE_TYPE_WEBLINK || _serviceType == API_SERVICE_TYPE_TWITTER || _serviceType == API_SERVICE_TYPE_INSTAGRAM|| _serviceType == API_SERVICE_TYPE_WEBIMAGE )
    {
        return self.primaryURL;
    }
    */

    
    NSString * visitingURL  = [[APIServices shared] publicURLString:_serviceKey];
    visitingURL = [NSString stringWithFormat:visitingURL, [_identifier ro_URLEncode]];
    NSURL * url = [NSURL URLWithString:visitingURL];
    return url;
}

static NSString * const kHOST_INSTAGRAM                 = @"http://instagram.com/p/";
static NSString * const kHOST_INSTGRAM_SHORT            = @"http://instagr.am/p/";
static NSString * const kHOST_INSTAGRAM_V2              = @"http://instagram.com/p/";
static NSString * const kHOST_INSTAGRAM_SHORT_V2        = @"http://instagr.am/p/";

static NSString * const kHOST_TCO                       = @"t.co";
static NSString * const kHOST_TWITTER_STATUS            = @"://twitter.com/";
static NSString * const kHOST_TWITTER_STATUS_2          =  @"/status/";

static NSString * const kHOST_YOUTUBE                   = @"youtube.com";
static NSString * const kHOST_YOUTUBE_SHORT             = @"youtu.be/";
static NSString * const kHOST_YOUTUBE_V2                = @"youtube.com/watch?v=";
static NSString * const kHOST_YOUTUBE_SHORT_V2          = @"youtu.be/";

static NSString * const kHOST_PUBMED                    = @"ncbi.nlm.nih.gov/pubmed/";
static NSString * const kHOST_PUBMED_M                  = @"ncbi.nlm.nih.gov/m/pubmed/";

static NSString * const kHOST_WIKIPEDIA                 = @"wikipedia.org/wiki/";
static NSString * const kHOST_WIKIPEDIA_V2              = @"wikipedia.org/wiki/";

static NSString * const kHOST_VIMEO_1                   = @"http://vimeo.com/";
static NSString * const kOperationExecutingStatusKey     = @"isExecuting";



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if([keyPath isEqualToString:@"isExecuting"])
    {
        self.fetchStatus = FetchingInProgress;
        [object removeObserver:self forKeyPath:keyPath context:nil];
    }
    
    
}

+ (NSURLRequest *)twitterRequestWithURL:(NSURL *)url
{
    if(![APIServices shared].twitterBearerToken)
    {
        NSString *key = @"Om3eLSYJx7WO2oll0e2kz3euf";
        NSString *rfc1738key = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *secret = @"svN01UYrh9gPYGYr6gT0XkGsaAaBb3VgJTT1jNCTa5eIqGK0zJ";
        NSString *rfc1738secret = [secret stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *concat = [NSString stringWithFormat:@"%@:%@", rfc1738key, rfc1738secret];
        NSString *enc = [[concat dataUsingEncoding:NSUTF8StringEncoding] base64Encoding];
        NSURL *theURL = [NSURL URLWithString:@"https://api.twitter.com/oauth2/token"];
        NSMutableURLRequest *getToken = [NSMutableURLRequest requestWithURL:theURL];
        [getToken addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", enc];
        [getToken addValue:authValue forHTTPHeaderField:@"Authorization"];
        
        NSString *post = @"grant_type=client_credentials";
        NSData *body = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        [getToken setHTTPMethod:@"POST"];
        [getToken setValue:[NSString stringWithFormat:@"%u", (unsigned int)[body length]] forHTTPHeaderField:@"Content-Length"];
        [getToken setHTTPBody:body];
        return [getToken copy];
    }else
    {
        NSMutableURLRequest *twitterrequest = [NSMutableURLRequest requestWithURL:url];
        [twitterrequest addValue:[NSString stringWithFormat:@"Bearer %@",[APIServices shared].twitterBearerToken] forHTTPHeaderField:@"Authorization"];
        [twitterrequest setHTTPMethod:@"GET"];
        return  [twitterrequest copy];
    }
}

- (AFJSONRequestOperation *)initiateOperation
{
//    NSLog( @"RSOLVED: %@\n%@", self.resolvedURL.description, self.description);
    
    if(_serviceType == API_SERVICE_TYPE_WEBIMAGE
       //||_serviceType == API_SERVICE_TYPE_WEBLINK
       ) return nil;
    
    
    
    NSURLRequest * urlrequest;
    if(!self.resolvedURL)
    {
        self.fetchStatus = FetchFailed;
        return nil;
    }

    if(_serviceType == API_SERVICE_TYPE_TWITTER)
    {
        urlrequest = [RequestObject twitterRequestWithURL:self.resolvedURL];
    }
    else
    {
        urlrequest = [[NSURLRequest alloc] initWithURL:self.resolvedURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    }
    
    
    
    
    __weak typeof (self) weakSelf = self;

    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:urlrequest];
    [operation addObserver:self forKeyPath:@"isExecuting" options:NSKeyValueObservingOptionNew context:nil];

    
    
    
    [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse)
    {
        
        weakSelf.fetchStatus = FetchRedirected;
        
        if(!redirectResponse) return request;
        
        NSURL * url = [weakSelf filterRedirectedURL:request.URL];
        
        if(weakSelf.serviceType == API_SERVICE_TYPE_TWITTER)
        {
            return [RequestObject twitterRequestWithURL:url];
            
        } else 
        return [[NSURLRequest alloc] initWithURL:url];
    }];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         if([[[operation.response valueForKey:@"URL"] absoluteString] isEqualToString:@"https://api.twitter.com/oauth2/token"] )
         {
             [[APIServices shared] setTwitterBearerToken:[responseObject objectForKey:@"access_token"]];
             [[weakSelf initiateOperation] start];
             return;
         }
         
         NSArray * results;
         static NSString *kfetchedDataKey = @"fetchedData";
         if(weakSelf.requestType == REQUEST_OBJECT_TYPE_SEARCH)
         {
             NSMutableDictionary * dict = [[weakSelf captureDataFromJSON:responseObject forSearchServiceIdentifier:[weakSelf serviceKey]] mutableCopy];
             if(dict && [dict allKeys] > 0)
             {
                 if(dict[kfetchedDataKey])
                 {
                     NSMutableArray * fetchedD =     [dict[kfetchedDataKey]mutableCopy];
                     [fetchedD enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                      {
                          [fetchedD replaceObjectAtIndex:idx withObject:[weakSelf attrStringForData:obj]];
                      }];
                     dict[kfetchedDataKey] = [fetchedD copy];
                 }
                 results   = [[weakSelf class] mergeAllArraysInObjectsOfDictionar:dict addKeyValueDict:@{@"serviceKey": [weakSelf serviceKey]}];
             }
         }
         else
         {
             NSMutableDictionary * dict = [[weakSelf captureDataFromJSON:responseObject] mutableCopy];
             if([dict[kfetchedDataKey] length] == 0)
             {
                 [dict removeObjectForKey:kfetchedDataKey];
             }else
             {
                 NSAttributedString * attr  = [weakSelf attrStringForData:dict[kfetchedDataKey]];
                 if(attr)
                 {
                     dict[kfetchedDataKey] = attr;
                 }
                 else
                 {
                     [dict removeObjectForKey:kfetchedDataKey];
                 }
             }
             results = @[[dict copy]];
         }
         [weakSelf setResultsArray:results];
         [weakSelf setDownloadProgress:1.0];
         
         [weakSelf setFetchStatus:FetchSuccessful];
         [weakSelf cacheData:weakSelf.resultsArray];


         
     } failure:^(AFHTTPRequestOperation *operation, NSError * error)
     {
         if(!weakSelf) return;

         
         NSDictionary * failed;
         if(weakSelf.requestType == REQUEST_OBJECT_TYPE_SEARCH)
         {
             failed = @{titleKey: @"SEARCH",
                        fetchedDataKey: [[NSAttributedString alloc] initWithString:weakSelf.identifier]};

         }
         else
         {
             switch (weakSelf.serviceType) {
                    case API_SERVICE_TYPE_REDIRECTED:
                    case API_SERVICE_TYPE_WEBLINK:
                    {
                        failed = @{titleKey: [weakSelf.primaryURL host]};
//                                   fetchedDataKey: [[NSAttributedString alloc] initWithString:weakSelf.primaryURL.absoluteString]};
                        break;
                    }
                 default:
                 {
                     failed = @{titleKey        : weakSelf.identifier};//,
//                                fetchedDataKey  :[[NSAttributedString alloc] initWithString:weakSelf.identifier]};
                     break;

                 }
             }
         }
         [weakSelf setResultsArray:@[failed]];
         [weakSelf setDownloadProgress:0.0];
         [weakSelf setFetchStatus:FetchFailed];
     }];
    
    
    return operation;
}


static NSString * const kAllotSeparator = @"=>";
static NSString * const kMutlipleSegmentDelimitor = @"|";


- (id)setCapturedObjectFromJSON:(id)json segmentKey:(NSString *)segmentKey inDict:(NSMutableDictionary *)mdict
{
//    NSLog(@"CAPTURE(%@): %@",_serviceKey, segmentKey);
    
    if([segmentKey rangeOfString:kAllotSeparator].location != NSNotFound)
    {
        //Alloting Segment Keys are always contain '=>' and if multiple, are separated by a |.
        NSArray * multipleSegments = [segmentKey componentsSeparatedByString:kMutlipleSegmentDelimitor];
        __block NSString * lastKeySegment;
        [multipleSegments enumerateObjectsUsingBlock:^(NSString * segkey, NSUInteger idx, BOOL * stop)
         {
             
             NSRange segKeyRange = [segkey rangeOfString:kAllotSeparator];
             
             if(segKeyRange.location == NSNotFound)
             {
                 //move Along.
                 lastKeySegment = segkey;
                 *stop = YES;
                 return;
             }
             NSString * jsonKey = [segkey substringToIndex:segKeyRange.location];
             NSString * objectKey = [segkey substringFromIndex:segKeyRange.location+segKeyRange.length];
             lastKeySegment = jsonKey;
             id result = [self resultObjForSegmentKey:jsonKey inJSON:json];
             if(nil != result && ![[NSNull null] isEqual:result])
             {
                 [mdict setObject:result forKey:objectKey];
             }
         }];
        
        if([segmentKey isEqualToString:@"$_POINTER"])
        {
            [mdict setObject:json forKey:segmentKey];
            return json;
        }
        else if ([segmentKey isEqualToString:@"$_GOTO_POINTER"])
        {
            id pointerJSON = mdict[@"$_POINTER"];
            [mdict removeObjectForKey:@"$_POINTER"];
            return pointerJSON;
        }
        
        return  [self resultObjForSegmentKey:lastKeySegment inJSON:json];
    }

    if([segmentKey isEqualToString:@"$_POINTER"])
    {
        [mdict setObject:json forKey:segmentKey];
        return json;
    }
    else if ([segmentKey isEqualToString:@"$_GOTO_POINTER"])
    {
        id pointerJSON = mdict[@"$_POINTER"];
        [mdict removeObjectForKey:@"$_POINTER"];
        return pointerJSON;
    }
    
    return  [self resultObjForSegmentKey:segmentKey inJSON:json];
}

- (NSDictionary *)captureDataFromJSON:(id)jsonObject
{
    if(!jsonObject) return nil;
    
    NSString *keyPath = [[APIServices shared] fetchKP:_serviceKey];
    
    NSMutableDictionary * mutableD = [NSMutableDictionary new];
    [self captureKeys:keyPath forJSON:jsonObject intoDictionary:mutableD];
    
    return [mutableD copy];
}


- (NSDictionary *)captureDataFromJSON:(id)jsonObject forSearchServiceIdentifier:(NSString *)searchKey
{
    if(!jsonObject || [jsonObject count] == 0) return nil;
    
    NSString * searchKeyPath = [[APIServices shared] searchKP:searchKey];
    if(!searchKeyPath) return nil;
    NSMutableDictionary * mutableD = [NSMutableDictionary new];
    [self captureKeys:searchKeyPath forJSON:jsonObject intoDictionary:mutableD];
    return [mutableD copy];
}

- (void)captureKeys:(NSString *)keyPath forJSON:(id)jsonObject intoDictionary:(NSMutableDictionary *)mdict
{
    if(!jsonObject || [jsonObject count]==0) return;
    __block id jsonToParse = jsonObject;
    
    NSArray * keysArray = [keyPath componentsSeparatedByString:@"."];
//    __block NSUInteger segments = keysArray.count;
    [keysArray enumerateObjectsUsingBlock:^(NSString * segmentKey, NSUInteger idx, BOOL * stop)
     {
         //:::Later
//         if(idx == segments-1) NSLog(@"stopped");
         jsonToParse = [self setCapturedObjectFromJSON:jsonToParse segmentKey:segmentKey inDict:mdict];
     }];
    
//    DLog(@"%@", [mdict description]);
    
}


- (id)resultObjForSegmentKey:(NSString *)segment inJSON:(id)json
{
    BOOL jsonIsArray = [json isKindOfClass:[NSArray class]];
    
    static NSString * arrayKey = @"[*]";
    static NSString * unknownKey = @"$_UNKNOWN_KEY";
    static NSString * identifierKey = @"$_IDENTIFIER";
    static NSString * bracketKey = @"[";
    
    
    
    if([segment isEqualToString:arrayKey])
    {
        return json;
    }
    else if([segment isEqualToString:unknownKey])
    {
        //Sending the first key :(
        NSArray *keyArray = [json allKeys];
        return json[keyArray[0]];
        
    }
    else if([segment rangeOfString:bracketKey].location != NSNotFound)
    {
        NSString * idxStr = [segment substringWithRange:NSMakeRange(1,[segment length]-2)];
        if(jsonIsArray)
        {
//            NSLog(@"its an array");
            NSInteger idx = [idxStr integerValue];
            return (idx < [json count]) ? json[idx] : nil;
//            return json[[idxStr integerValue]];
//            return [json objectAtIndex:[idxStr integerValue]  ];
        }
    }
    else if([segment isEqualToString:identifierKey])
    {
        return json[_identifier];
    }
    
    
    
    return (jsonIsArray) ? [self returnArrayForJSONArray:json cleanSegmentKey:segment] : json[segment];
}


//Nested Arrays cannot work!
- (NSArray *)returnArrayForJSONArray:(id)JSONArray cleanSegmentKey:(NSString *)cleanSegmentKey
{
    NSMutableArray * retArray = [NSMutableArray new];
    
    for(id json in JSONArray)
    {
        [retArray addObject:json[cleanSegmentKey]];
    }
    
    return [retArray copy];
}

- (void)dealloc
{
    self.resultsArray = nil;


}

+ (NSArray *)mergeAllArraysInObjectsOfDictionar:(NSDictionary *)dictionary addKeyValueDict:(NSDictionary *)keyValDict
{
    for(id obj in [dictionary allValues])
    {
        if(![obj isKindOfClass:[NSArray class]]) return nil;
    }
    
    
    NSArray * allKeys = [dictionary allKeys];
    NSUInteger numberOfArrays = [allKeys count];
    
    if(numberOfArrays == 0) return nil;
    
    NSUInteger sampleArrayIdx = 0;
    
    
    NSArray * sampleArrayOfFirstKey = dictionary[allKeys[sampleArrayIdx]];
    
    
    NSMutableArray * finalArray = [NSMutableArray new];
    
    
    [sampleArrayOfFirstKey enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop)
     {
         NSMutableDictionary * mdict = [NSMutableDictionary new];
         for(int i = 0; i<allKeys.count; i++)
         {
             NSString * key = allKeys[i];
             
             if(i == sampleArrayIdx)
             {
                 [mdict setObject:obj forKey:key];
             }
             else
             {
                 //get array.
                 NSArray * array = dictionary[key];
                 [mdict setObject:array[idx] forKey:key];
             }
         }
         
         
         if(keyValDict) [mdict addEntriesFromDictionary:keyValDict];
         
         [finalArray addObject:[mdict copy]];
         
     }];
    
    return [finalArray copy];
    
}


+ (NSArray *)mergeAllArraysInObjectsOfDictionar:(NSDictionary *)dictionary
{
    
    for(id obj in [dictionary allValues])
    {
        if(![obj isKindOfClass:[NSArray class]]) return nil;
    }
    
    NSArray * allKeys = [dictionary allKeys];
    NSUInteger numberOfArrays = [allKeys count];
    
    if(numberOfArrays == 0) return nil;
    
    NSUInteger sampleArrayIdx = 0;
    
    
    NSArray * sampleArrayOfFirstKey = dictionary[allKeys[sampleArrayIdx]];
    
    
    NSMutableArray * finalArray = [NSMutableArray new];
    
    
    [sampleArrayOfFirstKey enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop)
     {
         NSMutableDictionary * mdict = [NSMutableDictionary new];
         for(int i = 0; i<allKeys.count; i++)
         {
             NSString * key = allKeys[i];
             
             if(i == sampleArrayIdx)
             {
                 [mdict setObject:obj forKey:key];
             }
             else
             {
                 //get array.
                 NSArray * array = dictionary[key];
                 [mdict setObject:array[idx] forKey:key];
             }
         }
         
         [finalArray addObject:mdict];
         
     }];
    
    
    
    
    return [finalArray copy];
}

-(NSAttributedString *)attrStringForData:(NSString *)data
{
    static NSDictionary * titleAttribtues = nil;
    if(!titleAttribtues)
    {
        titleAttribtues =@{NSFontAttributeName: [UIFont boldSystemFontOfSize:14],
                           NSForegroundColorAttributeName: [UIColor blackColor]
                           };
    }
    
    if([data length] > 0)
        
    {
        return [[AshtonHTMLReader HTMLReader] attributedStringFromHTMLString:data];
    }
    
        return nil;
}
@end
