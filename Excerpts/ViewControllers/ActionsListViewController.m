//
//  ActionsListViewController.m
//   Renote
//
//  Created by M Raheel Sayeed on 19/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "ActionsListViewController.h"
#import "Workflows.h"
#import "NSString+RSParser.h"
#import "UIView+MotionEffect.h"
#import "DMScaleTransition.h"
#import "CustomActions.h"
#import "RSPullToAction.h"
#import "MRModalAlertView.h"


 NSUInteger const actionSectionIdx = 0;
NSUInteger const customSectionIdx = 1;


typedef void (^EditingCompletionBlock)(id  inputObject, BOOL saveTrack);

@interface ActionsListViewController () <WorkflowsDelegate>
{
    NSArray * _headActions;
    NSInteger xMotion;
    NSInteger yMotion;
}
@property (nonatomic, strong) EditingCompletionBlock editingCompletionBlock;
@property (nonatomic) NSArray * headWorkflowActions;
@property (nonatomic) NSArray * actionList;
@property (nonatomic) NSDictionary * workflowsDict;
@property (nonatomic, assign) BOOL sharableObjectIsString;
@property (nonatomic, strong) DMScaleTransition * scaleTransition;
@property (nonatomic, strong) NSArray * customActionsArray;

//@property (nonatomic, strong) UIScrollView * essentialButtonsView;
@property (nonatomic) WF_SHARED_OBJECT_CLASS_TYPE  sharedObjectType;
@end

@implementation ActionsListViewController
@synthesize scaleTransition;

- (instancetype)initWithShareableObject:(id)shareObject
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self)
    {
        _headActions = @[@"openin",@"clipboard", @"export", @"markdown"];
        
        self.scaleTransition = [[DMScaleTransition alloc] init];
        self.transitioningDelegate = self.scaleTransition;
        self.modalPresentationStyle = UIModalPresentationCustom;
        _sharedObject = shareObject;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        xMotion = 15;
        yMotion = 19;
    }
    return self;
}






- (void)filterActionsForClass:(Class)class
{
    [[Workflows shared] setDelegate:self];
    
//    NSMutableArray * mutableActions;
    

    if([class isSubclassOfClass:[NSString class]])
    {
        CustomActions * customs = [[CustomActions alloc] init];
        self.customActionsArray = [customs enabledActions];
        _sharedObjectType = WF_SHARED_OBJECT_CLASS_TYPE_STRING;
        self.title = ([_sharedObject topLine] == nil) ? _sharedObject : [_sharedObject topLine];
        _sharableObjectIsString = YES;
        _actionList = [[[Workflows shared] workflowsAvailableForObjectClasses:@[NSStringFromClass([NSString class])]] mutableCopy];
    }
    if([class isSubclassOfClass:[NSURL class]])
    {
        
        _sharedObjectType = WF_SHARED_OBJECT_CLASS_TYPE_URL;
        self.title = [(NSURL *)_sharedObject absoluteString];
        _sharableObjectIsString = NO;
        _actionList = [[[Workflows shared] workflowsAvailableForObjectClasses:@[NSStringFromClass([NSURL class])]] mutableCopy];

    }
    if([class isSubclassOfClass:[Note class]])
    {
        CustomActions * customs = [[CustomActions alloc] init];
        self.customActionsArray = [customs enabledActions];

        _sharedObjectType = WF_SHARED_OBJECT_CLASS_TYPE_CUSTOM;
        NSString * topLine = [[(Note *)_sharedObject text] topLine];
        self.title = [NSString stringWithFormat:@"%@",  (topLine) ? topLine : [(Note *)_sharedObject text]];
        _sharableObjectIsString = NO;
        _actionList = [[[Workflows shared] workflowsAvailableForObjectClasses:@[NSStringFromClass([NSString class])]] mutableCopy];
    }
    if([class isSubclassOfClass:[NSArray class]])
    {
        _sharedObjectType = WF_SHARED_OBJECT_CLASS_TYPE_ARRAY_OF_FILES;
        //array of excerpts
        self.title = [NSString stringWithFormat:@"Export %lu note(s)", (unsigned long)[(NSArray *)_sharedObject count]];
        _sharableObjectIsString = NO;
        _actionList = [[[Workflows shared] workflowsAvailableForObjectClasses:@[NSStringFromClass([NSArray class])]] mutableCopy];
    }

    //_actionList = [mutableActions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF.scheme IN %@)", _headActions]];
    //_headWorkflowActions = [mutableActions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.scheme IN %@", _headActions]];
    
    //_actionList = mutableActions;

    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)loadView
{
    [super loadView];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.clearsSelectionOnViewWillAppear = YES;
    self.view.backgroundColor = self.tableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
    self.tableView.separatorColor = [UIColor darkGrayColor];
    
    

    
}
- (void)closeSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
static CGFloat essentialButtonEdge = 60.f;

