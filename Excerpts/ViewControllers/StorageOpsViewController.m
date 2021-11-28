//
//  StorageOpsViewController.m
//   Renote
//
//  Created by M Raheel Sayeed on 04/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "StorageOpsViewController.h"
#import "DataManager.h"
#import "MRModalAlertView.h"
#import "IOAction.h"
#import "DatastoreSyncManager.h"
#import "MRModalAlertView.h"
#import "ActionMethods.h"
#import "CircleIndicatorView.h"
@interface StorageOpsViewController () <UIAlertViewDelegate, UIDocumentInteractionControllerDelegate>
{
    UIColor * normalTintColor;
    BOOL dropboxLinkHasChanged;
}
@property (nonatomic)     CircleIndicatorView * syncIndicator;
@property (nonatomic, assign, getter = dropboxIsLinked) BOOL datastoreIsLinked;
@property (nonatomic, strong) NSArray * arrayOfCells;
@property (nonatomic) UIDocumentInteractionController * documentInteractionController;
@property (nonatomic) NSManagedObjectContext * managedObjectContext;
@property (nonatomic) UIAlertView *waitAlertView;
@end

static NSString *const kTitleKey = @"title";
static NSString *const descKey = @"desc";
static NSString *const colorKey = @"color";
static NSString *const subtitleKey = @"subtitle";
static NSString *const key = @"key";
static NSString *const kIndicator = @"in";
static NSString * const kAccessoryView = @"av";

@implementation StorageOpsViewController



