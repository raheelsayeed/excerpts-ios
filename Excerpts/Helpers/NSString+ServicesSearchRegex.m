//
//  NSString+ServicesSearchRegex.m
//   Renote
//
//  Created by M Raheel Sayeed on 10/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "NSString+ServicesSearchRegex.h"
#import "NSRegularExpression+ServicesSearchRegex.h"

@implementation NSString (ServicesSearchRegex)



- (NSDictionary *)searchQueryDictionary
{
    if ([self length] < 1)
		return nil;
    
    NSMutableDictionary *queries = [NSMutableDictionary new];
    @autoreleasepool {
        
		NSArray *matches = [[NSRegularExpression servicesRegex] matchesInString:self options:0 range:NSMakeRange(0, [self length])];
		for (NSTextCheckingResult *oneResult in matches) {
            
            
			NSRange oneRange = [oneResult rangeAtIndex:1];
			NSString *key = [self substringWithRange:oneRange];
            
            NSRange queryRange = [oneResult rangeAtIndex:2];
            NSString * query = [self substringWithRange:queryRange];
            
            if(!query || ![query isValidQueryForKey:key])     continue;
            
            
            queries[query] = key;

		}
	}
    
    return ([queries count] > 0) ? [queries copy] : nil;
    
}


- (BOOL)isValidQueryForKey:(NSString *)serviceKey
{
    if([self length] < 1)
        return NO;
    
    return YES;
}


@end
