//
//  RSCollectionViewController.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 20/06/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "RSCollectionViewController.h"
#import "MainCell.h"
#import "AppDelegate.h"
#import "TLMenuInteractor.h"
#import "DataManager.h"


#import "MRModalAlertView.h"
#import "IOAction.h"
#import "UIBarButtonItem+Badge.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PanGestureRecognizer.h"
#import "SectionHeader.h"
#import "MRTableView.h"


#import "UICollectionView+EmptyState.h"

#import "SettingsController.h"

#import "RNNavigationBar.h"
#import "SBRCallbackActionHandler.h"
#import "ReviseViewController.h"

NSString * const kFVC_SortingKey = @"sort";

NSString * const kFVC_SortingKey_Modified=  @"modified:";
NSString * const kFVC_SortingKey_Created =  @"created:";
NSString * const kFVC_TagsObjectIDs    =    @"fvc_tobjIDs";
NSString * const kFVC_SortingDisplayTitle = @"fvc_sort_title";

@interface RSCollectionViewController ()<UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate, UINavigationBarDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate >
{
    BOOL shouldReloadCollectionView;
    BOOL showArchive;
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    UIBarButtonItem * _deleteButtonItem;
    NSUInteger topLayoutGuideLength;
    CGFloat sideInsetCollectionView;

    SBRCallbackActionHandlerCompletionBlock  returnNoteBlock;
    
    
}
@property (nonatomic, copy) void (^collectionViewFinishedUpdatingBlock)(void);
@property (nonatomic) UISearchBar * searchBar;
@property (nonatomic)     NSDictionary * fvc_data;
@property (nonatomic) id<TagViewControllerPanTarget> menuInteractor;
@property (nonatomic) NSBlockOperation *blockOperation;
@property (nonatomic) NSPredicate * tagsPredicate;
@property (nonatomic) NSMutableArray * updateBlocks;
@property (nonatomic) NSString * sortingKey;
@property (nonatomic) NSString * sortingtitle;
@property (nonatomic,assign) BOOL sortingAscending;
@property (nonatomic) NSArray * selectedTags;
@property (nonatomic, assign) NSInteger tagsQueryOption;
@property (weak, nonatomic) Note * returnedNote;
@end

@implementation RSCollectionViewController
@synthesize searchBar = _searchBar;

@synthesize fetchedResultsController = _fetchedResultsController, blockOperation, tagsPredicate = _tagsPredicate;

- (void)viewDidLoad
{
    showArchive = NO;
    [super viewDidLoad];
    sideInsetCollectionView = (isIPad) ? 40.f : 0.f;
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Archive" action:@selector(sendToArchive:)];
    UIMenuItem *menuItem2 = [[UIMenuItem alloc] initWithTitle:@"Add to Note" action:@selector(addToNote:)];
    UIMenuItem *menuItem3 = [[UIMenuItem alloc] initWithTitle:@"Unarchive" action:@selector(sendToUnarchive:)];
    [[UIMenuController sharedMenuController] setMenuItems:@[menuItem, menuItem2, menuItem3]];

    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * sKey = [defaults objectForKey:kSettings_fvc_sortingKey];
    self.sortingKey = (sKey) ? sKey : @"modifiedDate";
    self.sortingAscending = ([defaults boolForKey:kSettings_fvc_sortAscending]) ? [defaults boolForKey:kSettings_fvc_sortAscending] : NO;
    self.isGrid = [defaults objectForKey:kSettings_MainListStyle_Grid];
    
    

    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    

    [NSFetchedResultsController deleteCacheWithName:@"rootcache"];

    self.collectionView.backgroundColor = kColor_MainViewBG;
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 200, 70)];
    label.text = @"Note, something..";
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:26];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    //label.backgroundColor = kColor_MainViewBG;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.collectionView.emptyState_view = label;
    self.collectionView.emptyState_showAnimationDuration = 0.3;
    

    
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[MainCell class] forCellWithReuseIdentifier:@"MainCell"];
    [self.collectionView registerClass:[SectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headercell"];
    

    [NSFetchedResultsController deleteCacheWithName:@"rootcache"];
    
    self.selectedTags = [defaults objectForKey:kSettings_fvc_selectedTagsIDs];
    self.tagsQueryOption = [[defaults objectForKey:kSettings_fvc_selectedTagsOption] integerValue];
 
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagsDidChange:) name:@"SelectedTagsDidChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingDropboxChangesNotification:) name:kDatastoreSyncManagerIncomingChangeCountNotification object:nil];
    
    
    
    
    self.collectionView.clipsToBounds = YES;
    
    
    
    
    [self setupButtons];
    [self setupToolBarItems];
    
    
    
    self.menuInteractor = [[TLMenuInteractor alloc] initWithParentViewController:(UIViewController *)[APP_DELEGATE containerViewController]];
    PanGestureRecognizer *gestureRecognizer = [[PanGestureRecognizer alloc] initWithTarget:self.menuInteractor action:@selector(userDidPan:)];
    gestureRecognizer.maximumNumberOfTouches = 1;
    gestureRecognizer.delegate = (id)self.menuInteractor;

    [self.view addGestureRecognizer:gestureRecognizer];


    
    

}
- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    _searchBar.placeholder = title;
}
- (NSDictionary *)fvc_data
{
    if(!_fvc_data)
    {
        self.fvc_data = @{kSettings_fvc_sortingKey: @{@"creationDate" : @"created",
                                                      @"modifiedDate" : @"modified",
                                                      @"lastAccessedDate" : @"viewed"}};
        
    }
    return _fvc_data;
}





