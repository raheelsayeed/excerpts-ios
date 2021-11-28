//
//  RWebViewController.m
//   Renote
//
//  Created by M Raheel Sayeed on 03/01/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import "RWebViewController.h"
#import "ContainerController.h"
@interface RWebViewController (){
    BOOL correctInsets;
}

@property (nonatomic) UIVisualEffectView * header;

@end

@implementation RWebViewController

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super initWithURL:URL];
    if(self)
    {
        self.webController.showCustomBackItemButton = YES;
    }
    return self;
}

- (void)loadRequest:(NSURLRequest *)request
{
    [self.webController.webView loadRequest:request];
}
- (void)viewDidLoad {

    [super viewDidLoad];
    self.navigationBarHidden = YES;

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.header = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _header.frame = CGRectMake(0, 0, self.view.frame.size.width, 20.f);
    [self.view addSubview:_header];
    

    [self.webController loadView];
    [[self.webController webView] needsUpdateConstraints];
    
    correctInsets = YES;
    
    
    
    
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if(!correctInsets) return;
    
    
    CGFloat top = self.webController.topLayoutGuide.length;
    CGRect frame = self.webController.webView.frame;
    frame.origin.y = top;
    
    CGFloat bottom = self.webController.bottomLayoutGuide.length;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(20, 0, bottom, 0);
    
    BOOL sametraits = (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone) && (self.traitCollection.verticalSizeClass ==  UIUserInterfaceSizeClassCompact);
    
    insets.top = (sametraits) ? 0.f : 20.f;
    _header.hidden = sametraits;
    [self.webController.webView.scrollView setScrollIndicatorInsets:insets];
    [self.webController.webView.scrollView setContentInset:insets];
    
    correctInsets = NO;
}
- (void)goBack:(id)sender
{
    [(ContainerController *)self.parentViewController transitionToPrevious];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:self.webController.webView.isLoading];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    CGFloat top = self.webController.topLayoutGuide.length;
    CGRect frame = self.webController.webView.frame;
    frame.origin.y = top;

    CGFloat bottom = self.webController.bottomLayoutGuide.length;

    UIEdgeInsets insets = UIEdgeInsetsMake(20, 0, bottom, 0);
    
    BOOL sametraits = (newCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone) && (newCollection.verticalSizeClass ==  UIUserInterfaceSizeClassCompact);
    
    insets.top = (sametraits) ? 0.f : 20.f;
    insets.bottom = (sametraits) ? 32.f : 44.f;
    
    
    void (^changes)(void) = ^{
        _header.hidden = sametraits;
        [self.webController.webView.scrollView setScrollIndicatorInsets:insets];
        [self.webController.webView.scrollView setContentInset:insets];
        [self.webController.webView.scrollView setContentOffset:CGPointMake(0, insets.top)];
    };
    
    
    
    if(coordinator)
    {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        changes();
        
    } completion:nil];
    }else
    {
        changes();
    }
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}





@end
