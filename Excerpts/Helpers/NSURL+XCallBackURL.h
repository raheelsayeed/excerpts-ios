//
//  NSURL+XCallBackURL.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 10/01/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kXCallbackURLHost;
extern NSString * const kSourceParameterName;
extern NSString * const kSuccessURLParameterName;
extern NSString * const kErrorURLParameterName;
extern NSString * const kCancelURLParameterName;

// This category provides method to handle URL Schemes conforming with the
// x-callback-url specifications (http://x-callback-url.com/ )
@interface NSURL (XCallbackURL)

// Returns an autoreleased NSURL compliant to the x-callback-url specs.
+ (NSURL *)XCallbackURLWithScheme:(NSString *)scheme
                           action:(NSString *)action
                           source:(NSString *)source
                       successURL:(NSURL *)successURL
                         errorURL:(NSURL *)errorURL
                        cancelURL:(NSURL *)cancelURL
                       parameters:(NSDictionary *)parameters;

// Returns a dictionary with all the parameters in the query string.
- (NSDictionary *)xCallbackURL_queryParameters;

// Returns YES if the URL is compliant to the x-callback-url specs.
- (BOOL)isXCallbackURL;

@end