- (BOOL)gestureRecognizerShouldBegin:(PanGestureRecognizer *)recognizer
{

    
    
    
    if([recognizer isKindOfClass:[PanGestureRecognizer class]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}





- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    
    if([gestureRecognizer isKindOfClass:[PanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[PanGestureRecognizer class]])
    return YES;
    
    return NO;
}
/*

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
   
    
    return NO;
  }



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
   
    return NO;
    return YES;
}
*/
#pragma mark UISearchBar delegate Functions

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
    

    self.tagsPredicate = nil;
    [self setupButtons];
    [self fvc_resetAndRefetch];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    [self setTitle:@"Search.."];
 
    

    
    [self.navigationBar.topItem setLeftBarButtonItem:nil animated:NO];
    [self.navigationBar.topItem setRightBarButtonItem:nil animated:NO];
    [self.navigationBar setNeedsLayout];
    [searchBar setShowsCancelButton:YES animated:YES];


}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    if(!searchBar.text || [searchBar.text length] == 0) return;
    
    self.tagsPredicate = [NSPredicate predicateWithFormat:@"text CONTAINS [cd] %@", searchBar.text];
    shouldReloadCollectionView = YES;
    [self fvc_resetAndRefetch];
}
-(void)incomingDropboxChangesNotification:(NSNotification *)notification
{
    if([notification.object integerValue] > 10 && [notification.userInfo[@"storeTitle"] isEqualToString:@"Note"])
    {
        shouldReloadCollectionView = YES;
    }
}

-(void)tagsDidChange:(NSNotification *)notification
{
    if(!notification.object) return;
    
    if([notification.object isKindOfClass:[NSString class]])
    {//called: [Tags prepareForDeletion]:
        NSMutableArray * t = [_selectedTags mutableCopy];
        [t removeObject:notification.object];
        self.selectedTags = [t copy];
    }
    else if([notification.object isKindOfClass:[NSArray class]])
    {
        self.selectedTags = notification.object;
    }
    else
    {
        self.tagsQueryOption = [notification.object integerValue];
    }
    
    [self fvc_resetAndRefetch];
}
- (NSPredicate *)tagsPredicate
{
    if(_tagsPredicate) return _tagsPredicate;

    BOOL NoTagsOrNotNeeded = ((!_selectedTags || _selectedTags.count == 0) && _tagsQueryOption != 2);
    
    NSString * insert = ( _tagsQueryOption == 2) ? @"–" : [NSString stringWithFormat:@"%lu", (unsigned long)_selectedTags.count];
    self.navigationBar.topItem.leftBarButtonItem.badgeValue = insert;

    
    if(NoTagsOrNotNeeded)
    {
        self.title = (showArchive) ? @"Archived Notes" : @"Notes";
        _tagsPredicate = nil;
        return nil;
    }
    
    static NSString * allquery = @"SUBQUERY(tags, $tag, $tag.syncID IN %@).@count = %d";
    static NSString * anyQuery = @"ANY tags.syncID IN %@";
    static NSString * untaggedQuery = @"tags.@count == 0";
    
    switch (_tagsQueryOption) {
        case 0:
            self.title = @"Notes with tags";
            self.tagsPredicate = [NSPredicate predicateWithFormat:allquery, _selectedTags, _selectedTags.count];
            break;
        case 1:
            self.title = @"Notes with tags";
            self.tagsPredicate = [NSPredicate predicateWithFormat:anyQuery, _selectedTags];
            break;
        default:
            self.title = @"untagged notes";
            self.tagsPredicate = [NSPredicate predicateWithFormat:untaggedQuery];
            break;
    }

    return _tagsPredicate;
}
- (void)setTagsQueryOption:(NSInteger)tagsQueryOption
{
    _tagsQueryOption = tagsQueryOption;
    _tagsPredicate = nil;

}
- (void)setSelectedTags:(NSArray *)selectedTags
{
    _selectedTags = selectedTags;
    _tagsPredicate = nil;
}
- (void)fvc_resetAndRefetch
{
    [NSFetchedResultsController deleteCacheWithName:@"rootcache"];
    self.fetchedResultsController = nil;
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];

}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self addKeyboardObservers];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeKeyboardObservers];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    returnNoteBlock = nil;
    _returnedNote = nil;
}




- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

    CGPoint p;
    CGFloat tbarHt;
    
    if(newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact)
    {
        p = CGPointMake(0, -20);
        [self adjustScrollerInsetsWithOrigin:44.f];
        tbarHt = 32;
    }
    else
    {
        [self adjustScrollerInsetsWithOrigin:64.f];
        p = CGPointZero;
        tbarHt = 44;
    }
    
    CGRect  f = _navigationBar.frame;
    f.origin = p;
    _navigationBar.frame = f;
    
 
    

    
}

- (BOOL)prefersStatusBarHidden
{
    return self.isEditing || (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact);
}
- (void)adjustScrollerInsetsWithOrigin:(CGFloat)topY
{
    BOOL editing = self.isEditing;
    [[[self collectionView] collectionViewLayout] invalidateLayout];
    
   // if(editing)
    {
    }
    //else
    {
     //   CGPoint offset = self.collectionView.contentOffset;
     //   offset.y = offset.y - topY;
     //   [self.collectionView setContentOffset:offset animated:NO];
    }
    


    UIEdgeInsets insets = self.collectionView.contentInset;
    insets.top = (editing) ? 0.0 : topY;
    insets.bottom = _toolBar.bounds.size.height;
  
    
     self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake((editing)?0.0:topY, 0, _toolBar.bounds.size.height, 0);
      self.collectionView.contentInset = insets;
//    self.collectionView.contentInset =self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake((editing)?0.0:topY, sideInsetCollectionView, _toolBar.bounds.size.height, sideInsetCollectionView);
    
    if(editing)
    {
    CGPoint offset = self.collectionView.contentOffset;
    offset.y = offset.y - topY;
    [self.collectionView setContentOffset:offset animated:NO];
    }


}
-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
 
    
    
    
    
    if(editing)
    {
        UIBarButtonItem * flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _deleteButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(bulkDelete:)];
        UIBarButtonItem * mergeItem = [[UIBarButtonItem alloc] initWithTitle:@"Merge" style:UIBarButtonItemStylePlain target:self action:@selector(mergeNotes:)];
        
        
        
        UIBarButtonItem * archive;
        if(showArchive)
        {
            archive = [[UIBarButtonItem alloc] initWithTitle:@"←Unarchive" style:UIBarButtonItemStylePlain target:self action:@selector(bulkUnarchive:)];
        }
        else
        {
            archive = [[UIBarButtonItem alloc] initWithTitle:@"Archive→" style:UIBarButtonItemStylePlain target:self action:@selector(bulkArchive:)];
        }

        
        [_toolBar setItems:@[archive, flex, mergeItem, flex, _deleteButtonItem, flex, self.editButtonItem]];
        
        UIColor *editingColor = [UIColor colorWithRed:0.00 green:0.47 blue:1.00 alpha:1.00]; //blue
        _toolBar.barTintColor = editingColor;
        
    
        
    }else
    {
        _toolBar.barTintColor = nil;
        
        [self setupToolBarItems];
        
    }
    

    BOOL shortBar = (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact);
    CGFloat topY = (self.isEditing) ? 0.0 : (shortBar)?44.f:64.f;

    
    [UIView animateWithDuration:0.2 animations:^{
        
        
        [self adjustScrollerInsetsWithOrigin:topY];

        self.navigationBar.hidden = editing;
        
        [self setNeedsStatusBarAppearanceUpdate];
        NSArray * a = [self.collectionView indexPathsForVisibleItems];
        self.collectionView.allowsMultipleSelection = editing;
        [self.collectionView reloadItemsAtIndexPaths:a];

    }];
    

}


