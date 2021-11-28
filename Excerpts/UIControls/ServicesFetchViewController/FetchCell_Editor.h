//
//  FetchCell_Editor.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 11/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TapTextView;
@interface FetchCell_Editor : UICollectionViewCell
@property (nonatomic, strong) TapTextView * textView;

-(void)setEditing:(BOOL)editing;
+ (UIFont *)font;
+ (UIFont *)boldFont;

@end
