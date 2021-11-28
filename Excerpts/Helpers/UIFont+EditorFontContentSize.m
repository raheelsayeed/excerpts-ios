//
//  UIFont+AvenirContentSize.m
//  Dynamic Type
//
//  Created by John Szumski on 9/12/13.
//  Copyright (c) 2013 CapTech Consulting. All rights reserved.
//

#import "UIFont+EditorFontContentSize.h"

@implementation UIFont (EditorFontContentSize)

+ (UIFont *)preferredFontForTextStyle:(NSString *)style fontName:(NSString *)fontName
{
    if(!fontName)
    {
        return [UIFont preferredFontForTextStyle:style];
    }
    if([fontName isEqualToString:@"Avenir"])
    {
        return [UIFont preferredAvenirFontForTextStyle:style];
    }
    else if([fontName isEqualToString:@"Verdana"])
    {
        return [UIFont preferredVerdanaFontForTextStyle:style];
    }
    else if([fontName isEqualToString:@"CourierPrime"])
    {
        return [UIFont preferredCourierPrimeFontWithStyle:style];
    }
    else if ([fontName isEqualToString:@"Sintony"])
    {
        return [UIFont preferredSintonyFontForTextStyle:style];
    }
    else if ([fontName isEqualToString:@"Lato-Medium"])
    {
        
        return [UIFont preferredLatoFontForTextStyle:style];
    }
    else
    {
        return [UIFont editorFontWithName:fontName style:style];
    }
}

+ (UIFont*)editorFontWithName:(NSString *)fontName style:(NSString *)style
{
    if(!fontName)
    {
        return [UIFont preferredFontForTextStyle:style];
    }
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:style];
    CGFloat size = [fontDescriptor pointSize];
    return [UIFont fontWithName:fontName size:size];
}

+(UIFont *) font:(UIFont *)font bold:(BOOL)bold italic:(BOOL)italic
{
    UIFontDescriptorSymbolicTraits traits = 0;
    if (bold)
    {
        traits |= UIFontDescriptorTraitBold;
    }
    if (italic)
    {
        traits |= UIFontDescriptorTraitItalic;
    }
    return [UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:traits] size:font.pointSize];
}

+ (UIFont *)editorFontWithFamily:(NSString *)family bold:(BOOL)bold size:(CGFloat)size
{
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:(bold)?UIFontTextStyleSubheadline:UIFontTextStyleBody];
    

    if(size == 0.0) size = [descriptor pointSize];//  [[UIFont preferredFontForTextStyle:(bold)?UIFontTextStyleHeadline:UIFontTextStyleBody] pointSize];
       
    NSArray * fonts = [UIFont fontNamesForFamilyName:family];
    UIFont * anyFontFromFamily = [UIFont fontWithName:[fonts firstObject] size:size];

    if(bold)
    {
        UIFont * boldF = [UIFont font:anyFontFromFamily bold:YES italic:NO];
        if(boldF) return boldF;
        else
            return  [UIFont editorFontWithFamily:family style:UIFontTextStyleHeadline size:size];

    }
    else
    {
        UIFont * normal = [UIFont font:anyFontFromFamily bold:NO italic:NO];
        if(normal) return normal;
        return  [UIFont editorFontWithFamily:family style:UIFontTextStyleBody size:size];
    }
}
+ (UIFont *)editorFontWithFamily:(NSString *)family style:(NSString *)style size:(CGFloat)fontSize
{

    
    

    
    
    
    
    static dispatch_once_t onceToken;
    static NSDictionary *fontDictionary;
    dispatch_once(&onceToken, ^{

        fontDictionary = @{@"Lato" : @{UIFontTextStyleHeadline : @"Lato-Bold", UIFontTextStyleBody : @"Lato-Medium"},
                           @"DejaVu Sans Mono" : @{UIFontTextStyleHeadline : @"DejaVuSansMono-Bold", UIFontTextStyleBody : @"DejaVuSansMono"},
                           @"Inconsolata LGC" : @{UIFontTextStyleHeadline : @"InconsolataLGC-Bold", UIFontTextStyleBody : @"InconsolataLGC-Medium"},
                           @"Source Sans Pro" : @{UIFontTextStyleHeadline : @"SourceSansPro-Bold", UIFontTextStyleBody : @"SourceSansPro-Regular"},
                           @"Courier Prime" : @{UIFontTextStyleHeadline : @"CourierPrime-Bold", UIFontTextStyleBody : @"CourierPrime"},
                           @"Verdana"       : @{UIFontTextStyleHeadline : @"Verdana-Bold", UIFontTextStyleBody : @"Verdana"}
                           };
    });
    CGFloat size  = (fontSize == 0.0) ?  [[UIFont preferredFontForTextStyle:style] pointSize] : fontSize;
    return [UIFont fontWithName:fontDictionary[family][style] size:size];
}

