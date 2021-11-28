//
//  Demo_MainController.m
//  Renote
//
//  Created by M Raheel Sayeed on 29/01/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import "Demo_MainController.h"
#import "DemoViewController.h"
#import "AppDelegate.h"
#import "DMScaleTransition.h"
#import "IOAction.h"

@interface Demo_MainController ()
{
    DemoViewController * parent;
}
@property (nonatomic) UITapGestureRecognizer  * tap;
@end

@implementation Demo_MainController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSelf:)];
    _tap.numberOfTapsRequired = 1;
    _tap.enabled = NO;
    [self.view addGestureRecognizer:_tap];
    self.viewCount = 0;
    self.view.backgroundColor = kColor_MainViewBG;
    
    self.addSampleBtn.hidden = YES;

    

}
- (IBAction)addSampleNotes:(id)sender {
    
    // samplenotes will not be synced, unless chnages are made.
    
        __weak typeof(self) weakSelf = self;
        
        [IOAction importSampleDataFromBundleFolder:@"Sample Notes" completion:^(id exportedObject, BOOL success) {
            
            [MRModalAlertView showMessage:@"Some of them have tips."
                                    title:@"Sample notes added"
                                 overView:weakSelf.view];
            
        }];
        
    
}

- (void)dismissSelf:(id)sender
{
    DMScaleTransition *  t = [[DMScaleTransition alloc] init];
    self.parentViewController.transitioningDelegate = t;
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.viewCount == 0)
    {
        [self performSelector:@selector(startDemo) withObject:nil afterDelay:1];
    }

    
}
- (void)dealloc
{
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)startDemo
{
    self.viewCount += 1;
    
    
    
    Bubble * b = [self.parentViewController performSelector:@selector(bubble)];
    
    [self.view addSubview:b];
    
    
    if(self.viewCount >2)
    {
        [b startTopAnimationAtPoint:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))];
        _tap.enabled = YES;
        self.msg.text = @"Great. All pages can be reached via such drag gestures.\n\nMore: Settings > Help.\n\nTap anywhere to begin RENOTE.";
        _addSampleBtn.hidden = NO;
    }
    else
    {
        if(self.viewCount == 2)
        self.msg.text = @"Nice! You can scroll through your notes but the Note already being viewed/edited will remain Open.\n\nDrag Right-To-Left again to peek";
        
        [b startAnimatingLeftoToRight:NO atPoint:CGPointMake(self.view.bounds.size.width * 0.8, CGRectGetHeight(self.view.bounds) * 0.8)];
        
    }
    

}

@end