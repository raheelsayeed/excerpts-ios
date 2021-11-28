//
//  RSCallbackParser.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 14/01/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "RSCallbackParser.h"

@implementation RSCallbackParser


- (void)xCallbackURLParser:(RSCallbackParser *)parser shouldOpenSourceCallbackURL:(NSURL *)callbackURL{
    
    [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:callbackURL afterDelay:0.5];
}




-(BOOL)handleURL:(NSURL *)URL{
    
    if([URL.host isEqualToString:@"x-callback-url"])
        return [super handleURL:URL];
    else
       return  [self handleNonXCBURL:URL];
    
}

-(BOOL)handleNonXCBURL:(NSURL *)url
{
    if (![self verifyHasURLScheme]) {
        return NO;
    }
    NSDictionary *userParameters = [self userParametersFromURL:url];
    NSRange question = [url.absoluteString rangeOfString:@"?"];
    
    
    NSString *actionName = [url.absoluteString substringWithRange:NSMakeRange(url.scheme.length+3, question.location-(url.scheme.length+3))];
//    NSLog(@"%@, %lu, %d",actionName, (unsigned long)url.scheme.length, question.location);
    if ([actionName length] == 0) {
        return NO;
    }
    
    SBRCallbackActionHandler *handler = [self.handlers objectForKey:actionName];
    if (!handler) {
        return NO;
    }
    
    if (!handler.handlerBlock) {
        return NO;
    }
    
    BOOL handled = handler.handlerBlock(userParameters, nil, nil);
    
    return handled;
}


@end
