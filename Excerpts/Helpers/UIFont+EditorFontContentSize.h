//
//  UIFont+AvenirContentSize.h
//  Dynamic Type
//
//  Created by John Szumski on 9/12/13.
//  Copyright (c) 2013 CapTech Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (EditorFontContentSize)

+ (UIFont*)preferredAvenirFontForTextStyle:(NSString*)textStyle;
+ (UIFont *)preferredFontForTextStyle:(NSString *)style fontName:(NSString *)fontName;
+ (UIFont *)editorFontWithFamily:(NSString *)family style:(NSString *)style size:(CGFloat)fontSize;

+ (UIFont *)editorFontWithFamily:(NSString *)family bold:(BOOL)bold size:(CGFloat)size;
@end