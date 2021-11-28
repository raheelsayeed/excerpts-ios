//
//  FetchCell.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 13/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FetchCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *titleLabel;
+(UIFont *)font;
+(CGFloat)padding;
@end
