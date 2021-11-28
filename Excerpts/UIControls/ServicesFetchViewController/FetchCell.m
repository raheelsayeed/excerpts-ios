//
//  FetchCell.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 13/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "FetchCell.h"

@implementation FetchCell
@synthesize label, titleLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat tHeight = 15.f;
        CGFloat padding  = [[self class] padding];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding, self.contentView.frame.size.width- (2*padding), tHeight)];
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:13];
        [self.contentView addSubview:self.titleLabel];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(padding, tHeight + padding, self.contentView.frame.size.width-(2*padding), self.contentView.frame.size.height- (tHeight+10))];
        self.label.textAlignment = NSTextAlignmentLeft;
        self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        //self.label.textColor = [UIColor darkTextColor];
        CGFloat fsize = 16;
        if(isIPad) fsize += iPadFactor;
        //self.label.font = [[self class] font];
        self.label.font = [UIFont fontWithName:@"Helvetica-Light" size:(isIPad)?17+iPadFactor:17];
        
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        self.label.numberOfLines = 0;
        self.label.tag = 0;
        
        
        //self.label.frame = CGRectMake(10, 0, self.contentView.frame.size.width-20, self.contentView.frame.size.height-1);
        //self.label.backgroundColor = kColor_SVT;
        self.label.numberOfLines = 0;
        
        
       
        [self.contentView addSubview:self.label];
        
        //self.contentView.backgroundColor = self.label.backgroundColor = self.imageView.backgroundColor = kVignetteViewBGColor;
        self.clipsToBounds = YES;
    }
    return self;
}
+(CGFloat)padding
{
    return 10.f;
}
+(UIFont *)font{
    
    CGFloat fsize = 16.f;
    if(isIPad) fsize += iPadFactor;
    return  [UIFont fontWithName:@"SourceSansPro-Regular" size:fsize];
}



-(void)layoutSubviews
{
    [super layoutSubviews];
    //self.backgroundColor = [UIColor greenColor];
    //self.titleLabel.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];

    //self.label.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    CGFloat tHeight = 20.f;
    [self.titleLabel setFrame:CGRectMake(10, 10, self.contentView.frame.size.width-20, tHeight)];
    [self.titleLabel sizeToFit];
    [self.label setFrame:CGRectMake(10, tHeight + 5, self.contentView.frame.size.width-20, self.contentView.frame.size.height- (tHeight+5))];
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

/*
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
  
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetRGBStrokeColor(ctx, 0.3, 0.3, 0.3, 1.0); //0.9
    
    CGContextSetLineWidth(ctx,0.3f);
    
    CGContextMoveToPoint(ctx, 10.f, self.bounds.size.height-0.5);
    CGContextAddLineToPoint(ctx, self.bounds.size.width-20.f, self.bounds.size.height-0.5 );
    CGContextStrokePath(ctx);
}
*/



@end
