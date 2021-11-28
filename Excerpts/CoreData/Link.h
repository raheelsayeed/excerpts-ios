//
//  Link.h
//   Renote
//
//  Created by M Raheel Sayeed on 22/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RequestObject.h"

@class CachedLinkData, Note, RequestObject;

typedef NS_ENUM(NSUInteger, LINK_TYPE) {
    LINK_TYPE_FETCH = 0,
    LINK_TYPE_SEARCH,
};

@interface Link : NSManagedObject <RequestObjectLinkedDelegate>

@property (nonatomic, retain) NSString * serviceKey;
@property (nonatomic, retain) NSNumber * linkType;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) CachedLinkData *cache;
@property (nonatomic, retain) NSSet *notes;

+ (NSSet *)fetchOrCreateLinksforIdentifiers:(NSArray *)identifiers context:(NSManagedObjectContext *)context;
- (void)cacheData:(id)data requestObject:(RequestObject *)ro;
- (NSString*)fetchedTitle;

@end

@interface Link (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
