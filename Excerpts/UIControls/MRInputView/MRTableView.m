//
//  ServicesSelectorView.m
//   Renote
//
//  Created by M Raheel Sayeed on 18/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "MRTableView.h"
#import "APIServices.h"


@interface MRTableView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic) NSDictionary * dataDict;
@property (nonatomic) NSArray * displayTitleArray;
@property (nonatomic) NSString * selectedKey;
@end

@implementation MRTableView

- (instancetype)initTitle:(NSString *)title titlesAndValue:(NSDictionary *)dict selectedKey:(NSString *)selectedKey
{
    self = [self initWithFrame:CGRectMake(0, 0, 180, 200)];
    if(self)
    {
        self.title =title;
        self.dataDict = dict;
        _displayTitleArray = [dict allValues];
        _selectedKey = selectedKey;


    }
    return self;
}

- (UIView *)containerView
{
    if(_tableView) return _tableView;
    
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width, 200);
    
    self.tableView = [[UITableView alloc] initWithFrame:frame];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
    return _tableView;
}

- (BOOL)canBecomeFirstResponder
{
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _displayTitleArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"service";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];

        //[cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        //cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.textLabel.text = _displayTitleArray[indexPath.row];
    BOOL selected = ([_displayTitleArray[indexPath.row] isEqualToString:_dataDict[_selectedKey]]);
    cell.accessoryType = (selected) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
   __block NSString * value = _displayTitleArray[indexPath.row];

    
    [_dataDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isEqualToString:value])
        {
            _selectedKey = key;
            *stop = YES;
        }
    }];
}


- (id)resultObject
{
    return _selectedKey;
}

@end
