//
//  EXThemeLoader.m
//   Renote
//
//  Created by M Raheel Sayeed on 23/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "EXThemeLoader.h"
#import "VSTheme.h"

@interface EXThemeLoader ()

@property (nonatomic, strong, readwrite) VSTheme *defaultTheme;
@property (nonatomic, strong, readwrite) NSArray *themes;
@end

@implementation EXThemeLoader

+ (EXThemeLoader *)shared
{
    static EXThemeLoader *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[EXThemeLoader alloc] init];
    });
    return shared;
}

- (id)init {
	
	self = [super init];
	if (self == nil)
		return nil;
	

	NSDictionary *themesDictionary = [[self class] ExcerptThemeDictionary];
	
	NSMutableArray *themes = [NSMutableArray array];
	for (NSString *oneKey in themesDictionary) {
		
		VSTheme *theme = [[VSTheme alloc] initWithDictionary:themesDictionary[oneKey]];
		if ([[oneKey lowercaseString] isEqualToString:@"default"])
			self.defaultTheme = theme;
		theme.name = oneKey;
		[themes addObject:theme];
	}
    
    for (VSTheme *oneTheme in themes) { /*All themes inherit from the default theme.*/
		if (oneTheme != _defaultTheme)
			oneTheme.parentTheme = _defaultTheme;
    }
    
	_themes = themes;
	
	return self;
}

- (VSTheme *)themeNamed:(NSString *)themeName {
    
	for (VSTheme *oneTheme in self.themes) {
		if ([themeName isEqualToString:oneTheme.name])
			return oneTheme;
	}
    
	return nil;
}

+ (NSDictionary *)ExcerptThemeDictionary
{
    return @{@"Default": @{@"mainTextFont"  : @"Verdana",
                           @"mainTitleFont" : @"Verdana-Bold",
                           @"mainBGColor"   : @"ffffff"
                           },
             
             @"Dark"   : @{@"mainBGColor"   : @"708090"
                           }
             
             };
    
}

@end
