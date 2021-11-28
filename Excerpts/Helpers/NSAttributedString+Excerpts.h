//
//  NSAttributedString+V.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 16/07/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Excerpts)

+ (NSMutableAttributedString *)applyToString:(NSString *)string;
+ (NSMutableAttributedString *)boldFirstLine:(NSString *)string;
+ (NSAttributedString *)attributedStringFromHTML:(NSString *)htmlString boldFont:(UIFont *)boldFont;
@end
