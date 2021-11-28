//
//  ReorderViewController.m
//   Renote
//
//  Created by M Raheel Sayeed on 04/12/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "ReorderViewController.h"
#import "NSString+RSParser.h"
#import "MRModalAlertView.h"
#import "ActionMethods.h"
@interface ReorderViewController ()

@end

@implementation ReorderViewController

- (void)viewDidLoad {
    self.navigationController.navigationBar.tintColor = kColor_Dark_Content_tint;

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;


    [super viewDidLoad];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    self.title = @"Arrange Paragraphs";
    
}

- (void)parseInputObject:(id)inputObj
{
    self.dataArray = [[inputObj rs_paragraphs] mutableCopy];
    
    
    
}
- (id)parsedOutput
{
    return [self.dataArray componentsJoinedByString:@"\n\n"];
}


- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
 

}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak NSString * string = [self.dataArray objectAtIndex:indexPath.row];
    MRModalAlertView * alert = [[MRModalAlertView alloc] initWithTitle:@"Copy to clipboard?" mesage:string];
    
    
    [alert showForView:self.navigationController.view selectorBlock:^(BOOL result) {
        if(result)
        {
            [ActionMethods addToClipboard:string];
        }
    }];
}



 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         
         self.hasChanges = YES;
 // Delete the row from the data source
         [self.dataArray removeObjectAtIndex:indexPath.row];

         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     
     }
     
 }



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    self.hasChanges = YES;
    id object = [self.dataArray objectAtIndex:fromIndexPath.row];
    [self.dataArray removeObjectAtIndex:fromIndexPath.row];
    [self.dataArray insertObject:object atIndex:toIndexPath.row];
}




- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}




 
@end
