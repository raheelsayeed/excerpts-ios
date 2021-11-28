//
//  NSString+RSParser.h
//  Clinicals
//
//  Created by Mohammed Raheel Sayeed on 04/02/13.
//  Copyright (c) 2013 Medical Gear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RSParser)

- (NSArray *)rs_paragraphs;

+ (NSDictionary *)parseIntoDictionaryForString:(NSString *)string;
+ (NSArray *)parseIntoArray:(NSString *)string;
+ (NSArray *)parseNumberedListIntoArray:(NSString *)string;
+ (NSString *)removeBulletLinesAndAddThemTo:(NSMutableArray *)bulletArray forString:(NSString *)string;
- (NSString *)correction;

- (NSString *) md5;

- (NSArray *)arrayDictionaryForLinks;

//Generic Converter of String to Dict;
- (NSDictionary *)keyValueDictionary;

- (NSString *)stringGroupByFirstInitial;

- (NSString *)flattenHTML;
- (NSString *)removeHTML;
- (NSString *)ro_URLEncode;
-(NSString *)ro_urlEncodeUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)ro_URLEncoding2;

- (NSRange)rangeOfTopLine;
- (NSString *)stringByStrippingExcerptMetadata;
- (NSString *)topLine;
- (NSArray *)captureExcerptData;
- (NSString *)excerptMetadataWithTag:(NSString *)tag;
- (NSArray *)arrayOfDictionaryItemsTitleKey:(NSString *)titleKeyName keyName:(NSString *)keyName objName:(NSString *)objName lowercaseKeyValue:(BOOL)shouldLowercase;
- (NSString *)rs_sanitizeFileNameStringWithExtension:(NSString *)extension;
@end
