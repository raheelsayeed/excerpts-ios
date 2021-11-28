//
//  RNNavigationBar.m
//  Renote
//
//  Created by M Raheel Sayeed on 21/01/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import "RNNavigationBar.h"

@implementation RNNavigationBar


- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self removeShadow];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self removeShadow];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self removeShadow];
    }
    
    return self;
}
- (void)removeShadow
{
//    [self setShadowImage:[UIImage new]];
    [self setClipsToBounds:YES];
    return;
    
    [self.subviews enumerateObjectsUsingBlock:^(UIView *v, NSUInteger idx, BOOL *stop) {
        if ([NSStringFromClass([v class]) rangeOfString:@"BarBackground"].location != NSNotFound) {
            [v.subviews enumerateObjectsUsingBlock:^(UIView *v, NSUInteger idx, BOOL *stop) {
                if ([v isKindOfClass:[UIImageView class]]) {
                    if (CGRectGetHeight(v.bounds) == 0.5) {
                        [v removeFromSuperview];
                        *stop = YES;
                    }
                }
            }];
            *stop = YES;
        }
    }];
}

@end
