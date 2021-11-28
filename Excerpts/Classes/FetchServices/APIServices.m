
//
//  APIServices.m
//   Renote
//
//  Created by M Raheel Sayeed on 11/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "APIServices.h"
#import "AFJSONRequestOperation.h"
#import "NSString+RSParser.h"

@interface APIServices ()
@property (nonatomic, strong, readwrite) NSDictionary * apiDefinitions;

@end
@implementation APIServices



+ (instancetype)shared {
    static APIServices *_shared = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _shared = [[self alloc] init];
        _shared.twitterBearerToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterBeararToken"];
    });
    return _shared;
}




static NSString * const kAPI_KEYPATH_SEARCH_WIKI = @"query.search.[*].title=>identifier|title=>title|snippet=>fetchedData";
static NSString * const kAPI_KEYPATH_SEARCH_YOUTUBE = @"data.items.[*].id=>identifier|title=>title|description=>fetchedData|thumbnail.sqDefault=>imgURL";
static NSString * const kAPI_KEYPATH_SEARCH_WORDNIK = @"[*].word=>title|word=>identifier|text=>fetchedData";
static NSString * const kAPI_KEYPATH_SEARCH_PUBMED_YAHOOPIPES = @"value.items.[*].MedlineCitation.Article.ArticleTitle=>title|Journal.Title=>fetchedData";
static NSString * const kAPI_KEYPATH_SEARCH_PUBMED_YAHOOPIPES_REV1 = @"value.items.[*].MedlineCitation.$_POINTER.PMID.content=>identifier.$_GOTO_POINTER.Article.ArticleTitle=>fetchedData|Journal.Title=>title";


//### FETCH KEYS
static NSString * const kAPI_KEYPATH_FETCH_WIKI = @"query.pages.$_UNKNOWN_KEY.title=>title|extract=>fetchedData|thumbnail.source=>imgURL"; // wiki
static NSString * const kAPI_KEYPATH_FETCH_YOUTUBE = @"items.[0].snippet.title=>title|description=>fetchedData|thumbnails.high.url=>imgURL";
static NSString * const kAPI_KEYPATH_FETCH_PUBMED = @"result.$_IDENTIFIER.fulljournalname=>title|title=>fetchedData";
//http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=21631322&retmode=json
//http://www.ncbi.nlm.nih.gov/books/NBK25499/
//@"value.title=>fetchedTitle|items.[*].MedlineCitation.Article.ArticleTitle=>fetchedData|Journal.Title=>JournalTitle|ISOAbbreviation=>abbrviation";
static NSString * const kAPI_KEYPATH_FETCH_READABILITY = @"excerpt=>fetchedData|lead_image_url=>imgURL|title=>title";
static NSString * const kAPI_KEYPATH_FETCH_BOILERPIPE = @"response.title=>title|content=>fetchedData|images.[0].src=>imgURL";

static NSString * const kAPI_KEYPATH_FETCH_INSTAGRAM = @"title=>fetchedData|thumbnail_url=>imgURL|author_name=>title";
static NSString * const kAPI_KEYPATH_FETCH_VIMEO_EMBED = @"title=>title|thumbnail_url=>imgURL|description=>fetchedData";
static NSString * const kAPI_KEYPATH_FETCH_TWITTER_EMBED = @"author_name=>title|html=>fetchedData|";
static NSString * const kAPI_KEYPATH_FETCH_TWITTER_GET_STATUS = @"$_POINTER.text=>fetchedData|user.screen_name=>title.$_GOTO_POINTER.entities.media.[0].media_url=>imgURL";



