//
//  Note.m
//   Renote
//
//  Created by M Raheel Sayeed on 22/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "Note.h"
#import "NSManagedObject+Excerpts.h"
#import "Tag.h"
#import "Link.h"
//#import "NSDate-Utilities.h"
#import "CachedLinkData.h"
#import "RequestObject.h"
#import "SharedGroup.h"
#import "NSString+RSParser.h"


static NSString * const delimitor = @"¿";
static NSString * const kexp_tags = @"tags";
static NSString * const kexp_links = @"links";




@interface Note (PrimitiveAccessors)
- (NSString *)primitiveText;
- (void)setPrimitiveText:(NSString *)newText;
@end

@implementation Note


@dynamic creationDate;
@dynamic importIdentifier;
@dynamic performedActions;
@dynamic modifiedDate;
@dynamic syncID;
@dynamic text;
@dynamic title;
@dynamic type;
@dynamic lastAccessedDate;
@dynamic tags;
@dynamic sharedGroups;
@dynamic links;
@dynamic mentalStatus;
@dynamic cloudLocationNumber;
@dynamic weblinksCache;
@dynamic flagged;
@dynamic textHash;
@dynamic archived;
@dynamic lastSynced;
@synthesize monthYear_modifiedDate;
@synthesize monthYear_creationDate;
@synthesize monthYear_lastAccessedDate;



@synthesize preventModifiedDateChange = _preventModifiedDateChange;


- (id)cachedDataForRequestObject:(RequestObject *)ro
{
    if(!self.weblinksCache) return nil;
    
    NSDictionary * dict = [self.weblinksCache content];
    
    NSArray * array = dict[ro.primaryURL.absoluteString];
    
    return (array.count > 0) ? array : nil;
}

- (void)cacheData:(id)cache requestObject:(RequestObject *)ro
{
    if([(NSArray *)cache count] == 0) return;
    
    CachedLinkData * cacheObj = self.weblinksCache;
    
    NSMutableDictionary * mdict;
    if(!cacheObj)
    {
        cacheObj = [NSEntityDescription insertNewObjectForEntityForName:@"CachedLinkData" inManagedObjectContext:self.managedObjectContext];
        mdict = [NSMutableDictionary new];
        self.weblinksCache = cacheObj;
    }
    else
    {
        mdict = [[cacheObj content] mutableCopy];
    }
    
    [mdict setObject:cache forKey:ro.primaryURL.absoluteString];
    cacheObj.content = [mdict copy];
}

+ (Note *)entityWithText:(NSString *)text moc:(NSManagedObjectContext *)moc
{
    if(!text) return nil;
    Note * e = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:moc];
    e.text = text;
    //e.syncID = [[self class] syncIDderivedFromString:e.text];
    return e;
}

-(void)awakeFromInsert{
    
    NSDate * date = [NSDate date];
    self.creationDate = date;
    self.modifiedDate = date;
    //::: Duplicates.
    self.syncID = [[self class] syncID];
    [super awakeFromInsert];
    _preventModifiedDateChange = NO;

}

-(void)awakeFromFetch
{
    [super awakeFromFetch];
    _preventModifiedDateChange = NO;
}

- (NSString *)text
{
    [self willAccessValueForKey:@"text"];
    NSString *newText = [self primitiveText];
    [self didAccessValueForKey:@"text"];
    return newText;
}

- (void)setText:(NSString *)text
{
    [self willChangeValueForKey:@"text"];
    [self setPrimitiveValue:[text md5] forKey:@"textHash"];
    [self setPrimitiveText:text];
    [self didChangeValueForKey:@"text"];
}


- (EX_TYPE)ex_type
{
    return [[self type] integerValue];
}


- (void)updateDBRecord:(DBRecord *)record empty:(BOOL)wasEmpty
{
//    NSLog(@" \ninserted=%@\ndeleted=%@,\nupdated=%@\nfaulted=%@" , @(self.isInserted), @(self.isDeleted), @(self.isUpdated), @(self.isFault));

    if(!wasEmpty) //If I'm not New, and DBRecord is also Not new, just update the changed Values
    {
        [self updateDBRecord:record];
        return;
    }
    
    
    for(NSString * attribute in [[self class] syncableAttributeNames])
    {
        if([attribute isEqualToString:kexp_tags] && self.tags)
        {
            [self setTagsToRecord:record];
        }
        else if([attribute isEqualToString:kexp_links] && self.links)
        {
            [self setLinksToRecord:record];
        }
        else
        {
            if([self ex_type] == EX_TYPE_LOCAL)
            {
                if([self valueForKey:attribute])
                {
                    record[attribute] = [self valueForKey:attribute];
                }
            }
        }
    }
}

-(void)updateDBRecord:(DBRecord *)record
{

    for(NSString * changedKey in self.changedValues.allKeys)
    {
        if(![[[self class] syncableAttributeNames] containsObject:changedKey])
        {
            // dont sync unwanted attributes
            continue;
        }
        if([changedKey isEqualToString:kexp_tags])
        {
            [self setTagsToRecord:record];
        }
        else if ([changedKey isEqualToString:kexp_links])
        {
            [self setLinksToRecord:record];
        }
        
        else
        {
            if([self ex_type] == EX_TYPE_LOCAL)
            {
                record[changedKey] = [self valueForKey:changedKey];
            }
            
        }
    }
}

