//
//  ActionsListViewController.h
//   Renote
//
//  Created by M Raheel Sayeed on 19/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
@interface ActionsListViewController : UITableViewController

@property (nonatomic, weak, readonly) Note * note;
@property (nonatomic, strong, readonly) id sharedObject;



- (instancetype)initWithShareableObject:(id)shareObject;


@end