- (NSArray *)arrayOfCells
{
    if(_arrayOfCells) return _arrayOfCells;
    
    DBAccount * a = [[DBAccountManager sharedManager] linkedAccount];
    BOOL linked = [a isLinked];

    
    NSDictionary * linkCell = (linked) ?
    @{kTitleKey : @"Unlink Dropbox",
      descKey  : @"Warning: Unlinking Dropbox will disable cloud sync & storage",
      colorKey : @2,
      subtitleKey: (a.info.displayName) ? a.info.displayName : a.userId,
      key     : @"unlinkDropbox"} :
    
    @{kTitleKey : @"Link Dropbox",
      descKey  : @"RENOTE uses Dropbox for Syncing & Backup.\nNote: RENOTE does NOT save its data (tags or notes) in text files within a Dropbox folder, we only make use of Dropbox backend. ",
      colorKey : @1,
      kIndicator: @1,
      key      : @"linkDropbox"};
    
    
    NSDictionary * syncHelp = @{kTitleKey : @"More about Dropbox Sync",
                                key      : @"syncHelp",
                                kIndicator: @1,
                                colorKey : @0};
    
    

    
    NSMutableArray * cells= [@[ linkCell,
  
                                @{kTitleKey : @"Export all Notes",
                                    descKey  : @"All notes on this device are exported as text files into  zip archive.",
                                    colorKey : @1,
                                    key : @"exportAllNotes"},

                               
  
                               @{kTitleKey : @"Delete All Notes",
                                 descKey  : @"Warning: Deletes all Notes permanently on Device And Dropbox (if sync is enabled)",
                                 colorKey : @2,
                                 key      : @"deleteAllNotes"},
                               //These changes will be reflect on all devices running Excerpts linked with dropbox
  
                               @{kTitleKey : @"Delete All Tags",
                                 descKey  : @"Warning: Deletes all Tags permanently on Device And Dropbox (if sync is enabled)",
                                 colorKey : @2,
                                 key      : @"deleteAllTags"},
                               //These changes will be reflect on all devices running Excerpts linked with dropbox
                               
                               ] mutableCopy];
    
    if(linked)
    {
        if(!_syncIndicator)
        {
            self.syncIndicator = [[CircleIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        }
        BOOL syncEnabled = [[DataManager sharedInstance] isSyncEnabled];
        
        _syncIndicator.on = syncEnabled;

        NSDictionary * dict;
        if(syncEnabled)
        {
            dict = @{kTitleKey: @"Stop Sync & Backup",
                     descKey : @"Stops sync and backup. Dropbox will remain linked",
                     colorKey : @2,
                     key      : @"stopsync",
                     subtitleKey: @"Status: ON  ",
                     kAccessoryView: _syncIndicator };
        }else
        {
            dict = @{kTitleKey : @"Enable Sync & Backup",
                     descKey  : @"Syncs across other devices running RENOTE and linked with this account",
                     colorKey : @1,
                     key      : @"startsync",
                     subtitleKey: @"Status: OFF  ",
                     kAccessoryView:_syncIndicator};
        }
        [cells insertObject:dict atIndex:0];
    }
    
    [cells insertObject:syncHelp atIndex:1];

    
    self.arrayOfCells = [cells copy];
    
    return _arrayOfCells;
}
- (UIColor *)fontColorForCode:(NSNumber *)code
{
    switch ([code integerValue]) {
        case 0:
            return [UIColor blackColor];
            break;
        case 1:
            return normalTintColor;
            break;
        case 2:
            return [UIColor redColor];
            break;
        default:
            break;
    }
    
    return [UIColor blackColor];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(dropboxLinkHasChanged)
    {
        _arrayOfCells = nil;
        [self.tableView reloadData];
        dropboxLinkHasChanged = NO;
    }
    
    
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dropboxLinkHasChanged = NO;
    self.managedObjectContext = [[DataManager sharedInstance] managedObjectContext];
    self.title = @"Storage & Sync";
    normalTintColor = self.view.tintColor;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    

    
    

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)appDidBecomeActive:(NSNotification*)note
{
    if(dropboxLinkHasChanged)
    {
        _arrayOfCells = nil;
        [self.tableView reloadData];
        dropboxLinkHasChanged = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arrayOfCells.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    NSDictionary * d = self.arrayOfCells[indexPath.section];
    
    cell.textLabel.textColor = [self fontColorForCode: d[colorKey]];
    cell.textLabel.text = d[kTitleKey];
    cell.detailTextLabel.text = d[subtitleKey];
    cell.accessoryView = d[kAccessoryView];
    cell.accessoryType = (d[kIndicator]) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    

    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.arrayOfCells[section][descKey];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * code = _arrayOfCells[indexPath.section][key];
    
    if(!code) return;
    
    [self performSelector:NSSelectorFromString(code)];
    
}

- (void)syncHelp
{
    UIViewController * webController  = [ActionMethods webControllerForMarkdownFilename:@"Sync_And_Backup" cssFileName:@"markdown-whitebg" varReplacements:@{@"[[editorFontName]]": @"sans-serif"}];
    [(SVWebViewController *)webController  setShowHTMLActionButton:NO ];
    [self.navigationController pushViewController:webController animated:YES];

}

- (void)stopsync
{
    MRModalAlertView * alert = [[MRModalAlertView alloc] initWithTitle:@"Stop Syncing" mesage:@"Warning: This will stop syncing and any further actions of adding, updating or deleting notes and/or tags will not be synced and stay within this device. Are you sure you want to continue?"];
    [alert showForView:self.navigationController.view selectorBlock:^(BOOL result) {
        if(result)
        {
            _waitAlertView = nil;
            self.waitAlertView.title = @"Starting sync...";
            [self.waitAlertView show];
            [[DataManager sharedInstance] setSyncEnabled:NO];
    
            _arrayOfCells = nil;
            [self.tableView reloadData];
    
            [self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
        }
    }];

    
}
- (void)startsync
{
    _waitAlertView = nil;
    self.waitAlertView.title = @"Starting sync...";
    [self.waitAlertView show];

    [[DataManager sharedInstance] setSyncEnabled:YES];
    
    _arrayOfCells = nil;
    [self.tableView reloadData];
    
    [self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
}
- (void)linkDropbox
{
    dropboxLinkHasChanged = YES;
    [[DBAccountManager sharedManager] linkFromController:self];

}
- (BOOL)localStoreData
{
    
    if(!_managedObjectContext)
    {
//        NSLog(@"managedobjeccontext is nil");
        return NO;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (!results) {
            DLog(@"Fetch error: %@", error);
        }
        if ([results count] == 0) {
            return NO;
        }
        return YES;
}



- (BOOL)dropboxIsLinked
{
    return ([[[DBAccountManager sharedManager] linkedAccount] isLinked]);
}

- (UIAlertView*)waitAlertView
{
    if(!_waitAlertView)
    {
        self.waitAlertView = [[UIAlertView alloc] initWithTitle:@"Exporting, Please wait.." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    }
    return _waitAlertView;
}
- (void)deleteAllNotes
{
    MRModalAlertView * alert = [[MRModalAlertView alloc] initWithTitle:@"Delete Notes" mesage:@"Warning: This will permanently delete All Notes and their cached links.\n\nIf Sync is ON, these deletions will be reflected in  Dropbox and further propogate to all other devices that run RENOTE (with Sync ON). Turning Sync OFF BEFORE deleting Notes will remove them from this device only.\n\nPlease note: No files in Dropbox are affected. RENOTE removes records within the RENOTE-Dropbox linked space.\n\nProceed with deletions?"];
    
    [alert showForView:self.navigationController.view selectorBlock:^(BOOL result) {
        if(result)
        {
            _waitAlertView = nil;
            self.waitAlertView.title = @"Deleting All Notes";
            [[DataManager sharedInstance] deleteAllObjectsForEntityName:@[@"Note", @"Link", @"CachedLinkData"] useMainContextForSync:YES];
            [self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
        }
    }];
}
- (void)deleteAllTags
{
    MRModalAlertView * alert = [[MRModalAlertView alloc] initWithTitle:@"Delete Tags" mesage:@"Warning: This will permanently delete All Tags.\n\nIf Sync is ON, these deletions will be reflected in Dropbox and further propogate to all other devices that run RENOTE (with Sync ON). Turning Sync OFF BEFORE deleting Tags will remove them from this device only.\n\nPlease note: No files in Dropbox are affected. RENOTE removes records within the RENOTE-Dropbox linked space.\n\nProceed with deletions?"];
    __weak typeof(self) weakSelf = self;
    [alert showForView:self.navigationController.view selectorBlock:^(BOOL result) {
        if(result)
        {
            weakSelf.waitAlertView = nil;
            weakSelf.waitAlertView.title = @"Deleting All Tags";
            [[DataManager sharedInstance] deleteAllObjectsForEntityName:@[@"Tag"] useMainContextForSync:YES];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSettings_fvc_selectedTagsIDs];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectedTagsDidChange" object:nil];
            
            [weakSelf.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
        }
    }];
}
- (void)unlinkDropbox
{
    BOOL linked = [[[DBAccountManager sharedManager] linkedAccount] isLinked];
    
    if(!linked)
    {
        _arrayOfCells = nil;
        [self.tableView reloadData];
        return;
    }

    MRModalAlertView * alert = [[MRModalAlertView alloc] initWithTitle:@"Unlink & Stop Syncing" mesage:@"Warning: Unlinking Dropbox will disable syncing, Any further actions of adding, updating or deleting notes and/or tags will not be synced and stay within this device. Are you sure you want to continue?"];
    __weak typeof(self) weakSelf = self;
    
    [alert showForView:self.navigationController.view selectorBlock:^(BOOL result) {
        if(result)
        {
            dropboxLinkHasChanged = YES;
            _waitAlertView = nil;
            weakSelf.waitAlertView.title = @"Unlinking Dropbox and Turning Sync off";
            [weakSelf.waitAlertView show];
           
            [[DataManager sharedInstance] stopDbxFolderSync];
            [[DataManager sharedInstance] setSyncEnabled:NO];
            [[[DBAccountManager sharedManager] linkedAccount] unlink];
            _arrayOfCells = nil;
            [weakSelf.tableView reloadData];
            [weakSelf.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
        }
    }];
  
}

- (void)deleteAllRecordsFromAllDatastores
{
    [[DataManager sharedInstance] deleteAllObjectsForEntityName:@[@"Tag", @"Note"] useMainContextForSync:YES];
    [[[DataManager sharedInstance] datastoreSyncManager ]  deleteDatastores];

    
    //[[[DataManager sharedInstance] tagSyncManager] deleteDatastoreRecords];
    //[[[DataManager sharedInstance] datastoreSyncManagers] makeObjectsPerformSelector:@selector(deleteDatastoreRecords)];
}


- (void)deleteDataFromLocalDevice
{
    [[DataManager sharedInstance] setSyncEnabled:NO];
    [[DataManager sharedInstance] deleteAllObjectsForEntityName:@[@"Note", @"Tag", @"Link", @"CachedLinkData"] useMainContextForSync:YES];
}

- (void)exportAllNotes
{
    MRModalAlertView * modal = [[MRModalAlertView alloc] initWithTitle:@"Export Notes" mesage:@"All notes are exported as text files in a zipped archive. Proceed?"];
    [modal showForView:self.navigationController.view selectorBlock:^(BOOL result) {
        if(result)
        {
      
            
            self.waitAlertView.title = @"Exporting all Notes, please wait...";
            [self.waitAlertView show];
            
            NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
            NSError * error;
            NSArray *allObjects = [[[DataManager sharedInstance] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
            
            IOAction * exportZipArchive = [[IOAction alloc] initWithExportObject:allObjects exportActionKey:@"zip"];
            [exportZipArchive startExportWithCompletion:^(id exportedObject, BOOL success){
                [_waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
                if(success)
                {
                    [self openInInteraction:exportedObject];
                }
            }];
            
        }
    }];
    
    
   
}


- (BOOL)openInInteraction:(NSString *)attachmentPath
{
    NSURL * target = [NSURL fileURLWithPath:attachmentPath];

    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL: target];
    _documentInteractionController.delegate = self;
    _documentInteractionController.name = @"Renote Archive";
    return [_documentInteractionController  presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
}
- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller canPerformAction:(SEL)action
{
    return NO;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    
}
- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    _documentInteractionController = nil;
}
- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller
{
    if([[NSFileManager defaultManager] removeItemAtURL:controller.URL error:nil])
    {
        _documentInteractionController = nil;
    }
}
@end
