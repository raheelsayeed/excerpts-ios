//
//  DebugDatastoreController.m
//   Renote
//
//  Created by M Raheel Sayeed on 30/08/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "DebugDatastoreController.h"
#import "DataManager.h"
#import "Note.h"
#import "MRModalAlertView.h"

@interface DebugDatastoreController ()

@property (nonatomic) NSArray * data;
@property (nonatomic) DBDatastoreManager * manager;

@end

@implementation DebugDatastoreController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)setuptoolbar
{
    UIBarButtonItem * addStore = [[UIBarButtonItem alloc] initWithTitle:@"+notestore" style:UIBarButtonItemStylePlain target:self action:@selector(addNoteStore)];
    UIBarButtonItem * unsynced = [[UIBarButtonItem alloc] initWithTitle:@"UnsyncedCount" style:UIBarButtonItemStylePlain target:self action:@selector(unsynced)];
    
    self.toolbarItems = @[addStore, unsynced];
    
}
- (void)unsynced
{
    NSManagedObjectContext * moc = [[DataManager sharedInstance] managedObjectContext];
    NSUInteger allNotes = [Note objectCountInManagedObjectContext:moc];
    NSUInteger unsyncedNotes = [Note unsyncedObjectCountWithMOC:moc];
    NSUInteger allTags = [Tag objectCountInManagedObjectContext:moc];
    NSUInteger unsyncedTags = [Tag unsyncedObjectCountWithMOC:moc];
    
    [MRModalAlertView showMessage:[NSString stringWithFormat:@"Notes\nUnsynced / All = %lu / %lu\n\nTags\nUnsynced / All = %lu / %lu", (unsigned long)unsyncedNotes, (unsigned long)allNotes, (unsigned long)unsyncedTags, (unsigned long)allTags] title:@"LOCAL STATE" overView:self.view];
}
- (void)addNoteStore
{
    DBError * error = nil;
    DBDatastore * notestore = [_manager openOrCreateDatastore:@"notestore_1" error:&error];
    notestore.title = @"Note";
    if(error)
    {
        NSLog(@"%@", error.description);
    }
    
    
    
    
}
- (void)deleteNoteStoreWithID:(NSString *)notestoreID
{
    [[DataManager sharedInstance] setSyncEnabled:NO];
    
    DBError * error = nil;
//    DBDatastore  *store = [_manager openDatastore:notestoreID error:&error];
//    [store close];
    [_manager deleteDatastore:notestoreID error:&error];
    
//    [[DataManager sharedInstance] setSyncEnabled:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
  
    [self setuptoolbar];
    
    self.title = @"Debug Datastore";
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if(![[DBAccountManager sharedManager] linkedAccount]) return;
    
    
    self.manager = [DBDatastoreManager sharedManager];
    
    [self reloadData];

    __weak typeof(self) weakSelf = self;
    
    [_manager addObserver:self block:^{
        [weakSelf reloadData];
    }];

}
- (void)reloadData
{
    DBError * error = nil;
    self.data = [_manager listDatastores:&error];
    if(error)
    {
        self.data = nil;
    }
    [self.tableView reloadData];
}

- (void)dealloc
{
    [_manager removeObserver:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString * iden = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:iden];
    }
    
    if(!_data) return cell;

    DBDatastoreInfo * info = _data[indexPath.section];
    DBDatastore * datastore = [[DBDatastoreManager sharedManager] openDatastore:info.datastoreId error:nil];
    
    cell.textLabel.text = info.datastoreId;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: Count=%lu", info.title, (unsigned long)datastore.recordCount-1];
    

    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DBDatastoreInfo * info = _data[indexPath.section];
        
        [self deleteNoteStoreWithID:info.datastoreId];
        
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
