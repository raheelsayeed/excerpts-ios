//
//  Demo_MainController.h
//  Renote
//
//  Created by M Raheel Sayeed on 29/01/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Demo_MainController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *msg;

@property (nonatomic, assign) NSInteger viewCount;
@property (weak, nonatomic) IBOutlet UIButton *addSampleBtn;

- (void)startDemo;
@end
