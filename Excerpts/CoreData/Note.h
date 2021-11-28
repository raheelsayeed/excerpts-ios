//
//  Note.h
//   Renote
//
//  Created by M Raheel Sayeed on 22/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Excerpts.h"
#import "RequestObject.h"



static NSInteger EX_TYPE_UNSYNCABLE = -1;


typedef NS_ENUM(NSUInteger, EX_TYPE) {
    EX_TYPE_LOCAL = 0,
    EX_TYPE_DROPBOX,
};

@class CachedLinkData, SharedGroup;

@interface Note : NSManagedObject <RequestObjectLinkedDelegate>

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * importIdentifier;
@property (nonatomic, retain) NSString * performedActions;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) CachedLinkData * weblinksCache;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * mentalStatus;
@property (nonatomic, retain) NSNumber * cloudLocationNumber;
@property (nonatomic, retain) NSDate * lastAccessedDate;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSSet *sharedGroups;
@property (nonatomic, retain) NSSet *links;
@property (nonatomic, assign) BOOL preventModifiedDateChange;
@property (nonatomic, retain) NSNumber *archived;
@property (nonatomic, retain) NSNumber *flagged;
@property (nonatomic, retain) NSString * textHash;
@property (nonatomic, retain) NSNumber * lastSynced;

@property (nonatomic, assign) NSString * monthYear_creationDate;
@property (nonatomic, assign) NSString * monthYear_modifiedDate;
@property (nonatomic, assign) NSString * monthYear_lastAccessedDate;

- (EX_TYPE)ex_type;
+ (Note *)entityWithText:(NSString *)text moc:(NSManagedObjectContext *)moc;
- (NSString *)exportString;

@end

@interface Note (CoreDataGeneratedAccessors)

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addLinksObject:(NSManagedObject *)value;
- (void)removeLinksObject:(NSManagedObject *)value;
- (void)addLinks:(NSSet *)values;
- (void)removeLinks:(NSSet *)values;

- (void)addSharedGroupObject:(SharedGroup *)value;
- (void)removeSharedGroupObject:(SharedGroup *)value;
- (void)addSharedGroups:(NSSet *)values;
- (void)removeSharedGroups:(NSSet *)values;




@end
