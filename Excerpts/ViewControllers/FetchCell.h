//
//  FetchCell.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 13/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIServices.h"

@interface FetchCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton * titleButton;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, weak) id delegate;
//@property (nonatomic, strong) UITapGestureRecognizer * tap;

@property (nonatomic, weak) NSDictionary * dataDictionary;
@property (nonatomic, assign) API_SERVICE_TYPE serviceType;
@property (nonatomic, strong) UIColor * bgColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor * mainTextColor UI_APPEARANCE_SELECTOR;

+(UIFont *)font;
+(CGFloat)padding;
+(CGFloat)emptyCellSize;


@end
