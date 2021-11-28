//
//  TagViewController.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 13/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "TagViewController.h"
#import "TagCollectionFlowLayout.h"
#import "TagCollectionCell.h"
#import "BDKCollectionIndexView.h"
#import "NSString+RSParser.h"
#import "TLMenuInteractor.h"
#import "DataManager.h"
#import "MRInputTextFieldView.h"
#import "MRModalAlertView.h"
#import "UIView+MotionEffect.h"
#import "PanGestureRecognizer.h"
#import "UICollectionView+EmptyState.h"

static NSString   * kTagsDidChange = @"SelectedTagsDidChange";

@interface TagViewController () <UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    BOOL sectionDidChange;
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    UIToolbar * toolBar;
    BOOL haultUpdate;

}
@property (nonatomic, strong) NSBlockOperation *blockOperation;
@property (strong, nonatomic) BDKCollectionIndexView *indexView;
@property (nonatomic, strong) NSMutableDictionary * tagIndexSelectionHolder;
@property (nonatomic, strong) UISegmentedControl  * tagSelector;
@property (nonatomic)     NSMutableArray *selectedTagsArray;
@property (nonatomic) NSMutableArray * updateBlocks;
@property (nonatomic, copy) void (^collectionViewFinishedUpdatingBlock)(void);


@end



@implementation TagViewController
{
    TagCollectionCell *_sizingCell;
    BOOL shouldReloadCollectionView;
    UIButton * editButton;
    UIAlertView * editAlertView;
}
@synthesize fetchedResultsController = _fetchedResultsController, blockOperation;


-(id)initWithPanTarget:(id<TagViewControllerPanTarget>)panTarget
{
    TagCollectionFlowLayout *flowLayout = [[TagCollectionFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:flowLayout];
    if(self)
    {
        self.parallaxEnabled = YES;
        _parallaxMenuMinimumRelativeValue = @(-15);
        _parallaxMenuMaximumRelativeValue = @(15);
        _panTarget = panTarget;
        
        self.selectedTagsArray = [NSMutableArray new];


    }
    return self;
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (id)init
{
    TagCollectionFlowLayout *flowLayout = [[TagCollectionFlowLayout alloc] init];
   // [flowLayout setSectionInset:UIEdgeInsetsMake(0 ,28.f, 44, 0)];

    self = [super initWithCollectionViewLayout:flowLayout];
    if(self)
    {
        
        _parallaxEnabled = YES;

    }
    return self;
}
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    toolBar.frame = CGRectMake(0, self.view.frame.size.height - 44.f, self.view.frame.size.width, 44);

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];

  
    
    [self.view addSubview:self.indexView];
    self.view.opaque = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:(isIPad) ? 0.8 : 0.7];
    self.collectionView.delaysContentTouches = NO;
    self.collectionView.backgroundView.opaque = NO;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[TagCollectionCell class] forCellWithReuseIdentifier:@"TagCell"];
    
    self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 200, 70)];
    label.text = @"Tags";
    label.textColor = [UIColor lightTextColor];
    //label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:26];
    label.textAlignment = NSTextAlignmentCenter;

    self.collectionView.emptyState_view = label;
    self.collectionView.emptyState_showAnimationDuration = 0.4;
    
    _sizingCell = [[TagCollectionCell alloc] initWithFrame:CGRectZero];
   
    
    
    
    CGFloat headerHeight = 44;
     toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height- 24, self.view.frame.size.width, headerHeight)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    toolBar.barStyle = UIBarStyleBlack;
    toolBar.translucent = YES;
    [self.view addSubview:toolBar];
    
    
    

    self.tagSelector  = [[UISegmentedControl alloc] initWithItems:@[@"AND", @"OR",@"untagged"]];
    [_tagSelector addTarget:self action:@selector(tagSelectionOption:) forControlEvents:UIControlEventValueChanged];
    _tagSelector.tintColor = [UIColor colorWithRed:0.20 green:0.66 blue:0.86 alpha:1.00];
    [_tagSelector setSelectedSegmentIndex:0];
    _tagSelector.selectedSegmentIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:kSettings_fvc_selectedTagsOption] integerValue];
    [_tagSelector setBackgroundColor:[UIColor blackColor]];


    
    UIBarButtonItem * segmentBtn = [[UIBarButtonItem alloc] initWithCustomView:_tagSelector];
    UIBarButtonItem * flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:nil];
    
    self.editButtonItem.tintColor = [UIColor whiteColor];
    [toolBar setItems:@[ segmentBtn , flex, self.editButtonItem]];
    
    
    
    self.collectionView.allowsMultipleSelection = YES;
    
    
    CGRect iframe = CGRectMake(0,
                              20.f,
                              28.f,
                              self.collectionView.frame.size.height - (headerHeight+20));
    self.indexView.frame = iframe;
    
    