+ (UIFont *)preferredAvenirFontForTextStyle:(NSString *)textStyle
{
	// choose the font size
	CGFloat fontSize = 16.f;
	NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;
    
    static NSString *FONT_NAME_REGULAR = @"Avenir-Book";
    static NSString *FONT_NAME_MEDIUM = @"Avenir-Medium";
    
    static dispatch_once_t onceToken;
    static NSDictionary *AvenirfontSizeOffsetDictionary;
    dispatch_once(&onceToken, ^{
        
        AvenirfontSizeOffsetDictionary = @{ UIContentSizeCategoryExtraSmall     :     @{ UIFontTextStyleBody : @(-2),
                                                                                   UIFontTextStyleHeadline : @(-2),
                                                                                   UIFontTextStyleSubheadline : @(-4),
                                                                                   UIFontTextStyleCaption1 : @(-5),
                                                                                   UIFontTextStyleCaption2 : @(-5),
                                                                                   UIFontTextStyleFootnote : @(-4) },
                                      
                                      UIContentSizeCategorySmall          :   @{ UIFontTextStyleBody : @(-1),
                                                                                 UIFontTextStyleHeadline : @(-1),
                                                                                 UIFontTextStyleSubheadline : @(-3),
                                                                                 UIFontTextStyleCaption1 : @(-5),
                                                                                 UIFontTextStyleCaption2 : @(-5),
                                                                                 UIFontTextStyleFootnote : @(-4) },
                                      
                                      UIContentSizeCategoryMedium         :   @{ UIFontTextStyleBody : @(0),
                                                                                 UIFontTextStyleHeadline : @(0),
                                                                                 UIFontTextStyleSubheadline : @(-2),
                                                                                 UIFontTextStyleCaption1 : @(-5),
                                                                                 UIFontTextStyleCaption2 : @(-5),
                                                                                 UIFontTextStyleFootnote : @(-4) },
                                      
                                      UIContentSizeCategoryLarge          :   @{ UIFontTextStyleBody : @(1),
                                                                                 UIFontTextStyleHeadline : @(1),
                                                                                 UIFontTextStyleSubheadline : @(-1),
                                                                                 UIFontTextStyleCaption1 : @(-4),
                                                                                 UIFontTextStyleCaption2 : @(-5),
                                                                                 UIFontTextStyleFootnote : @(-3) },
                                      
                                      UIContentSizeCategoryExtraLarge     :   @{ UIFontTextStyleBody : @(2),
                                                                                 UIFontTextStyleHeadline : @(2),
                                                                                 UIFontTextStyleSubheadline : @(0),
                                                                                 UIFontTextStyleCaption1 : @(-3),
                                                                                 UIFontTextStyleCaption2 : @(-4),
                                                                                 UIFontTextStyleFootnote : @(-2) },
                                      
                                      UIContentSizeCategoryExtraExtraLarge :  @{ UIFontTextStyleBody : @(3),
                                                                                 UIFontTextStyleHeadline : @(3),
                                                                                 UIFontTextStyleSubheadline : @(1),
                                                                                 UIFontTextStyleCaption1 : @(-2),
                                                                                 UIFontTextStyleCaption2 : @(-3),
                                                                                 UIFontTextStyleFootnote : @(-1) },
                                      
                                      UIContentSizeCategoryExtraExtraExtraLarge : @{ UIFontTextStyleBody : @(4),
                                                                                     UIFontTextStyleHeadline : @(4),
                                                                                     UIFontTextStyleSubheadline : @(2),
                                                                                     UIFontTextStyleCaption1 : @(-1),
                                                                                     UIFontTextStyleCaption2 : @(-2),
                                                                                     UIFontTextStyleFootnote : @(0) }
                                      };
    });
    
    // adjust the default font size based on what the User has set in Settings
    CGFloat fontSizeOffset = [AvenirfontSizeOffsetDictionary[contentSize][textStyle] doubleValue];
    fontSize += fontSizeOffset;
    
    // choose the font weight
	if ([textStyle isEqualToString:UIFontTextStyleHeadline] ||
		[textStyle isEqualToString:UIFontTextStyleSubheadline]) {
        
		return [UIFont fontWithName:FONT_NAME_MEDIUM size:fontSize];
        
	} else {
		return [UIFont fontWithName:FONT_NAME_REGULAR size:fontSize];
	}
}