- (void)mergeNotes:(UIBarButtonItem *)barItem
{
    __block NSArray * merges = [self.collectionView indexPathsForSelectedItems];
    if(merges.count < 2) return;
    
    NSString * msg = [NSString stringWithFormat:@"Are you sure about merging %lu notes into a single note?", (unsigned long)merges.count];
    MRModalAlertView * alert = [[MRModalAlertView alloc] initWithTitle:@"Merge Notes" mesage:msg];
    __weak RSCollectionViewController * weakSelf = self;
    [alert showForView:self.view
         selectorBlock:^(BOOL result){
             
             if(result)
             {
                 NSManagedObjectContext * moc = [[DataManager sharedInstance] managedObjectContext];
                 NSMutableArray * selectedNotes = [NSMutableArray new];
                 __block __weak Note * weakTopNote;
                 [merges enumerateObjectsUsingBlock:^(NSIndexPath  *ip, NSUInteger idx, BOOL *stop) {
                     
                     Note * dNote = [weakSelf.fetchedResultsController objectAtIndexPath:ip];
                     
                     [selectedNotes addObject:dNote.text];

                    
                     if(idx == 0)
                     {
                         weakTopNote = dNote;
                     }
                     else
                     {
                         [weakTopNote addLinks:dNote.links];
                         [weakTopNote addTags:dNote.tags];
                         [moc deleteObject:dNote];
                        
                     }
                     
                 }];
                 
                 weakTopNote.text = [selectedNotes componentsJoinedByString:@"\n\n"];
                 weakTopNote.modifiedDate = [NSDate date];
                 [moc save:nil];
                 

                 _collectionViewFinishedUpdatingBlock = ^{
                     NSIndexPath * ipp = [weakSelf.fetchedResultsController indexPathForObject:weakTopNote];
                     [weakSelf.collectionView selectItemAtIndexPath:ipp animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
                 };
             }
         }];

}
-(void)bulkDelete:(id)sender
{
    
    __block NSArray * deletions = [self.collectionView indexPathsForSelectedItems];
    if(deletions.count == 0) return;
    NSString * msg = [NSString stringWithFormat:@"Are you sure about permanently deleting %lu notes?", (unsigned long)deletions.count];
    MRModalAlertView * alert = [[MRModalAlertView alloc] initWithTitle:@"Delete Notes" mesage:msg];
    [alert showForView:self.view
         selectorBlock:^(BOOL result){
             if(result)
             {
                 for(NSIndexPath *ip in deletions)
                 {
                     Note * vig = [_fetchedResultsController objectAtIndexPath:ip];
                     [[[DataManager sharedInstance] managedObjectContext] deleteObject:vig];
                 }
                 [[[DataManager sharedInstance] managedObjectContext] processPendingChanges];
                 [[[DataManager sharedInstance] managedObjectContext] save:nil];
             }
    }];
    
}
- (void)bulkArchive:(id)sender
{
    __block NSArray * selections = [self.collectionView indexPathsForSelectedItems];
    if(selections.count == 0) return;
    
        for(NSIndexPath *ip in selections)
        {
            Note * n = [_fetchedResultsController objectAtIndexPath:ip];
            n.archived = @(YES);
        }
    
    __weak RSCollectionViewController * weakSelf = self;
    
    _collectionViewFinishedUpdatingBlock = ^{
        
        [[weakSelf collectionView] reloadData];
        [[[DataManager sharedInstance] managedObjectContext] processPendingChanges];
        [[[DataManager sharedInstance] managedObjectContext] save:nil];

    };

}
- (void)bulkUnarchive:(id)sender
{
    __block NSArray * selections = [self.collectionView indexPathsForSelectedItems];
    
    if(selections.count == 0) return;
    
        for(NSIndexPath *ip in selections)
        {
            Note * n = [_fetchedResultsController objectAtIndexPath:ip];
            n.archived = @(NO);
        }
    
    
    __weak RSCollectionViewController * weakSelf = self;
    
    _collectionViewFinishedUpdatingBlock = ^{
        
        [[weakSelf collectionView] reloadData];
        [[[DataManager sharedInstance] managedObjectContext] processPendingChanges];
        [[[DataManager sharedInstance] managedObjectContext] save:nil];

    };

}


#pragma mark  -  UICOLLECTIONVIEW DELEGATE/SOURCE
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}



- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat min = [(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacing];
    
   // CGFloat interItemSpacing =((isIPad) ? 1.3 : 0.3) * [[UIScreen mainScreen] scale];

    CGFloat width = self.collectionView.bounds.size.width - (2*self.collectionView.contentInset.left  );
    


    if(_isGrid.boolValue)
    {
        return   CGSizeMake((width/2)  - min, 155.f);
    }
    else
    {
        return   CGSizeMake(width - 20.f, 100.f);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    
    MainCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MainCell" forIndexPath:indexPath];
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureCell:note sortKey:_sortingKey];
    return cell;
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath  {
    
    SectionHeader * r = (SectionHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headercell" forIndexPath:indexPath];
    id <NSFetchedResultsSectionInfo> theSection = [[_fetchedResultsController sections] objectAtIndex:indexPath.section];
    
    r.delegate = self;
    r.titleLabel.text = [[theSection name] uppercaseString];
    r.countLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[theSection numberOfObjects]];
    r.countLabel.tag = r.leftBtn.tag = r.rightBtn.tag = r.sortingBtn.tag = indexPath.section;
    [r.sortingBtn setTitle:_sortingtitle forState:UIControlStateNormal];
    r.leftBtn.hidden  = (indexPath.section == 0);
    r.rightBtn.hidden = (indexPath.section == [[_fetchedResultsController sections] count]-1);
    return r;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isEditing || [[UIMenuController sharedMenuController] isMenuVisible]) return;
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if(returnNoteBlock)
    {
        _returnedNote = note;
        return;
    }
    
    [APP_DELEGATE showEditorViewControllerWithObject:note from:self completionBlock:nil startEditing:NO];
}
#pragma mark - UICollectionViewDelegate methods
- (BOOL)collectionView:(UICollectionView *)collectionView
      canPerformAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
    
    if(action == @selector(delete:) || action == @selector(copy:) || action == @selector(paste:)) return YES;
    
    if(!showArchive &&  action == @selector(sendToArchive:)) return YES;

    if(showArchive &&  action == @selector(sendToUnarchive:)) return YES;
    
     return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MainCell * cell = (MainCell *)[collectionView cellForItemAtIndexPath:indexPath];
    Note * note = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.notePointer = note;
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
         performAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
    
    
    MainCell * cell = (MainCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if(action   ==   @selector(copy:))
    {
        Note * e = [_fetchedResultsController objectAtIndexPath:indexPath];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setValue:e.text forPasteboardType:(NSString *)kUTTypeText];
        [cell blink];
    }
    
    if(action   ==   @selector(paste:))
    {
        Note * e = [_fetchedResultsController objectAtIndexPath:indexPath];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if(pasteboard.string)
        {
            e.text = [e.text stringByAppendingFormat:@"\n\n%@", pasteboard.string];
            [[e managedObjectContext] save:nil];
            [cell blink];
        }
    }
    
    
    
    
}

- (void)showTagsViewController
{
    if(self.parentViewController.presentedViewController)
    {
        [self.parentViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    [_menuInteractor performSelector:@selector(presentMenu)];
}


- (void)newNote:(id)sender
{
    
    [APP_DELEGATE showEditorViewControllerWithObject:nil from:self completionBlock:nil startEditing:YES];
}


-(void)setupButtons
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if(!_navigationBar)
    {
        self.navigationBar = [[RNNavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64.f)];
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:nil];
        self.navigationBar.barTintColor = kColor_MainViewBG;
        self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.navigationBar.autoresizesSubviews = YES;
        self.navigationBar.translucent = YES;
        self.navigationBar.barStyle = UIBarStyleBlack;
        [self.navigationBar pushNavigationItem:navItem animated:NO];
        [self.view addSubview:self.navigationBar];
    }

    UIBarButtonItem * tagItem = self.navigationBar.topItem.leftBarButtonItem;
    if(!tagItem)
    {
        UIButton * tagBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [tagBtn setImage:[UIImage imageNamed:@"price_tag1"] forState:UIControlStateNormal];
        [tagBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [tagBtn setFrame:CGRectMake(0, 0, 30, 30)];
        [tagBtn addTarget:self action:@selector(showTagsViewController) forControlEvents:UIControlEventTouchUpInside];
        tagItem = [[UIBarButtonItem alloc] initWithCustomView:tagBtn];
        tagItem.shouldHideBadgeAtZero = YES;
        tagItem.badgeOriginX = 15.f;
        self.navigationBar.topItem.leftBarButtonItem = tagItem;
        
    }
    
    if(!self.navigationBar.topItem.rightBarButtonItem)
    {
        self.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newNote:)];
    }
    
    if(!_searchBar)
    {
        self.searchBar = [[UISearchBar alloc]  init];
        self.searchBar.delegate = self;
        self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        self.searchBar.placeholder = @"Notes";
        self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        CGFloat swidth = self.view.frame.size.width * 0.9;
        self.searchBar.frame = CGRectMake(0, 0, swidth, 30);
        [(UITextField *)[self.searchBar valueForKey:@"_searchField"] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
        [(UITextField *)[self.searchBar valueForKey:@"_searchField"] setKeyboardAppearance:UIKeyboardAppearanceDark];
        UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, 20, swidth, 30)];
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [v addSubview:_searchBar];
        self.navigationBar.topItem.titleView = v;
    }
    
    
    
    
    
    
    
}

