//
//  SectionHeader.m
//   Renote
//
//  Created by M Raheel Sayeed on 29/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "SectionHeader.h"

@implementation SectionHeader



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGRect frame = CGRectInset(self.bounds, 0, 4);
        frame.origin.x = self.bounds.size.width - 25;
        frame.size.height = 20;
        frame.size.width =  20;
     
        self.countLabel  =  [[UILabel alloc] initWithFrame:frame];
        self.countLabel.backgroundColor = [kColor_SVT colorWithAlphaComponent:0.8]; // [UIColor colorWithWhite:0.8 alpha:1.0];
        self.countLabel.layer.cornerRadius = 20/2;
        self.countLabel.layer.masksToBounds = YES;
        self.countLabel.textColor = [UIColor whiteColor];
        self.countLabel.font  = [UIFont fontWithName:@"HelveticaNeue" size:12];
        self.countLabel.textAlignment = NSTextAlignmentCenter;
        self.countLabel.adjustsFontSizeToFitWidth = YES;
        

        CGFloat btnWidth = 55;
        frame.origin.x = CGRectGetMaxX(self.bounds) - 25 - btnWidth;
        frame.size.width = btnWidth;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.origin.y = 0;
        self.sortingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.sortingBtn.frame = frame;
//        [_sortingBtn sizeToFit];
        [self.sortingBtn.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Italic" size:11]];
        [self.sortingBtn setTitle:@"modified" forState:UIControlStateNormal];
        [self.sortingBtn addTarget:(id)_delegate action:@selector(sectionSortingAction:) forControlEvents:UIControlEventTouchUpInside];
        self.sortingBtn.tag = 3;
        [self addSubview:_sortingBtn];
        
        
        CGFloat chevWidth = 37;
        self.rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        frame = self.countLabel.frame;
        frame.origin.y = 0;
        frame.size.width = chevWidth;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.origin.x = CGRectGetMidX(self.bounds) + chevWidth;
        self.rightBtn.frame = frame;
        [self.rightBtn.imageView setContentMode:UIViewContentModeCenter];
        [self.rightBtn setImage:[[self class]  chevronImageDown] forState:UIControlStateNormal];
        [self.rightBtn addTarget:(id)_delegate action:@selector(sectionRightArrowAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightBtn];
        
        
        self.leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        frame.origin.x = CGRectGetMidX(self.bounds);
        self.leftBtn.frame = frame;
        [self.leftBtn setImage:[[self class]  chevronImageUP] forState:UIControlStateNormal];
        [self.leftBtn addTarget:(id)_delegate action:@selector(sectionLeftArrowAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftBtn];

    

        
        
        
        
        [self addSubview:self.countLabel];
        self.backgroundColor = [kColor_MainViewBG colorWithAlphaComponent:0.9];
        //self.backgroundColor = [UIColor colorWithWhite:0.92 alpha:0.9];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 0, 1)];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.opaque = YES;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        _titleLabel.textColor = [UIColor colorWithRed:0.37 green:0.51 blue:0.60 alpha:1.00];//[UIColor blackColor];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _titleLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
    
    
    
    CGRect frame = CGRectInset(self.bounds, 0, 4);
    frame.origin.x = self.bounds.size.width - 25;
    frame.size.height = 20;
    frame.size.width =  20;
    self.countLabel.frame = frame;
    
    CGFloat btnWidth = 55;
    frame.origin.x = CGRectGetMaxX(self.bounds) - 25 - btnWidth;
    frame.size.width = btnWidth;
    frame.size.height = CGRectGetHeight(self.bounds);
    frame.origin.y = 0;
    self.sortingBtn.frame = frame;
    
    
    CGFloat chevWidth = 37;
    frame = self.countLabel.frame;
    frame.origin.y = 0;
    frame.size.width = chevWidth;
    frame.size.height = CGRectGetHeight(self.bounds);
    frame.origin.x = CGRectGetMidX(self.bounds) + chevWidth;
    self.rightBtn.frame = frame;
    
    frame.origin.x = CGRectGetMidX(self.bounds);
    self.leftBtn.frame = frame;
}

static UIImage * chevronImageUP = nil;
+ (UIImage *)chevronImageUP
{
    if(!chevronImageUP)
    {
        chevronImageUP = [UIImage imageNamed:@"chevron-up"];
    }
    return chevronImageUP;
}

static UIImage * chevronImageDown = nil;

+ (UIImage *)chevronImageDown
{
    if(!chevronImageDown)
    {
        chevronImageDown = [UIImage imageNamed:@"chevron-down"];
    }
    return chevronImageDown;
}




- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 0.2f);
   
    CGContextMoveToPoint(context, 5.0, rect.size.height-0.2f); //start at this point
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height-0.2f); //draw to this point
    CGContextStrokePath(context);
    
}
@end
