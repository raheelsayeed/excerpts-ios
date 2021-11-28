//
//  FetchViewController.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 11/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

/*
 ##  1. Export Files
 ##  2. Import Vignettes
 ##  3. Export to dropbox
 */
#import <UIKit/UIKit.h>
#import "FetchImageCell.h"
#import "FetchCell.h"
#import "FetchCell_Editor.h"
#import "AFJSONRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "FetchServices.h"

@interface FetchViewController : UICollectionViewController


@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic) CGSize editingItemSize;

@end