- (UIBarButtonItem *)archiveNotesBtn
{
    UIButton * archiveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [archiveBtn setTitle:@"Archive" forState:UIControlStateNormal];
    archiveBtn.selected = showArchive;
    [archiveBtn addTarget:self action:@selector(toggleArchive:) forControlEvents:UIControlEventTouchUpInside];
    [archiveBtn setTintColor:[UIColor whiteColor]];
    [archiveBtn sizeToFit];
    return [[UIBarButtonItem alloc] initWithCustomView:archiveBtn];
}

-(void)setupToolBarItems
{
    
    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];

    UIBarButtonItem * flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * openDocument = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStylePlain target:self action:@selector(openDocument:)];

    if(!_toolBar)
    {
        CGFloat width = self.view.frame.size.width;
        
        self.navigationController.toolbarHidden = YES;
        self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44.f, width, 44.f)];
        [self.toolBar setBarStyle:UIBarStyleBlack];
        self.toolBar.tintColor = kColor_WhiteButtonTint;
//        self.toolBar.barTintColor = kColor_SVT;
        self.toolBar.translucent = YES;
        [self.view addSubview:self.toolBar];
    }
    
    UIBarButtonItem * revise = [[UIBarButtonItem alloc] initWithTitle:@"Revise" style:UIBarButtonItemStylePlain target:self action:@selector(showRevision:)];
    
    [self.toolBar setItems:@[[self archiveNotesBtn], flexSpace, openDocument, flexSpace, settings,flexSpace, revise, flexSpace,self.editButtonItem]];

}
- (void)showRevision:(id)sender
{
    [self presentViewController:[ReviseViewController presentWithNavigationController] animated:YES completion:nil];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    CGSize  size = self.view.bounds.size;
    CGFloat tbarHt = (size.height < size.width) ? 32.f : 44;
    CGRect f = _toolBar.frame;
    f.origin.y = size.height - tbarHt;
    f.size.width = size.width;
    f.size.height = tbarHt;
    _toolBar.frame = f;
}

- (void)setEmptyMsg:(NSString *)msg
{
    UILabel * b = (UILabel *)self.collectionView.emptyState_view;
    b.text = msg;
}

- (void)toggleArchive:(UIButton *)btn
{
    btn.selected = !btn.isSelected;
    
    if(btn.isSelected != showArchive)
    {
        showArchive = btn.isSelected;
        [self setEmptyMsg:(showArchive)?@"Archive is empty":@"Tap \"+\", Make some notes"];
        shouldReloadCollectionView = YES;
        [self fvc_resetAndRefetch];
    }
}



-(void)showSettings
{
    SettingsController *settingsVC = [[SettingsController alloc] init];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:settingsVC];

    if(isIPad)
    {
        navC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navC animated:YES completion:nil];
    }
    else
    {
        [self presentViewController:navC animated:YES completion:nil];
    }
}