//    self.collectionView.contentInset = UIEdgeInsetsMake(0 ,28.f, headerHeight, 0);
    self.collectionView.contentInset = UIEdgeInsetsMake(0 ,0, headerHeight, 0);

    
    
    PanGestureRecognizer *gestureRecognizer = [[PanGestureRecognizer alloc] initWithTarget:self.panTarget action:@selector(userDidPan:)];
    gestureRecognizer.maximumNumberOfTouches = 1;
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [[DataManager sharedInstance] setTagsFetchController:[self fetchedResultsController]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTagsArrived:) name:kDatastoreSyncManagerIncomingChangeCountNotification object:nil];

}
- (void)newTagsArrived:(NSNotification *)note
{
    static NSString * tagEntity = @"Tag";
    
    if(![note.userInfo[@"storeTitle"] isEqualToString:tagEntity]) return;
    
    NSInteger count = [note.object integerValue];
    if(count > 10) shouldReloadCollectionView = YES;
    
}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer {
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
        CGPoint velocity = [panRecognizer velocityInView:self.parentViewController.view];
        
        if(velocity.x < 0.0)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    return NO;
}
-(void)doneWasPressed:(id)sender {

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveOnTerminate
{
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if(_selectedTagsArray.count == 0)
    {
        [d removeObjectForKey:kSettings_fvc_selectedTagsIDs];
    }
    else
    {
        [d setObject:[_selectedTagsArray copy] forKey:kSettings_fvc_selectedTagsIDs];
    }
    [d  setObject:@(_tagSelector.selectedSegmentIndex) forKey:kSettings_fvc_selectedTagsOption];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    if(self.parallaxEnabled)
    {
        [self addParallexEffect];
        
    }
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(self.parallaxEnabled)
    {
        [self.collectionView removeMotionEffects];
    }
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    
    
    
    
    if(self.isEditing == editing) return;
    
    [super setEditing:editing animated:animated];

    
    //_tagSelector.hidden = editing;
    self.collectionView.allowsMultipleSelection = !editing;
    [self.collectionView reloadData];
    
    toolBar.barTintColor = (editing) ? self.view.tintColor : nil;
    
    
    UIBarButtonItem * flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:nil];


    if(editing)
    {
        UIBarButtonItem * clearTagSelection = [[UIBarButtonItem alloc] initWithTitle:@"Clear Tag Selections" style:UIBarButtonItemStylePlain target:self action:@selector(clearTagSelections:)];
        clearTagSelection.tintColor = [UIColor whiteColor];
        [toolBar setItems:@[clearTagSelection, flex,self.editButtonItem]];
    }
    else
    {
        [toolBar setItems:@[[[UIBarButtonItem alloc] initWithCustomView:_tagSelector], flex, self.editButtonItem]];
        
    }
    
    
    
    if(!editing && _tagSelector.selectedSegmentIndex == 2)
    {
        self.collectionView.alpha = 0.5;
    }
    else
    {
        self.collectionView.alpha = 1.0;
    }
}
- (void)clearTagSelections:(id)sender
{
    NSArray * selectedTags = [[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
    
    [selectedTags makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
    

    for (NSString * firstLetter in _tagIndexSelectionHolder.allKeys)
    {
        NSInteger index = [[_indexView indexTitles] indexOfObject:firstLetter];
        UILabel * lbl = [_indexView indexLabels][index];
        lbl.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    }
    [_tagIndexSelectionHolder removeAllObjects];
    [_selectedTagsArray removeAllObjects];
    [self postTagsNotification];
    
    
    [MRModalAlertView showMessage:@"Tags that you selected to filter notes have all been unselected"
                            title:@"All Tags Unselected"
                         overView:self.view];
}


-(void)postTagsNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagsDidChange object:[_selectedTagsArray copy]];
}
-(void)tagSelectionOption:(UISegmentedControl *)segment{
    
    if(segment.selectedSegmentIndex == 2)
    {
        self.collectionView.alpha = 0.4;
    }
    else
    {
        self.collectionView.alpha = 1;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagsDidChange object:@(segment.selectedSegmentIndex)];

}


-(void)addNewTag
{
    Tag *tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:[[DataManager sharedInstance] managedObjectContext]];
    tag.title = [NSString stringWithFormat:@"title:%lu", (unsigned long)self.fetchedResultsController.fetchedObjects.count];
    [[DataManager sharedInstance] save];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    editAlertView = nil;
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kDatastoreSyncManagerIncomingChangeCountNotification];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.collectionView.collectionViewLayout invalidateLayout];
}
- (BDKCollectionIndexView *)indexView {
    if (_indexView) return _indexView;
    CGRect frame = CGRectMake(0,
                              CGRectGetMinY(self.collectionView.frame)+self.topLayoutGuide.length,
                              28.f,
                              CGRectGetHeight(self.collectionView.frame)-(self.bottomLayoutGuide.length+self.topLayoutGuide.length));
    
    self.indexView = [BDKCollectionIndexView indexViewWithFrame:frame indexTitles:@[]];
    _indexView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [_indexView addTarget:self
                   action:@selector(indexViewValueChanged:)
         forControlEvents:UIControlEventValueChanged];
    return _indexView;
}
- (void)indexViewValueChanged:(BDKCollectionIndexView *)sender {
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:sender.currentIndex];
    if (![self collectionView:self.collectionView cellForItemAtIndexPath:path])
        return;
    
    [self.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    CGFloat yOffset = self.collectionView.contentOffset.y;
    
    self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, yOffset);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isEditing) return;
    
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    BOOL selected = [tag.selected boolValue];
    cell.selected = selected;
    
    if(selected)
    {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    else
    {
        
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    
    TagCollectionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"TagCell" forIndexPath:indexPath];
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if(self.isEditing)
    {
        cell.tagBgColor =  [UIColor colorWithRed:0.16 green:0.76 blue:0.97 alpha:1.00];
    }
    else
    {

        cell.tagBgColor = [UIColor colorWithWhite:0.8 alpha:1.0];
     

    }
    cell.label.text = tag.title;
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CGSize sz = [tag.title sizeWithAttributes:@{NSFontAttributeName : [TagCollectionCell font]}];
    
    return CGSizeMake(sz.width+15, 32);
    
//    return CGSizeMake(sz.width+15 +((self.isEditing) ? 0 : 0) , ([[DataManager sharedInstance] is_ipad]) ? 42 : 32);
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if(self.isEditing)
    {
        [self editTag:tag atIndexPath:indexPath];
        return;
    }

//    [tag setPrimitiveValue:@YES forKey:@"selected"];
    haultUpdate = YES;
    tag.selected = @YES;
   
    if(![_selectedTagsArray containsObject:tag.syncID])
    {
        [_selectedTagsArray addObject:tag.syncID];
    }

    [self postTagsNotification];
    
    [self highlightSectionIndex:indexPath.section];
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];


    haultUpdate = YES;
    tag.selected = @NO;
    
    
    if([_selectedTagsArray containsObject:tag.syncID])
        [_selectedTagsArray removeObject:tag.syncID];

    
    [self postTagsNotification];
    
    [self deHighlightSectionIndex:indexPath.section];

}

