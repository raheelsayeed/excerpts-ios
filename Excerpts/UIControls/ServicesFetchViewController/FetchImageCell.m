//
//  FetchImageCell.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 14/01/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "FetchImageCell.h"
@implementation FetchImageCell
@synthesize imageView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        //self.imageView.backgroundColor = [UIColor lightGrayColor];
        [self.imageView setClipsToBounds:YES];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
