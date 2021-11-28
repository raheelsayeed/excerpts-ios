//
//  Demo_NoteController.h
//  Renote
//
//  Created by M Raheel Sayeed on 29/01/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import "ExcerptViewController.h"

@interface Demo_NoteController : ExcerptViewController

@property (nonatomic, assign) NSInteger viewCount;
@property (nonatomic) UILabel * msg;

- (void)startDemo;

@end
