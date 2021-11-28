//
//  NSURL+XCallBackURL.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 10/01/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "NSURL+XCallBackURL.h"


NSString * const kXCallbackURLHost = @"x-callback-url";
NSString * const kSourceParameterName = @"x-source";
NSString * const kSuccessURLParameterName = @"x-success";
NSString * const kErrorURLParameterName = @"x-error";
NSString * const kCancelURLParameterName = @"x-cancel";

// Encodes the |input| string adding percentage escapes for certain chars.
static NSString* encodeByAddingPercentEscapes(NSString *input) {
    NSString *encodedValue = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                        kCFAllocatorDefault,
                                                        (CFStringRef)input,
                                                        NULL,
                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                        kCFStringEncodingUTF8));
    return encodedValue;
}

// Decodes the |input| string replacing percentage escapes for certain chars.
static NSString* decodeByReplacingPercentEscapes(NSString *input) {
    NSString *decodedCallbackURLString =
    (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                        kCFAllocatorDefault,
                                                                        (CFStringRef)input,
                                                                        CFSTR(""),
                                                                        kCFStringEncodingUTF8));
    return decodedCallbackURLString;
}

@implementation NSURL (XCallbackURL)

+ (NSURL *)XCallbackURLWithScheme:(NSString *)scheme
                           action:(NSString *)action
                           source:(NSString *)source
                       successURL:(NSURL *)successURL
                         errorURL:(NSURL *)errorURL
                        cancelURL:(NSURL *)cancelURL
                       parameters:(NSDictionary *)parameters {
    if (!scheme) {
        return nil;
    }
    NSMutableString *urlString = [NSMutableString string];
    if (!action) {
        action = @"";
    }
    [urlString appendFormat:@"%@://%@/%@",
     scheme, kXCallbackURLHost, encodeByAddingPercentEscapes(action)];
    
    NSMutableArray *paramsArray = [NSMutableArray array];
    
    if (source) {
        [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",
                                kSourceParameterName,
                                encodeByAddingPercentEscapes(source)]];
    }
    
    if (successURL) {
        [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",
                                kSuccessURLParameterName,
                                encodeByAddingPercentEscapes([successURL absoluteString])]];
    }
    
    if (errorURL) {
        [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",
                                kErrorURLParameterName,
                                encodeByAddingPercentEscapes([errorURL absoluteString])]];
    }
    
    if (cancelURL) {
        [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",
                                kCancelURLParameterName,
                                encodeByAddingPercentEscapes([cancelURL absoluteString])]];
    }
    
    NSArray *paramKeys = [parameters allKeys];
    for (NSUInteger i = 0; i < [paramKeys count]; i++) {
        NSString *key = [paramKeys objectAtIndex:i];
        id value = [parameters objectForKey:key];
        if ([NSNull null] != value) {
            [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",
                                    encodeByAddingPercentEscapes(key),
                                    encodeByAddingPercentEscapes(value)]];
        } else {
            [paramsArray addObject:[NSString stringWithFormat:@"%@",
                                    encodeByAddingPercentEscapes(key)]];
        }
    }
    
    if ([paramsArray count]) {
        [urlString appendFormat:@"?%@",
         [paramsArray componentsJoinedByString:@"&"]];
    }
    
    return [NSURL URLWithString:urlString];
}

- (NSDictionary *)xCallbackURL_queryParameters {
    NSString *query = [self query];
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
    for (NSString *keyValuePair in [query componentsSeparatedByString:@"&"]) {
        NSArray *keyAndValueArray = [keyValuePair componentsSeparatedByString:@"="];
        if ([keyAndValueArray count] < 1) {
            continue;
        }
        NSString *key =
        decodeByReplacingPercentEscapes([keyAndValueArray objectAtIndex:0]);
        id value = [NSNull null];
        if ([keyAndValueArray count] > 1) {
            value =
            decodeByReplacingPercentEscapes([keyAndValueArray objectAtIndex:1]);
        }
        [queryParams setObject:value forKey:key];
    }
    return queryParams;
}

- (BOOL)isXCallbackURL {
    return [[self host] isEqualToString:kXCallbackURLHost];
}

@end    