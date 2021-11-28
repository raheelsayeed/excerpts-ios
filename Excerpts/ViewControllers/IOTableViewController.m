//
//  IOTableViewController.m
//   Renote
//
//  Created by M Raheel Sayeed on 04/12/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "IOTableViewController.h"

@interface IOTableViewController ()

@end

@implementation IOTableViewController

- (instancetype)initWithInputObject:(id)inputObject
{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self)
    {
        self.hasChanges = NO;
        [self parseInputObject:inputObject];
    }
    return self;
}
- (void)parseInputObject:(id)inputObj
{
    if([inputObj isKindOfClass:[NSArray class]])
    {
        _dataArray = [inputObj mutableCopy];
    }
    else
    {
        self.dataArray = [@[@"Subclass the Parsing.."] mutableCopy];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kColor_SVT;
    [self setEditing:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
}


- (void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if(_completionBlock)
        {
            _completionBlock([self parsedOutput], _hasChanges);
            _completionBlock = nil;
        }
    }];
}
- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        if(_completionBlock)
        {
            _completionBlock(nil, NO);
            _completionBlock = nil;

        }
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)parsedOutput
{
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * iden = @"datacell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
        cell.detailTextLabel.numberOfLines = 3;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
    }
    
    cell.detailTextLabel.text = _dataArray[indexPath.row];
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}



/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}




- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}




@end