- (NSString *)searchKeyPathForServiceType:(API_SERVICE_TYPE)type
{
    switch (type) {
        case API_SERVICE_TYPE_PUBMED:
            return kAPI_KEYPATH_SEARCH_PUBMED_YAHOOPIPES_REV1;
            break;
        case API_SERVICE_TYPE_WORDNIK:
            return kAPI_KEYPATH_SEARCH_WORDNIK;
            break;
            
        case API_SERVICE_TYPE_WIKI:
            return kAPI_KEYPATH_SEARCH_WIKI;
            break;
        
        case API_SERVICE_TYPE_YOUTUBE:
            return kAPI_KEYPATH_SEARCH_YOUTUBE;
            break;
        default:
            return nil;
            break;
    }
}
- (NSString *)searchKeyPathForServiceKey:(NSString *)key
{
    if([key isEqualToString:kAPI_CODE_Wikipedia])
    {
        return kAPI_KEYPATH_SEARCH_WIKI;
    }
    if([key isEqualToString:kAPI_CODE_Youtube])
    {
        return kAPI_KEYPATH_SEARCH_YOUTUBE;
    }
    if([key isEqualToString:kAPI_CODE_PubMed])
    {
        return kAPI_KEYPATH_SEARCH_PUBMED_YAHOOPIPES_REV1;
    }
    if([key isEqualToString:kAPI_CODE_Wordnik])
    {
        return kAPI_KEYPATH_SEARCH_WORDNIK;
    }
    return nil;
}

- (NSString *)fetchKeyPathForServiceType:(API_SERVICE_TYPE)type
{
    switch (type) {
        case API_SERVICE_TYPE_PUBMED:
            return kAPI_KEYPATH_FETCH_PUBMED;
            break;
            
        case API_SERVICE_TYPE_WIKI:
            return kAPI_KEYPATH_FETCH_WIKI;
            break;
            
        case API_SERVICE_TYPE_YOUTUBE:
            return kAPI_KEYPATH_FETCH_YOUTUBE;
            break;
            
        case API_SERVICE_TYPE_INSTAGRAM:
            return kAPI_KEYPATH_FETCH_INSTAGRAM;
            break;
            
        case API_SERVICE_TYPE_WEBLINK:
            return kAPI_KEYPATH_FETCH_READABILITY;
            break;
            
        default:
            return nil;
            break;
    }
}
- (NSString *)fetchKeyPathForServiceKey:(NSString *)key
{
    
    return nil;
}

