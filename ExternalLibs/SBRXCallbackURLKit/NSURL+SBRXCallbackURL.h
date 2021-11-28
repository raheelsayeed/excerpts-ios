//
//  NSURL+SBRXCallbackURL.h
//  XCallbackURLParserDemo
//
//  Created by Sebastian Rehnby on 8/8/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (SBRXCallbackURL)

- (NSDictionary *)sbr_queryParameters;
+ (NSURL *)vigCallBackURLWithScheme:(NSString *)scheme urlStr:(NSString *)urlString  x_success:(NSString *)success x_cancel:(NSString *)cancel x_error:(NSString *)error;
+ (NSURL *)v_xCallBackURLWithScheme:(NSString *)scheme urlStr:(NSString *)urlString x_source:(NSString *)sourceName x_success:(NSString *)success x_cancel:(NSString *)cancel x_error:(NSString *)error shouldEncode:(BOOL)encode;

@end