+ (UIFont *)preferredVerdanaFontForTextStyle:(NSString *)textStyle
{
	// choose the font size
	CGFloat fontSize = 14.f;
	NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;
    
    static NSString *FONT_NAME_REGULAR = @"Verdana";
    static NSString *FONT_NAME_MEDIUM = @"Verdana-Bold";
    
    static dispatch_once_t onceToken;
    static NSDictionary *fontSizeOffsetDictionaryVerdana;
    dispatch_once(&onceToken, ^{
        
        fontSizeOffsetDictionaryVerdana = @{ UIContentSizeCategoryExtraSmall     :     @{ UIFontTextStyleBody : @(-2),
                                                                                   UIFontTextStyleHeadline : @(-2),
                                                                                   UIFontTextStyleSubheadline : @(-4),
                                                                                   UIFontTextStyleCaption1 : @(-5),
                                                                                   UIFontTextStyleCaption2 : @(-5),
                                                                                   UIFontTextStyleFootnote : @(-4) },
                                      
                                      UIContentSizeCategorySmall          :   @{ UIFontTextStyleBody : @(-1),
                                                                                 UIFontTextStyleHeadline : @(-1),
                                                                                 UIFontTextStyleSubheadline : @(-3),
                                                                                 UIFontTextStyleCaption1 : @(-5),
                                                                                 UIFontTextStyleCaption2 : @(-5),
                                                                                 UIFontTextStyleFootnote : @(-4) },
                                      
                                      UIContentSizeCategoryMedium         :   @{ UIFontTextStyleBody : @(0),
                                                                                 UIFontTextStyleHeadline : @(0),
                                                                                 UIFontTextStyleSubheadline : @(-2),
                                                                                 UIFontTextStyleCaption1 : @(-5),
                                                                                 UIFontTextStyleCaption2 : @(-5),
                                                                                 UIFontTextStyleFootnote : @(-4) },
                                      
                                      UIContentSizeCategoryLarge          :   @{ UIFontTextStyleBody : @(1),
                                                                                 UIFontTextStyleHeadline : @(1),
                                                                                 UIFontTextStyleSubheadline : @(-1),
                                                                                 UIFontTextStyleCaption1 : @(-4),
                                                                                 UIFontTextStyleCaption2 : @(-5),
                                                                                 UIFontTextStyleFootnote : @(-3) },
                                      
                                      UIContentSizeCategoryExtraLarge     :   @{ UIFontTextStyleBody : @(2),
                                                                                 UIFontTextStyleHeadline : @(2),
                                                                                 UIFontTextStyleSubheadline : @(0),
                                                                                 UIFontTextStyleCaption1 : @(-3),
                                                                                 UIFontTextStyleCaption2 : @(-4),
                                                                                 UIFontTextStyleFootnote : @(-2) },
                                      
                                      UIContentSizeCategoryExtraExtraLarge :  @{ UIFontTextStyleBody : @(3),
                                                                                 UIFontTextStyleHeadline : @(3),
                                                                                 UIFontTextStyleSubheadline : @(1),
                                                                                 UIFontTextStyleCaption1 : @(-2),
                                                                                 UIFontTextStyleCaption2 : @(-3),
                                                                                 UIFontTextStyleFootnote : @(-1) },
                                      
                                      UIContentSizeCategoryExtraExtraExtraLarge : @{ UIFontTextStyleBody : @(4),
                                                                                     UIFontTextStyleHeadline : @(4),
                                                                                     UIFontTextStyleSubheadline : @(2),
                                                                                     UIFontTextStyleCaption1 : @(-1),
                                                                                     UIFontTextStyleCaption2 : @(-2),
                                                                                     UIFontTextStyleFootnote : @(0) }
                                      };
    });
    // adjust the default font size based on what the User has set in Settings
    CGFloat fontSizeOffset = [fontSizeOffsetDictionaryVerdana[contentSize][textStyle] doubleValue];
    fontSize += fontSizeOffset;
    
    // choose the font weight
	if ([textStyle isEqualToString:UIFontTextStyleHeadline] ||
		[textStyle isEqualToString:UIFontTextStyleSubheadline]) {
        
		return [UIFont fontWithName:FONT_NAME_MEDIUM size:fontSize-1];
        
	} else {
		return [UIFont fontWithName:FONT_NAME_REGULAR size:fontSize];
	}
}



