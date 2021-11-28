//
//  EXThemeLoader.h
//   Renote
//
//  Created by M Raheel Sayeed on 23/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "VSTheme.h"

@class VSTheme;

@interface EXThemeLoader : NSObject

@property (nonatomic, strong, readonly) VSTheme *defaultTheme;
@property (nonatomic, strong, readonly) NSArray *themes;

+ (EXThemeLoader *)shared;
+ (NSDictionary *)ExcerptThemeDictionary;

- (VSTheme *)themeNamed:(NSString *)themeName;

@end
