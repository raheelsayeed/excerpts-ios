//
//  EXTImageViewController.h
//  Excerpts
//
//  Created by M Raheel Sayeed on 16/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EXTImageViewController : UIViewController

@property (strong, nonatomic)  UIScrollView *scrollView;

@property (strong, nonatomic)  UIImageView *imageView;

@property (strong, nonatomic, readonly) UIImage *image;

- (instancetype)initWithImage:(UIImage *)image;

@end