- (void)deHighlightSectionIndex:(NSUInteger)index
{
    UILabel*lbl = [self.indexView indexLabels][index];

    
    int i = 1;
    
    if(_tagIndexSelectionHolder[lbl.text])
    {
        NSNumber * n = _tagIndexSelectionHolder[lbl.text];
        if(n.intValue == 1)
        {
            lbl.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
            [_tagIndexSelectionHolder removeObjectForKey:lbl.text];
        }
        else
        {
            n  = @(n.intValue - i);
            _tagIndexSelectionHolder[lbl.text] = n;
        }
    }

}

- (void)highlightSectionIndex:(NSUInteger)index
{
    
    UILabel * lbl = [_indexView indexLabels][index];
    lbl.textColor = [UIColor whiteColor];
    NSString * firstLetter = lbl.text;
    
    if(!_tagIndexSelectionHolder)
    {
        self.tagIndexSelectionHolder = [NSMutableDictionary new];
    }
    
    int i = 1;
    
    if(_tagIndexSelectionHolder[firstLetter])
    {
        NSNumber * n = _tagIndexSelectionHolder[firstLetter];
        n  = @(n.intValue + i);
        _tagIndexSelectionHolder[firstLetter] = n;
    }
    else
    {
        _tagIndexSelectionHolder[firstLetter] = @(i);
    }
    
}
- (void)highlightSectionIndexForTitle:(NSString *)title
{
    NSString * firstLetter = [[title substringToIndex:1] uppercaseString];
    [self highlightSectionIndex:[_indexView.indexTitles indexOfObject:firstLetter]];
//    UILabel * lbl = [_indexView.indexLabels objectAtIndex:[_indexView.indexTitles indexOfObject:firstLetter]];
   
    
    
}



