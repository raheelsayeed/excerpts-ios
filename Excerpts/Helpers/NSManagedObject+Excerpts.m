//
//  NSManagedObject+Vignettes.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 09/12/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "NSManagedObject+Excerpts.h"
#import <objc/runtime.h>
#import "NSString+RSParser.h"


@implementation NSManagedObject (Excerpts)
@dynamic canSyncToDropboxDatastore;


-(BOOL)canSyncToDB
{
    if(!self.canSyncToDropboxDatastore)
        self.canSyncToDropboxDatastore = @(YES);
    return [self.canSyncToDropboxDatastore boolValue];
    
}


- (NSNumber *)canSyncToDropboxDatastore {
    return objc_getAssociatedObject(self, @selector(canSyncToDropboxDatastore));
}
- (void)setCanSyncToDropboxDatastore:(NSNumber *)number
{
    objc_setAssociatedObject(self, @selector(canSyncToDropboxDatastore), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSString *)syncID
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    NSString *uuid = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuidRef));
    return [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

-(NSNumber *)dataStoreIdentifier
{
    return @0;
}
-(void)assignDatastoreIdentifier:(NSNumber *)number
{
    
}

+ (NSString *)syncIDderivedFromString:(NSString *)string
{
    if(!string) return [self syncID];
    
    return [string md5];
}

- (void)updateDBRecord:(DBRecord *)record empty:(BOOL)empty
{
    
}
- (void)updateDBRecord:(DBRecord *)record
{
    
}
-(void)updateFromDBRecord:(DBRecord *)record{
    
}
- (NSString *)uppercaseFirstLetterOfTitle {
    [self willAccessValueForKey:@"uppercaseFirstLetterOfTitle"];
    NSString *stringToReturn;
    unichar c = [[self valueForKey:@"title"] characterAtIndex:0];
    if (isdigit(c)) {
        
        stringToReturn = @"#";
    }else{
        
        stringToReturn = [[NSString stringWithFormat:@"%C", c] uppercaseString];
    }

    
    [self didAccessValueForKey:@"uppercaseFirstLetterOfTitle"];
    return stringToReturn;
}




+ (NSString *)entityName
{
    return @"To_BE_SUBCLASSED";
}

- (void)synced
{
    
}
- (void)unsynced
{
    
}

+ (NSUInteger)objectCountInManagedObjectContext:(NSManagedObjectContext *)moc predicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    if(predicate) [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesSubentities:NO];
    [fetchRequest setResultType:NSCountResultType];
    NSError * error = nil;
    
    NSUInteger noteCount = [moc countForFetchRequest:fetchRequest error:&error];
    if(error)
    {
        DLog(@"%@, %@", error, error.localizedDescription);
    }
    return noteCount;
}

+ (NSUInteger)objectCountInManagedObjectContext:(NSManagedObjectContext *)moc
{
    return [[self class] objectCountInManagedObjectContext:moc predicate:nil];
}
+ (NSUInteger)unsyncedObjectCountWithMOC:(NSManagedObjectContext *)moc
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"lastSynced == %@", @(NO)];
    return [[self class] objectCountInManagedObjectContext:moc predicate:predicate];
}


+ (NSManagedObject *)getOrCreateObjectWithIdentifier:(NSString *)identifier attribute:(NSString *)attribute moc:(NSManagedObjectContext *)moc propertiesDict:(NSDictionary *)propertiesDictionary
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[[self class] entityName]];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", attribute, identifier]];
    NSError * error = nil;
    NSArray * objects = [moc executeFetchRequest:fetchRequest error:&error];
    if(error)
    {
        return nil;
    }
    
    NSManagedObject * managedObject;
    
    if(objects.count > 0)
    {
        managedObject = objects[0];
        //objects = nil;
    }
    else
    {
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:[[self class] entityName] inManagedObjectContext:moc];
        [managedObject setValue:identifier forKey:attribute];
    }
    
    if(propertiesDictionary)
    {
        for(NSString * key in propertiesDictionary.allKeys)
        {
            if([key isEqualToString:attribute])
                continue;
            [managedObject setValue:propertiesDictionary[key] forKey:key];
        }
        
    }
    
    return managedObject;
}