- (void)addButtonsToScrollView:(NSArray *)buttons
{
    if(buttons.count == 0) return;
    static CGFloat padding = 14.f;
    
    __block CGFloat startingX = padding;
    
    CGFloat containerHt = _essentialButtonsView.bounds.size.height;
    __block CGFloat topY = (containerHt/2) - (essentialButtonEdge/2) + 10.f;
    [buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         WorkflowAction * wfa = (WorkflowAction *)obj;
         UIButton * button = [[self class] essentialButtonWithTitle:wfa.actionTitle];
         [button setImage:[UIImage imageNamed:wfa.scheme] forState:UIControlStateNormal];
         [button addTarget:self action:@selector(headerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
         CGRect frame = button.frame;
         button.tag = idx;
         frame.origin.x = startingX;
         frame.origin.y = topY;
         startingX += frame.size.width + padding;
         button.frame = frame;
         
         [self.essentialButtonsView addSubview:button];
     }];
    
    [self.essentialButtonsView setContentSize:CGSizeMake(startingX + padding,containerHt)];
}


+ (UIButton *)essentialButtonWithTitle:(NSString *)title
{
    CGSize btnSize = CGSizeMake(essentialButtonEdge, essentialButtonEdge);
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = (CGRect){CGPointZero, btnSize};
    //button.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.4];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
    UIImage *bg = [[UIImage imageNamed:@"buttonOverlay"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setBackgroundImage:bg forState:UIControlStateNormal];
    button.layer.borderColor = [[UIColor grayColor] CGColor];
    return button;
}
 
 -(void)headerButtonAction:(id)sender
 {
 __weak ActionsListViewController * wS = self;
 WorkflowAction * workflowAction = _headWorkflowActions[[sender tag]];
 [[Workflows shared] startWorkflows:@[workflowAction] completion:^(id inputObject, BOOL success)
 {
 [wS dismissViewControllerAnimated:YES completion:nil];
 
 }];
 
 }
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    RSPullToAction *closeAc = [self.tableView addPullToActionPosition:RSPullActionPositionTop actionHandler:^(RSPullToAction * v)
                               {
                                   [weakSelf closeSelf];
                               }];
    closeAc.text  = @"Back";
    closeAc.enablePullToAction = NO;
    closeAc.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf filterActionsForClass:[_sharedObject class]];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           /*
                           NSMutableArray * arr = [NSMutableArray new];
                           for(WorkflowAction * wf  in _headWorkflowActions)
                           {
                               [arr addObject:wf];
                           }
                           [self addButtonsToScrollView:[arr copy]];*/
                           
                           __strong ActionsListViewController *strongSelf = weakSelf;
                           //[strongSelf.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){0,2}] withRowAnimation:UITableViewRowAnimationAutomatic];
                           [strongSelf.tableView reloadData];
                     
                       });
    });
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView enableAllRSViewPullActionViews:YES];
}

- (void)dealloc
{
    [self.tableView enableAllRSViewPullActionViews:NO];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case actionSectionIdx:
            return [_actionList count];
            break;
        case customSectionIdx:
            return _customActionsArray.count;
        default:
            return _headWorkflowActions.count;
            break;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if(section==0)
    {
        return self.title;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if(indexPath.section == customSectionIdx) return;

    
     CGSize const itemSize = CGSizeMake(32, 32);
    if(CGSizeEqualToSize(cell.imageView.image.size, itemSize))
    {
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        return;
    }
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell1";
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell addMotionEffectsForX_Max:@(xMotion) X_Min:@(-xMotion) Y_Max:@(yMotion) Y_Min:@(-yMotion)];
        cell.backgroundColor = [UIColor colorWithWhite:0.35 alpha:0.3];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor lightTextColor];
        cell.imageView.tintColor = [UIColor whiteColor];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.imageView setBounds:CGRectMake(0, 0, 32, 32)];
        cell.imageView.layer.cornerRadius = 7.f;
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.clipsToBounds = YES;
    }
    
    if(indexPath.section == actionSectionIdx)
    {
        WorkflowAction * action = _actionList[indexPath.row];
        cell.textLabel.text = action.title;//[NSString stringWithFormat:@"%@ %@", action.identifier, action.actionTitle];
        
        UIImage * img = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", action.scheme, action.action]];
        
        cell.imageView.image = (img) ? img : [UIImage imageNamed:action.scheme];
        
        cell.imageView.backgroundColor = [UIColor clearColor];

    }
    
    else  if(indexPath.section == customSectionIdx)
    {
        NSDictionary * dict = _customActionsArray[indexPath.row];
//        cell.detailTextLabel.text = dict[urlString];
        cell.textLabel.text  = dict[kActionTitle];
        cell.imageView.backgroundColor = [UIColor lightTextColor];
        cell.imageView.image = nil;

        
    }

    
    
   
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak ActionsListViewController * wS = self;

    if(indexPath.section == customSectionIdx)
    {
        NSDictionary * dict = _customActionsArray[indexPath.row];
        WorkflowAction * wfaction = [[WorkflowAction alloc] initWithIdentifier:dict[kActionTitle] url_string:dict[kURLString]];
        wfaction.actionTitle = dict[kActionTitle];
        if(![wfaction canOpenURL])
        {
            [MRModalAlertView showMessage:@"The URL for this custom action could not be opened." title:@"Bug" overView:self.view];
            
            return;
        }
        [[Workflows shared] startWorkflows:@[wfaction] completion:nil];
    }
    else if(indexPath.section == actionSectionIdx)
    {
        WorkflowAction * workflowAction = _actionList[indexPath.row];
        [[Workflows shared] startWorkflows:@[workflowAction] completion:^(id inputObject, BOOL success)
         {
             [wS dismissViewControllerAnimated:YES completion:nil];
             
         }];
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}


 


