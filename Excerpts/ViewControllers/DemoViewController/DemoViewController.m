//
//  DemoViewController.m
//  Renote
//
//  Created by M Raheel Sayeed on 29/01/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import "DemoViewController.h"
#import "Bubble.h"
#import "Demo_MainController.h"
#import "Demo_NoteController.h"
#import "ExcerptViewController.h"
#import "DMScaleTransition.h"

@interface DemoViewController () < ContainerViewControllerDatasource>
{
    Demo_NoteController * noteVC;
    UITapGestureRecognizer * tap;
    
}
@property (nonatomic) Demo_MainController *mainVC;
@property (nonatomic) DMScaleTransition * transition;
@end

@implementation DemoViewController

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.modalPresentationCapturesStatusBarAppearance = YES;
        self.modalPresentationStyle = UIModalPresentationCustom;
        
        self.mainVC = [[Demo_MainController alloc] initWithNibName:@"Demo_MainController" bundle:nil];
        [self setInitialViewController:_mainVC];

      
        
        
        
        
        noteVC = [[Demo_NoteController alloc] initWithNote:nil];
        noteVC.shouldTurnOnEditMode = NO;
        
        self.bubble = [[Bubble alloc] initWithFrame:CGRectMake(50, 400, 60, 60)];
        self.bubble.backgroundColor = [self.view tintColor];

        
        [_mainVC.view addSubview:_bubble];
        
        
        self.datasource = self;
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = kColor_Orange;
    
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dismissSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)containerViewController:(UIViewController *)container viewControllerBeforeViewController:(UIViewController *)vc
{
    if(vc == _mainVC) return nil;
    
    return _mainVC;
}
- (UIViewController *)containerViewController:(UIViewController *)container viewControllerAfterViewController:(UIViewController *)vc
{
    if(vc == _mainVC) return noteVC;
    
    return nil;

    
}
- (void)containerViewController:(UIViewController *)container viewControllerWillTransitionToNewTraits:(UITraitCollection *)traitCollection coordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    
}

- (void)stopAllAnimatedIndications
{
    [_bubble stopAnimating];
    
}

- (void)animationTransitionEnded
{
    [super animationTransitionEnded];
    
    [_bubble stopAnimating];
    
    [self.currentViewController.view addSubview:self.bubble];
    
    [self.currentViewController performSelector:@selector(startDemo)];


}

- (void)dealloc
{
    
}

@end
