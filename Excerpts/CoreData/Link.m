//
//  Link.m
//   Renote
//
//  Created by M Raheel Sayeed on 22/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "Link.h"
#import "CachedLinkData.h"
#import "Note.h"
#import "NSManagedObject+Excerpts.h"
#import "RequestObject.h"




@implementation Link

@dynamic serviceKey;
@dynamic linkType;
@dynamic identifier;
@dynamic title;
@dynamic syncID;
@dynamic cache;
@dynamic notes;


- (NSString *)fetchedTitle
{
    return (self.title) ? self.title : [NSString stringWithFormat:@"%@-%@",[[APIServices shared] titleForService:self.serviceKey], self.identifier];
}





- (void)requestObjectDidChange:(RequestObject *)ro
{
    
//    NSLog(@"%@", self.title);
    if(self.title || ro.downloadProgress < 1.0) return;
    
    if(ro.requestType == REQUEST_OBJECT_TYPE_FETCH)
    {
        NSDictionary * dict = ro.resultsArray[0];
        NSString * t = dict[@"title"];
        if(t) self.title = t;
    }
    
    
}

- (void)setIdentifier:(NSString *)identifier
{
    [self willChangeValueForKey:@"identifier"];

    if([identifier rangeOfString:@" "].location != NSNotFound)
    {
       // identifier = [identifier stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    }
    
    [self setPrimitiveValue:identifier forKey:@"identifier"];


    
    [self didChangeValueForKey:@"identifier"];
}


- (id)cachedDataForRequestObject:(RequestObject *)ro
{
    if(self.cache && self.cache.content)
    {
        return self.cache.content;
    }
    
    return nil;
}

- (void)cacheData:(id)data requestObject:(RequestObject *)ro
{
    if(!ro) return;
    
    if(self.linkType.integerValue == LINK_TYPE_SEARCH)
    {
//        NSLog(@"Cannot Cache Links Of Search Type");
        return;
    }
    
    CachedLinkData * newCache = [self cache];
    if(!newCache)
    {
        newCache = [NSEntityDescription insertNewObjectForEntityForName:@"CachedLinkData" inManagedObjectContext:self.managedObjectContext];
        [self performSelectorOnMainThread:@selector(setCache:) withObject:newCache waitUntilDone:YES];
    }
    newCache.content = ro.resultsArray;
   // DLog(@"%@", newCache.content);
    newCache.cacheDate = [NSDate date];
}

-(id)cachedData{
    
    if(self.cache && self.cache.content)
        return self.cache.content;
    else
        return nil;
}
-(void)prepareForDeletion
{
    [self deleteCache];
    [super prepareForDeletion];
}
-(void)deleteCache
{
    if(self.cache)
    {
        [self.managedObjectContext deleteObject:self.cache];
    }
}

+ (NSSet *)fetchOrCreateLinksforIdentifiers:(NSArray *)identifiers context:(NSManagedObjectContext *)context
{
    return [[self class] exp_fetchOrCreateObjectsWithIDs:identifiers ofAttribute:@"identifier" inEntity:@"Link" context:context];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
   // DLog(@"%@ not found", key);
}
- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}


@end
