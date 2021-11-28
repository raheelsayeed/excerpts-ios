//
//  CachedLinkData.h
//   Renote
//
//  Created by M Raheel Sayeed on 22/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class Note, Link;

@interface CachedLinkData : NSManagedObject

@property (nonatomic, retain) id content;
@property (nonatomic, retain) NSDate * cacheDate;
@property (nonatomic, retain) Link *link;
@property (nonatomic, retain) Note * note;

@end
