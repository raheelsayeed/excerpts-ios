//
//  ExcerptViewController.m
//   Renote
//
//  Created by M Raheel Sayeed on 23/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "AppDelegate.h"
#import "ExcerptViewController.h"
#import "KeyboardAccessoryBar.h"
#import "DataManager.h"
#import "UIView+MotionEffect.h"
#import "NSManagedObject+Excerpts.h"
#import "NSAttributedString+Excerpts.h"
#import <libkern/OSAtomic.h>
#import "VGTokenFieldView.h"
#import "NSString+RSParser.h"
#import "FetchCell.h"
#import "FetchCell_Editor.h"
#import "UIImageView+AFNetworking.h"
#import "MRModalAlertView.h"
#import "NSString+QSKit.h"
#import "SVWebViewController.h"
#import "ActionsListViewController.h"
#import "RSPullToAction.h"

#import "EXTImageViewController/EXTImageViewController.h"
#import "UIImage+AspectFit.h"
#import "TGRImageZoomAnimationController.h"
#import "TGRImageViewController.h"
#import "NSURL+QSKit.h"
#import "LinkSearchCell.h"
#import "ContainerViewController.h"
#import "ExcerptCollectionHeaderView.h"

#import "NSString+ServicesSearchRegex.h"


#import "RequestObject.h"
#import "EXOperationQueue.h"
#import "JDStatusbarNotification.h"

#import "JTSReachabilityResponder.h"
#import "Workflows.h"
#define kEditingIndexPath     [NSIndexPath indexPathForItem:0 inSection:0]


static NSString * fetchCell = @"fetchCell";
static NSString * fetchImageCell = @"imgCell";
static NSString * editorIdentifier = @"editor";
static char EVC_KVO_ContextOps = 1;




@interface ExcerptViewController () <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, TITokenFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, WorkflowsDelegate>
{
    NSString * noteHolder;
    CALayer * _drawerImageLayer;
    UIImageView * _drawerIndicator;
}

@property (nonatomic, assign) BOOL fetchNoteLinks;
@property (nonatomic, strong) VGTokenFieldView *tagTokenField;
@property (nonatomic, weak)   TapTextView *weakTextView;
@property (weak, nonatomic)   UIImageView * weakCellImageView;
@property (nonatomic, strong) NSCache * cacheSizeOfFetchObjects;
@property (nonatomic, assign) BOOL snippetExpanded;
@property (nonatomic, strong) KeyboardAccessoryBar * keyToolbar;
@property (nonatomic, strong) DBFile * dropboxFile;
@property (nonatomic) UIButton * floatingActionBtn;
@property (nonatomic) NSArray * requestObjects;
@property (nonatomic) NSMutableDictionary * mappingFetchedResults;

@end

@implementation ExcerptViewController

-(instancetype)initWithNote:(Note *)note
{
    
    self = [super initWithFetchSectionIndex:1];
    if(self)
    {
        self.title = @"Note";
        self.note = note;
        self.editingIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    return self;
}
- (void)setNote:(id)note
{
    
    [self performSelectorOnMainThread:@selector(resetLinks) withObject:nil waitUntilDone:YES];

    _note = nil;
    
    [self removeLinkAttribution];
    
    if(nil == note || [note isKindOfClass:[NSString class]])
    {
        noteHolder = (NSString *)note;
        _note = nil;
        _weakTextView.text = nil;
        _weakTextView.text = noteHolder;
        _shouldTurnOnEditMode = YES;
    }
    else
    {
        _shouldTurnOnEditMode = NO;
        _note = note;
        _note.lastAccessedDate = [NSDate date];
        noteHolder = _note.text;
        _weakTextView.text = nil;
        _weakTextView.text = noteHolder;
        [self addLinkAttribution];
    }
    
    [_cacheSizeOfFetchObjects removeObjectForKey:editorIdentifier];
    [_tagTokenField setNote:_note];
    [self fetchLinks:nil];
}
-(void)resetLinks
{

    for(RequestObject * ro in self.requestObjects)
    {
        if([ro observationInfo]) [ro removeObserver:self forKeyPath:NSStringFromSelector(@selector(fetchStatus))];
    }
    self.requestObjects = nil;
    [self abortFetchOperations];
    [self.cacheSizeOfFetchObjects removeAllObjects];
    
    if(self.collectionView.numberOfSections > 1)
    {
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, self.collectionView.numberOfSections-1)]];
    }
    
     
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return (self.isEditing == NO);
}

- (void)setRequestObjects:(NSArray *)requestObjects
{
    _requestObjects = requestObjects;
    [_mappingFetchedResults removeAllObjects];
}


- (NSMutableDictionary *)mappingFetchedResults
{
    if(!_mappingFetchedResults)
    {
        self.mappingFetchedResults = [NSMutableDictionary new];
    }
    return _mappingFetchedResults;
}




