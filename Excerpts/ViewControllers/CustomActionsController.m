//
//  CustomActionsController.m
//   Renote
//
//  Created by M Raheel Sayeed on 23/05/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "CustomActionsController.h"
#import "MRInputAlertView.h"
#import "MRInputTextFieldView.h"
#import "MRTextInputView.h"


@interface CustomActionsController ()
@property (nonatomic) CustomActions * customActions;
@end


@implementation CustomActionsController

+ (UIViewController *)customActionsController
{
    CustomActionsController * customActionsController = [[CustomActionsController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController * n = [[UINavigationController alloc] initWithRootViewController:customActionsController];
    return n;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Actions";
    self.navigationItem.rightBarButtonItems =@[self.editButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)]];
    self.customActions = [[CustomActions alloc] init];
    [[self tableView] reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_customActions saveActions];
}


- (void)showURLEditorWithCustomActionIndex:(NSNumber*)indexNumber
{
    
    __weak CustomActionsController * weakSelf = self;
    __weak NSNumber * weakIndexNumber = indexNumber;
    
    MRTextInputView * textV = [[MRTextInputView alloc] initWithFrame:CGRectMake(0, 0, 280, 400)];
    textV.buttonTitles = @[@"OK", @"Cancel", @"Paste"];
    textV.destructiveButtonIndex = 1;
    /*
     Paste Action is done within MRTextInputView
     */
    if(indexNumber)
    {
        textV.title = _customActions.actions[indexNumber.integerValue][kActionTitle];
        textV.text = _customActions.actions[indexNumber.integerValue][kURLString];
    }
    
    
    [textV showForView:self.navigationController.view dismissCompletionBlock:^(MRTextInputView *textAlertView, int buttonIndex)
     {
         
         if(textAlertView.destructiveButtonIndex == buttonIndex)
             return ;
         
         NSString * urlTitle = textAlertView.titleTextField.text;
         NSString * urlpath = textAlertView.textView.text;
         
         if(urlpath.length > 3 && urlTitle.length > 3)
         {
             if([NSURL URLWithString:urlpath])
             {

                 if(weakIndexNumber)
                 {
                     [[weakSelf customActions] editActionAtIndex:weakIndexNumber.integerValue title:urlTitle url:urlpath];
                     [[weakSelf tableView] reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakIndexNumber.integerValue inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                 }
                 else
                 {
                 
                     [[weakSelf customActions] addActionWithTitle:urlTitle url:urlpath];
                     [[weakSelf tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[weakSelf.customActions.actions count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                      
                 }
             }
             
         }
         
     }];
    
}
- (void)showURLEditorWithTitle:(NSString *)title path:(NSString *)urlPath
{
    
}
- (void)addAction:(id)sender
{
    [self showURLEditorWithCustomActionIndex:nil];

}
- (void)customAlert:(id)sender
{
    UIView *myCustomView = [[UIView alloc] initWithFrame:CGRectMake(20, 100, 280, 300)];
    [myCustomView setBackgroundColor:[UIColor colorWithRed:0.9f green:0.0f blue:0.0f alpha:0.8f]];
    [myCustomView setAlpha:0.0f];
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dismissButton addTarget:self action:@selector(dismissCustomView:) forControlEvents:UIControlEventTouchUpInside];
    [dismissButton setTitle:@"Close" forState:UIControlStateNormal];
    [dismissButton setFrame:CGRectMake(20, 250, 240, 40)];
    [myCustomView addSubview:dismissButton];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, 240, 35)];
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    [myCustomView addSubview:textField];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 75, 240, 150)];
    [myCustomView addSubview:textView];
    
    [self.view addSubview:myCustomView];
    
    [UIView animateWithDuration:0.2f animations:^{
        [myCustomView setAlpha:1.0f];
    }];
}

- (void)dismissCustomView:(UIButton *)sender
{
    [UIView animateWithDuration:0.2f animations:^{
        [sender.superview setAlpha:0.0f];
    }completion:^(BOOL done){
        [sender.superview removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _customActions.actions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIden = @"actioncell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIden];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIden];
        //cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:[UIFont smallSystemFontSize]];
        UISwitch * onControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        onControl.onTintColor = kColor_Orange;
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = onControl;
        [onControl addTarget:self action:@selector(switchDidChange:) forControlEvents:UIControlEventValueChanged];
        cell.editingAccessoryType = UITableViewCellAccessoryNone;
    }
    NSDictionary * dict  = _customActions.actions[indexPath.row];
    cell.textLabel.text = dict[kActionTitle];
    cell.detailTextLabel.text = dict[kURLString];
    [(UISwitch *)cell.accessoryView  setOn:[dict[kActionEnabled] boolValue]];
    [(UISwitch *)cell.accessoryView setTag:indexPath.row];
    
    return cell;
}
- (void)switchDidChange:(UISwitch *)switcher
{
    [_customActions enableAction:switcher.on atIndex:switcher.tag];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_customActions removeActionAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [_customActions moveItemFrom:fromIndexPath.row to:toIndexPath.row];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showURLEditorWithCustomActionIndex:@(indexPath.row)];
}

@end
