//
//  VGTokenFieldView.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 26/12/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "VGTokenFieldView.h"
#import "Tag.h"
#import "AppDelegate.h"
#import "TagViewController.h"
#import "DataManager.h"
#import "Note.h"
#import "Link.h"
#import "MRModalAlertView.h"
#import "MRTextInputView.h"
#import "RSPullToAction.h"
#import "KeyboardAccessoryBar.h"
#import "UIImageView+AFNetworking.h"
#import "LinkSearchCell.h"
#import "NSString+RSParser.h"
#import "AFJSONRequestOperation.h"
#import "NSAttributedString+Ashton.h"

@interface VGTokenFieldView () <TITokenFieldDelegate>

@property (nonatomic, assign, getter = isSwitchingMode) BOOL switchingMode;
@property (nonatomic, strong) NSArray *tokenLinksArray;
@property (nonatomic, strong) RSPullToAction  *switchPullToActionView;
@property (nonatomic, strong) UIActivityIndicatorView * serviceActivityIndicator;
@property (nonatomic, strong) NSOperationQueue * searchOperationQueue;
@property (nonatomic, strong) UIBarButtonItem * servicesSelectorBtn;
@property (nonatomic, strong) NSArray * linksModeButtons;
@property (nonatomic, strong) NSArray * activeSearchServices;

@end

@implementation VGTokenFieldView
@synthesize modeType = _modeType, allowMultipleSelection = _allowMultipleSelection;


- (instancetype)initWithFrame:(CGRect)frame note:(Note *)note sourceDelegate:(id)delegate;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.searchOperationQueue = [NSOperationQueue new];
        self.searchOperationQueue.maxConcurrentOperationCount = 1;
        self.activeSearchServices = [[NSUserDefaults standardUserDefaults] objectForKey:kSettings_ActiveSearchServices];
        if(!_activeSearchServices) self.activeSearchServices = @[kAPI_CODE_Wikipedia, kAPI_CODE_Wordnik, kAPI_CODE_Youtube];
        _sourceDelegate = delegate;
        [self setupScrollerActions];
        _allowMultipleSelection = NO;
        self.directionalLockEnabled = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
        self.tokenField.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        self.tokenField.textColor  =  [UIColor whiteColor];
        [self setSearchSubtitles:NO];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.tokenField.enablesReturnKeyAutomatically = YES;
        self.tokenField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.tokenField.delegate = self;
        self.shouldSearchInBackground = YES;
        self.shouldSortResults = NO;
        [self.resultsTable setSeparatorColor:[UIColor colorWithWhite:0.5 alpha:0.3]];
        self.resultsTable.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)setNote:(Note *)note
{
    _tagsArray = nil;
    _linksArray = nil;
    [self clearAllTokens];
    _note = note;
    _modeType = -1;
    

}
- (void)clearAllTokens
{
    self.switchingMode = YES;
    [self.tokenField removeAllTokens];
    self.switchingMode = NO;
}

- (void)initialiseSets
{
    if(!_tagsArray)
    {
        self.tagsArray = [NSMutableSet new];
        self.linksArray = [NSMutableSet new];
        [self setModeType:VGTAGMODE];
    }

    
}

+ (TIToken *)tagTokenWithTag:(Tag *)tag
{
    TIToken *  token = [[self class] tagTokenWithTitle:tag.title];
    token.representedObject = tag;
    return token;
}
+ (TIToken *)tagTokenWithTitle:(NSString *)title
{
    TIToken * token = [[TIToken alloc] initWithTitle:title];
    token.representedObject = title;
    return token;
}
- (void)fillTags
{
    for(Tag *tag in _note.tags)
    {
        [self.tokenField addToken:[[self class] tagTokenWithTag:tag]];
    }
    for(id tagObj in _tagsArray)
    {
        if([tagObj isKindOfClass:[Tag class]])
        {
            [self.tokenField addToken:[[self class] tagTokenWithTag:tagObj]];
        }
        else
        {
            [self.tokenField addToken:[[self class] tagTokenWithTitle:tagObj]];
        }
    }

}

