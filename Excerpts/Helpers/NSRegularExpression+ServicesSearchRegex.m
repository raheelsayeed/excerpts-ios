//
//  NSRegularExpression+ServicesSearchRegex.m
//   Renote
//
//  Created by M Raheel Sayeed on 10/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "NSRegularExpression+ServicesSearchRegex.h"

@implementation NSRegularExpression (ServicesSearchRegex)


+ (NSRegularExpression *)servicesRegex
{
    static NSString * const kServicesSearchRegexPattern = @"(?:^|\r|\n|\r\n)@(pubmed|wiki): (.*)";
    static NSRegularExpression *regex = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
		NSError *error = nil;
		regex = [NSRegularExpression regularExpressionWithPattern:kServicesSearchRegexPattern options:0 error:&error];
	});
    
    return regex;
}

@end
