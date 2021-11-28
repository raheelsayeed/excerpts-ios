//
//  UIFontDescriptor+Avenir.m
//   Renote
//
//  Created by M Raheel Sayeed on 10/05/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "UIFontDescriptor+Avenir.h"

NSString *const ANUIFontTextStyleCaption3 = @"ANUIFontTextStyleCaption3";

@implementation UIFontDescriptor (Avenir)
+(UIFontDescriptor *)preferredAvenirFontDescriptorWithTextStyle:(NSString *)style {
    static dispatch_once_t onceToken;
    static NSDictionary *fontSizeTable;
    dispatch_once(&onceToken, ^{
        fontSizeTable = @{
                          UIFontTextStyleHeadline: @{UIContentSizeCategoryExtraExtraExtraLarge: @(23),
                                                     UIContentSizeCategoryExtraExtraLarge: @(21),
                                                     UIContentSizeCategoryExtraLarge: @(18),
                                                     UIContentSizeCategoryLarge: @(16),
                                                     UIContentSizeCategoryMedium: @(15),
                                                     UIContentSizeCategorySmall: @(14),
                                                     UIContentSizeCategoryExtraSmall: @(13),},
                          
                          UIFontTextStyleSubheadline: @{UIContentSizeCategoryExtraExtraExtraLarge: @(22),
                                                        UIContentSizeCategoryExtraExtraLarge: @(20),
                                                        UIContentSizeCategoryExtraLarge: @(17),
                                                        UIContentSizeCategoryLarge: @(16),
                                                        UIContentSizeCategoryMedium: @(14),
                                                        UIContentSizeCategorySmall: @(13),
                                                        UIContentSizeCategoryExtraSmall: @(12),},
                          
                          UIFontTextStyleBody: @{UIContentSizeCategoryExtraExtraExtraLarge: @(21),
                                                 UIContentSizeCategoryExtraExtraLarge: @(19),
                                                 UIContentSizeCategoryExtraLarge: @(16),
                                                 UIContentSizeCategoryLarge: @(15),
                                                 UIContentSizeCategoryMedium: @(14),
                                                 UIContentSizeCategorySmall: @(12),
                                                 UIContentSizeCategoryExtraSmall: @(12),},
                          
                          UIFontTextStyleCaption1: @{UIContentSizeCategoryExtraExtraExtraLarge: @(20),
                                                     UIContentSizeCategoryExtraExtraLarge: @(18),
                                                     UIContentSizeCategoryExtraLarge: @(15),
                                                     UIContentSizeCategoryLarge: @(14),
                                                     UIContentSizeCategoryMedium: @(13),
                                                     UIContentSizeCategorySmall: @(12),
                                                     UIContentSizeCategoryExtraSmall: @(11),},
                          
                          UIFontTextStyleCaption2: @{UIContentSizeCategoryExtraExtraExtraLarge: @(19),
                                                     UIContentSizeCategoryExtraExtraLarge: @(17),
                                                     UIContentSizeCategoryExtraLarge: @(14),
                                                     UIContentSizeCategoryLarge: @(13),
                                                     UIContentSizeCategoryMedium: @(12),
                                                     UIContentSizeCategorySmall: @(12),
                                                     UIContentSizeCategoryExtraSmall: @(11),},
                          
                          ANUIFontTextStyleCaption3: @{UIContentSizeCategoryExtraExtraExtraLarge: @(18),
                                                       UIContentSizeCategoryExtraExtraLarge: @(16),
                                                       UIContentSizeCategoryExtraLarge: @(13),
                                                       UIContentSizeCategoryLarge: @(12),
                                                       UIContentSizeCategoryMedium: @(12),
                                                       UIContentSizeCategorySmall: @(11),
                                                       UIContentSizeCategoryExtraSmall: @(10),},
                          
                          UIFontTextStyleFootnote: @{UIContentSizeCategoryExtraExtraExtraLarge: @(17),
                                                     UIContentSizeCategoryExtraExtraLarge: @(15),
                                                     UIContentSizeCategoryExtraLarge: @(12),
                                                     UIContentSizeCategoryLarge: @(12),
                                                     UIContentSizeCategoryMedium: @(11),
                                                     UIContentSizeCategorySmall: @(10),
                                                     UIContentSizeCategoryExtraSmall: @(10),},
                          };
    });
    
    
    NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;
    
    return [UIFontDescriptor fontDescriptorWithName:@"Avenir" size:((NSNumber *)fontSizeTable[style][contentSize]).floatValue];
}


@end