- (NSDictionary *)apiDefinitions
{
    if(_apiDefinitions) return _apiDefinitions;
    
    self.apiDefinitions =
    
            @{kAPI_CODE_Wikipedia:
                 @{title: kAPI_Title_Wiki,
                   getAPI: @"http://en.wikipedia.org/w/api.php?action=query&titles=%@&prop=extracts|pageimages&exintro&indexpageids&piprop=thumbnail|name&pilimit=3&pithumbsize=500&format=json",
                   searchAPI  : @"http://www.wikipedia.org/w/api.php?action=query&list=search&srwhat=text&srsearch=%@&format=json",
                   fetchKeyPath : kAPI_KEYPATH_FETCH_WIKI,
                   searchKeyPath: kAPI_KEYPATH_SEARCH_WIKI,
                   publicURL: @"http://wikipedia.org/wiki/%@"
                   },
             
             kAPI_CODE_Youtube:
                 @{title: kAPI_Title_Youtube,
                   getAPI: @"https://www.googleapis.com/youtube/v3/videos?id=%@&key=AIzaSyBhUTii8-gXwwVi_9uzVmtEZduX4GnmYqU&part=snippet,contentDetails,statistics,status",
                   searchAPI  : @"http://gdata.youtube.com/feeds/api/videos?q=%@&v=2&alt=jsonc&max-results=11",
                   fetchKeyPath : kAPI_KEYPATH_FETCH_YOUTUBE,
                   searchKeyPath: kAPI_KEYPATH_SEARCH_YOUTUBE,
                   publicURL: @"http://www.youtube.com/watch?v=%@"
                   },
              
              kAPI_CODE_PubMed:
                  @{title: kAPI_Title_PubMed,
                    getAPI: @"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=%@&retmode=json",
                    searchAPI  : @"http://pipes.yahoo.com/pipes/pipe.run?_id=1b39ecc3914d5f3f2570d8800e5e80a2&_render=json&n=10&offset=0&q=%@",
                    fetchKeyPath : kAPI_KEYPATH_FETCH_PUBMED,
                    searchKeyPath: kAPI_KEYPATH_SEARCH_PUBMED_YAHOOPIPES_REV1,
                    publicURL: @"http://ncbi.nlm.nih.gov/pubmed/%@",
                    publicSearchURL: @"http://www.ncbi.nlm.nih.gov/pubmed?term=%@&dispmax=50"
                    },
              /*
              kAPI_CODE_WebLink:
                  @{title: kAPI_Title_InternetLink,
                    getAPI: @"http://www.readability.com/api/content/v1/parser?url=%@&token=f33f3280f5aa9aac744cb84b21797ffd4e0d0188",
                    fetchKeyPath: kAPI_KEYPATH_FETCH_READABILITY},
              */
              
              //http://www.readability.com/api/content/v1/parser?url=http://indianexpress.com/article/cities/delhi/delhi-university-in-process-of-developing-math-kits-for-blind-students/&token=f33f3280f5aa9aac744cb84b21797ffd4e0d0188
              
              //http://boilerpipe-web.appspot.com/extract?url=http%3A%2F%2Fsmartddx.com%2Flabgear&extractor=ArticleExtractor&output=json&extractImages=3
              
              kAPI_CODE_WebLink:
                  @{title: kAPI_Title_InternetLink,
                    getAPI: @"http://boilerpipe-web.appspot.com/extract?url=%@&extractor=ArticleExtractor&output=json&extractImages=1",
                    fetchKeyPath: kAPI_KEYPATH_FETCH_BOILERPIPE},
              
              kAPI_CODE_Instagram:
                  @{title: kAPI_Title_Instagram,
                    getAPI: @"http://api.instagram.com/oembed?url=http://instagram.com/p/%@",
                    fetchKeyPath: kAPI_KEYPATH_FETCH_INSTAGRAM,
                    publicURL: @"http://instagram.com/p/%@"}, // Identifier is the URL itself, hence will give an empty String.
              
              kAPI_CODE_Wordnik:
                  @{title: kAPI_Title_Wordnik,
                    searchAPI: @"http://api.wordnik.com:80/v4/word.json/%@/definitions?limit=4&includeRelated=true&sourceDictionaries=all&useCanonical=true&includeTags=true&api_key=ef8a9d0ab4490fdddc0050e3bc709585437ee1d5a8a25daae",
                    publicURL: @"https://www.wordnik.com/words/%@",
                    searchKeyPath: kAPI_KEYPATH_SEARCH_WORDNIK,
                    },
              
              kAPI_CODE_WebImage:
                  @{title: kAPI_Title_WebImage},
              
              kAPI_CODE_VIMEO:
                  @{title: @"Vimeo",
                    getAPI: @"http://vimeo.com/api/oembed.json?url=http://vimeo.com/%@",
                    fetchKeyPath: kAPI_KEYPATH_FETCH_VIMEO_EMBED,
                    publicURL: @"http://vimeo.com/m/%@"},
              
              kAPI_CODE_TWITTER:
                  @{title: @"Twitter",
                    getAPI: @"https://api.twitter.com/1.1/statuses/show/%@.json",//@"https://api.twitter.com/1/statuses/oembed.json?id=%@",
                    fetchKeyPath: kAPI_KEYPATH_FETCH_TWITTER_GET_STATUS,
                    publicURL: @"http://twitter.com/status/%@"}
              
             };
    
    //https://api.twitter.com/1/statuses/oembed.json?id=463440424141459456
    
    return _apiDefinitions;
}
- (NSString *)fetchKP:(NSString*)serviceKey
{
    return self.apiDefinitions[serviceKey][fetchKeyPath];
}
- (NSString *)searchKP:(NSString*)serviceKey
{
    return self.apiDefinitions[serviceKey][searchKeyPath];

}
- (NSString *)getURLString:(NSString*)serviceKey
{
    return self.apiDefinitions[serviceKey][getAPI];
}
- (NSString *)searchURLString:(NSString*)serviceKey
{
    return self.apiDefinitions[serviceKey][searchAPI];
}
- (NSString *)publicURLString:(NSString *)serviceKey
{
    return self.apiDefinitions[serviceKey][publicURL];
}
- (NSString *)completePublicURL:(NSString *)serviceKey identifier:(NSString *)identifier
{
    
    return [self completePublicURL:serviceKey identifier:identifier publicSearchLink:NO];
}
- (NSString *)completePublicURL:(NSString *)serviceKey identifier:(NSString *)identifier publicSearchLink:(BOOL)searchLink
{
    NSString * urlstring;
    
    if(searchLink)
    {
        urlstring = self.apiDefinitions[serviceKey][publicSearchURL];
    }
    else
    {
        urlstring = [self publicURLString:serviceKey];
    }

    return [NSString stringWithFormat:urlstring, identifier];
}
- (NSString *)titleForService:(NSString *)serviceKey
{
    return self.apiDefinitions[serviceKey][title];
}
- (NSString *)titleForService:(NSString *)serviceKey identifier:(NSString *)identifier
{
    if(!serviceKey) return nil;
    if(!identifier) return [self titleForService:serviceKey];
    
    if([serviceKey isEqualToString:kAPI_CODE_TWITTER])
    {
        return [NSString stringWithFormat:@"@%@", identifier];
    }
    else
    if([serviceKey isEqualToString:kAPI_CODE_Wikipedia])
    {
        return [identifier stringByRemovingPercentEncoding];
    }
    else
    
    if([serviceKey isEqualToString:kAPI_CODE_Youtube])
    {
        return identifier;
    }
    
    return [self titleForService:serviceKey];
}