-(void)fetchLinks:(id)sender
{
    
    if(!_note) return;
    
    [self.fetchOperationQueue setSuspended:YES];
    

    
       // dispatch_async(dispatch_get_main_queue(), ^
         //              {
                           
        NSMutableArray * rs = [NSMutableArray new];
        
        for(Link *link in _note.links)
        {
            RequestObject * ro = [[RequestObject alloc] initWithIdentifier:link.identifier title:link.title serviceKey:link.serviceKey];
            ro.linkedObject = link;
            ro.cacheEnabled = self.cacheFetchedData;
            [rs addObject:ro];
        }
    if(_fetchNoteLinks)
    {
        NSArray * webLinks2 = [_note.text qs_links];
        [webLinks2 enumerateObjectsUsingBlock:^(NSString * linkStr, NSUInteger idx, BOOL *stop) {
            
            static NSString * khttp = @"http";
            
            if(![[linkStr substringToIndex:4] isEqualToString:khttp]) return;
            
            RequestObject * ro = [[RequestObject alloc] initWithURLString:linkStr forDefinedServicesOnly:YES];
            
            if(ro){
                ro.linkedObject = _note;
                ro.cacheEnabled = self.cacheFetchedData;
                [rs addObject:ro];
            }
        }];
    }
    NSDictionary * dict = [self.note.text searchQueryDictionary];

        for(NSString * key in [dict allKeys])
        {
            RequestObject * req = [[RequestObject alloc] initWithIdentifier:key title:nil serviceKey:dict[key]];
            [req setRequestType:REQUEST_OBJECT_TYPE_SEARCH];
            req.cacheEnabled = self.cacheFetchedData;
            [rs addObject:req];
        }
    
    self.requestObjects = [NSArray arrayWithArray:rs];
    
    rs = nil;
    
    [self.requestObjects enumerateObjectsUsingBlock:^(RequestObject *requestObj, NSUInteger idx, BOOL *stop)
    {
        if(requestObj.serviceType == API_SERVICE_TYPE_WEBIMAGE)
        {
            [self.mappingFetchedResults setObject:[NSValue valueWithNonretainedObject:requestObj] forKey:@(idx+1)];
        }
    }];
    
    [self.collectionView reloadData];
       // });
    
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        
        if(weakSelf.requestObjects.count == 0) return;
        
        [weakSelf.requestObjects enumerateObjectsUsingBlock:^(RequestObject *req, NSUInteger idx, BOOL *stop) {
            
         
            
            if(req.identifier || req.primaryURL)
            {
                static NSString * resultsKey = @"fetchStatus";
                [req addObserver:weakSelf forKeyPath:resultsKey options:NSKeyValueObservingOptionNew context:&FetchObjectKVOContext];
            }
            if(!req.cacheEnabled || (req.cacheEnabled && ![req assignCachedDataFromLinkedObject]))
            {
                AFJSONRequestOperation * requestOperation = [req initiateOperation];
                if(requestOperation)
                {
                    [requestOperation setSuccessCallbackQueue:weakSelf.backgroundQueue];
                    [requestOperation setFailureCallbackQueue:weakSelf.backgroundQueue];
                    [weakSelf.fetchOperationQueue addOperation:requestOperation];
                }
            }
        }];
   
        
        [weakSelf.fetchOperationQueue setSuspended:NO];
    });
}

- (void)setCacheFetchedData:(BOOL)shouldCache
{
    [super setCacheFetchedData:shouldCache];
}

- (void)invalidateCollectionViewLayout
{
    [_cacheSizeOfFetchObjects removeAllObjects];
    [self.collectionView.collectionViewLayout invalidateLayout];

}

