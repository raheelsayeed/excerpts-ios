//
//  VGTokenFieldView.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 26/12/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//


#import "TITokenField.h"
#import "VGTokenFieldView.h"
#import "Note.h"






typedef enum {
    VGTAGMODE=1,
    VGTAGSERVICEMODE=2
} VGMODE;

@class AFJSONRequestOperation;

@interface VGTokenFieldView : TITokenFieldView

@property (nonatomic, assign) VGMODE modeType;
@property (nonatomic, assign) BOOL allowMultipleSelection;
@property (nonatomic, weak) Note * note;
@property (nonatomic, weak) id sourceDelegate;
@property (nonatomic, strong) NSMutableSet *linksArray;
@property (nonatomic, strong) NSMutableSet *tagsArray;

-(void)setModeType:(VGMODE)type;
-(void)switchTokenMode:(id)sender;
-(void)addSearchOperationsForServices:(NSArray *)services inQueue:(NSOperationQueue *)queue;
- (instancetype)initWithFrame:(CGRect)frame note:(Note *)note sourceDelegate:(id)delegate;
-(void)showOverView:(UIView *)container size:(CGSize)size animate:(BOOL)animate;
-(void)hide:(id)sender;
@end




