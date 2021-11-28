//
//  NSURL+SBRXCallbackURL.m
//  XCallbackURLParserDemo
//
//  Created by Sebastian Rehnby on 8/8/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import "NSURL+SBRXCallbackURL.h"
#import "NSString+SBRXCallbackURL.h"

@implementation NSURL (SBRXCallbackURL)

- (NSDictionary *)sbr_queryParameters {
  NSArray *chunks = [[self query] componentsSeparatedByString:@"&"];
  NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:[chunks count]];
  
  [chunks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSArray *parts = [obj componentsSeparatedByString:@"="];
    
    if ([parts count] == 2) {
      NSString *name = parts[0];
      NSString *value = parts[1];
      parameters[name] = [value sbr_URLDecode];
    }
  }];
  
  return [parameters copy];
}

+ (NSURL *)v_xCallBackURLWithScheme:(NSString *)scheme urlStr:(NSString *)urlString x_source:(NSString *)sourceName x_success:(NSString *)success x_cancel:(NSString *)cancel x_error:(NSString *)error shouldEncode:(BOOL)encode
{
    
    if(encode)
    {
        sourceName  =   [sourceName sbr_URLEncode];
        //urlString   =   [urlString sbr_URLEncode];
        success     =   [success sbr_URLEncode];
        cancel      =   [cancel sbr_URLEncode];
        error       =   [error sbr_URLEncode];
    }
    
    NSString * string = [NSString stringWithFormat:@"%@://x-callback-url/%@", scheme, urlString];
    if(sourceName)
        string = [string stringByAppendingFormat:@"&x-source=%@", sourceName];
    if(success)
        string = [string stringByAppendingFormat:@"&x-success=%@", success];
    if(cancel)
        string = [string stringByAppendingFormat:@"&x-cancel=%@", cancel];
    if(error)
        string = [string stringByAppendingFormat:@"&x-error=%@", error];
    
    return [NSURL URLWithString:string];
}

+ (NSURL *)vigCallBackURLWithScheme:(NSString *)scheme urlStr:(NSString *)urlString  x_success:(NSString *)success x_cancel:(NSString *)cancel x_error:(NSString *)error
{
    return [[self class] v_xCallBackURLWithScheme:scheme urlStr:urlString x_source:@"Vignettes" x_success:success x_cancel:cancel x_error:error shouldEncode:NO];
}


@end
