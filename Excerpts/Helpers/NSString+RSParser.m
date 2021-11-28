//
//  NSString+RSParser.m
//  Clinicals
//
//  Created by Mohammed Raheel Sayeed on 04/02/13.
//  Copyright (c) 2013 Medical Gear. All rights reserved.
//

#import "NSString+RSParser.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (RSParser)


- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}
- (NSString *)stringGroupByFirstInitial {
    
    NSString *temp = [self uppercaseString];
    if (!temp.length || temp.length == 1)
        return self;
    return [temp substringToIndex:1];
}
- (NSString *)flattenHTML {
    NSScanner *thescanner;
    NSString *text = nil;
    NSString *flattened;
    
    thescanner = [NSScanner scannerWithString:self];
    
    while ([thescanner isAtEnd] == NO ) {
        [thescanner scanUpToString:@"<" intoString:nil];//:@"<" intostring:null] ;
        [thescanner scanUpToString:@">" intoString:&text];
        flattened  = [self stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text]
                                               withString:@" "];
    }
    return flattened;
}

- (NSString *)removeHTML {
    
    static NSRegularExpression *regexp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexp = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>" options:kNilOptions error:nil];
    });
    
    return [regexp stringByReplacingMatchesInString:self
                                            options:kNilOptions
                                              range:NSMakeRange(0, self.length)
                                       withTemplate:@""];
}



- (NSRange)rangeOfTopLine{
    NSRange stringRange = NSMakeRange(0, [self length]);
    NSRange firstReturn = [self rangeOfString:@"\n"];
    if(firstReturn.location == NSNotFound || firstReturn.location == stringRange.length-1)
        return NSMakeRange(NSNotFound, 0);
    else
        return NSMakeRange(0, firstReturn.location);
}

- (NSString *)topLine{
    
    NSRange topLineRange = [self rangeOfTopLine];
    
    if(topLineRange.location == NSNotFound)
    {
        return nil;
    }
    else
    {
        return [self substringWithRange:topLineRange];
    }
}

- (NSString *)correction{
    return [self stringByReplacingOccurrencesOfString:@"|" withString:@"\n"];
}
- (NSRange)rangeOfExcerptMetadata:(NSString *)metadataTag
{
    NSRange range = [self rangeOfString:metadataTag];
    if(range.location == NSNotFound) return range;
    
    NSString* excerptdata = [self substringFromIndex:range.location];
    NSRange endrange = [excerptdata rangeOfString:@"\n\n"];
    
    if(endrange.location != NSNotFound)
    {
        return (NSRange){range.location, endrange.location};
    }
    else
    {
        return (NSRange){range.location, self.length - range.location};
    }
    
}
-(NSString *)ro_urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}
- (NSString *)ro_URLEncode {
    NSString *encodedString = (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                     (__bridge CFStringRef)self,
                                                                                                     NULL,
                                                                                                     (CFStringRef) @"!*'();:@&=+$,/?%#[]–",
                                                                                                     kCFStringEncodingUTF8);
    return encodedString;
}

- (NSString *)ro_URLEncoding2
{
 return  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,                  (CFStringRef)self,             NULL,
                                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                               kCFStringEncodingUTF8 ));
}


