//
//  JTSReachabilityResponder.h
//  JTSReachability
//
//  Created by Jared Sinclair on 12/9/13.
//  Copyright (c) 2013 Nice Boy LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JTSReachability.h"

typedef void(^JTSReachabilityHandler)(JTSNetworkStatus status);

@interface JTSReachabilityResponder : NSObject

+ (instancetype)sharedInstance;

- (void)addHandler:(JTSReachabilityHandler)handler forKey:(NSString *)key;
- (void)removeHandlerForKey:(NSString *)key;
- (JTSNetworkStatus)networkStatus;
- (BOOL)isReachable;

@end
