//
//  SVModalWebViewController.h
//
//  Created by Oliver Letterer on 13.08.11.
//  Copyright 2011 Home. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import <UIKit/UIKit.h>

#import "SVWebViewController.h"
@class SVWebViewController;


@interface SVModalWebViewController : UINavigationController

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL *)URL;
- (instancetype)initWithHtml:(NSString *)html;

- (SVWebViewController *)webController;
@property (nonatomic, strong) UIColor *barsTintColor;

@end
