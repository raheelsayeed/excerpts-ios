//
//  NSAttributedString+V.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 16/07/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "NSAttributedString+Excerpts.h"
//#import <libxml2/libxml/HTMLparser.h>
#import <libxml2/libxml/HTMLparser.h>



static inline NSRegularExpression * ParenthesisRegularExpression() {
    static NSRegularExpression *_parenthesisRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _parenthesisRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"\\([^\\(\\)]+\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _parenthesisRegularExpression;
}

@implementation NSAttributedString (Excerpts)



+ (NSMutableAttributedString *)boldFirstLine:(NSString *)string
{
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange stringRange = NSMakeRange(0, [mutableAttributedString length]);
    
    NSRange firstReturn = [string rangeOfString:@"\n"];
    
    if(firstReturn.location == NSNotFound || firstReturn.location == stringRange.length-1)
        return mutableAttributedString;
    NSRange firstLineRange = NSMakeRange(0, firstReturn.location);
    
    UIFont *boldFont = [UIFont fontWithName:@"Verdana-Bold" size:14];
    [mutableAttributedString removeAttribute:NSFontAttributeName range:firstLineRange];
    [mutableAttributedString addAttribute:NSFontAttributeName value:boldFont range:firstLineRange];
    
    return mutableAttributedString;
}


+ (NSMutableAttributedString *)applyToString:(NSString *)string
{
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange stringRange = NSMakeRange(0, [mutableAttributedString length]);
    
    NSRegularExpression *regexp = ParenthesisRegularExpression();
    [regexp enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        UIFont *italicSystemFont = [UIFont italicSystemFontOfSize:14.f];
        
        [mutableAttributedString removeAttribute:NSFontAttributeName range:result.range];
        [mutableAttributedString addAttribute:NSFontAttributeName value:italicSystemFont range:result.range];
        
        [mutableAttributedString removeAttribute:NSForegroundColorAttributeName range:result.range];
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:result.range];
    }];
    
    return mutableAttributedString;
    
    
}




