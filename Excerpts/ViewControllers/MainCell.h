//
//  MainCell.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 20/06/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;

@interface MainCell : UICollectionViewCell

@property (nonatomic) UILabel* label;
@property (nonatomic) UILabel* metaLabel;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) UIImageView * imageView;

@property (nonatomic, strong) UIColor * labelTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor * sideLabelTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor * cellBackgroundColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIFont  * labelFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSString * fontTypeName UI_APPEARANCE_SELECTOR;
@property (weak, nonatomic) Note *notePointer;


- (void)configureCell:(Note *)note sortKey:(NSString *)sortKey;


- (void)blink;
- (void)sendToArchive:(id)sender;
- (void)sendToUnarchive:(id)sender;
@end
