//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVModalWebViewController.h"

@interface SVWebViewController : UIViewController

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, assign) BOOL showToolbar;
@property (nonatomic, assign) BOOL showHTMLActionButton;
@property (nonatomic, assign) BOOL showCustomBackItemButton;

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;
- (instancetype)initWithHtml:(NSString *)html;
@end