+ (UIFont *)preferredSintonyFontForTextStyle:(NSString *)textStyle
{
	// choose the font size
	CGFloat fontSize = 14.f;
	NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;
    
    static NSString *FONT_NAME_REGULAR = @"Sintony-Regular";
    static NSString *FONT_NAME_MEDIUM = @"Sintony-Bold";
    
    static dispatch_once_t onceToken;
    static NSDictionary *fontSizeOffsetDictionaryVerdana;
    dispatch_once(&onceToken, ^{
        
        fontSizeOffsetDictionaryVerdana = @{ UIContentSizeCategoryExtraSmall     :     @{ UIFontTextStyleBody : @(-2),
                                                                                          UIFontTextStyleHeadline : @(-2),
                                                                                          UIFontTextStyleSubheadline : @(-4),
                                                                                          UIFontTextStyleCaption1 : @(-5),
                                                                                          UIFontTextStyleCaption2 : @(-5),
                                                                                          UIFontTextStyleFootnote : @(-4) },
                                             
                                             UIContentSizeCategorySmall          :   @{ UIFontTextStyleBody : @(-1),
                                                                                        UIFontTextStyleHeadline : @(-1),
                                                                                        UIFontTextStyleSubheadline : @(-3),
                                                                                        UIFontTextStyleCaption1 : @(-5),
                                                                                        UIFontTextStyleCaption2 : @(-5),
                                                                                        UIFontTextStyleFootnote : @(-4) },
                                             
                                             UIContentSizeCategoryMedium         :   @{ UIFontTextStyleBody : @(0),
                                                                                        UIFontTextStyleHeadline : @(0),
                                                                                        UIFontTextStyleSubheadline : @(-2),
                                                                                        UIFontTextStyleCaption1 : @(-5),
                                                                                        UIFontTextStyleCaption2 : @(-5),
                                                                                        UIFontTextStyleFootnote : @(-4) },
                                             
                                             UIContentSizeCategoryLarge          :   @{ UIFontTextStyleBody : @(1),
                                                                                        UIFontTextStyleHeadline : @(1),
                                                                                        UIFontTextStyleSubheadline : @(-1),
                                                                                        UIFontTextStyleCaption1 : @(-4),
                                                                                        UIFontTextStyleCaption2 : @(-5),
                                                                                        UIFontTextStyleFootnote : @(-3) },
                                             
                                             UIContentSizeCategoryExtraLarge     :   @{ UIFontTextStyleBody : @(2),
                                                                                        UIFontTextStyleHeadline : @(2),
                                                                                        UIFontTextStyleSubheadline : @(0),
                                                                                        UIFontTextStyleCaption1 : @(-3),
                                                                                        UIFontTextStyleCaption2 : @(-4),
                                                                                        UIFontTextStyleFootnote : @(-2) },
                                             
                                             UIContentSizeCategoryExtraExtraLarge :  @{ UIFontTextStyleBody : @(3),
                                                                                        UIFontTextStyleHeadline : @(3),
                                                                                        UIFontTextStyleSubheadline : @(1),
                                                                                        UIFontTextStyleCaption1 : @(-2),
                                                                                        UIFontTextStyleCaption2 : @(-3),
                                                                                        UIFontTextStyleFootnote : @(-1) },
                                             
                                             UIContentSizeCategoryExtraExtraExtraLarge : @{ UIFontTextStyleBody : @(4),
                                                                                            UIFontTextStyleHeadline : @(4),
                                                                                            UIFontTextStyleSubheadline : @(2),
                                                                                            UIFontTextStyleCaption1 : @(-1),
                                                                                            UIFontTextStyleCaption2 : @(-2),
                                                                                            UIFontTextStyleFootnote : @(0) }
                                             };
    });
    // adjust the default font size based on what the User has set in Settings
    CGFloat fontSizeOffset = [fontSizeOffsetDictionaryVerdana[contentSize][textStyle] doubleValue];
    fontSize += fontSizeOffset;
    
    // choose the font weight
	if ([textStyle isEqualToString:UIFontTextStyleHeadline] ||
		[textStyle isEqualToString:UIFontTextStyleSubheadline]) {
        
		return [UIFont fontWithName:FONT_NAME_MEDIUM size:fontSize];
        
	} else {
		return [UIFont fontWithName:FONT_NAME_REGULAR size:fontSize];
	}
}