//#################################################################################################################################
//#################################################################################################################################
//#################################################################################################################################

//###################################################################
//###################################################################

static NSString * const kAllotSeparator = @"=>";
static NSString * const kMutlipleSegmentDelimitor = @"|";


- (id)setCapturedObjectFromJSON:(id)json segmentKey:(NSString *)segmentKey inDict:(NSMutableDictionary *)mdict
{
    //NSLog(@"CAPTURE: %@", segmentKey);
    
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

- (NSDictionary *)captureDataFromJSON:(id)jsonObject forSearchServiceIdentifier:(NSString *)searchKey
{
    if(!jsonObject || [jsonObject count] == 0) return nil;
    
    NSString * searchKeyPath = [self searchKP:searchKey];
    
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
    __block NSUInteger segments = keysArray.count;
    [keysArray enumerateObjectsUsingBlock:^(NSString * segmentKey, NSUInteger idx, BOOL * stop)
     {
//         if(idx == segments-1) NSLog(@"stopped");
         jsonToParse = [self setCapturedObjectFromJSON:jsonToParse segmentKey:segmentKey inDict:mdict];
     }];
    
//    DLog(@"%@", [mdict description]);
    
}


- (id)resultObjForSegmentKey:(NSString *)segment inJSON:(id)json
{
    BOOL jsonIsArray = [json isKindOfClass:[NSArray class]];
    
    
    
    
    if([segment isEqualToString:@"[*]"])
    {
        return json;
    }
    else if([segment isEqualToString:@"$_UNKNOWN_KEY"])
    {
        //Sending the first key :(
        NSArray *keyArray = [json allKeys];
        return json[keyArray[0]];
        
    }
    else if([segment rangeOfString:@"["].location != NSNotFound)
    {
        NSString * idxStr = [segment substringWithRange:NSMakeRange(1,[segment length]-2)];
        if(jsonIsArray)
        {
//            NSLog(@"its an array");
            return [json objectAtIndex:[idxStr integerValue]  ];
        }
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



+ (NSArray *)mergeAllArraysInObjectsOfDictionary :(NSDictionary *)dictionary addKeyValueDict:(NSDictionary *)keyValDict
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


+ (NSArray *)mergeAllArraysInObjectsOfDictionary:(NSDictionary *)dictionary
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

-(AFJSONRequestOperation *)searchOperationForService:(NSString *)serviceKey
                                          searchTerm:(NSString *)searchTerm
                                             success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                             failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    NSString *urlSearchStr = [self searchURLString:serviceKey];
    if([serviceKey isEqualToString:@"wiki"]) searchTerm = [searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    searchTerm = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:urlSearchStr,[searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest * req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    

    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
                                                                                        success:success
                                                                                        failure:failure];
    
    return operation;
    
}

@end
