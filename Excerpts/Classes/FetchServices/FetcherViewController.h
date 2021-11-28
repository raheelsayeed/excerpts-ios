//
//  FetcherViewController.h
//   Renote
//
//  Created by M Raheel Sayeed on 23/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFJSONRequestOperation.h"
#import "NSAttributedString+Excerpts.h"
#import "JTSReachability.h"

static char FetchObjectKVOContext = 0;


@interface FetcherViewController : UICollectionViewController

@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic) CGSize editingItemSize;
@property (nonatomic, strong) NSOperationQueue *fetchOperationQueue;
@property (nonatomic, assign) BOOL cacheFetchedData;
@property (nonatomic, strong) dispatch_queue_t backgroundQueue;
@property (nonatomic, assign) BOOL shouldUseWIFIOnlyForFetchingLinks;
@property (nonatomic, assign) JTSNetworkStatus networkStatus;
@property (nonatomic, assign, getter = canUseInternet) BOOL useInternet;








-(instancetype)initWithFetchSectionIndex:(NSUInteger)index;
- (id)fetchData:(NSString *)iden apiKey:(NSString *)apiKey title:(NSString *)title linkedObject:(id)linkedObject observeForFetches:(BOOL)observe initiateFetchOp:(BOOL)initiateOp;

//-(void)fetchArticleWithIdentifier:(NSString *)identifier serviceKey:(NSString *)serviceKey withTitle:(NSString *)link_Title forLinkObj:(id)linkObject;
-(void)abortFetchOperations;
-(void)startFetchOperations;


-(void)registerCollectionCells;
-(void)reloadFetchDataAtIndex:(NSUInteger)index;

void runOnMainQueueWithoutDeadlocking(void (^block)(void));

- (void)cacheFetchedData:(NSString *)string forService:(NSString *)serviceKey withIdentifier:(NSString *)identifier forLinkObject:(id)linkObject;
- (void)setCacheFetchedData:(BOOL)shouldCache;
-(NSAttributedString *)attrStringForData:(NSString *)data;



@end