- (void)addLinkAttribution
{
    if (!_weakTextView || [_weakTextView.text length] < 1)
        return;

    
    
    NSMutableAttributedString * mstr = [_weakTextView.attributedText mutableCopy];
    
    
    
    
    dispatch_once(&pred, ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Liberal-URL-Regex-Pattern" ofType:@""];
        NSError *error = nil;
        NSString *pattern = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    });
    
    NSAssert(regex != nil, @"The regular expression for qs_links was not loaded.");
    
    @autoreleasepool {
        
        NSArray *matches = [regex matchesInString:_weakTextView.text options:0 range:NSMakeRange(0, [_weakTextView.text length])];
        
        NSInteger index = 0;
        
        UIColor *tint = self.view.tintColor;
        
        for (NSTextCheckingResult *oneResult in matches) {
            
            NSRange oneRange = [oneResult rangeAtIndex:1];
            NSString *oneLink = [_weakTextView.text substringWithRange:oneRange];
            NSData *stringToClean = [oneLink dataUsingEncoding: NSASCIIStringEncoding allowLossyConversion: YES];
            
            NSString *stringCleaned = [[NSString alloc] initWithData: stringToClean encoding: NSASCIIStringEncoding];

            NSURL * url = [NSURL URLWithString:stringCleaned];//
            NSAttributedString * linkedMark = [[NSAttributedString alloc] initWithString:@" ∞ "
                                                                              attributes:@{NSLinkAttributeName:url}];
            
            NSInteger atIndex = oneRange.location + oneRange.length + (index * 3);
            
            NSRange arrowRange = NSMakeRange(atIndex+1, 1);
            
            [mstr insertAttributedString:linkedMark atIndex:atIndex];
            [mstr addAttribute:NSUnderlineColorAttributeName value:tint range:arrowRange];
            [mstr addAttribute:NSUnderlineStyleAttributeName value:@1 range:arrowRange];
            [mstr addAttribute:NSForegroundColorAttributeName value:tint range:arrowRange];
            [mstr addAttribute:NSLinkAttributeName value:url range:NSMakeRange(atIndex-1, 1)];
            [mstr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.35 alpha:1.0] range:NSMakeRange(oneRange.location+(index*3), oneRange.length)];
            index++;
        }
        _weakTextView.attributedText = mstr.copy;
    }

}
- (void)removeLinkAttribution
{
    
    if (!_weakTextView || [_weakTextView.text length] < 1) return;
    NSMutableAttributedString * m = _weakTextView.attributedText.mutableCopy;
    NSRange range = NSMakeRange(0, _weakTextView.text.length);
    [m removeAttribute:NSLinkAttributeName range:range];
    [m removeAttribute:NSUnderlineColorAttributeName range:range];
    [m removeAttribute:NSUnderlineStyleAttributeName range:range];
    [m removeAttribute:NSForegroundColorAttributeName range:range];
    _weakTextView.attributedText = m.copy;
    _weakTextView.text = [_weakTextView.text stringByReplacingOccurrencesOfString:@" ∞ " withString:@""];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kColor_Excerpt_Background_Gray;
//    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Add to Note" action:@selector(addToNote:)];
//   [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObject:menuItem]];

    
    self.view.tag = 1;

    [self.collectionView registerClass:[ExcerptCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"eheadercell"];
    
    
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drawer"]];
//    image.frame = CGRectMake(3, CGRectGetMidY(self.view.bounds), 4.5, 20);
//    image.center = self.view.center;
    
    // make new layer to contain shadow and masked image
    _drawerImageLayer = [CALayer layer];
    _drawerImageLayer.borderColor = [self.view tintColor].CGColor;
    _drawerImageLayer.borderWidth = 0.0f;

    _drawerImageLayer.frame = CGRectMake(3, CGRectGetMidY(self.view.bounds), 4.5, 20);
    
    image.layer.masksToBounds = YES;
    
    
    [_drawerImageLayer addSublayer:image.layer];
    
    [self.view.layer addSublayer:_drawerImageLayer];
    
    
    
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    self.collectionView.alwaysBounceVertical = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.cacheFetchedData = [[defaults objectForKey:kSettings_CacheLinks] boolValue];
    self.fetchNoteLinks   = [[defaults objectForKey:kSettings_FetchNoteLinks] boolValue];
    
    
    
    [self invalidateCollectionViewLayout];
    
    __weak ExcerptViewController * weakSelf = self;
    RSPullToAction *u = [self.collectionView addPullToActionPosition:RSPullActionPositionTop actionHandler:^(RSPullToAction * v)
                 {
                     [weakSelf doActions:v];
                 }];
    u.text = @"Share";//⚪︎⚪︎ ⚪︎
    u.backgroundColor = [UIColor clearColor];
    u.showPullActionIndicator = NO;
    
    self.textExpander = [[SMTEDelegateController alloc] init];
    self.textExpander.nextDelegate = self;
    self.textExpander.clientAppName = @"RENOTE";
    self.textExpander.appGroupIdentifier = @"group.com.smartddx.textexpander";
    
    
    self.cacheSizeOfFetchObjects = [[NSCache alloc] init];
    NSString  * theme =[[NSUserDefaults standardUserDefaults] objectForKey:kSettings_ThemeName];
    [self setTheme:theme];
    
    
    CGFloat edge = 40;
    CGRect btnFrame = CGRectMake(10, self.view.frame.size.height-(edge+10), edge, edge);
    self.floatingActionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.floatingActionBtn setFrame:btnFrame];
    [self.floatingActionBtn setTitle:@"⚪︎⚪︎⚪︎" forState:UIControlStateNormal];
    [self.floatingActionBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.floatingActionBtn setBackgroundColor: [UIColor colorWithWhite:0.93 alpha:0.5]];
    [self.floatingActionBtn.layer setCornerRadius:edge/2];
    [self.floatingActionBtn.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.floatingActionBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.floatingActionBtn.layer setBorderWidth:0.7f * [UIScreen mainScreen].scale];
    [self.floatingActionBtn.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.floatingActionBtn.layer setShadowOffset:CGSizeMake(-1, 1.f)];
    [self.floatingActionBtn.layer setShadowOpacity:0.5f];
    self.floatingActionBtn.hidden = YES;
    int m = 9;
    [self.floatingActionBtn addMotionEffectsForX_Max:@(m) X_Min:@(-m) Y_Max:@(m) Y_Min:@(-m)];
    [self.floatingActionBtn addTarget:self action:@selector(doActions:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.floatingActionBtn];
    
}
- (void)keyboardWillShow:(NSNotification *)note
{
    
    if(_weakTextView.scrollEnabled) return;

    __block     CGPoint p = self.collectionView.contentOffset;
    _weakTextView.contentOffset = p;
    [self.collectionView  scrollRectToVisible:CGRectMake(0, 0, self.editingItemSize.width, self.editingItemSize.height) animated:NO];
    
    _weakTextView.disableContentScroll = YES;
    self.collectionView.alwaysBounceHorizontal = self.editing;
    _weakTextView.scrollEnabled = YES;

    
    self.collectionView.scrollEnabled = !self.editing;
    _weakTextView.disableContentScroll = NO;
        [_weakTextView scrollToCaretInTextView:_weakTextView animated:NO];

    [self.collectionView performBatchUpdates:nil completion:^(BOOL finished) {
        //CGRect caretRect = [_weakTextView caretRectForPosition:_weakTextView.selectedTextRange.start];
        //[_weakTextView scrollRectToVisible:caretRect animated:NO];
    }];
    
    
}
- (void)keyboardWillHide:(NSNotification *)note
{
    


    if(!_weakTextView.scrollEnabled) return;
    

    CGPoint p = _weakTextView.contentOffset;
    
    _weakTextView.scrollEnabled = NO;

  
    self.collectionView.alwaysBounceHorizontal = self.editing;

    
    _weakTextView.disableContentScroll = YES;
    


    
    [self.collectionView performBatchUpdates:^{

        [self.collectionView setContentOffset:p];
        _weakTextView.disableContentScroll = NO;


    }completion:^(BOOL finished) {
        self.collectionView.scrollEnabled = !self.editing;

    }];
}

- (void)keyboardDidShow:(NSNotification *)note
{
    
    if(!noteHolder && !_tagTokenField.superview)
    {
        _weakTextView.scrollEnabled = NO;
        _weakTextView.scrollEnabled = YES;
    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    if(indexPath.section == 0 && indexPath.item == 0) return NO;
    
    if (action == @selector(addToNote:)) {
        return YES;
    }
    return NO;
}
- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(addToNote:))
    {
        return NO;
    }
    
    return [super canPerformAction:action withSender:sender];
    
}
//Yes for showing menu in general
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) return NO;
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if(context == &EVC_KVO_ContextOps)
    {
        if([keyPath isEqualToString:kSettings_CacheLinks])
        {
            self.cacheFetchedData = [change[NSKeyValueChangeNewKey] boolValue];
        }
        else if([keyPath isEqualToString:kSettings_FetchNoteLinks])
        {
            self.fetchNoteLinks = [change[NSKeyValueChangeNewKey] boolValue];
        }
        else if([keyPath isEqualToString:KSettings_UseWifiOnly])
        {
            self.shouldUseWIFIOnlyForFetchingLinks = [change[NSKeyValueChangeNewKey] boolValue];
        }
        else if([keyPath isEqualToString:kSettings_EditorFontFamily])
        {
            [self removeLinkAttribution];
            NSString *newFontFamily = change[NSKeyValueChangeNewKey];
            FetchCell_Editor  * editor = (FetchCell_Editor *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            editor.fontFamily = newFontFamily;
            [self addLinkAttribution];

        }
    }
    
    else
    {
            runOnMainQueueWithoutDeadlocking(^{
                
                __block ROFetchStatus status = [change[NSKeyValueChangeNewKey] integerValue];
                RequestObject * ro = (RequestObject *)object;
                

                if(status == FetchIdle && ro.serviceType != API_SERVICE_TYPE_WEBIMAGE)
                {
                    return;
                }
              
                
                
                __block NSUInteger  idx = [self.requestObjects indexOfObject:ro]; // section 0 is the Editor.
                
                if(idx == NSNotFound) return;
                idx += 1;
                
                
                for(int i=0; i<ro.resultsArray.count; i++)
                {
                    NSIndexPath * ip = [NSIndexPath indexPathForItem:i inSection:idx];
                    [_cacheSizeOfFetchObjects removeObjectForKey:ip];
                }
                
                if(status==FetchFailed||status==FetchFromCache||status==FetchSuccessful || (ro.serviceType == API_SERVICE_TYPE_WEBIMAGE))
                {
                    [self.mappingFetchedResults setObject:[NSValue valueWithNonretainedObject:ro] forKey:@(idx)];
                }
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:idx]];
            });
        
    }
}
-(void)registerCollectionCells
{
    [self.collectionView registerClass:[FetchCell class] forCellWithReuseIdentifier:fetchCell];
    [self.collectionView registerClass:[FetchCell_Editor class] forCellWithReuseIdentifier:editorIdentifier];
}
- (void)reloadEditor
{
    [self removeLinkAttribution];
    _weakTextView.text = noteHolder;
    [self addLinkAttribution];
    [_cacheSizeOfFetchObjects removeObjectForKey:editorIdentifier];
    [self.collectionView performBatchUpdates:nil completion:nil];

    
}
-(BOOL)prefersStatusBarHidden
{
    return YES;
    
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.editingCompletionBlock = nil;
}
- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    if(parent && _shouldTurnOnEditMode)
    {
        _shouldTurnOnEditMode = NO;
        [_weakTextView becomeFirstResponder];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if(editing)
    {
        //_drawerImageLayer.backgroundColor = [[[self.view tintColor] colorWithAlphaComponent:0.1] CGColor];
           _drawerImageLayer.shadowColor = [self.view tintColor].CGColor;
            _drawerImageLayer.shadowRadius = 0.f;
            _drawerImageLayer.shadowOffset = CGSizeMake(1, -1);
            _drawerImageLayer.shadowOpacity = 1.f;

    }
    else
    {
        _drawerImageLayer.backgroundColor = nil;
        _drawerImageLayer.shadowOffset = CGSizeZero;
        
    }
    [_drawerImageLayer setPosition:CGPointMake(5.f, (editing)?35:CGRectGetMidY(self.view.bounds))];
    
    if(editing) [self removeLinkAttribution]; else [self addLinkAttribution];

    [super setEditing:editing animated:animated];
    
    [_weakTextView enableAllRSViewPullActionViews:editing];

    [self editorBecomeFirstResponder:editing];
}


