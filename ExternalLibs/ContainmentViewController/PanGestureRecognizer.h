//
//  PanGestureRecognizer.h
//  Pager
//
//  Created by Alfred Hanssen on 9/18/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PanDirection)
{
    PanDirectionNone,
    PanDirectionBack,
    PanDirectionForward
};

@interface PanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, assign) PanDirection panDirection;
@property (nonatomic, assign) PanDirection newDirection;

@property (nonatomic, assign) BOOL panDidChangeDirection;

@end
