//
//  FetcherViewController.m
//   Renote
//
//  Created by M Raheel Sayeed on 23/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "FetcherViewController.h"
#import "NSString+QSKit.h"
#import "ExcerptCollectionViewFlowLayout.h"




@interface FetcherViewController ()


@property (nonatomic, assign) NSUInteger _fetchSectionIndex;
@end


@implementation FetcherViewController
@synthesize editingIndexPath = _editingIndexPath, cacheFetchedData = _cacheFetchedData;

- (instancetype) initWithFetchSectionIndex:(NSUInteger)index
{
    ExcerptCollectionViewFlowLayout * flowLayout = [[ExcerptCollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(320, 100)];
    flowLayout.minimumInteritemSpacing = 0.f;
    flowLayout.minimumLineSpacing = 0.f;
    
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 15, 0);
    self = [super initWithCollectionViewLayout:flowLayout];
    if(self)
    {
        self.backgroundQueue = dispatch_queue_create("com.renoteapp.ios.backgroundRequests", NULL);
        _fetchOperationQueue = [NSOperationQueue new];
        _fetchOperationQueue.maxConcurrentOperationCount = 1;
        _cacheFetchedData = YES;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerCollectionCells];
}
-(void)registerCollectionCells
{
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FetchCell"];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addKeyboardNotifications];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];

}
/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayout];
}
*/
# pragma mark - UIKeyboard Events
- (void)keyboardWillShow:(NSNotification *)note
{
    [self.collectionView  scrollRectToVisible:CGRectMake(0, 0, _editingItemSize.width, _editingItemSize.height) animated:NO];
    self.collectionView.scrollEnabled = !self.editing;
    self.collectionView.alwaysBounceHorizontal = self.editing;
    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (void)addKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
 
}
- (void)keyboardWillChange:(NSNotification *)notification {
    
    NSDictionary* keyboardInfo = [notification userInfo];
    CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _editingItemSize = CGSizeMake(keyboardFrame.size.width, keyboardFrame.origin.y);

    
    

    
    

}

- (BOOL)canUseInternet
{
   return  (self.shouldUseWIFIOnlyForFetchingLinks) ? (self.networkStatus == ReachableViaWiFi) : YES;
}

#pragma mark Fetch Operations
-(void)abortFetchOperations
{
    [self.fetchOperationQueue cancelAllOperations];
    self.fetchOperationQueue = nil;
    self.fetchOperationQueue = [NSOperationQueue new];
    self.fetchOperationQueue.maxConcurrentOperationCount = 1;
//    [self.fetchOperationQueue setSuspended:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}




#pragma mark - COllection View delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 0;
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    
    static NSString * cellIdentifier = @"FetchCell";
    UICollectionViewCell * cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

@end
