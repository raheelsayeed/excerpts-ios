//
//  SectionHeader.h
//   Renote
//
//  Created by M Raheel Sayeed on 29/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectionHeader : UICollectionReusableView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) UILabel *countLabel;
@property (nonatomic) UIButton *sortingBtn;
@property (nonatomic) UIButton *rightBtn;
@property (nonatomic) UIButton *leftBtn;
@property (nonatomic, weak) id delegate;

@end