+ (UIFont *)preferredLatoFontForTextStyle:(NSString *)textStyle
{
	// choose the font size
	CGFloat fontSize = 15.f;
	NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;
    
    static NSString *FONT_NAME_REGULAR = @"Lato-Medium";
    static NSString *FONT_NAME_MEDIUM = @"Lato-Bold";
    
    static dispatch_once_t onceToken;
    static NSDictionary *fontSizeOffsetDictionaryLato;
    dispatch_once(&onceToken, ^{
        
        fontSizeOffsetDictionaryLato = @{ UIContentSizeCategoryExtraSmall     :     @{ UIFontTextStyleBody : @(-2),
                                                                                          UIFontTextStyleHeadline : @(-2),
                                                                                          UIFontTextStyleSubheadline : @(-4),
                                                                                          UIFontTextStyleCaption1 : @(-5),
                                                                                          UIFontTextStyleCaption2 : @(-5),
                                                                                          UIFontTextStyleFootnote : @(-4) },
                                             
                                             UIContentSizeCategorySmall          :   @{ UIFontTextStyleBody : @(-1),
                                                                                        UIFontTextStyleHeadline : @(-1),
                                                                                        UIFontTextStyleSubheadline : @(-3),
                                                                                        UIFontTextStyleCaption1 : @(-5),
                                                                                        UIFontTextStyleCaption2 : @(-5),
                                                                                        UIFontTextStyleFootnote : @(-4) },
                                             
                                             UIContentSizeCategoryMedium         :   @{ UIFontTextStyleBody : @(0),
                                                                                        UIFontTextStyleHeadline : @(0),
                                                                                        UIFontTextStyleSubheadline : @(-2),
                                                                                        UIFontTextStyleCaption1 : @(-5),
                                                                                        UIFontTextStyleCaption2 : @(-5),
                                                                                        UIFontTextStyleFootnote : @(-4) },
                                             
                                             UIContentSizeCategoryLarge          :   @{ UIFontTextStyleBody : @(1),
                                                                                        UIFontTextStyleHeadline : @(1),
                                                                                        UIFontTextStyleSubheadline : @(-1),
                                                                                        UIFontTextStyleCaption1 : @(-4),
                                                                                        UIFontTextStyleCaption2 : @(-5),
                                                                                        UIFontTextStyleFootnote : @(-3) },
                                             
                                             UIContentSizeCategoryExtraLarge     :   @{ UIFontTextStyleBody : @(2),
                                                                                        UIFontTextStyleHeadline : @(2),
                                                                                        UIFontTextStyleSubheadline : @(0),
                                                                                        UIFontTextStyleCaption1 : @(-3),
                                                                                        UIFontTextStyleCaption2 : @(-4),
                                                                                        UIFontTextStyleFootnote : @(-2) },
                                             
                                             UIContentSizeCategoryExtraExtraLarge :  @{ UIFontTextStyleBody : @(3),
                                                                                        UIFontTextStyleHeadline : @(3),
                                                                                        UIFontTextStyleSubheadline : @(1),
                                                                                        UIFontTextStyleCaption1 : @(-2),
                                                                                        UIFontTextStyleCaption2 : @(-3),
                                                                                        UIFontTextStyleFootnote : @(-1) },
                                             
                                             UIContentSizeCategoryExtraExtraExtraLarge : @{ UIFontTextStyleBody : @(4),
                                                                                            UIFontTextStyleHeadline : @(4),
                                                                                            UIFontTextStyleSubheadline : @(2),
                                                                                            UIFontTextStyleCaption1 : @(-1),
                                                                                            UIFontTextStyleCaption2 : @(-2),
                                                                                            UIFontTextStyleFootnote : @(0) }
                                             };
    });
    // adjust the default font size based on what the User has set in Settings
    CGFloat fontSizeOffset = [fontSizeOffsetDictionaryLato[contentSize][textStyle] doubleValue];
    fontSize += fontSizeOffset;
    
    // choose the font weight
	if ([textStyle isEqualToString:UIFontTextStyleHeadline] ||
		[textStyle isEqualToString:UIFontTextStyleSubheadline]) {
        
		return [UIFont fontWithName:FONT_NAME_MEDIUM size:fontSize];
        
	} else {
		return [UIFont fontWithName:FONT_NAME_REGULAR size:fontSize];
	}
}




