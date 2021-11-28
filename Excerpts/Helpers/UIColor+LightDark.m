//
//  UIColor+LightDark.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 17/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "UIColor+LightDark.h"

@implementation UIColor (LightDark)

- (UIColor *)lighterColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.3, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    return nil;
}
@end