- (void)setupUndoGrouping
{
    if(!_note) return;

    NSManagedObjectContext * moc = [_note managedObjectContext];
        NSUndoManager * undoM  = [moc undoManager];
        [undoM beginUndoGrouping];
    
}

- (void)endUndoGroupingByRevertingChanges:(BOOL)shouldUndoChanges
{
    if(!_note) return;

    NSUndoManager * undo = [[_note managedObjectContext] undoManager];
    [undo endUndoGrouping];
    
    if(shouldUndoChanges) [undo undo];
}


#pragma mark - CACHE ITEM SIZE




#pragma mark - Collection View delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1 + _requestObjects.count;
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    
    if(section == 0) return 1;
    if(!_mappingFetchedResults || _mappingFetchedResults.count == 0) return 0;
    NSValue  * value = [_mappingFetchedResults objectForKey:@(section)];
    RequestObject * ro = [value nonretainedObjectValue];
    return (ro) ? ro.resultsArray.count : 0;
}
- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath  {
    
    if(indexPath.section == 0) return nil;
    if (kind == UICollectionElementKindSectionHeader)
    {

        ExcerptCollectionHeaderView * r = (ExcerptCollectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"eheadercell" forIndexPath:indexPath];
        if(r.actionBtn.allTargets.count < 1)
        {
            [r.actionBtn addTarget:self action:@selector(sectionActionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        RequestObject * ro = self.requestObjects[indexPath.section-1];
        r.actionBtn.tag = indexPath.section;
        r.requestObject = ro;
        return r;
    }
    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return CGSizeZero;
    }
    else
    {
        return CGSizeMake(self.collectionView.bounds.size.width, 30);
    }
}




- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat boundsHeight = self.collectionView.bounds.size.height-30.f;
    
    
    CGFloat width = self.collectionView.bounds.size.width;
    if(indexPath.section == 0)
    {
        if(self.isEditing)
        {
            return CGSizeMake(width, self.editingItemSize.height);
        }
        BOOL noRequests = (_requestObjects.count == 0);
        if(_weakTextView)
        {
            if([_cacheSizeOfFetchObjects objectForKey:editorIdentifier])
            {
                return [[_cacheSizeOfFetchObjects objectForKey:editorIdentifier]  CGSizeValue];
            }
            else
            {
                CGSize size = [_weakTextView sizeThatFits:CGSizeMake(width, FLT_MAX)];
                size = CGSizeMake(width, (noRequests) ? MAX(size.height, boundsHeight) : size.height);
                NSValue *val = [NSValue valueWithCGSize:size];
                [_cacheSizeOfFetchObjects setObject:val forKey:editorIdentifier];
                return size;
            }
        }
        else
        {
            FetchCell_Editor * cell = [[FetchCell_Editor alloc] initWithFrame:self.collectionView.bounds];
            cell.textView.text = noteHolder;
            CGSize size = [cell.textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
            return  CGSizeMake(width, (noRequests) ? MAX(size.height, boundsHeight) : size.height);
        }
        
    }
    
    
    if([_cacheSizeOfFetchObjects objectForKey:indexPath])
    {
        return [[_cacheSizeOfFetchObjects objectForKey:indexPath] CGSizeValue];
    }
    
    RequestObject * ro = [[_mappingFetchedResults objectForKey:@(indexPath.section)] nonretainedObjectValue];
    NSDictionary * dataDict = ro.resultsArray[indexPath.item];
    
    CGFloat height = [FetchCell emptyCellSize];
    CGFloat padding = [FetchCell padding];
    CGFloat cellWidth = width  - (2 * self.collectionView.contentInset.left);
    width = cellWidth - (2*padding);
    
    CGSize constraintSize = CGSizeMake(width, FLT_MAX);
    
    height = padding;
    
    if(dataDict[titleKey])
    {
        NSString * title = [dataDict[titleKey] stringByAppendingString:@" ⇾"];
        CGRect frame = [title boundingRectWithSize:constraintSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont buttonFontSize]]}
                                                        context:nil];
        height += frame.size.height;
        height += padding;

    }
    
    if(dataDict[imgURLKey])
    {
        height += 200.f + (padding);
    }

    if(dataDict[fetchedDataKey])
    {
        UIFontDescriptor * desriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
       UIFont * font = [UIFont fontWithDescriptor:desriptor size:15];
        CGRect e = [[dataDict[@"fetchedData"] string] boundingRectWithSize:CGSizeMake(width, FLT_MAX)
                                                                          options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                attributes:@{NSFontAttributeName:font}
                                                                          context:nil];
        height += e.size.height;
        height += padding;
    }
    
    CGSize size = CGSizeMake(cellWidth, height);
    [_cacheSizeOfFetchObjects setObject:[NSValue valueWithCGSize:size] forKey:indexPath];
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    
    if(indexPath.section ==  0)
    {
        FetchCell_Editor *cell = [cv dequeueReusableCellWithReuseIdentifier:editorIdentifier forIndexPath:indexPath];
        if(!_weakTextView)
        {
            cell.textView.delegate = self.textExpander;
            cell.textView.tag = 111;
            _weakTextView = cell.textView;
            cell.textView.text = noteHolder;
            //[cell.textView sizeToFit];
            [self addLinkAttribution];
        }
        return cell;
    }else{
        
        RequestObject * ro = [[_mappingFetchedResults objectForKey:@(indexPath.section)] nonretainedObjectValue];
        FetchCell *cell = [cv dequeueReusableCellWithReuseIdentifier:fetchCell forIndexPath:indexPath];
        if(!cell.delegate) cell.delegate = self;
        NSDictionary * dataDict = ro.resultsArray[indexPath.item];
        cell.dataDictionary = dataDict;
        cell.serviceType = ro.serviceType;
        if(!dataDict[imgURLKey]) return cell;
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:dataDict[imgURLKey]]];
        __weak FetchCell *weakCell = cell;
        [cell.imageView setImageWithURLRequest: urlRequest
                              placeholderImage: nil
                                       success: ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                           __strong FetchCell *strongCell = weakCell;
                                           strongCell.imageView.image = image;
                                           [strongCell setNeedsLayout];
                                           
                                       } failure: NULL];
        
        
        return cell;
    }
}




