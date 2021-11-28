//
//  EXTImageViewController.m
//  Excerpts
//
//  Created by M Raheel Sayeed on 16/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "EXTImageViewController.h"

@interface EXTImageViewController () <UIScrollViewDelegate>

@property (strong, nonatomic)  UITapGestureRecognizer *singleTapGestureRecognizer;
//@property (strong, nonatomic)  UITapGestureRecognizer *doubleTapGestureRecognizer;

@end

@implementation EXTImageViewController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithNibName:Nil bundle:nil];
    if(self)
    {
        _image = image;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.delaysContentTouches = NO;
//    self.scrollView.autoresizesSubviews = YES;
    self.scrollView.maximumZoomScale = 2.f;
    self.scrollView.minimumZoomScale = 1.f;
    self.scrollView.contentMode = UIViewContentModeScaleToFill;
    self.scrollView.bounces = YES;
    self.scrollView.scrollEnabled =YES;

    [self.view addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    

    [self.scrollView addSubview:self.imageView];
    
    self.view.backgroundColor = self.scrollView.backgroundColor = self.imageView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    
    [self addGuestures];
}
- (void)addGuestures
{
    self.singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.singleTapGestureRecognizer];
    /*
    self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
     */

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.image;
    
//    self.scrollView.contentSize = self.imageView.image.size;

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private methods

- (void)handleSingleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        // Zoom out
        [self.scrollView zoomToRect:self.scrollView.bounds animated:YES];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        // Zoom in
        CGPoint center = [tapGestureRecognizer locationInView:self.scrollView];
        CGSize size = CGSizeMake(self.scrollView.bounds.size.width / self.scrollView.maximumZoomScale,
                                 self.scrollView.bounds.size.height / self.scrollView.maximumZoomScale);
        CGRect rect = CGRectMake(center.x - (size.width / 2.0), center.y - (size.height / 2.0), size.width, size.height);
        [self.scrollView zoomToRect:rect animated:YES];
    }
    else {
        // Zoom out
        [self.scrollView zoomToRect:self.scrollView.bounds animated:YES];
    }
}
@end
