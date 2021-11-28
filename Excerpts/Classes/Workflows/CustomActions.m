//
//  CustomActions.m
//   Renote
//
//  Created by M Raheel Sayeed on 23/05/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "CustomActions.h"



@interface CustomActions ()
@property (nonatomic, strong, readwrite) NSMutableArray * actions;
@end

@implementation CustomActions

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [self loadActions];
    }
    return self;
}

- (NSArray *)enabledActions
{
    return [_actions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"enabled == 1"]];
}

- (NSURL *)applicationAppSupportDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)checkIfApplicationSupportDirectoryExists
{

    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *appSupportDir = [self applicationAppSupportDirectory].path;
    if(![manager fileExistsAtPath:appSupportDir])
    {
        __autoreleasing NSError *error;
        BOOL ret = [manager createDirectoryAtPath:appSupportDir withIntermediateDirectories:NO attributes:nil error:&error];
        if(!ret)
        {
            NSLog(@"ERROR app support: %@", error);
            return NO;
        }
    }
    return YES;

}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}
- (NSString * )customActionsFilePath
{
    //::: Confirm if I should check the "Application Support" directory is always there or needs to be created and accounted for
    
    if([self checkIfApplicationSupportDirectoryExists])
    {
        return [[self applicationAppSupportDirectory].path stringByAppendingPathComponent:@"Custom_actions.plist"];
    }
    
    return nil;
}

- (void)saveActions
{
    if([_actions writeToFile:[self customActionsFilePath] atomically:YES])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@(_actions.count) forKey:kActionsCountKey];
    }
}
- (void)loadActions
{
    NSString * path = [self customActionsFilePath];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if(!fileExists)
    {
        self.actions = [NSMutableArray new];
//        [self addDemo];
        
    }
    else
    {
        self.actions = [NSMutableArray arrayWithContentsOfFile:path];
        //if(self.actions.count == 0) [self addDemo];
    }
    
//    NSLog(@"%@", self.actions.description);
    
}

- (void)addDemo
{
    [self addActionWithTitle:@"Vignettes - New"
                         url:@"vignettes://x-callback-url/new?text=[[note]]"];
    [self addActionWithTitle:@"MedCalc - New"
                         url:@"medcalc://x-callback-url/formula/SAAG"];
    [self addActionWithTitle:@"Simplenote - New"
                         url:@"simplenote://new?tag=[[title]]&content=[[note]]"];
}

- (void)addActionWithTitle:(NSString *)title url:(NSString *)urlStr
{
    [_actions addObject:@{kURLString: urlStr,
                          kActionTitle: title,
                          kActionEnabled: @YES}];
}

- (void)enableAction:(BOOL)enable atIndex:(NSUInteger)idx
{
    NSMutableDictionary * dict = [_actions[idx] mutableCopy];
    [dict setObject:@(enable) forKey:kActionEnabled];
    [_actions replaceObjectAtIndex:idx withObject:[dict copy]];
}

- (void)editActionAtIndex:(NSUInteger)index title:(NSString *)title url:(NSString *)urlStr
{
    
    NSMutableDictionary * mdict = [_actions[index] mutableCopy];
    mdict[kURLString] = urlStr;
    mdict[kActionTitle] = title;
    [_actions replaceObjectAtIndex:index withObject:[mdict copy]];
}

- (void)removeActionAtIndex:(NSUInteger)index
{
    [_actions removeObjectAtIndex:index];
}

- (void)moveItemFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex
{
    id object = [_actions objectAtIndex:fromIndex];
    [_actions removeObjectAtIndex:fromIndex];
    [_actions insertObject:object atIndex:toIndex];
}

@end