+ (TIToken *)linkTokenWithLinkObject:(NSString *)title representedObj:(id)repObj
{
    TIToken * token = [[TIToken alloc] initWithTitle:title representedObject:repObj];
    token.tintColor = kColor_Orange;
    token.textColor = [UIColor whiteColor];
    return token;
}
- (void)fillLinks
{
    for(Link  *link in _note.links)
    {
        [self.tokenField addToken:[[self class] linkTokenWithLinkObject:link.fetchedTitle representedObj:link]];
    }
    
    for(id LinkObj in _linksArray)
    {
        if([LinkObj isKindOfClass:[Link class]])
        {
            [self.tokenField addToken:[[self class] linkTokenWithLinkObject:[LinkObj fetchedTitle] representedObj:LinkObj]];
        }
        else
        {
            [self.tokenField addToken:[[self class] linkTokenWithLinkObject:LinkObj[@"title"] representedObj:LinkObj]];
        }
    }

}
- (void)setupScrollerActions
{
    __weak VGTokenFieldView * weakSelf = self;
    __weak typeof(self.sourceDelegate) weakDelegate  = _sourceDelegate;
    
    RSPullToAction * exit = [self addPullToActionPosition:RSPullActionPositionLeft actionHandler:^(RSPullToAction *v)
                     {
                         [weakSelf hide:weakDelegate];

                     }];
    exit.text = @"Back";
    exit.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];

    
    self.switchPullToActionView = [self addPullToActionPosition:RSPullActionPositionRight actionHandler:^(RSPullToAction *v)
                     {
                         [weakSelf switchTokenMode:weakDelegate];
                         
                     }];
    _switchPullToActionView.text = @"Switch";
    _switchPullToActionView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
}




-(void)showOverView:(UIView *)container size:(CGSize)size animate:(BOOL)animate
{
    if([self superview]) return;
    
    [_searchOperationQueue setSuspended:NO];

    [self initialiseSets];
    [self resetKeyboard];
    [container addSubview:self];

    self.alpha = 0.0;
    
    [UIView animateWithDuration:0.35
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         //self.frame = newf;
                         self.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self becomeFirstResponder];
                     }];
    
}
- (void)dealloc
{
    [self enableAllRSViewPullActionViews:NO];
}
-(void)hide:(id)sender
{
    [_searchOperationQueue cancelAllOperations];
    [_searchOperationQueue setSuspended:YES];
    if(sender != NULL) [sender becomeFirstResponder];

    [UIView animateWithDuration:0.35
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
    {
        self.alpha = 0.0;
    }
     completion:^(BOOL finished)
     {
         if(self.superview != nil) [self removeFromSuperview];
     }];
    
    
}
-(void)rightKeyboardAccessoryBarAction:(id)sender
{
    [self switchTokenMode:_sourceDelegate];
    
}
- (void)leftKeyboardAccessoryBarAction:(id)sender
{
    [self hide:_sourceDelegate];
}

- (UIActivityIndicatorView *)serviceActivityIndicator
{
    if(_serviceActivityIndicator) return _serviceActivityIndicator;
    
    self.serviceActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.serviceActivityIndicator setFrame:CGRectMake(0, 0, 35, 35)];
    return _serviceActivityIndicator;
}


-(void)switchTokenMode:(id)sender{
    VGMODE m = (_modeType == VGTAGMODE) ? VGTAGSERVICEMODE : VGTAGMODE;
    [self setModeType:m];
    [self resetKeyboard];
}

