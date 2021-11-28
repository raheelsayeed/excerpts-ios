//
//  TagViewController.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 13/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class TagViewController, PanGestureRecognizer;
@protocol TagViewControllerPanTarget <NSObject>
-(void)userDidPan:(PanGestureRecognizer *)gestureRecognizer;
@end

@interface TagViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readonly) id<TagViewControllerPanTarget> panTarget;
@property (strong, readwrite, nonatomic) id parallaxMenuMinimumRelativeValue;
@property (strong, readwrite, nonatomic) id parallaxMenuMaximumRelativeValue;
@property (assign, readwrite, nonatomic) BOOL parallaxEnabled;

-(id)initWithPanTarget:(id<TagViewControllerPanTarget>)panTarget;
- (void)saveOnTerminate;
-(void)pauseFRC:(BOOL)pause;

@end