- (void)fetchImageViewTapped:(UITapGestureRecognizer *)tap
{
    _weakCellImageView = (UIImageView *)tap.view;
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[tap locationInView:self.collectionView]];
    RequestObject * ro  = self.requestObjects[indexPath.section - 1];
    
    if(ro.serviceType == API_SERVICE_TYPE_YOUTUBE || ro.serviceType == API_SERVICE_TYPE_VIMEO)
    {
        [APP_DELEGATE showGlobalWebViewWithURL:[ro urlForViewingLink]];
    }
    else
        
    {
        UIImage *img = _weakCellImageView.image;
        TGRImageViewController *imageViewController = [[TGRImageViewController alloc] initWithImage:img];
        imageViewController.transitioningDelegate = self;
        [self presentViewController:imageViewController animated:YES completion:nil];
    }
}

- (void)addToNote:(NSString *)textToAdd
{
    if(!textToAdd) return;
    
    NSString * text = (textToAdd.length < 20) ? textToAdd : [textToAdd substringToIndex:20];
    
    MRModalAlertView * choice = [[MRModalAlertView alloc] initWithTitle:@"Add To Note" mesage:[NSString stringWithFormat:@"The text \"%@...\" should be appended or prepended to the note?\n\nYou can also rearrange paragraphs.", text]];
    choice.destructiveButtonIndex = 2;
    choice.buttonTitles = @[@"Append", @"Prepend", @"Cancel"];
    
    [choice showForView:self.view dismissCompletionBlock:^(id alertView, int buttonIndex) {
        
        if(buttonIndex == 2 || buttonIndex == -1) return;
        
        if(buttonIndex == 0)
        {
            noteHolder = [noteHolder stringByAppendingFormat:@"\n\n%@", textToAdd];
        }
        else if(buttonIndex == 1)
        {
            noteHolder = [NSString stringWithFormat:@"%@\n\n%@", textToAdd, noteHolder];
        }
        _note.text = noteHolder;
        [self reloadEditor];
        
    }];
    
}

    

- (void)fetchCellActionButtonPressed:(UIButton *)sender
{
    
    NSIndexPath *indexPath = nil;
    indexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:sender.center fromView:sender.superview]];
    RequestObject * ro  = self.requestObjects[indexPath.section - 1];
    
    if(ro.requestType == REQUEST_OBJECT_TYPE_SEARCH)
    {
        NSString * identifier = ro.resultsArray[indexPath.item][@"identifier"];
        if(identifier)
        {
            NSString * urlstring = [[APIServices shared] completePublicURL:ro.serviceKey identifier:identifier];
            [APP_DELEGATE showGlobalWebViewWithURL:[NSURL URLWithString:urlstring]];
        }
    }
    else
    {
        [APP_DELEGATE showGlobalWebViewWithURL:[ro urlForViewingLink]];
    }
    
}