+ (UIFont *)preferredCourierPrimeFontWithStyle:(NSString *)textStyle
{
	// choose the font size
	CGFloat fontSize = 14.f;
	NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;
    
    static NSString *FONT_NAME_REGULAR = @"CourierPrime";
    static NSString *FONT_NAME_MEDIUM = @"CourierPrime-Bold";
    
    static dispatch_once_t onceToken;
    static NSDictionary *fontSizeOffsetDictionaryCourierPrime;
    dispatch_once(&onceToken, ^{
        
        fontSizeOffsetDictionaryCourierPrime = @{ UIContentSizeCategoryExtraSmall     :     @{ UIFontTextStyleBody : @(-2),
                                                                                   UIFontTextStyleHeadline : @(-2),
                                                                                   UIFontTextStyleSubheadline : @(-4),
                                                                                   UIFontTextStyleCaption1 : @(-5),
                                                                                   UIFontTextStyleCaption2 : @(-5),
                                                                                   UIFontTextStyleFootnote : @(-4) },
                                      
                                      UIContentSizeCategorySmall          :   @{ UIFontTextStyleBody : @(-1),
                                                                                 UIFontTextStyleHeadline : @(-1),
                                                                                 UIFontTextStyleSubheadline : @(-3),
                                                                                 UIFontTextStyleCaption1 : @(-5),
                                                                                 UIFontTextStyleCaption2 : @(-5),
                                                                                 UIFontTextStyleFootnote : @(-4) },
                                      
                                      UIContentSizeCategoryMedium         :   @{ UIFontTextStyleBody : @(0),
                                                                                 UIFontTextStyleHeadline : @(0),
                                                                                 UIFontTextStyleSubheadline : @(-2),
                                                                                 UIFontTextStyleCaption1 : @(-5),
                                                                                 UIFontTextStyleCaption2 : @(-5),
                                                                                 UIFontTextStyleFootnote : @(-4) },
                                      
                                      UIContentSizeCategoryLarge          :   @{ UIFontTextStyleBody : @(1),
                                                                                 UIFontTextStyleHeadline : @(1),
                                                                                 UIFontTextStyleSubheadline : @(-1),
                                                                                 UIFontTextStyleCaption1 : @(-4),
                                                                                 UIFontTextStyleCaption2 : @(-5),
                                                                                 UIFontTextStyleFootnote : @(-3) },
                                      
                                      UIContentSizeCategoryExtraLarge     :   @{ UIFontTextStyleBody : @(2),
                                                                                 UIFontTextStyleHeadline : @(2),
                                                                                 UIFontTextStyleSubheadline : @(0),
                                                                                 UIFontTextStyleCaption1 : @(-3),
                                                                                 UIFontTextStyleCaption2 : @(-4),
                                                                                 UIFontTextStyleFootnote : @(-2) },
                                      
                                      UIContentSizeCategoryExtraExtraLarge :  @{ UIFontTextStyleBody : @(3),
                                                                                 UIFontTextStyleHeadline : @(3),
                                                                                 UIFontTextStyleSubheadline : @(1),
                                                                                 UIFontTextStyleCaption1 : @(-2),
                                                                                 UIFontTextStyleCaption2 : @(-3),
                                                                                 UIFontTextStyleFootnote : @(-1) },
                                      
                                      UIContentSizeCategoryExtraExtraExtraLarge : @{ UIFontTextStyleBody : @(4),
                                                                                     UIFontTextStyleHeadline : @(4),
                                                                                     UIFontTextStyleSubheadline : @(2),
                                                                                     UIFontTextStyleCaption1 : @(-1),
                                                                                     UIFontTextStyleCaption2 : @(-2),
                                                                                     UIFontTextStyleFootnote : @(0) }
                                      };
    });
    
    // adjust the default font size based on what the User has set in Settings
    CGFloat fontSizeOffset = [fontSizeOffsetDictionaryCourierPrime[contentSize][textStyle] doubleValue];
    fontSize += fontSizeOffset;
    
    // choose the font weight
	if ([textStyle isEqualToString:UIFontTextStyleHeadline] ||
		[textStyle isEqualToString:UIFontTextStyleSubheadline]) {
        
		return [UIFont fontWithName:FONT_NAME_MEDIUM size:fontSize];
        
	} else {
		return [UIFont fontWithName:FONT_NAME_REGULAR size:fontSize];
	}
}
@end