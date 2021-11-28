//
//  FetchCell_Editor.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 11/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapTextView.h"

@class TapTextView;

@interface FetchCell_Editor : UICollectionViewCell <NSLayoutManagerDelegate, NSTextStorageDelegate>
@property (nonatomic, strong) TapTextView * textView;
@property (nonatomic, strong) UIColor * editorTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor * cellBackgroundColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIFont * textFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIFont * boldFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) NSString * fontTypeName UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) NSString * fontFamily UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) CGFloat fontSize;


/*
+ (UIFont *)font;
+ (UIFont *)boldFont;
*/
@end