- (NSString *)ro_URLDecode {
    NSString *decodedString = (__bridge_transfer NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)self,
                                                                                                                     CFSTR(""),
                                                                                                                     kCFStringEncodingUTF8);
    return decodedString;
}
- (NSString *)stringByStrippingExcerptMetadata
{
    NSRange range = [self rangeOfExcerptMetadata:@"@RENOTE\n---------\n"];
    if(range.location == NSNotFound) return self;
    return  [[self stringByReplacingCharactersInRange:range withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)excerptMetadataWithTag:(NSString *)tag
{
    
    NSRange range = [self rangeOfString:tag];
    
    if(range.location == NSNotFound) return nil;
    
    NSString* excerptdata = [self substringFromIndex:range.location+range.length];
    
        NSRange endrange = [excerptdata rangeOfString:@"\n\n"];
    if(endrange.location != NSNotFound)
    {
        NSString * newString = [excerptdata substringToIndex:endrange.location];
        return (newString) ? newString : excerptdata;
    }
    else
    {
        return excerptdata;
    }

}
+ (NSDictionary *)parseIntoDictionaryForString:(NSString *)string{
    NSMutableDictionary *mdict = [NSMutableDictionary new];
    //NSString *sdf = @"^\\* \(.+\)$";
    
    NSError *error;
    NSString *pattern = @"(\\A|\\n\\s*\\n)(.*?\\S[\\s\\S]*?\\S)(?=(\\Z|\\s*\\n\\s*\\n\\n))";

    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    [regex enumerateMatchesInString:string
                            options:0
                              range:NSMakeRange(0, [string length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             NSString *paragraph = [string substringWithRange:[result rangeAtIndex:2]];
                             
                             NSMutableDictionary *dict = [NSMutableDictionary new];
                             
                             NSRange titleRange = [paragraph rangeOfString:@"\n---"];
                             if( titleRange.location == NSNotFound){
                                 [dict setObject:paragraph forKey:@"desc"];
                                 
                             }else{
                                 NSRange titleSeparatorEnd  = [paragraph rangeOfString:@"-\n"];
                                 [dict setObject:[paragraph substringToIndex:titleRange.location] forKey:@"title"];
                                 
                                 if([paragraph length] <= titleSeparatorEnd.location+titleSeparatorEnd.length)
                                 {
                                     //No description;
                                 }else 
                                 [dict setObject:[paragraph substringFromIndex:titleSeparatorEnd.location + titleSeparatorEnd.length] forKey:@"desc"];
                             }
                             
                             if(dict[@"desc"])
                                 [mdict setObject:[dict objectForKey:@"desc"] forKey:[[dict objectForKey:@"title"]  lowercaseString]];

                             
                         }];
    
    
    return [NSDictionary dictionaryWithDictionary:mdict];
    
}
#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

- (NSString *)rs_sanitizeFileNameStringWithExtension:(NSString *)extension
{
    if(!self || [self length] == 0) return nil;
    
    NSString * fn = ([self rangeOfTopLine].location == NSNotFound) ? self : self.topLine;
    
    if(fn.length > 54)
    {
        fn = [fn substringWithRange:NSMakeRange(0, 54)];
    }
    
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|:.\"<>"];
    
    fn = allTrim([[fn componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""]);

    if(!fn) return nil;
    
    return (extension) ? [fn  stringByAppendingPathExtension:extension] : fn;
    
}

- (NSArray *)arrayOfDictionaryItemsTitleKey:(NSString *)titleKeyName keyName:(NSString *)keyName objName:(NSString *)objName lowercaseKeyValue:(BOOL)shouldLowercase
{
    if(!self || nil == self) return nil;
    
    if(!keyName) keyName = @"key";
    if(!objName) objName = @"object";
    if(!titleKeyName) titleKeyName = @"title";

    NSMutableArray *finalArray = [NSMutableArray new];
    NSError *error;
    NSString *pattern = @"([^\r\n\\s]*): \\s*([^\r\n\"]*)\\s*(?:\"(.*)\")?";
    
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    [regex enumerateMatchesInString:self
                            options:0
                              range:NSMakeRange(0, [self length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             NSString *keyStr   =     [[self substringWithRange:[result rangeAtIndex:1]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                             NSString *objectStr    = [[self substringWithRange:[result rangeAtIndex:2]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                             NSString *titleStr;
                             if([result rangeAtIndex:3].location != NSNotFound)
                             {
                                 titleStr = [[self substringWithRange:[result rangeAtIndex:3]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                             }
                             if(shouldLowercase)
                             {
                                 keyStr = [keyStr lowercaseString];
                                 objectStr = [objectStr lowercaseString];
                                 titleStr = (titleStr) ? [titleStr lowercaseString] : nil;
                             }
                             NSDictionary *dict;
                             
                             if(!titleStr)
                             {
                                 dict = @{keyName: keyStr,
                                          objName:  objectStr};
                             }
                             else
                             {
                                 dict = @{keyName: keyStr,
                                          objName: objectStr,
                                          titleKeyName: titleStr};
                             }
                             [finalArray addObject:dict];
                         }];
    
    if(finalArray.count > 0)
        return [finalArray copy];
    else
        return nil;

}

- (NSArray *)arrayDictionaryForLinks
{
    if(!self || nil == self) return nil;
    NSMutableArray *finalArray = [NSMutableArray new];
    NSError *error;
    NSString *pattern = @"([^\r\n\\s]*): ([^\r\n\\s]*)\\s*(?:\"(.*)\")?";
    
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    [regex enumerateMatchesInString:self
                            options:0
                              range:NSMakeRange(0, [self length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             NSString *keyStr = [[self substringWithRange:[result rangeAtIndex:1]] lowercaseString];
                             NSString *objectStr = [self substringWithRange:[result rangeAtIndex:2]];
                             
                             NSString *titleStr;
                             if([result rangeAtIndex:3].location != NSNotFound)
                             {
                                 titleStr = [self substringWithRange:[result rangeAtIndex:3]];
                             }
                             
                             
                             NSDictionary *dict;
                             
                             if(!titleStr)
                                 dict = @{keyStr: @{@"link": objectStr}};
                             else
                                 dict = @{keyStr: @{@"link": objectStr, @"title": titleStr}};
                             [finalArray addObject:dict];
                             
                         }];
    
    if(finalArray.count > 0)
        return [NSArray arrayWithArray:finalArray];
    else
        return nil;
}

- (NSDictionary *)keyValueDictionary
{
    /*
     Pattern of String
     KEY:_String //One space after colon, no space after Key
     KEY:_String
     */
    if(!self || nil == self) return nil;
    NSMutableDictionary *finalDict = [NSMutableDictionary new];
    NSError *error;
    NSString *pattern = @"([^\r\n\\s]*): (.*)";
    
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    [regex enumerateMatchesInString:self
                            options:0
                              range:NSMakeRange(0, [self length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             NSString *keyStr = [[self substringWithRange:[result rangeAtIndex:1]] lowercaseString];
                             NSString *objectStr = [self substringWithRange:[result rangeAtIndex:2]];
                             
                             if(keyStr && objectStr)
                             {
   
                                 [finalDict setObject:objectStr forKey:keyStr];
                             }
                             
                             
                                                         
                         }];
    
    if([finalDict allKeys].count > 0)
        return [NSDictionary dictionaryWithDictionary:finalDict];
    else
        return nil;
    
}

- (NSArray *)rs_paragraphs
{
    if(!self) return nil;
    NSMutableArray *marray  = [NSMutableArray new];
    NSError *error;
    NSString *pattern = @"(\\A|\\n\\s*\\n)(.*?\\S[\\s\\S]*?\\S)(?=(\\Z|\\s*\\n\\s*\\n))";
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    
    NSString  * text = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [regex enumerateMatchesInString:text
                            options:0
                              range:NSMakeRange(0, [text length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSString *paragraph = [[text substringWithRange:[result rangeAtIndex:2]]  stringByReplacingOccurrencesOfString:@"\r" withString:@""];
         [marray addObject:paragraph];
     }];
    
    return (marray.count > 0) ? [marray copy] : nil;
}

+ (NSArray *)parseIntoArray:(NSString *)string{
    
    
    if(!string || nil == string) return nil;
    NSMutableArray *marray  = [NSMutableArray new];
    NSError *error;
    NSString *pattern = @"(\\A|\\n\\s*\\n)(.*?\\S[\\s\\S]*?\\S)(?=(\\Z|\\s*\\n\\s*\\n))";
    
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    [regex enumerateMatchesInString:string
                            options:0
                              range:NSMakeRange(0, [string length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             NSString *paragraph = [[string substringWithRange:[result rangeAtIndex:2]]  stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                             BOOL extend = NO;
 
                             NSMutableDictionary *dict = [NSMutableDictionary new];
                             
                             NSRange titleRange = [paragraph rangeOfString:@"\n---"];
                             if( titleRange.location == NSNotFound){
                                 [dict setObject:paragraph forKey:@"desc"];
                             }else{
                                 
                                 
                                 NSRange titleSeparatorEnd  = [paragraph rangeOfString:@"-\n"];
                                 if(titleSeparatorEnd.location == NSNotFound) titleSeparatorEnd = [paragraph rangeOfString:@"-\r\n"];
                                 NSRange arrowIndicatior = NSMakeRange(0, 2);
                                 NSString *titleLine = [paragraph substringToIndex:titleRange.location];
                                 
                                 if([[titleLine substringWithRange:arrowIndicatior] isEqualToString:@"> "]){
                                     extend = YES;
                                     
                                     NSString *title  = [titleLine substringFromIndex:2];
                                     
                                     //[dict setObject:[titleString substringFromIndex:2] forKey:@"title"];
                                     
                                     
                                     
                                     [dict setObject:title forKey:@"desc"];
                                     if([title isEqualToString:@"Differential Diagnosis"])
                                         [dict setObject:@1 forKey:@"ddx"];
                                     
                                     [dict setObject:@1  forKey:@"extend"];
                                     [dict setObject:[paragraph substringFromIndex:2] forKey:@"extended"];
                                     
                                     //return ;

                                     
                                     
                                 }
                                 

                                  
        
                                 else{

                                 [dict setObject:[paragraph substringToIndex:titleRange.location] forKey:@"title"];
                                     if([[dict objectForKey:@"title"] isEqualToString:@"Differential Diagnosis"])
                                     [dict setObject:@1 forKey:@"ddx"];
                                 }
                                 
                                 
                                 
                                 if(!extend){
                                     
                                NSString *text = [paragraph substringFromIndex:titleSeparatorEnd.location+titleSeparatorEnd.length];
                                NSMutableArray *numberedList = [NSMutableArray new];
                                NSString *desc = [self removeBulletLinesAndAddThemTo:numberedList forString:text];
                                if(desc != nil)[dict setObject:desc forKey:@"desc"];
                                if(numberedList.count >0)[dict setObject:[NSArray arrayWithArray:numberedList] forKey:@"array"];
                                 }
                                 

                             }
                             [marray addObject:dict];
                             
                         }];
    

    return [NSArray arrayWithArray:marray];

}

+ (NSString *)removeBulletLinesAndAddThemTo:(NSMutableArray *)bulletArray forString:(NSString *)string{
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
	int count = [lines count];
	NSMutableArray *lines2 = [NSMutableArray arrayWithArray:lines];
	int i;
	for ( i = 0 ; i < count ; i++ )
	{
		if ([[lines objectAtIndex:i] hasPrefix:@"- "])
		{
            [bulletArray addObject:[[lines objectAtIndex:i] stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
			[lines2 replaceObjectAtIndex:i withObject:[NSNull null]];
		}
	}
	[lines2 removeObjectIdenticalTo:[NSNull null]];
    
	NSString *result = [lines2 componentsJoinedByString:@"\n"];
    
    if  ( [allTrim( result ) length] == 0 ) return nil;
    else
	return result;
}
- (NSString *) removeCommentedLines
{
	NSArray *lines = [self componentsSeparatedByString:@"\n"];// componentsSeparatedByLineSeparators];
	int count = [lines count];
	NSMutableArray *lines2 = [NSMutableArray arrayWithArray:lines];
	int i;
	for ( i = 0 ; i < count ; i++ )
	{
		if ([[lines objectAtIndex:i] hasPrefix:@"- "])
		{
    
			[lines2 replaceObjectAtIndex:i withObject:[NSNull null]];
		}
	}
	[lines2 removeObjectIdenticalTo:[NSNull null]];
	NSString *result = [lines2 componentsJoinedByString:@"\n"];
	return result;
}
//http://stackoverflow.com/questions/6628135/removing-numbers-and-separators-from-a-numbered-list

+ (NSArray *)parseNumberedListIntoArray:(NSString *)string{
    NSMutableArray *marray  = [NSMutableArray new];
    NSError *error;
    NSString *pattern = @"-\\s+([a-zA-Z\\s*]+)(?=\n*[.]+)";
    
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    [regex enumerateMatchesInString:string
                            options:0
                              range:NSMakeRange(0, [string length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             NSString *paragraph = [string substringWithRange:[result rangeAtIndex:1]];
                             [marray addObject:paragraph];
                             
                             
                             
                         }];
    return [NSArray arrayWithArray:marray];
    
}

- (NSArray *)captureExcerptData
{
    
    NSError *error;
//    NSString *pattern = @"(?<=<!-- note -->)(.*?\\S[\\s\\S]*?.*)(?=<!-- end -->)";
    NSString * pattern = @"(?<=<!-- note -->)\\s*(.*?\\S[\\s\\S]*?\\S)\\s*(?=<!-- end -->)";
    
    
    
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    
    __block NSString * captured = nil;
    [regex enumerateMatchesInString:self
                            options:0
                              range:NSMakeRange(0, [self length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             NSString *paragraph = [self substringWithRange:[result rangeAtIndex:1]];
                             
                             captured = paragraph;
                             
                             
                         }];
    
       return  (captured) ? [captured arrayOfDictionaryItemsTitleKey:nil keyName:nil objName:nil lowercaseKeyValue:NO] : nil;
}



@end