- (void)sectionRightArrowAction:(UIButton *)sender
{
    NSInteger tag=  [sender tag];
    NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:tag+1];
    [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
//    [self.collectionView flashScrollIndicators];
   
}
- (void)sectionLeftArrowAction:(UIButton *)sender
{
    NSInteger tag=  [sender tag];
    NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:tag-1];
    [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (void)setSortingAscending:(BOOL)sortingAscending
{
    _sortingAscending = sortingAscending;
    [[NSUserDefaults standardUserDefaults] setBool:sortingAscending forKey:kSettings_fvc_sortAscending];
}
- (void)setSortingKey:(NSString *)sortingKey
{
    _sortingKey = sortingKey;
    self.sortingtitle = self.fvc_data[kSettings_fvc_sortingKey][sortingKey];
    [[NSUserDefaults standardUserDefaults] setObject:sortingKey forKey:kSettings_fvc_sortingKey];
}


- (void)sectionSortingAction:(UIButton *)sender
{
    MRTableView * mrt = [[MRTableView alloc] initTitle:@"Sort by dates:" titlesAndValue:_fvc_data[kSettings_fvc_sortingKey] selectedKey:_sortingKey];
    mrt.buttonTitles = @[@"▲", @"▼"];
    mrt.selectedButtonIndex = (self.sortingAscending) ? 0 : 1;
    __weak typeof(self) weakSelf = self;
    [mrt showForView:self.view dismissCompletionBlock:^(NSString * sortKey, int buttonIndex)
    {
        if(sortKey)
        {
            weakSelf.sortingKey = sortKey;
        }
        if(buttonIndex != -1)
        {
            weakSelf.sortingAscending = (buttonIndex == 0);
        }
        
        if(buttonIndex != -1 || sortKey)
        {
            [weakSelf fvc_resetAndRefetch];
        }
        
    }];
    
    
}










#pragma mark FetchedResultsController Delegate

-(NSFetchedResultsController *)fetchedResultsController
{
    if(_fetchedResultsController)
        return _fetchedResultsController;
    
    NSManagedObjectContext *context = [[DataManager sharedInstance] managedObjectContext];
    //NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    //[context setUndoManager:undoManager];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:25];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:_sortingKey ascending:_sortingAscending];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:[NSString stringWithFormat:@"monthYear_%@",_sortingKey] cacheName:@"rootcache"]; //monthYear
    
    aFetchedResultsController.delegate = self;

    NSPredicate * textPredicate = [NSPredicate predicateWithFormat:@"text != nil AND archived == %@", @(showArchive)];
    
    if(self.tagsPredicate)
    {
        NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[textPredicate, _tagsPredicate]];
        aFetchedResultsController.fetchRequest.predicate = compoundPredicate;
    }
    else
    {
        aFetchedResultsController.fetchRequest.predicate = textPredicate;
    }
    
    self.fetchedResultsController = aFetchedResultsController;
    
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    if(_fetchedResultsController.sections.count == 0)
    {
        NSString * notice;
        if(_tagsPredicate)
        {
            
            notice = (showArchive) ? @"Empty" : @"Nothing came up\n with those filters.\nMaybe in Archives?";
        }
        else
        {
            notice = (showArchive) ? @"No notes archived yet." : @"Tap \"+\"\nMake some notes..";
        }
        [self setEmptyMsg:notice];
    }
    
        [self adjustedCollectionViewInsets];

    return _fetchedResultsController;
    
}

- (UIEdgeInsets)adjustedCollectionViewInsets
{
    BOOL horizontal = self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact;
    BOOL editing = self.isEditing;
    CGFloat top = (editing) ? 0.f : (horizontal) ? 44.f : 64.f;
    CGFloat bottom = 44.f;
    
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(top, sideInsetCollectionView, bottom, sideInsetCollectionView);
    
    UIEdgeInsets cVInsets = self.collectionView.contentInset;
    cVInsets.top = top;
    cVInsets.bottom = bottom;
//    self.collectionView.contentInset = cVInsets;
//    self.collectionView.scrollIndicatorInsets = insets;
    self.collectionView.contentInset = self.collectionView.scrollIndicatorInsets = insets;
    
    return insets;
    
}



- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.updateBlocks = [NSMutableArray new];
//    shouldReloadCollectionView = NO;
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
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
   if(controller.sections.count == 0 || shouldReloadCollectionView || self.updateBlocks.count > 10)
    {
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
    
//    NSLog(@"RSCollectionView: performBatchedUpdate");
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




#pragma mark - SETTINGS
- (void)addSettingsObservers:(BOOL)add
{
    if(add)
    {
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:kSettings_MainListStyle_Grid options:NSKeyValueObservingOptionNew context:nil];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:kSettings_MainListStyle_Grid];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:kSettings_MainListStyle_Grid])
    {
        
        self.isGrid = change[NSKeyValueChangeNewKey];
    }
}
#pragma mark - Keyboard Notifications
-(void)addKeyboardObservers
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
}
-(void)removeKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
}
-(void)keyboardWillChangeFrame:(NSNotification*)aNotification{
    
    
    NSDictionary* info = [aNotification userInfo];
    CGRect currentKbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    BOOL keyboardVisible = CGRectIntersectsRect(currentKbRect, screenRect);
    if(!keyboardVisible) return; //it was already visible, so let didChangeFrame handle it...
    
    
    CGFloat keyboardHeight;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            keyboardHeight = currentKbRect.size.height;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            keyboardHeight = currentKbRect.size.width;
            break;
    }
    
    
    /*
     performed when:
     1. Keyboard _IS_  Visible:
     This assumes that willChangeFrame is happening in rotation while keyboard is present.
     */
    
    UIEdgeInsets insets = [self.collectionView contentInset];
    insets.bottom = self.bottomLayoutGuide.length;
    [self.collectionView setContentInset:insets];
    [self.collectionView setScrollIndicatorInsets:insets];
    
}