- (void)sectionActionButtonPressed:(UIButton *)sender
{
    RequestObject * ro  = self.requestObjects[sender.tag-1];
    
    [[Workflows shared] setDelegate:self];
    
    NSArray *array = [[Workflows shared] workflowsAvailableForObjectClasses:@[NSStringFromClass([NSURL class])]];
    NSMutableArray * arr = [NSMutableArray new];
    
    for(WorkflowAction * wfa in array)
    {
        WorkflowActionActivity * activity = [[WorkflowActionActivity alloc] initWithWorkflowAction:wfa];
        [arr addObject:activity];
    }
    
    
    [MRModalAlertView showMessage:[NSString stringWithFormat:@"%@\n\n%@", ro.urlForViewingLink.absoluteString, _note.exportString] title:@"S" overView:self.view];
    return;
    
    
    UIActivityViewController * activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[ro.urlForViewingLink] applicationActivities:[arr copy]];
    activityViewController.popoverPresentationController.sourceView = sender;
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView != self.collectionView) return;
    
    if(scrollView.contentOffset.y > 250.f)
    {
        if(_floatingActionBtn.isHidden) _floatingActionBtn.hidden = NO;
    }
    else
    {
        if(!_floatingActionBtn.isHidden) _floatingActionBtn.hidden = YES;
    }
}


- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [_cacheSizeOfFetchObjects removeAllObjects];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:_weakCellImageView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:_weakCellImageView];
    }
    return nil;
}


#pragma mark - TEXT VIEW
- (BOOL)textViewShouldBeginEditing:(TapTextView *)textView
{
    
    if(!self.isEditing || _shouldTurnOnEditMode)
    {
        [self setEditing:YES animated:NO];
    }

    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [_cacheSizeOfFetchObjects removeObjectForKey:editorIdentifier];

}
-(BOOL)textViewShouldEndEditing:(TapTextView *)textView
{

    
    if(self.isEditing && (!_tagTokenField || _tagTokenField.isHidden))
    {
        [self setEditing:NO animated:NO];
    }
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{

}


-(void)textViewDidChange:(UITextView *)textView
{
    if (self.snippetExpanded) {
        [self performSelector:@selector(twiddleText:) withObject:textView afterDelay:0.01];
        self.snippetExpanded = NO;
    }
    noteHolder = textView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    
    if(self.textExpander.isAttemptingToExpandText)
    {
        self.snippetExpanded = YES;
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    return YES;
}



- (void)twiddleText:(UITextView*)textView
{
    [textView.textStorage edited:NSTextStorageEditedCharacters range:NSMakeRange(0, textView.textStorage.length) changeInLength:0];
}

-(BOOL)canBecomeFirstResponder
{
    return ([self isEditing]) && ([_tagTokenField isHidden]);
}

- (BOOL)becomeFirstResponder
{
        [self.keyToolbar setTextInputDelegate:_weakTextView];
        [_keyToolbar setKeyboardMode:EXCERPT_KEYBOARD_TEXT];
        [_keyToolbar setKeyboardAccessoryButtonActionDelegate:self];
    //:::1.1
        if(self.isEditing) [_weakTextView becomeFirstResponder];
    return YES;
}

#pragma mark - TIToken TextField
-(void)showTagView
{
    if(!_tagTokenField)
    {
        CGRect frame = CGRectMake(0, 0, self.collectionView.frame.size.width - 0, self.editingItemSize.height);
        frame = self.view.bounds;
        self.tagTokenField = [[VGTokenFieldView alloc] initWithFrame:frame note:_note sourceDelegate:self];
        _tagTokenField.tokenField.inputAccessoryView = self.keyToolbar;
        [_tagTokenField setNote:_note];
    }
    _tagTokenField.frame = self.view.bounds;
    UIEdgeInsets  insets = [[_tagTokenField resultsTable] contentInset];
    insets.bottom  = self.view.bounds.size.height - self.editingItemSize.height;
    [[_tagTokenField resultsTable] setContentInset:insets];
    [[_tagTokenField resultsTable] setScrollIndicatorInsets:insets];
    [self.keyToolbar setTextInputDelegate:_tagTokenField.tokenField];
    [self.keyToolbar setKeyboardAccessoryButtonActionDelegate:_tagTokenField];
    [_tagTokenField showOverView:self.view size:CGSizeZero animate:YES];
}

- (NSString *)searchStringForTokenField:(TITokenField *)tokenField{
    return [noteHolder topLine];
}

#pragma mark - SETTINGS
- (void)addSettingsObservers:(BOOL)add
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if(add)
    {
        [defaults addObserver:self forKeyPath:kSettings_CacheLinks options:NSKeyValueObservingOptionNew context:&EVC_KVO_ContextOps];
        [defaults addObserver:self forKeyPath:kSettings_FetchNoteLinks options:NSKeyValueObservingOptionNew context:&EVC_KVO_ContextOps];
        [defaults addObserver:self forKeyPath:KSettings_UseWifiOnly options:NSKeyValueObservingOptionNew context:&EVC_KVO_ContextOps];
        [defaults addObserver:self forKeyPath:kSettings_EditorFontFamily options:NSKeyValueObservingOptionNew context:&EVC_KVO_ContextOps];


    }
    else
    {
        [defaults removeObserver:self forKeyPath:kSettings_CacheLinks  context:&EVC_KVO_ContextOps];
        [defaults removeObserver:self forKeyPath:kSettings_FetchNoteLinks  context:&EVC_KVO_ContextOps];
        [defaults removeObserver:self forKeyPath:KSettings_UseWifiOnly  context:&EVC_KVO_ContextOps];
        [defaults removeObserver:self forKeyPath:kSettings_EditorFontFamily  context:&EVC_KVO_ContextOps];




    }
}

#pragma mark toolbar Functions
-(void)setupEditorWithText:(id)text tags:(NSArray *)tagArray completion:(EditingCompletionBlock)completionBlock
{
    [self setNote:(id)text];
    self.editingCompletionBlock = completionBlock;
}

- (KeyboardAccessoryBar *)keyToolbar
{

    if(!_keyToolbar)
    {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 35);
        self.keyToolbar = [[KeyboardAccessoryBar alloc] initWithFrame:frame textInputDelegate:_weakTextView];
        self.keyToolbar.keyboardAccessoryButtonActionDelegate = self;
        return _keyToolbar;
    }
    
    return _keyToolbar;
}

