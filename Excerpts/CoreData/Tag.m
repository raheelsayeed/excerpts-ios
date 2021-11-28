//
//  Tag.m
//   Renote
//
//  Created by M Raheel Sayeed on 22/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "Tag.h"
#import "Note.h"


@implementation Tag

@dynamic colorCode;
@dynamic selected;
@dynamic stick;
@dynamic syncID;
@dynamic title;
@dynamic type;
@dynamic notes;
@dynamic dbxDatastoreID;
@dynamic lastSynced;


- (void)awakeFromFetch{
    [super awakeFromFetch];
//     self.canSyncToDropboxDatastore = @(YES);
}
-(void)awakeFromInsert
{
    self.syncID = [[self class] syncID];
    [super awakeFromInsert];
}

-(void)updateDBRecord:(DBRecord *)record
{
    
    if(!self.title) return;
    
    record[@"title"] = self.title;
    
}
-(void)updateDBRecord:(DBRecord *)record empty:(BOOL)wasEmpty
{
    
//    NSLog(@" \ninserted=%@\ndeleted=%@,\nupdated=%@\nfaulted=%@\n%@\n\ntitlrecord=%@" , @(self.isInserted), @(self.isDeleted), @(self.isUpdated), @(self.isFault), self.changedValues.allKeys, record[@"title"]);
    
    
    
    

    if(wasEmpty) //if DBRecord is New or I'm New.
    {
        [self updateDBRecord:record];
        return;
    }
    
    
    NSArray * keys = self.changedValues.allKeys;
    
   
    if([keys containsObject:@"title"])
    {
        [self updateDBRecord:record];
        return;
    }
    
    
    //Only Verify:
    
    if(![self.title isEqualToString:record[@"title"]])
    {
        [self updateDBRecord:record];
        
    }
    
    
    
   
    
}
-(void)updateFromDBRecord:(DBRecord *)record
{
    [super updateFromDBRecord:record];

    if(record[@"title"])    self.title = record[@"title"];
}

- (NSNumber *)dataStoreIdentifier
{
    return @0;
}

- (BOOL)canSyncToDB
{
    if([self.changedValues.allKeys containsObject:@"title"] || [self.changedValues.allKeys containsObject:kDefaultSyncAttributeName])
    {
        return YES;
    }
    return NO;
}

- (void)prepareForDeletion {
    
    if([self.selected boolValue])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectedTagsDidChange" object:self.syncID];
    }
}


+ (NSSet *)exp_fetchOrCreateTags:(NSArray *)identifiers context:(NSManagedObjectContext *)moc
{
    return [[self class] exp_fetchOrCreateObjectsWithIDs:identifiers ofAttribute:@"title" inEntity:@"Tag" context:moc];
}


static NSArray * syncableAttributes = nil;

+ (NSArray *)syncableAttributeNames
{
    if(!syncableAttributes) syncableAttributes = @[@"title"];
    return syncableAttributes;
}


- (void)willChangeValueForKey:(NSString *)key
{
    [super willChangeValueForKey:key];

    if([key isEqualToString:@"lastSynced"]) return;
    
    if([[self.class syncableAttributeNames] containsObject:key]) [self unsynced];
    
    
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