+ (NSSet *)exp_fetchOrCreateObjectsWithIDs:(NSArray *)identifiers ofAttribute:(NSString *)attribute inEntity:(NSString *)entityName context:(NSManagedObjectContext *)moc setAttributeProperties:(NSDictionary *)attributeProperties
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(%K IN %@)", attribute, identifiers]];
    //[fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:attribute ascending:YES]]];
    NSError *error;
    NSArray *presentObjects = [moc executeFetchRequest:fetchRequest error:&error];
    BOOL nothingFetched = (!presentObjects || presentObjects.count == 0);
    if(identifiers.count == presentObjects.count)
    {
        if(attributeProperties)
        {
            for(NSManagedObject * mangedObj in presentObjects)
            {
                NSDictionary * properties = attributeProperties[[mangedObj valueForKey:attribute]];
                if(!properties) continue;
                [mangedObj setValuesForKeysWithDictionary:properties];
            }
            
        }
        return [NSSet setWithArray:presentObjects];
    }
    
    if(!nothingFetched)
    {
        NSMutableArray *itemsWithUniqueElements = [identifiers mutableCopy];
        
        for (NSManagedObject *mobject in presentObjects)
        {
            [itemsWithUniqueElements removeObject:[mobject valueForKey:attribute]];
        }
//        NSLog(@"Unique = %d", itemsWithUniqueElements.count);
        identifiers = [itemsWithUniqueElements copy];
    }
    
    NSMutableSet  * finalObjects = [NSMutableSet new];
    for(NSString * iden in identifiers)
    {
        NSManagedObject * newObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
        [newObject setValue:iden forKey:attribute];
//        NSLog(@"created=%@==%@", newObject.description, [newObject valueForKey:attribute] );
        [finalObjects addObject:newObject];
    }
    
//    NSLog(@"presentob=%d, newfetched=%d", presentObjects.count, finalObjects.count);
    
    if(presentObjects)
        [finalObjects addObjectsFromArray:presentObjects];
    
//    NSLog(@", total=%d == %d", finalObjects.count, identifiers.count);
    
    if(attributeProperties)
    {
       for(NSManagedObject * mangedObj in finalObjects)
       {
           NSDictionary * properties = attributeProperties[[mangedObj valueForKey:attribute]];
           if(!properties) continue;
           [mangedObj setValuesForKeysWithDictionary:properties];
       }
        
    }
    
    
    return [finalObjects copy];
}





+ (NSSet *)exp_fetchOrCreateObjectsWithIDs:(NSArray *)identifiers ofAttribute:(NSString *)attribute inEntity:(NSString *)entityName context:(NSManagedObjectContext *)moc

{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(%K IN %@)", attribute, identifiers]];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:attribute ascending:YES]]];
    NSError *error;
    NSArray *presentObjects = [moc executeFetchRequest:fetchRequest error:&error];
    BOOL nothingFetched = (!presentObjects || presentObjects.count == 0);
    if(identifiers.count == presentObjects.count)
    {
        return [NSSet setWithArray:presentObjects];
    }
    
    if(!nothingFetched)
    {
        NSMutableArray *itemsWithUniqueElements = [identifiers mutableCopy];

        for (NSManagedObject *mobject in presentObjects)
        {
            [itemsWithUniqueElements removeObject:[mobject valueForKey:attribute]];
        }
//        NSLog(@"Unique = %d", itemsWithUniqueElements.count);
        identifiers = [itemsWithUniqueElements copy];
    }
    
    NSMutableSet  * finalObjects = [NSMutableSet new];
    for(NSString * iden in identifiers)
    {
        NSManagedObject * newObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
        [newObject setValue:iden forKey:attribute];
//        NSLog(@"created=%@==%@", newObject.description, [newObject valueForKey:attribute] );
        [finalObjects addObject:newObject];
    }
    
//    NSLog(@"presentob=%lu, newfetched=%d", (unsigned long)presentObjects.count, finalObjects.count);

    if(presentObjects)
    [finalObjects addObjectsFromArray:presentObjects];
    
//    NSLog(@", total=%d == %d", finalObjects.count, identifiers.count);

    return [finalObjects copy];
}

+ (NSArray *)syncableAttributeNames
{
    return nil;
}
@end
