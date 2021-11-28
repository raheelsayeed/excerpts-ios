//
//  TagCollectionCell.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 23/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIColor *tagBgColor;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic, assign) BOOL editMode;

+(UIFont *)font;
@end
