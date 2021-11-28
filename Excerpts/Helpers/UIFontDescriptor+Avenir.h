//
//  UIFontDescriptor+Avenir.h
//   Renote
//
//  Created by M Raheel Sayeed on 10/05/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString *const ANUIFontTextStyleCaption3;

@interface UIFontDescriptor (Avenir)
@property (nonatomic, copy) NSString * bodyFontName;
@property (nonatomic, copy) NSString * boldBodyFontName;



+(UIFontDescriptor *)preferredAvenirFontDescriptorWithTextStyle:(NSString *)style;


@end