- (void)resetKeyboard
{
    KeyboardAccessoryBar * bar = (KeyboardAccessoryBar *)self.tokenField.inputAccessoryView;
    
    bar.keyboardAccessoryButtonActionDelegate = self;
    
    if(_modeType == VGTAGSERVICEMODE)
    {
        _switchPullToActionView.text = @"Tags";
        [bar setKeyboardMode:EXCERPT_KEYBOARD_LINKS];
        [bar setLeftButtonTitle:@"Back"];
        [bar setRightButtonTitle:@"Tags"];
        [bar setButtonTitles:self.linksModeButtons];
        
    }
    else
    {
        _switchPullToActionView.text = @"Links";
        [bar setKeyboardMode:EXCERPT_KEYBOARD_TAG];

        
    }
    
}





- (BOOL)isFirstResponder
{
    return ([self.tokenField isFirstResponder]) || ([self superview]);
}
-(void)setModeType:(VGMODE)type{

    if(_modeType == type) return;
    
    _modeType = type;
    
    [_resultsArray removeAllObjects];
    [self.resultsTable reloadData];
    _switchingMode = YES;
    
   // self.tokenField.text = nil;
    
    if(_modeType == VGTAGMODE)
    {
        [self.tokenField setReturnKeyType:UIReturnKeyDefault];
        [self.tokenField reloadInputViews]; //::: Does Not work on iOS8
        [self.tokenField setDelegate:self];
        [self.tokenField becomeFirstResponder];
        [self setForcePickSearchResult:NO];
        [self.tokenField setPromptText:@"Tags:"];
        

        
        if([[DataManager sharedInstance] tagsFetchController])
        {
            self.sourceArray = [[[DataManager sharedInstance] tagsFetchController] fetchedObjects];
        }
        else
        {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:[[DataManager sharedInstance]managedObjectContext]];
            [fetchRequest setEntity:entity];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            [fetchRequest setSortDescriptors:@[sortDescriptor]];
            NSError *error = nil;
            NSArray *array = [[[DataManager sharedInstance] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
            self.sourceArray = array;
        }

        
    }else if(_modeType == VGTAGSERVICEMODE)
    {
        [self.tokenField setReturnKeyType:UIReturnKeySearch];
        [self.tokenField reloadInputViews];
        [self.tokenField becomeFirstResponder];
        [self.tokenField setPromptText:@"Links:"];
    }
    
    [self.tokenField setText:@" "];
    self.tokenField.text = nil;
    
    [self.resultsTable reloadData];
    [self fillData];
    [self setSearchResultsVisible:NO];
    _switchingMode = NO;

}
- (void)fillData
{
    [[self tokenField] removeAllTokens];

    if(_modeType == VGTAGMODE)
    {
        [self fillTags];
    }
    else if (_modeType == VGTAGSERVICEMODE)
    {
        [self fillLinks];
    }
}


- (void)setSearchResultsVisible:(BOOL)visible
{
    [super setSearchResultsVisible:visible];
}


- (void)resultsForSearchString:(NSString *)searchString {
    
    if(_modeType == VGTAGMODE)
    {
        [super resultsForSearchString:searchString];
    }
}
-(void)tokenFieldTextDidChange:(TITokenField *)field
{
    if(_modeType == VGTAGMODE)
    {
        [super tokenFieldTextDidChange:field];
    }
}

- (void)addLinkToken:(TIToken *)linkToken
{
        [_linksArray addObject:linkToken.representedObject];
}
- (void)removeLinkToken:(TIToken *)linkToken
{
    if(_note)
    {
        if([linkToken.representedObject isKindOfClass:[Link class]])
        {
            [_note removeLinksObject:linkToken.representedObject];
        }
        else
        {
            [_linksArray removeObject:linkToken.representedObject];
        }
    }
    else
    {
        [_linksArray removeObject:linkToken.representedObject];
    }
}
- (void)addTagToken:(TIToken *)tagToken
{
    if(!_tagsArray) self.tagsArray = [NSMutableSet new];
    
    if(!tagToken.representedObject) tagToken.representedObject = tagToken.title;
    
    if(_note)
    {
        if([tagToken.representedObject isKindOfClass:[Tag class]])
        {
            [_note addTagsObject:tagToken.representedObject];
        }
        else
        {
            [_tagsArray addObject:tagToken.representedObject];
        }
    }
    else
    {
        [_tagsArray addObject:tagToken.representedObject];
    }
}

- (void)removeTagToken:(TIToken *)tagToken
{
    if(_note)
    {
        if([tagToken.representedObject isKindOfClass:[Tag class]])
        {
            [_note removeTagsObject:tagToken.representedObject];
        }
        else
        {
            [_tagsArray removeObject:tagToken.representedObject];
        }
    }
    else
    {
        [_tagsArray removeObject:tagToken.representedObject];
    }
}


- (void)tokenField:(TITokenField *)tokenField didRemoveToken:(TIToken *)token
{
    if(self.isSwitchingMode) return;
    
    if(_modeType == VGTAGSERVICEMODE)
    {
        [self removeLinkToken:token];
    }
    else if (_modeType == VGTAGMODE)
    {
        [self removeTagToken:token];
    }
    
}

- (void)tokenField:(TITokenField *)tokenField didAddToken:(TIToken *)token
{
    
    if(self.isSwitchingMode) return;
    
    if(_modeType == VGTAGMODE)
    {
        [self addTagToken:token];
    }

    else if(_modeType == VGTAGSERVICEMODE)
    {
        [self addLinkToken:token];
    }
    }



//wikipedia
//http://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=serum&srprop&format=json
//youtube
//http://gdata.youtube.com/feeds/api/videos?q=alb&v=2&alt=jsonc&max-results=11
//wordnik
//http://api.wordnik.com/v4/word.json/albumin/definitions?limit=4&includeRelated=true&sourceDictionaries=all&useCanonical=true&includeTags=true&api_key=ef8a9d0ab4490fdddc0050e3bc709585437ee1d5a8a25daae

- (void)addResultsToArray:(NSArray *)array
{
    [_resultsArray addObjectsFromArray:array];
}

- (void)addSearchOperationsForServices:(NSArray *)services inQueue:(NSOperationQueue *)queue
{
    if(!services || services.count == 0)
    {
        MRModalAlertView * alertView = [[MRModalAlertView alloc] initWithTitle:kApp_Display_title mesage:@"Select atleast one search service - Wikipedia or Youtube or Wordnik"];
        alertView.viewPosition = MRVIEWPOSITIONTOP;
        [alertView showForView:[self superview] selectorBlock:nil];
        return;
    }
    NSString *searchTerms = [self.tokenField.text substringFromIndex:1];
    if(searchTerms == nil || [searchTerms length] < 2)
    {
        if([_sourceDelegate respondsToSelector:@selector(searchStringForTokenField:)])
        {
            searchTerms = [_sourceDelegate searchStringForTokenField:self.tokenField];
        }
        if([searchTerms length] < 3)
        {
            MRModalAlertView * alertView = [[MRModalAlertView alloc] initWithTitle:kApp_Display_title mesage:@"Type in keywords for searching"];
            alertView.viewPosition = MRVIEWPOSITIONTOP;
            [alertView showForView:[self superview] selectorBlock:nil];
            return;
        }
    }
    [_resultsArray removeAllObjects];
    [self.resultsTable reloadData];
    [self setSearchResultsVisible:NO];
    __weak APIServices * weakAPIServices = [APIServices shared];
    __weak VGTokenFieldView *weakSelf = self;
    __weak NSOperationQueue *weakQueue = queue;
    [_serviceActivityIndicator startAnimating];


    for(NSString *servicesKey in services)
    {
        __weak NSString * weakServiceKey = servicesKey;
        AFJSONRequestOperation * operation = [[APIServices shared] searchOperationForService:servicesKey
                                                                                  searchTerm:searchTerms
                                                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                              {
                                                  NSMutableDictionary * dict = [[weakAPIServices captureDataFromJSON:JSON forSearchServiceIdentifier:weakServiceKey] mutableCopy];
                                                  
                                                  
                                                  if(dict && [dict allKeys] > 0)
                                                  {
                                                      NSArray * results  = [APIServices mergeAllArraysInObjectsOfDictionary:dict addKeyValueDict:@{@"serviceKey": weakServiceKey}];
                                                      [weakSelf addResultsToArray:results];
                                                      [weakSelf.resultsTable reloadData];
                                                      [weakSelf setSearchResultsVisible:YES];
                                                  }
                                                  if([weakQueue operationCount] == 0) [[weakSelf serviceActivityIndicator] stopAnimating];

                                                  
                                              }
                                                                                     failure:^(NSURLRequest *request, NSHTTPURLResponse *response , NSError *error, id JSON)
                                              {
                                                  if([weakQueue operationCount] == 0) [[weakSelf serviceActivityIndicator] stopAnimating];
                                                  
                                              }];
        [queue addOperation:operation];
        
    }
    
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


    _allowMultipleSelection = YES;
    tableView.allowsMultipleSelection = _allowMultipleSelection;
    
    id representedObject = _resultsArray[indexPath.row];

    if(_modeType == VGTAGSERVICEMODE)
    {
        
        if([representedObject[@"serviceKey"] isEqualToString:@"wordnik"])
        {
            MRTextInputView * mr = [[MRTextInputView alloc] initWithFrame:CGRectMake(0, 0, 260, 400)];
            mr.title = [NSString stringWithFormat:@"Wordnik: %@", representedObject[@"identifier"]];
            mr.buttonTitles = @[@"OK"];
            mr.editableTitle = NO;
            NSAttributedString * attr = [[NSAttributedString alloc] mn_initWithHTMLString:representedObject[@"fetchedData"]];
            mr.attributedString = attr;
            mr.editable = NO;
            [mr showForView:self.superview dismissCompletionBlock:nil];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
            
        }
        [_linksArray addObject:representedObject];
        [self.tokenField addToken:[[self class] linkTokenWithLinkObject:representedObject[@"title"] representedObj:representedObject]];
    }
    else
    {
        Tag *t = (Tag *)representedObject;
        [self.tokenField addToken:[[self class] tagTokenWithTag:t]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(!_allowMultipleSelection)
    {
        [self setSearchResultsVisible:NO];
    }
    else
    {
        [_resultsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        if(_resultsArray.count == 0) [self setSearchResultsVisible:NO];
    }
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(_modeType == VGTAGSERVICEMODE)
    {
        [_searchOperationQueue cancelAllOperations];
        [self addSearchOperationsForServices:_activeSearchServices inQueue:_searchOperationQueue];
    }
    else
    {
        if(!self.switchingMode && textField.isFirstResponder)
        {
            [self.tokenField tokenizeText];
        }
    }
    return YES;
}


#pragma mark - RESULTS TABLE DELEGATE
- (NSString *)tokenField:(TITokenField *)tokenField displayStringForRepresentedObject:(id)object
{
    Tag * tag = object;
    return tag.title;
}
-(NSString *)tokenField:(TITokenField *)tokenField searchResultStringForRepresentedObject:(id)object
{
    Tag * tag = object;
    return tag.title;
}
- (CGFloat)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (UITableViewCell *)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView cellForRepresentedObject:(id)object
{
    
    if(_modeType == VGTAGMODE)
    {
        static NSString * CellIdentifier = @"ResultsCell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.imageView.image = [[UIImage imageNamed:@"price_tag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.imageView.tintColor = kColor_WhiteButtonTint;
        }
        Tag * tag = object;
        cell.textLabel.text = tag.title;
        return cell;
    }
    
    //services mode
    
    static NSString * CellIdentifier = @"servicesCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.imageView.tintColor = [UIColor whiteColor];

    }
    
    NSDictionary * searchPackage = (NSDictionary *)object;
    
    cell.textLabel.text = searchPackage[@"title"];
    cell.detailTextLabel.text = [searchPackage[@"fetchedData"] removeHTML];
    
    NSString * serviceKey = searchPackage[@"serviceKey"];
    
    
    //cell.serviceKey = searchPackage[@"serviceKey"];
    if([serviceKey isEqualToString:@"wiki"])
    {
        //wiki-32 minicons-social-wikipedia
        [cell.imageView setImage:[UIImage imageNamed:@"wiki-32"]];
    }
    else if([serviceKey isEqualToString:@"ytube"])
    {
        [cell.imageView setImage:[UIImage imageNamed:@"ionicons-social-youtube-24"]];
    }
    else
    {
        [cell.imageView setImage:[UIImage imageNamed:@"wordnik"]];
    }
    if (nil == searchPackage[@"imgURL"])
    {
        [cell.imageView cancelImageRequestOperation];
        return cell;
    }

    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: searchPackage[@"imgURL"] ]];
    CGSize targetSize = cell.imageView.bounds.size;
    __weak UITableViewCell *weakCell = cell;
    [cell.imageView setImageWithURLRequest: urlRequest
                          placeholderImage: nil
                                   success: ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
             
             CGFloat imageHeight = image.size.height;
             CGFloat imageWidth = image.size.width;
             
             CGSize newSize = weakCell.imageView.bounds.size;
             CGFloat scaleFactor = targetSize.width / imageWidth;
             newSize.height = imageHeight * scaleFactor;
             
             UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
             [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
             UIImage *small = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
             
             dispatch_async(dispatch_get_main_queue(),^{
                 __strong UITableViewCell *strongCell = weakCell;
                 strongCell.imageView.image = small;
             });
             
         });
         
     } failure: NULL];
    
    return cell;
}





