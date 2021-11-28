//
//  ExcerptCollectionHeaderView.m
//   Renote
//
//  Created by M Raheel Sayeed on 14/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "ExcerptCollectionHeaderView.h"
#import "RequestObject.h"

@interface ExcerptCollectionHeaderView ()
@property (nonatomic, strong) NSArray * loadingAnimationImages;

@end
@implementation ExcerptCollectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kVignetteViewBGColor;
        self.layer.borderWidth = 0.0;
//        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.clipsToBounds = NO;
        [self addSubview:self.titleLabel];
        
        self.actionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.actionBtn.adjustsImageWhenHighlighted = YES;
        [self.actionBtn setImage:[UIImage imageNamed:@"cexcerptprogress"] forState:UIControlStateNormal];
        [self.actionBtn.imageView setContentMode:UIViewContentModeCenter];
        [self.actionBtn setFrame:CGRectMake(frame.size.width - 50, 0, 40, 30)];
        [self.actionBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        self.actionBtn.imageView.animationImages = self.loadingAnimationImages;
        self.actionBtn.imageView.animationDuration = 0.7;
        [self addSubview:self.actionBtn];
        
        
        //CGRect aframe = self.actionBtn.frame;
        //aframe.origin.y = TopY;
        //aframe.origin.x = CGRectGetWidth(self.contentView.bounds) - self.actionBtn.frame.size.width - 10;
    }
    return self;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        
        CGRect bounds = self.bounds;
        bounds.origin.x = 10.f;
        bounds.size.width -= 60;
        _titleLabel = [[UILabel alloc] initWithFrame:bounds];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.opaque = YES;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        _titleLabel.textColor = [UIColor colorWithRed:0.37 green:0.51 blue:0.60 alpha:1.00];//[UIColor blackColor];
        
        //_titleLabel.font =  [UIFont fontWithName:@"Helvetica-Light" size:14];
        //_titleLabel.textColor = [UIColor blackColor];//  [UIColor colorWithWhite:0.2 alpha:1.0];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}

- (NSArray *)loadingAnimationImages
{
    if(_loadingAnimationImages) return _loadingAnimationImages;
    
    self.loadingAnimationImages = @[[UIImage imageNamed:@"cexcerptprogress1"],
                                    [UIImage imageNamed:@"cexcerptprogress2"],
                                    [UIImage imageNamed:@"cexcerptprogress3"]
                                    ];
    return _loadingAnimationImages;
}

- (void)updateStatus:(ROFetchStatus)status
{
    if(status == FetchingInProgress || status == FetchRedirected)
    {
        [self startAnimating];
    }
    else
    {
        [self stopAnimating];
        
        switch (status) {
            case FetchSuccessful:
                self.actionBtn.tintColor = nil;
                break;
            case FetchFailed:
                self.actionBtn.tintColor = [UIColor redColor];
                break;
            case FetchFromCache:
                self.actionBtn.tintColor = kColor_Orange;
                break;
            case FetchIdle:
                self.actionBtn.tintColor = [UIColor blackColor];
                break;
            default:
                self.actionBtn.tintColor = [UIColor greenColor];
                break;
        }
    }
}


- (void)updateStatus
{
    [self updateStatus:_requestObject.fetchStatus];
}


- (void)setRequestObject:(RequestObject *)requestObject
{
    _requestObject = requestObject;
    self.titleLabel.text = _requestObject.title;
//    self.titleLabel.text = (_requestObject.fetchStatus==FetchingInProgress||_requestObject.fetchStatus==FetchRedirected)?_requestObject.resolvedURL.absoluteString:_requestObject.title;
    [self updateStatus];
}

- (void)startAnimating
{
    if(self.actionBtn.imageView.isAnimating) return;
    [self.actionBtn.imageView startAnimating];
}
-(void)stopAnimating
{
    if(!self.actionBtn.imageView.isAnimating) return;
    
    [self.actionBtn.imageView stopAnimating];
}

- (void)dealloc
{
    _requestObject = nil;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.0 alpha:1.f].CGColor);
    CGContextSetLineWidth(context, 0.1f);

    CGContextMoveToPoint(context, 0.f, 0.05f); //start at this point
    CGContextAddLineToPoint(context, rect.size.width, 0.05f); //draw to this point
    CGContextStrokePath(context);

    
    CGContextMoveToPoint(context, 10.f, rect.size.height-0.1f); //start at this point
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height-0.1f); //draw to this point
//    CGContextStrokePath(context);
    

}



@end
