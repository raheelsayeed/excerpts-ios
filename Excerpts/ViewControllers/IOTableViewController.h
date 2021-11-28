//
//  IOTableViewController.h
//   Renote
//
//  Created by M Raheel Sayeed on 04/12/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(id  inputObject, BOOL success);


@interface IOTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray  *dataArray;
@property (nonatomic, weak) id delegate;
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic,assign) BOOL hasChanges;

- (instancetype)initWithInputObject:(id)inputObject;
- (void)parseInputObject:(id)inputObj;
- (id)parsedOutput;
- (void)done:(id)sender;
- (void)cancel:(id)sender;

@end