#pragma mark FetchedResultsController

-(NSFetchedResultsController *)fetchedResultsController
{
    if(_fetchedResultsController)
        return _fetchedResultsController;
    
    [NSFetchedResultsController deleteCacheWithName:@"tcache"];
    NSManagedObjectContext *context = [[DataManager sharedInstance] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setPropertiesToFetch:@[@"title"]];
//    [fetchRequest setIncludesSubentities:NO];
    //[fetchRequest setIncludesPendingChanges:NO];
    [fetchRequest setFetchBatchSize:20];
    
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title != nil"]];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"uppercaseFirstLetterOfTitle"  cacheName:@"tcache"];
    aFetchedResultsController.delegate = self;

    self.fetchedResultsController = aFetchedResultsController;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    }
    
    

    self.indexView.indexTitles = [_fetchedResultsController sectionIndexTitles];
    
    [_selectedTagsArray removeAllObjects];
    
    NSArray * selected = [[_fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
    
    for(Tag * tag in  selected)
    {
        [_selectedTagsArray addObject:tag.syncID];
        [self highlightSectionIndexForTitle:tag.title];
    }
    
    return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.updateBlocks = [NSMutableArray new];
    sectionDidChange = NO;
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    sectionDidChange = YES;
    __weak UICollectionView *weakCollectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            shouldReloadCollectionView = YES;
            [self.updateBlocks addObject:^{
                [weakCollectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
        }
            break;
        case NSFetchedResultsChangeDelete:
        {
            [self.updateBlocks addObject:^{
                [weakCollectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
        }
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            
            [self.updateBlocks addObject:^{
                [weakCollectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
        }
            break;
            
            
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            //shouldReloadCollectionView = YES;
            
            [self.updateBlocks addObject:^{
                [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            }];
        }
            break;
        case NSFetchedResultsChangeDelete:
        {
            [self.updateBlocks addObject:^{[collectionView deleteItemsAtIndexPaths:@[indexPath]];}];
        }
            break;
        case NSFetchedResultsChangeUpdate:
        {
            if(haultUpdate)
            {
                haultUpdate = NO;
                return;
            }

            [self.updateBlocks addObject:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
        }
            break;
        case NSFetchedResultsChangeMove:
        {
            [self.updateBlocks addObject:^{
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            }];
        }
            break;
            
    }
}



- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //    [self.collectionView reloadData];
    //    return;
    
    
   if(sectionDidChange) _indexView.indexTitles = [controller sectionIndexTitles];

    
    
    if(controller.sections.count == 0 || shouldReloadCollectionView || self.updateBlocks.count > 10)
    {
//        NSLog(@"Reloading CollectionView");
        [self.collectionView reloadData];
        self.updateBlocks = nil;
        if(_collectionViewFinishedUpdatingBlock)
        {
            _collectionViewFinishedUpdatingBlock();
            _collectionViewFinishedUpdatingBlock = nil;
            
        }
        
        shouldReloadCollectionView = NO;
        return;
    }
    
//    NSLog(@"TagController: performBatchedUpdate");
    [self.collectionView performBatchUpdates:^{
        
        for (void (^updateBlock)(void) in self.updateBlocks) {
            updateBlock();
        }
        
    } completion:^(BOOL finished) {
        
        if(_collectionViewFinishedUpdatingBlock)
        {
            _collectionViewFinishedUpdatingBlock();
            _collectionViewFinishedUpdatingBlock = nil;
            
        }
    }];
}



-(void)pauseFRC:(BOOL)pause
{
    if(pause)
    {
        self.fetchedResultsController.delegate = nil;
    }
    else
    {
        self.fetchedResultsController.delegate = self;
        [self.fetchedResultsController performFetch:NULL];
        [self.collectionView reloadData];
    }
}

#pragma mark - Motion
- (void)addParallexEffect
{
    [self.collectionView addMotionEffectsForX_Max:self.parallaxMenuMaximumRelativeValue X_Min:self.parallaxMenuMinimumRelativeValue Y_Max:self.parallaxMenuMaximumRelativeValue Y_Min:self.parallaxMenuMinimumRelativeValue];

}



- (void)editTag:(Tag *)tag atIndexPath:(NSIndexPath *)indexPath
{
    
    __weak Tag *tg = tag;
    __weak NSIndexPath * ip = indexPath;
    __weak typeof(self) weakSelf = self;

    [self.collectionView removeMotionEffects];

    
    MRInputTextFieldView * inputFieldView = [[MRInputTextFieldView alloc] initWithTitle:@"Edit Tag" fieldText:tg.title];
    inputFieldView.buttonTitles = @[@"Change", @"Delete"];
    inputFieldView.textField.keyboardAppearance = UIKeyboardAppearanceDark;
    [inputFieldView setDestructiveButtonIndex:1];
    [inputFieldView showForView:self.view
         dismissCompletionBlock:^(id a, int buttonIndex)
    {
        if(!a)
        {
            [weakSelf.collectionView deselectItemAtIndexPath:ip animated:YES];
            [weakSelf addParallexEffect];
            return;
        }
        else if(buttonIndex == 0)
        {
            if([a length] > 0 && ![a isEqualToString:tg.title])
            {
                tg.title = a;
                [weakSelf.collectionView deselectItemAtIndexPath:ip animated:YES];
                [[[DataManager sharedInstance] managedObjectContext] save:nil];
            }
        }
        else if(buttonIndex == 1)
        {
            if([tg.selected boolValue])
            {
                [weakSelf.selectedTagsArray removeObject:tg.syncID];
                [weakSelf postTagsNotification];
                
            }
            [weakSelf deHighlightSectionIndex:ip.section];
            [[[DataManager sharedInstance] managedObjectContext] deleteObject:tg];
            [[[DataManager sharedInstance] managedObjectContext] save:nil];

        }
        [weakSelf.collectionView deselectItemAtIndexPath:ip animated:YES];
        [weakSelf addParallexEffect];
    }];
    
    
    
    return;
    
    
    
    
    
}




@end
