//
//  MainCellSeparatorView.m
//   Renote
//
//  Created by M Raheel Sayeed on 08/05/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "MainCellSeparatorView.h"


@implementation MainCellSeparatorView
{
    BOOL _isInitializing;
}
@synthesize separatorColor = _separatorColor;

- (id)initWithFrame:(CGRect)frame
{
    _isInitializing = YES;

    self = [super initWithFrame:frame];
    if (self) {
        
        //_separatorColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    }
    _isInitializing = NO;

    return self;
}

- (void)prepareForReuse
{
   // self.backgroundColor = _separatorColor;
    [super prepareForReuse];
    
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
    
    self.backgroundColor = separatorColor;
    
}
- (UIColor *)separatorColor
{
    if(_separatorColor == nil) {
    //    _separatorColor = [[[self class] appearanceCT] separatorColor];
    }
    
    if(_separatorColor != nil) {
        return _separatorColor;
    }
    
    return [UIColor colorWithWhite:0.0 alpha:1.0];
}


@end