- (void)leftKeyboardAccessoryBarAction:(id)sender
{
    [self setEditing:NO animated:YES];
    
    [_weakTextView resignFirstResponder];
    
    if(!_note && !noteHolder)
    {
        if(_editingCompletionBlock)
        {
            _editingCompletionBlock(nil, NO);
            _editingCompletionBlock = nil;
        }
        return;
    }
    
    BOOL refetchLinks = NO;

    NSManagedObjectContext * moc = [[DataManager sharedInstance] managedObjectContext];
    
    
    if(!_note && noteHolder)
    {

        
        _note = [Note entityWithText:noteHolder moc:moc];
        _note.lastAccessedDate = _note.creationDate;

    }
    else
    {
        if(_note.weblinksCache)  [moc deleteObject:_note.weblinksCache];
        _note.text  = noteHolder;
    }
    
        if(_tagTokenField.tagsArray.count > 0)
        {
            
            NSMutableArray * newlyCreatedTags = [NSMutableArray new];
            for(id tagObj in _tagTokenField.tagsArray)
            {
                if([tagObj isKindOfClass:[Tag class]])
                {
                    [_note addTagsObject:tagObj];
                }
                else
                {
                    [newlyCreatedTags addObject:tagObj];
                }
            }
            
            if(newlyCreatedTags.count > 0)
            {
                NSSet * newtagSet = [Tag exp_fetchOrCreateTags:newlyCreatedTags  context:moc];
                [_note addTags:newtagSet];
            }
            [_tagTokenField.tagsArray removeAllObjects];
        }
        
        if(_tagTokenField.linksArray.count > 0)
        {
            
            static NSString * linkidentifierKey = @"identifier";
            NSMutableDictionary * linkIdentifiersDictionary = [NSMutableDictionary new];
            for(NSDictionary * linkDict in _tagTokenField.linksArray)
            {
                [linkIdentifiersDictionary setObject:linkDict forKey:linkDict[linkidentifierKey]];
            }
            
            NSSet * linkSet = [Link exp_fetchOrCreateObjectsWithIDs:[linkIdentifiersDictionary allKeys] ofAttribute:linkidentifierKey inEntity:@"Link" context:moc setAttributeProperties:[linkIdentifiersDictionary copy]];
            [_note addLinks:linkSet];
            
            
            [_tagTokenField.linksArray removeAllObjects];
        }
        
        

    
    
        if([_note hasChanges] && [_note changedValues].count > 0)
        {
            NSArray * changedKeys = _note.changedValues.allKeys;

            if([changedKeys containsObject:@"links"])
            {
                refetchLinks = YES;
            }

            if([changedKeys containsObject:@"text"])
            {
                _note.modifiedDate = [NSDate date];
            }
            if(_note.type.integerValue == EX_TYPE_DROPBOX) [self openAndSaveDropboxFile];
        }
        
    
    [moc save:nil];

    if(_editingCompletionBlock)
    {
       _editingCompletionBlock(_note, YES);
       _editingCompletionBlock = nil;
    }
    
    if(refetchLinks)
    {
        [self resetLinks];
        [self fetchLinks:nil];
    }
    
}
-(void)rightKeyboardAccessoryBarAction:(id)sender
{
    [self setEditing:NO animated:YES];
    [_weakTextView resignFirstResponder];
    [_weakTextView enableAllRSViewPullActionViews:NO];
    
    if(self.editingCompletionBlock)
    {
        self.editingCompletionBlock(nil, NO);
        self.editingCompletionBlock = nil;
    }
    
    if(!_note && !noteHolder)
    {

    }
    else
    {
        if([_note hasChanges])
        {
            [_note.managedObjectContext refreshObject:_note mergeChanges:NO];
        }
    }
 
    
}



#pragma mark - Workflows
-(void)doActions:(id)sender{
    
    __weak typeof(sender) weakSender = sender;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
    [[Workflows shared] setDelegate:self];
    if((!_note && !noteHolder) || [noteHolder length] < 2) return;
    WorkflowAction * action1 = [[Workflows shared] workFlowActionWithScheme:@"share" actionKey:@"text"];
    [[Workflows shared] setSenderObject:weakSender];
        [[Workflows shared] startWorkflows:@[action1] completion:nil];

        dispatch_async(dispatch_get_main_queue(), ^{

        });
    });
    
}






- (void)setNetworkStatus:(JTSNetworkStatus)networkStatus
{
    [super setNetworkStatus:networkStatus];
    
    [self changeRequestsForStatus:networkStatus];
    
}

- (void)setShouldUseWIFIOnlyForFetchingLinks:(BOOL)shouldUseWIFIOnlyForFetchingLinks
{
    [super shouldUseWIFIOnlyForFetchingLinks];
    
    [self enableReachabilityObserving:shouldUseWIFIOnlyForFetchingLinks];
    
    if(shouldUseWIFIOnlyForFetchingLinks)
    {
//        [self setNetworkStatus:[[JTSReachabilityResponder sharedInstance] networkStatus]];
    }
}
- (void)enableReachabilityObserving:(BOOL)enable
{
    static NSString * rechabilityKey = @"reachability";
    if(enable)
    {
        JTSReachabilityResponder *responder = [JTSReachabilityResponder sharedInstance];
        __weak typeof(self) weakSelf = self;
        self.networkStatus = [[JTSReachabilityResponder sharedInstance] networkStatus];
        [responder addHandler:^(JTSNetworkStatus status) {
            
            weakSelf.networkStatus = status;
            
            
        } forKey:rechabilityKey];
    }
    else
    {
        JTSReachabilityResponder *responder = [JTSReachabilityResponder sharedInstance];
        [responder removeHandlerForKey:rechabilityKey];
    }
}

- (BOOL)shouldFetchForStatus:(JTSNetworkStatus)status
{
    if(!self.shouldUseWIFIOnlyForFetchingLinks) return YES;
    
    if (self.shouldUseWIFIOnlyForFetchingLinks && status == ReachableViaWWAN)
    {
            return NO;
    }
    if(status == NotReachable)
    {
        return NO;
    }
    return YES;
}
- (void)changeRequestsForStatus:(JTSNetworkStatus)status
{
    BOOL go = [self shouldFetchForStatus:status];
    
    if(!go)
    {
        [self.fetchOperationQueue setSuspended:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if(self.fetchOperationQueue.operationCount == 0) return;
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [weakSelf.requestObjects makeObjectsPerformSelector:@selector(resetFetchStatus)];
        });
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WiFi not available" message:@"Fetching new uncached links has been stopped. To continue using Network, Turn \"Use only Wi-Fi\" off in Settings" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
    }
    else
    {
        if(self.fetchOperationQueue.isSuspended && self.fetchOperationQueue.operationCount > 0)
        {
            [self.fetchOperationQueue setSuspended:NO];
        }
    }
}





