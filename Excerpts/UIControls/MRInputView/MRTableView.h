//
//  ServicesSelectorView.h
//   Renote
//
//  Created by M Raheel Sayeed on 18/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "MRInputAlertView.h"

@interface MRTableView : MRInputAlertView
- (instancetype)initTitle:(NSString *)title titlesAndValue:(NSDictionary *)dict selectedKey:(NSString *)selectedKey;
@end