-(void)keyboardDidShow:(NSNotification*)aNotification{
}

-(void)keyboardWillShow:(NSNotification*)aNotification{
    
   // keyboardDocked = YES;
    //    DLog(@"keyboardWillShow");
    
}
-(void)keyboardDidChangeFrame:(NSNotification*)aNotification{
    
    
    NSDictionary* info = [aNotification userInfo];
    CGRect currentKbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    BOOL keyboardVisible = CGRectIntersectsRect(currentKbRect, screenRect);
    
    if(keyboardVisible)
    {
        UIWindow *w = [self.view window];
        currentKbRect = [w convertRect:currentKbRect fromWindow:nil];
        currentKbRect = [self.view  convertRect:currentKbRect fromView:nil];
        
        UIEdgeInsets insets = [self.collectionView contentInset];
        insets.bottom = self.view.frame.size.height  -  currentKbRect.origin.y;
        [self.collectionView setContentInset:insets];
        [self.collectionView setScrollIndicatorInsets:insets];

    }
    
}

#pragma mark - Document Handling
- (void)openDocument:(UIBarButtonItem *)sender
{
    
    UIDocumentMenuViewController * menu = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeText] inMode:UIDocumentPickerModeImport];
    menu.delegate = self;
    menu.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:menu animated:YES completion:nil];
    
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    documentPicker.delegate = self;
    [documentMenu dismissViewControllerAnimated:YES completion:nil];
    documentMenu.popoverPresentationController.barButtonItem = documentMenu.popoverPresentationController.barButtonItem;
    [self presentViewController:documentPicker animated:YES completion:nil];
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    
    __weak typeof(self) weakSelf = self;
    
    [IOAction importOperationWithFileURL:url completion:^(id exportedObject, BOOL success) {
        if(success)
        {
            Note * note = [exportedObject firstObject];
            Note * mainThreadNote = (Note *) [[[DataManager sharedInstance] managedObjectContext] objectWithID:note.objectID];

            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Imported Successfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            if(mainThreadNote)
            {
                [APP_DELEGATE showEditorViewControllerWithObject:mainThreadNote from:weakSelf completionBlock:nil startEditing:YES];
            }
            
        }
        else
        {
            [MRModalAlertView showMessage:@"Something went wrong, could not import file."
                                    title:kApp_Display_title
                                 overView:weakSelf.view];
        }
        
    }];
    [controller dismissViewControllerAnimated:NO completion:nil];

    
}



- (void)activeSelectionModeForGetAction:(BOOL)active params:(NSDictionary *)parameters callback:(SBRCallbackActionHandlerCompletionBlock)completionBlock
{
    if(!completionBlock) return;
    
    returnNoteBlock = completionBlock;
    
    if(self.isEditing) self.editing = NO;
    
    NSString * success = (parameters[@"var"]) ? parameters[@"var"] : parameters[@"x-success"];
    
    success = @"SELECT A NOTE TO SEND";
    
    UIBarButtonItem * cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSendNoteToURL:)];
    UIBarButtonItem * sendbtn   = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendNoteToURL:)];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:11];
    label.text = [success uppercaseString];
    label.textColor = [UIColor lightTextColor];
    label.text = success;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentCenter;
    
    UIBarButtonItem * btnLabel = [[UIBarButtonItem alloc] initWithCustomView:label];
    

    UIBarButtonItem * flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.toolBar setBarTintColor:kColor_Red_labGear];
    [self.toolBar setItems:@[[self archiveNotesBtn], cancel, flex,btnLabel,flex, sendbtn] animated:YES];
    [label sizeToFit];
    [MRModalAlertView showMessage:@"Select a note you want to send, you can search and/or filter to find it." title:@"Note Request" overView:self.view];
}

- (void)cancelSendNoteToURL:(id)sender
{
    self.editing = NO;
    if(returnNoteBlock)
    {
        returnNoteBlock(nil, nil, YES);
        returnNoteBlock = nil;
    }
    _returnedNote = nil;
}
-(void)sendNoteToURL:(id)sender
{
    if(!_returnedNote)
    {
        [MRModalAlertView showMessage:@"Please select a note or tap \"Cancel\"." title:@"Note Request" overView:self.view];
        return;
    }
    self.editing = NO;
    if(returnNoteBlock)
    {
        returnNoteBlock(@{@"text": _returnedNote.text}, nil, NO);
        returnNoteBlock = nil;
    }
    _returnedNote = nil;
    
}


@end