+ (NSAttributedString *)attributedStringFromHTML:(NSString *)htmlString boldFont:(UIFont *)boldFont
{
    xmlDoc *document = htmlReadMemory([htmlString cStringUsingEncoding:NSUTF8StringEncoding], htmlString.length, nil, NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
    
    if (document == NULL)
        return nil;
    
    NSMutableAttributedString *finalAttributedString = [[NSMutableAttributedString alloc] init];
    
    xmlNodePtr currentNode = document->children;
    while (currentNode != NULL) {
        NSAttributedString *childString = [self attributedStringFromNode:currentNode boldFont:boldFont];
        if(childString)
        [finalAttributedString appendAttributedString:childString];
        
        currentNode = currentNode->next;
    }
    
    xmlFreeDoc(document);
    
    return [finalAttributedString copy];
}

+ (NSAttributedString *)attributedStringFromNode:(xmlNodePtr)xmlNode boldFont:(UIFont *)boldFont
{
    NSMutableAttributedString *nodeAttributedString = [[NSMutableAttributedString alloc] init];
    
    if ((xmlNode->type != XML_ENTITY_REF_NODE) && ((xmlNode->type != XML_ELEMENT_NODE) && xmlNode->content != NULL)) {
        [nodeAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithCString:(const char *)xmlNode->content encoding:NSUTF8StringEncoding]]];
    }
    
    // Handle children
    xmlNodePtr currentNode = xmlNode->children;
    while (currentNode != NULL) {
        NSAttributedString *childString = [self attributedStringFromNode:currentNode boldFont:boldFont];
        [nodeAttributedString appendAttributedString:childString];
        
        currentNode = currentNode->next;
    }
    
    if (xmlNode->type == XML_ELEMENT_NODE) {
        
        NSRange nodeAttributedStringRange = NSMakeRange(0, nodeAttributedString.length);
        
        // Build dictionary to store attributes
        NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
        if (xmlNode->properties != NULL) {
            xmlAttrPtr attribute = xmlNode->properties;
            
            while (attribute != NULL) {
                NSString *attributeValue = @"";
                
                if (attribute->children != NULL) {
                    attributeValue = [NSString stringWithCString:(const char *)attribute->children->content encoding:NSUTF8StringEncoding];
                }
                NSString *attributeName = [[NSString stringWithCString:(const char*)attribute->name encoding:NSUTF8StringEncoding] lowercaseString];
                [attributeDictionary setObject:attributeValue forKey:attributeName];
                
                attribute = attribute->next;
            }
        }
        
        // Bold Tag
        if (strncmp("b", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            if (boldFont) {
                [nodeAttributedString addAttribute:NSFontAttributeName value:boldFont range:nodeAttributedStringRange];
            }
        }
        
        // Underline Tag
        else if (strncmp("u", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            [nodeAttributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:nodeAttributedStringRange];
        }
        
        // Stike Tag
        else if (strncmp("strike", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            [nodeAttributedString addAttribute:NSStrikethroughStyleAttributeName value:@(YES) range:nodeAttributedStringRange];
        }
        
        // Stoke Tag
        else if (strncmp("stroke", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            UIColor *strokeColor = [UIColor purpleColor];
            NSNumber *strokeWidth = @(1.0);
            
            if ([attributeDictionary objectForKey:@"color"]) {
                strokeColor = [self colorFromHexString:[attributeDictionary objectForKey:@"color"]];
            }
            if ([attributeDictionary objectForKey:@"width"]) {
                strokeWidth = @(fabs([[attributeDictionary objectForKey:@"width"] doubleValue]));
            }
            if (![attributeDictionary objectForKey:@"nofill"]) {
                strokeWidth = @(-fabs([strokeWidth doubleValue]));
            }
            
            [nodeAttributedString addAttribute:NSStrokeColorAttributeName value:strokeColor range:nodeAttributedStringRange];
            [nodeAttributedString addAttribute:NSStrokeWidthAttributeName value:strokeWidth range:nodeAttributedStringRange];
        }
        
        // Shadow Tag
        else if (strncmp("shadow", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowOffset = CGSizeMake(0, 0);
            shadow.shadowBlurRadius = 2.0;
            shadow.shadowColor = [UIColor blackColor];
            
            if ([attributeDictionary objectForKey:@"offset"]) {
                shadow.shadowOffset = CGSizeFromString([attributeDictionary objectForKey:@"offset"]);
            }
            if ([attributeDictionary objectForKey:@"blurradius"]) {
                shadow.shadowBlurRadius = [[attributeDictionary objectForKey:@"blurradius"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"color"]) {
                shadow.shadowColor = [self colorFromHexString:[attributeDictionary objectForKey:@"color"]];
            }
            
            [nodeAttributedString addAttribute:NSShadowAttributeName value:shadow range:nodeAttributedStringRange];
        }
        
        // Font Tag
        else if (strncmp("font", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            NSString *fontName = nil;
            NSNumber *fontSize = nil;
            UIColor *foregroundColor = nil;
            UIColor *backgroundColor = nil;
            
            if ([attributeDictionary objectForKey:@"face"]) {
                fontName = [attributeDictionary objectForKey:@"face"];
            }
            if ([attributeDictionary objectForKey:@"size"]) {
                fontSize = @([[attributeDictionary objectForKey:@"size"] doubleValue]);
            }
            if ([attributeDictionary objectForKey:@"color"]) {
                foregroundColor = [self colorFromHexString:[attributeDictionary objectForKey:@"color"]];
            }
            if ([attributeDictionary objectForKey:@"backgroundcolor"]) {
                backgroundColor = [self colorFromHexString:[attributeDictionary objectForKey:@"backgroundcolor"]];
            }
            
            if (fontName == nil && fontSize != nil) {
                [nodeAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[fontSize doubleValue]] range:nodeAttributedStringRange];
            }
            else if (fontName != nil && fontSize == nil) {
                [nodeAttributedString addAttribute:NSFontAttributeName value:[self fontOrSystemFontForName:fontName size:12.0] range:nodeAttributedStringRange];
            }
            else if (fontName != nil && fontSize != nil) {
                [nodeAttributedString addAttribute:NSFontAttributeName value:[self fontOrSystemFontForName:fontName size:fontSize.floatValue] range:nodeAttributedStringRange];
            }
            
            if (foregroundColor) {
                [nodeAttributedString addAttribute:NSForegroundColorAttributeName value:foregroundColor range:nodeAttributedStringRange];
            }
            if (backgroundColor) {
                [nodeAttributedString addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:nodeAttributedStringRange];
            }
        }
        
        // Paragraph Tag
        else if (strncmp("p", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            
            if ([attributeDictionary objectForKey:@"align"]) {
                NSString *alignString = [[attributeDictionary objectForKey:@"align"] lowercaseString];
                
                if ([alignString isEqualToString:@"left"]) {
                    paragraphStyle.alignment = NSTextAlignmentLeft;
                }
                else if ([alignString isEqualToString:@"center"]) {
                    paragraphStyle.alignment = NSTextAlignmentCenter;
                }
                else if ([alignString isEqualToString:@"right"]) {
                    paragraphStyle.alignment = NSTextAlignmentRight;
                }
                else if ([alignString isEqualToString:@"justify"]) {
                    paragraphStyle.alignment = NSTextAlignmentJustified;
                }
            }
            if ([attributeDictionary objectForKey:@"linebreakmode"]) {
                NSString *lineBreakModeString = [[attributeDictionary objectForKey:@"linebreakmode"] lowercaseString];
                
                if ([lineBreakModeString isEqualToString:@"wordwrapping"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                }
                else if ([lineBreakModeString isEqualToString:@"charwrapping"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
                }
                else if ([lineBreakModeString isEqualToString:@"clipping"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
                }
                else if ([lineBreakModeString isEqualToString:@"truncatinghead"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingHead;
                }
                else if ([lineBreakModeString isEqualToString:@"truncatingtail"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
                }
                else if ([lineBreakModeString isEqualToString:@"truncatingmiddle"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
                }
            }
            
            if ([attributeDictionary objectForKey:@"firstlineheadindent"]) {
                paragraphStyle.firstLineHeadIndent = [[attributeDictionary objectForKey:@"firstlineheadindent"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"headindent"]) {
                paragraphStyle.headIndent = [[attributeDictionary objectForKey:@"headindent"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"hyphenationfactor"]) {
                paragraphStyle.hyphenationFactor = [[attributeDictionary objectForKey:@"hyphenationfactor"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"lineheightmultiple"]) {
                paragraphStyle.lineHeightMultiple = [[attributeDictionary objectForKey:@"lineheightmultiple"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"linespacing"]) {
                paragraphStyle.lineSpacing = [[attributeDictionary objectForKey:@"linespacing"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"maximumlineheight"]) {
                paragraphStyle.maximumLineHeight = [[attributeDictionary objectForKey:@"maximumlineheight"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"minimumlineheight"]) {
                paragraphStyle.minimumLineHeight = [[attributeDictionary objectForKey:@"minimumlineheight"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"paragraphspacing"]) {
                paragraphStyle.paragraphSpacing = [[attributeDictionary objectForKey:@"paragraphspacing"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"paragraphspacingbefore"]) {
                paragraphStyle.paragraphSpacingBefore = [[attributeDictionary objectForKey:@"paragraphspacingbefore"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"tailindent"]) {
                paragraphStyle.tailIndent = [[attributeDictionary objectForKey:@"tailindent"] doubleValue];
            }
            
            [nodeAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:nodeAttributedStringRange];
        }
    }
    
    return nodeAttributedString;
}

+ (UIFont *)fontOrSystemFontForName:(NSString *)fontName size:(CGFloat)fontSize {
    UIFont * font = [UIFont fontWithName:fontName size:fontSize];
    if(font) {
        return font;
    }
    return [UIFont systemFontOfSize:fontSize];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    if (hexString == nil)
        return nil;
    
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    char *p;
    NSUInteger hexValue = strtoul([hexString cStringUsingEncoding:NSUTF8StringEncoding], &p, 16);
    
    return [UIColor colorWithRed:((hexValue & 0xff0000) >> 16) / 255.0 green:((hexValue & 0xff00) >> 8) / 255.0 blue:(hexValue & 0xff) / 255.0 alpha:1.0];
}



@end
