//
//  RSPullToAction.h
//  SCUnreadMenu
//
//  Created by M Raheel Sayeed on 03/05/14.
//  Copyright (c) 2014 Subjective-C. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^actionHandler)(void);
typedef NS_ENUM(NSUInteger, RSPullToActionState) {
    RSPullActionStateNormal = 0,
    RSPullActionStateStopped,
    RSPullActionStateLoading,
};
typedef NS_ENUM(NSUInteger, RSPullToActionPostition) {
    RSPullActionPositionTop,
    RSPullActionPositionBottom,
    RSPullActionPositionLeft,
    RSPullActionPositionRight,
};



@interface RSPullToAction : UIView

@property (nonatomic, copy) NSString * text;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, copy) void (^pullToRefreshHandler)(RSPullToAction *v);
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL showPullActionIndicator;
@property (nonatomic, assign) CGFloat effectiveChangeStateInset;
@property (nonatomic, assign, readonly) RSPullToActionPostition position;
@property (nonatomic, assign) CGFloat originalInsetTop;
@property (nonatomic, assign) CGFloat originalInsetBottom;
@property (nonatomic, assign) CGFloat threshold;
@property (nonatomic, weak) UIView * alphaView;
@property (nonatomic, assign) CGFloat indicatorInset;

@property (nonatomic, assign) BOOL enablePullToAction;
- (void)setShowPullActionIndicator:(BOOL)showPullActionIndicator animated:(BOOL)animated;
- (void)assignFramePositionForScrollView;
//- (void)setShowPullToAction:(BOOL)showPullToAction;
- (instancetype)initWithText:(NSString *)text position:(RSPullToActionPostition)position;
@end


@interface UIScrollView (RSPullToAction)
- (RSPullToAction *)addPullToActionPosition:(RSPullToActionPostition)position actionHandler:(void (^)(RSPullToAction *v))handler;
- (void)enableAllRSViewPullActionViews:(BOOL)enable;
@end


