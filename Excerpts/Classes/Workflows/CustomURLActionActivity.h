//
//  CustomURLActionActivity.h
//   Renote
//
//  Created by M Raheel Sayeed on 30/11/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>
        
@interface CustomURLActionActivity : UIActivity
@property (nonatomic) NSDictionary * dataDict;

- (instancetype)initWithTitle:(NSString *)title URLString:(NSString*)urlString;

@end
