//
//  NSManagedObject+Vignettes.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 09/12/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Dropbox/Dropbox.h>

static NSString * kDefaultSyncAttributeName = @"syncID";

@interface NSManagedObject (Excerpts)
@property (nonatomic, strong) NSNumber * canSyncToDropboxDatastore;


- (void)synced;
- (void)unsynced;

-(BOOL)canSyncToDB;

+ (NSUInteger)objectCountInManagedObjectContext:(NSManagedObjectContext *)moc;
+ (NSUInteger)unsyncedObjectCountWithMOC:(NSManagedObjectContext *)moc;
+ (NSUInteger)objectCountInManagedObjectContext:(NSManagedObjectContext *)moc predicate:(NSPredicate *)predicate;

+ (NSString *)syncID;
+ (NSString *)syncIDderivedFromString:(NSString *)string;
-(NSNumber *)dataStoreIdentifier;
-(void)assignDatastoreIdentifier:(NSNumber *)number;

-(void)updateDBRecord:(DBRecord *)record empty:(BOOL)empty;
-(void)updateDBRecord:(DBRecord *)record;
-(void)updateFromDBRecord:(DBRecord *)record;
- (NSString *)uppercaseFirstLetterOfTitle;

+ (NSManagedObject *)getOrCreateObjectWithIdentifier:(NSString *)identifier attribute:(NSString *)attribute moc:(NSManagedObjectContext *)moc propertiesDict:(NSDictionary *)propertiesDictionary;
+ (NSSet *)exp_fetchOrCreateObjectsWithIDs:(NSArray *)identifiers ofAttribute:(NSString *)attribute inEntity:(NSString *)entityName context:(NSManagedObjectContext *)moc setAttributeProperties:(NSDictionary *)attributeProperties;



+ (NSSet *)exp_fetchOrCreateObjectsWithIDs:(NSArray *)identifiers ofAttribute:(NSString *)attribute inEntity:(NSString *)entityName context:(NSManagedObjectContext *)moc;

+ (NSArray *)syncableAttributeNames;
@end