- (void)setTheme:(NSString *)themeName
{
    UIColor *collectionView_bg = [UIColor blackColor];

    if([themeName isEqualToString:@"Dark"])
    {
        [[FetchCell appearance] setBackgroundColor:kColor_MAinView_Dark_Background];
        
        //[[FetchCell_Editor appearance] setEditorTextColor:[UIColor lightTextColor]];

       // [[FetchCell_Editor appearance] setCellBackgroundColor:kColor_MAinView_Dark_Background];
       // [[FetchCell_Editor appearance] setTextColor:[UIColor lightTextColor]];
        
    }else
    {
        collectionView_bg = [UIColor colorWithWhite:0.92 alpha:1.0];
       // [[FetchCell sgv_appearance] setBackgroundColor:kVignetteViewBGColor];
//        [[FetchCell_Editor appearance] setCellBackgroundColor:[UIColor colorWithWhite:0.92 alpha:1.0]];
        //[[FetchCell_Editor appearance] setEditorTextColor:[UIColor darkTextColor]];

        //[[FetchCell_Editor appearance] setTextColor:[UIColor darkTextColor]];
        [[FetchCell appearance] setBackgroundColor:kVignetteViewBGColor];

    }
    
    self.collectionView.backgroundColor = collectionView_bg;
}


- (BOOL)editorBecomeFirstResponder:(BOOL)becomeResponder
{
    
    if(becomeResponder)
    {
        if(!_weakTextView.inputAccessoryView)
        {
            [_weakTextView setInputAccessoryView:self.keyToolbar];
            [_keyToolbar setTextInputDelegate:_weakTextView];

        }

    }
    
   // if(!becomeResponder)
       //_weakTextView.scrollEnabled = becomeResponder;
    
    _weakTextView.alwaysBounceHorizontal = becomeResponder;
    _weakTextView.alwaysBounceVertical = NO;
    _weakTextView.showsHorizontalScrollIndicator = NO;

    
    return YES;
}

#pragma Mark - Dropbox File Type


- (void)openAndSaveDropboxFile
{
    DBPath * dbpath     = [[DBPath alloc] initWithString:_note.importIdentifier];
    DBError *error = nil;
    DBFilesystem * fileSystem = [DBFilesystem sharedFilesystem];
    if(!fileSystem)
    {
        fileSystem = [[DBFilesystem alloc] initWithAccount:[[DBAccountManager sharedManager] linkedAccount]];
    }
    _dropboxFile  = [fileSystem openFile:dbpath error:&error];
    if(error)
    {
        DLog(@"%@", error.description);
    }
    else
    {
        [_dropboxFile writeString:noteHolder error:&error];
        if(error)
            DLog(@"%@", error.description)
            ;
        [_dropboxFile close];
    }
}


#pragma mark - WorkFlowDelegate
-(id)dataObjectForWorkflow:(WorkflowAction *)workflow{
    
    NSString * shareItem;
    
    if(workflow.shareActivityItems)
    {
        id Obj = workflow.shareActivityItems[0];
        if([Obj isKindOfClass:[NSURL class]])
        {
            shareItem = [Obj absoluteString];

        }else
        {
            shareItem = Obj;
        }
    }
    else
    {
        shareItem = (_note) ? _note.text : noteHolder;

    }
    
    if([workflow.scheme isEqualToString:@"saveInDocumentPicker"])
    {
        shareItem = (_note) ? [_note exportString] : noteHolder;
    }
    
    NSMutableDictionary * reps;
    
    if ([workflow replacements]) {
        reps = [[workflow replacements] mutableCopy];
    }
    else
    {
        reps = [[workflow requiredParameters] mutableCopy];
        [reps addEntriesFromDictionary:[workflow optionalParameters]];
    }
    
    
    for(NSString * key in reps.allKeys)
    {
        id value = reps[key];
        if([value isKindOfClass:[NSString class]])
        {
            
            if([value isEqualToString:kWF_NOTE_VARIABLE])
            {
                [reps setObject:shareItem forKey:key];
                
            }else if ([value rangeOfString:@"[[title]]"].location != NSNotFound)
            {
                NSString * topLine = [shareItem topLine];
                if(topLine)
                {
                    reps[key] = [value stringByReplacingOccurrencesOfString:@"[[title]]" withString:topLine];
                    
                }else
                {
                    [reps removeObjectForKey:key];
                }

            }else if([value isEqualToString:@"[[markdown-text]]"])
            {
                [reps setObject:shareItem forKey:key];
            }
            else if ([value isEqualToString:@"[[url]]"])
            {
                [reps setObject:shareItem forKey:key];
            }
            else if ([value isEqualToString:kWF_FILENAME_VARIABLE])
            {
                
                reps[key] = [shareItem rs_sanitizeFileNameStringWithExtension:@"txt"];
            }
            
            
        }
    }
    return [reps copy];
}
/*
-(void)workflowDidEnd:(WorkflowAction *)wfAction withSuccessParam:(NSString *)successURLParam
{
    DLog(@"%@ %@ %@ %@", successURLParam, wfAction.identifier, wfAction.scheme, wfAction.action);
}
-(void)finishedExecutingAllWorkflows{
    DLog(@"doine..");
}
-(void)workflowWillStart:(WorkflowAction *)workflow
{
    DLog(@"%@", workflow.scheme);
}*/
-(void)workflowAction:(WorkflowAction *)wfaction didReturn:(id)returnValue
{    
    if(returnValue)
    {
        noteHolder = returnValue;
        if(_note)
        {
            _note.text = noteHolder;
            [_note.managedObjectContext save:nil];
        }
        [self reloadEditor];
    }
}

- (void)dealloc
{
    [self.collectionView    enableAllRSViewPullActionViews:NO];
    
    for(RequestObject * ro in _requestObjects)
    {
        if([ro observationInfo]) [ro removeObserver:self forKeyPath:NSStringFromSelector(@selector(fetchStatus))];
    }

}


@end