-(id)exportObjectForWorkflowAction:(WorkflowAction *)workflowAction
{
    return [_sharedObject copy];
    
    if([workflowAction.scheme isEqualToString:@"export"])
    {
        if([workflowAction.action isEqualToString:@"txt"])
            return _sharedObject;
        else
            return @[_sharedObject];
    }
    
    return nil;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    return;
    NSLog(@"%f %f", scrollView.contentInset.top, scrollView.contentOffset.y);
    if(scrollView.contentOffset.y < -120.f || scrollView.contentOffset.y > 120.f)
  
        [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.tableView reloadData];
}

-(void)doWorkflowActions:(NSArray *)actions completed:(EditingCompletionBlock)completionBlock{
    
   // [[Workflows shared] setDelegate:self];
   // [[Workflows shared] startWorkFlowsWithTitles:actions];
   // self.editingCompletionBlock = completionBlock;
    
}

-(id)dataObjectForWorkflow:(WorkflowAction *)workflow{
    
    NSString * stext;


    if(_sharedObjectType == WF_SHARED_OBJECT_CLASS_TYPE_STRING)
    {
        stext = _sharedObject;
    }
    else if (_sharedObjectType == WF_SHARED_OBJECT_CLASS_TYPE_CUSTOM)
    {
        stext = [(Note *)_sharedObject text];
    }
    else if (_sharedObjectType == WF_SHARED_OBJECT_CLASS_TYPE_URL)
    {
        stext = [(NSURL *)_sharedObject absoluteString];
    }
    
    if([workflow.scheme isEqualToString:@"clipboard"])
    {
        return stext;
    }
    
    
    
    
    
    
    
 
    
    NSMutableDictionary * reps;
    
    
  
    
    
    
    if ([workflow replacements]) {
        reps = [[workflow replacements] mutableCopy];
    }
    else
    {
        reps = [[workflow requiredParameters] mutableCopy];
        DLog(@"%@", [[workflow optionalParameters] description]);
        [reps addEntriesFromDictionary:[workflow optionalParameters]];
    }
    
    DLog(@"%@", reps.description);
    
    for(NSString * key in reps.allKeys)
    {
        id value = reps[key];
        if([value isKindOfClass:[NSString class]])
        {
            
            if([value isEqualToString:@"[[note]]"])
            {
                [reps setObject:stext forKey:key];
                
            }else if ([value rangeOfString:@"[[title]]"].location != NSNotFound)
            {
                NSString * topLine = [stext topLine];
                if(topLine)
                {
                    reps[key] = [value stringByReplacingOccurrencesOfString:@"[[title]]" withString:topLine];
                    
                }else
                {
                    [reps removeObjectForKey:key];
                }
                
                
                
            }else if([value isEqualToString:@"[[markdown-text]]"])
            {
                [reps setObject:stext forKey:key];
            }
            else if ([value isEqualToString:@"[[url]]"])
            {
                [reps setObject:stext forKey:key];
            }
            else if ([value isEqualToString:@"[[filename]]"])
            {
                reps[key] = [stext rs_sanitizeFileNameStringWithExtension:@"txt"];
            }
            
            
        }
    }
//    DLog(@"%@", reps.description);
    return [reps copy];
}
-(void)workflowDidEnd:(WorkflowAction *)wfAction withSuccessParam:(NSString *)successURLParam
{
   
    
    
    NSUInteger idx = [_actionList indexOfObject:wfAction];
    NSIndexPath * ip = [NSIndexPath indexPathForRow:idx inSection:0];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:ip];
    
    if([successURLParam rangeOfString:@"success"].location != NSNotFound)
    {

        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }
}
-(void)finishedExecutingAllWorkflows{

}
-(void)workflowWillStart:(WorkflowAction *)workflow
{

    
}


@end
