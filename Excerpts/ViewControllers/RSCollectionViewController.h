//
//  RSCollectionViewController.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 20/06/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SBRCallbackActionHandler.h"
@class  RNNavigationBar;
@interface RSCollectionViewController : UICollectionViewController <UIActionSheetDelegate, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) UIToolbar * toolBar;
@property (nonatomic) RNNavigationBar *navigationBar;
@property (nonatomic) NSNumber * isGrid;

- (void)addSettingsObservers:(BOOL)add;

- (void)activeSelectionModeForGetAction:(BOOL)active params:(NSDictionary *)parameters callback:(SBRCallbackActionHandlerCompletionBlock)completionBlock;

@end