- (UIColor *)colorForSearchCode:(NSString *)code selected:(BOOL)selected
{
    if(!selected) return [UIColor darkGrayColor];
    
    /*
    if([code isEqualToString:kAPI_CODE_Wikipedia])
    {
        return [UIColor whiteColor];
    }
    
    if([code isEqualToString:kAPI_CODE_Youtube])
    {
        return [UIColor colorWithRed:0.82 green:0.06 blue:0.11 alpha:1.00];
    }
    
    if([code isEqualToString:kAPI_CODE_Wordnik])
    {
        return [UIColor orangeColor];
    }*/
    
    return [UIColor whiteColor];
    
}

- (UIBarButtonItem *)itemWithImage:(NSString *)imgName searchServiceCode:(NSString *)code
{
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imgName] style:UIBarButtonItemStylePlain target:self   action:@selector(apiServiceBtnTapped:)];
    item.title = code;
    item.tintColor = [self colorForSearchCode:code selected:[_activeSearchServices containsObject:code]];
    return item;
}
- (NSArray *)linksModeButtons
{
    if(!_linksModeButtons)
    {
        UIBarButtonItem *wiki = [self itemWithImage:@"wiki-32" searchServiceCode:kAPI_CODE_Wikipedia];
        UIBarButtonItem *        wordnik = [self itemWithImage:@"wordnik" searchServiceCode:kAPI_CODE_Wordnik];
        UIBarButtonItem *        ytube = [self itemWithImage:@"ytube-32" searchServiceCode:kAPI_CODE_Youtube];
        UIBarButtonItem * activityItem = [[UIBarButtonItem alloc] initWithCustomView:self.serviceActivityIndicator];
        self.linksModeButtons = @[wiki,wordnik,ytube, activityItem];
    }
    return _linksModeButtons;
}
- (void)apiServiceBtnTapped:(UIBarButtonItem *)sender
{
    NSMutableArray * array = [_activeSearchServices mutableCopy];
    
    BOOL active = [_activeSearchServices containsObject:sender.title];
    
    if(active)
    {
        [array removeObject:sender.title];
    }
    else
    {
        [array addObject:sender.title];
    }
    
    sender.tintColor = [self colorForSearchCode:sender.title selected:!active];
    
    
    self.activeSearchServices = [array copy];
    
    if(_activeSearchServices.count == 0)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSettings_ActiveSearchServices];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:_activeSearchServices forKey:kSettings_ActiveSearchServices];
    }
    
}
@end



