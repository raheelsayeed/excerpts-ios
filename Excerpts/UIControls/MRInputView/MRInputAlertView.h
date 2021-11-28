//
//  CustomIOS7AlertView.h
//  CustomIOS7AlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@class MRInputAlertView;

typedef void (^onButtonTouchUpInside)(id alertView, int buttonIndex);

typedef NS_ENUM(NSInteger, MRVIEWPOSITION)
{
    MRVIEWPOSITIONTOP,
    MRVIEWPOSITIONCENTER,
};


@protocol MRInputAlertViewDelegate

- (void)mrInputAlertViewButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface MRInputAlertView : UIView < MRInputAlertViewDelegate>

@property (nonatomic, strong) UIView *containerView; // Container within the dialog (place your ui elements here)
@property (nonatomic, strong) UIView *buttonView;    // Buttons on the bottom of the dialog

@property (nonatomic, assign) id<MRInputAlertViewDelegate> delegate;
@property (nonatomic, strong) NSArray *buttonTitles;
@property (nonatomic, assign) NSInteger destructiveButtonIndex;
@property (nonatomic, assign) NSInteger selectedButtonIndex;
@property (nonatomic, strong) NSString * title;
@property (nonatomic) UITextField * titleTextField;
@property (nonatomic, assign) BOOL autoresizeContainerView;
@property (nonatomic, assign) BOOL editableTitle;
@property (copy) onButtonTouchUpInside buttonCompletionBlock;
@property (nonatomic, assign) MRVIEWPOSITION viewPosition;




- (id)init;


- (void)showForView:(UIView *)referenceView dismissCompletionBlock:(onButtonTouchUpInside)buttonTouchBlock;
- (void)close;

- (IBAction)mrInputAlertViewButtonTouchUpInside:(id)sender;


- (id)resultObject;
- (void)setSubView: (UIView *)subView;

@end