- (void)setTagsToRecord:(DBRecord *)dbRecord
{
    [dbRecord removeObjectForKey:kexp_tags];
    
    if(self.tags.count > 0)
    {
        DBList *list = [dbRecord getOrCreateList:kexp_tags];
        
        for(Tag *tag in self.tags)
        {
            [list addObject:tag.syncID];
        }
        
    }

}
- (void)setLinksToRecord:(DBRecord *)dbRecord
{
    [dbRecord removeObjectForKey:kexp_links];
    if(self.links.count > 0)
    {
        DBList *list = [dbRecord getOrCreateList:kexp_links];
        
        for(Link *link in self.links)
        {
            NSString * str = [NSString stringWithFormat:@"%@%@%@",
                              [link.identifier stringByReplacingOccurrencesOfString:@" " withString:@"_"],
                              delimitor,
                              link.serviceKey];
            if(self.title) str = [str stringByAppendingFormat:@"%@%@", delimitor, self.title];
            [list addObject:str];
            
            //[list addObject:[NSString stringWithFormat:@"%@%@%@%@%@",[link.identifier stringByReplacingOccurrencesOfString:@" " withString:@"_" ], delimitor, link.serviceKey, delimitor, link.title]];
        }
        
    }

}




-(void)updateFromDBRecord:(DBRecord *)record
{
    
    NSLog(@"%@", record.fields.allKeys.description);
    
    for(NSString * fieldKey in record.fields.allKeys)
    {
        if([fieldKey isEqualToString:@"tags"])
        {
            DBList *list = record[fieldKey];
            if(nil == list)
            {
                [self setTags:nil];
                continue;
            }
            NSSet  *ourTags   = [Tag exp_fetchOrCreateObjectsWithIDs:list.values ofAttribute:@"syncID" inEntity:@"Tag" context:self.managedObjectContext];
            [self setTags:ourTags];
        }
        else if([fieldKey isEqualToString:@"links"])
        {
            DBList *list = record[fieldKey];
            if(nil == list)
            {
                [self setLinks:nil];
                continue;
            }
            NSMutableDictionary * linkDictionary = [NSMutableDictionary new];
            for(NSString *linkString in list.values)
            {
                NSArray *comp = [linkString componentsSeparatedByString:delimitor];
                if(comp.count > 2)
                    [linkDictionary setObject:@{@"title": comp[2],
                                                @"type":comp[1]}
                                       forKey:comp[0]];
                else
                {
                    [linkDictionary setObject:@{@"type": comp[1]} forKey:comp[0]];
                }
            }
            NSSet *ourLinks = [Link fetchOrCreateLinksforIdentifiers:[linkDictionary allKeys] context:self.managedObjectContext];
            [self setLinks:nil];
            for(Link *link in ourLinks)
            {
                NSDictionary * linkData = linkDictionary[link.identifier];
                link.serviceKey = linkData[@"type"];
                link.title = linkData[@"title"];
            }
            [self setLinks:ourLinks];
        }
        else
        {
            [self setValue:record[fieldKey] forKeyPath:fieldKey];
        }
    }
    

}

static NSDateFormatter *formatter = nil;

+ (NSDateFormatter *)formatter
{
    if(!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        
        NSString *formatTemplate = [NSDateFormatter dateFormatFromTemplate:@"MMMM YYYY" options:0 locale:[NSLocale currentLocale]];
        [formatter setDateFormat:formatTemplate];

    }
    return formatter;
}




- (NSString *)monthYear_modifiedDate
{
    if(!self.modifiedDate) return @"  UNCHANGED";
    return [NSString stringWithFormat:@"  %@", [[[self class] formatter] stringFromDate:self.modifiedDate]];
    return self.monthYear_modifiedDate;
}
- (NSString *)monthYear_creationDate
{
    return [NSString stringWithFormat:@"  %@", [[[self class] formatter] stringFromDate:self.creationDate]];
}
- (NSString *)monthYear_lastAccessedDate
{
    if(!self.lastAccessedDate) return @"  UNVIEWED";
    return [NSString stringWithFormat:@"  %@", [[[self class] formatter] stringFromDate:self.lastAccessedDate]];
}

- (NSNumber *)dataStoreIdentifier
{
    return self.cloudLocationNumber;
}

-(void)assignDatastoreIdentifier:(NSNumber *)number
{
    self.cloudLocationNumber = number;
}

static NSArray * syncableAttributes = nil;

+ (NSArray *)syncableAttributeNames
{
    if(!syncableAttributes)
        syncableAttributes = @[@"text", @"tags", @"links", @"modifiedDate",  @"lastAccessedDate", @"creationDate", @"archived"];
    return syncableAttributes;
}




- (NSString *)exportString
{
    NSMutableString * mcontent = [self.text mutableCopy];
    
    if(self.tags.count > 0 || self.links.count > 0 || self.archived.boolValue == YES)
    {
        [mcontent appendString:@"\n\n\n@RENOTE\n---------\n"];
        if(self.tags.count > 0)
        {
            [mcontent appendFormat:@"tags:"];
            for(Tag *tag in self.tags) [mcontent appendFormat:@" %@,", tag.title];
            [mcontent appendFormat:@"\n"];
        }
        if(self.archived.boolValue == YES)
        {
            [mcontent appendFormat:@"archived: %@\n", self.archived.description];
        }
        if(self.links.count > 0)
        {
            for(Link *link in self.links)
            {
                
                NSString * encodedIdentifier = [link.identifier stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
                DLog(@"%@ == %@", link.identifier, encodedIdentifier);

                
                [mcontent appendFormat:@"- %@\n", [[APIServices shared] completePublicURL:link.serviceKey identifier:[link.identifier stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }
        }
    }
    
    return mcontent.copy;
}



- (void)willChangeValueForKey:(NSString *)key
{
    if([[self.class syncableAttributeNames] containsObject:key]) [self unsynced];
    
    [super willChangeValueForKey:key];
    
}

- (void)synced
{
    [self setPrimitiveValue:@YES forKey:@"lastSynced"];

    
}


- (void)unsynced
{
    [self setPrimitiveValue:@NO forKey:@"lastSynced"];
    
}





@end
