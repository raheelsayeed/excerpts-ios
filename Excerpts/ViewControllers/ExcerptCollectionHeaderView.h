//
//  ExcerptCollectionHeaderView.h
//   Renote
//
//  Created by M Raheel Sayeed on 14/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RequestObject;

@interface ExcerptCollectionHeaderView : UICollectionReusableView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton * actionBtn;
@property (nonatomic, weak) RequestObject * requestObject;

- (void)updateStatus;

@end
