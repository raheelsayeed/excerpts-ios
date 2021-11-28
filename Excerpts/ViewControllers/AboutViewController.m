//
//  AboutViewController.m
//   Renote
//
//  Created by M Raheel Sayeed on 11/05/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "AboutViewController.h"
#import "SVWebViewController.h"
#import "ActionMethods.h"
#import <StoreKit/StoreKit.h>
#import "UIView+MotionEffect.h"

@interface AboutViewController () <SKStoreProductViewControllerDelegate>
{
    NSArray * array;
}

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    self.title = @"About";
    [super viewDidLoad];
    self.tableView.backgroundColor = kColor_MainViewBG;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    array = @[@"Visit renoteapp.com", @"Rate this App, Please..", @"Gift app..",  @"Acknowledgements"];
    
    int m = 9;
    [self.hoverImg addMotionEffectsForX_Max:@(m) X_Min:@(-m) Y_Max:@(m) Y_Min:@(-m)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return array.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return  [NSString stringWithFormat:@"Version %@ (%@)\nThank you for purchasing RENOTE.\nPlease consider reviewing on App Store. It was made by just one guy.",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * iden = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden forIndexPath:indexPath];
    cell.textLabel.text = array[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
            case 0:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.renoteapp.com"]];
            break;
        case 1:
        {
            NSString * iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=955123296"; //955123296
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iOS7AppStoreURLFormat]];

        }
            break;
        case 2:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-appss://itunes.apple.com/us/app/id955123296?mt=8"]];
        }
            break;
        case 3:
        {
            SVWebViewController * web = (SVWebViewController * )[ActionMethods webControllerForMarkdownFilename:@"Acknowledgements" cssFileName:@"markdown-whitebg" varReplacements:@{@"[[editorFontName]]": @"sans-serif"}];
            web.showHTMLActionButton = NO;
            [self.navigationController pushViewController:web animated:YES];
        }
            break;
            
        default:
        {

        }
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAppWithIdentifier:(NSString *)identifier
{
        SKStoreProductViewController *controller = [[SKStoreProductViewController alloc] init];
        controller.delegate = self;
        [controller loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : identifier}
                              completionBlock:NULL];
        [self presentViewController:controller animated:YES completion:nil];
}

@end
