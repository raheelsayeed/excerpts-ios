//
//  Tag.h
//   Renote
//
//  Created by M Raheel Sayeed on 22/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Excerpts.h"


@class Note;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSNumber * colorCode;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSNumber * lastSynced;

@property (nonatomic, retain) NSNumber * stick;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) NSString * dbxDatastoreID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSSet *notes;

+ (NSSet *)exp_fetchOrCreateTags:(NSArray *)identifiers context:(NSManagedObjectContext *)moc;

@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;


@end
