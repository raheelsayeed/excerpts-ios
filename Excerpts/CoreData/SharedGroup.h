//
//  SharedGroup.h
//   Renote
//
//  Created by M Raheel Sayeed on 13/11/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface SharedGroup : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSSet *notes;
@end

@interface SharedGroup (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
