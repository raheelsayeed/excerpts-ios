//
//  FetchCell.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 13/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "FetchCell.h"

#import <QuartzCore/QuartzCore.h>

@interface FetchCell ()
@property (nonatomic) CAGradientLayer * gradientOverlay;
@property (nonatomic) CALayer         * imageLayer;

@end
@implementation FetchCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchImageViewTapped:)];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, 200)];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.imageView setClipsToBounds:YES];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.imageView setUserInteractionEnabled:YES];
        [self.imageView addGestureRecognizer:tap];
//        [self.imageView setGestureRecognizers:@[tap]];
        [self.contentView addSubview:self.imageView];
        /*
        self.gradientOverlay = [CAGradientLayer layer];
        self.gradientOverlay.frame = self.imageView.layer.bounds;

        
        self.gradientOverlay.colors = [NSArray arrayWithObjects:
                                    (id)[UIColor colorWithWhite:0.0f alpha:0.9f].CGColor,
                                    (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
                                    nil];
        
        self.gradientOverlay.locations = @[@(0.0f), @(0.8)];
//        [NSArray arrayWithObjects:                               [NSNumber numberWithFloat:0.0f],     [NSNumber numberWithFloat:0.8f],                                nil];
        
         self.gradientOverlay.contentsScale = [UIScreen mainScreen].scale;
        */


        //[self.imageView.layer addSublayer:self.gradientOverlay];
        
        self.imageLayer = [CALayer new];
        self.imageLayer.contents =  (__bridge id)[ [UIImage imageNamed:@"playOverlay"] CGImage ] ;
        self.imageLayer.frame = CGRectMake((self.contentView.bounds.size.width/2)-25, (200/2) - 25, 50, 50);
        [self.imageView.layer addSublayer:self.imageLayer];

        
        
        CGFloat padding  = [[self class] padding];
        CGRect blackFrame =CGRectMake(padding, padding, self.contentView.frame.size.width-(2*padding), 10);
        CGFloat tHeight = (2 *padding) + 10;
        
        self.titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.titleButton.frame = blackFrame;
        [self.titleButton.titleLabel setNumberOfLines:0];
        [self.titleButton.titleLabel setTextAlignment:NSTextAlignmentLeft];

        self.titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        self.titleButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        [self.titleButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.titleButton addTarget:self action:@selector(fetchCellActionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        //[self.titleButton setBackgroundColor:[UIColor colorWithRed:.32 green:.32 blue:.32 alpha:.10]];
        //[self.titleButton.titleLabel setAdjustsFontSizeToFitWidth:NO];

        //[self.titleButton.titleLabel setBaselineAdjustment:UIBaselineAdjustmentNone];
        [self.contentView addSubview:self.titleButton];
//        UIFontDescriptor * tdesriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCaption2];
//        self.titleButton.titleLabel.font = [UIFont fontWithDescriptor:tdesriptor size:16];

        
        
        
        
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(padding, tHeight, self.contentView.frame.size.width-(2*padding), 20)];
        self.label.textAlignment = NSTextAlignmentLeft;
        //self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.label.textColor = [UIColor colorWithWhite:0.35 alpha:1.0];
        CGFloat fsize = 16;
        if(isIPad) fsize += iPadFactor;
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        self.label.numberOfLines = 0;
        self.label.tag = 0;
        //self.label.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.2];
        self.label.userInteractionEnabled = YES;
        self.label.numberOfLines = 0;

        
        
        UIFontDescriptor * desriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
        self.label.font = [UIFont fontWithDescriptor:desriptor size:15];
        [self.contentView addSubview:self.label];
        
        
        //self.contentView.clipsToBounds = YES;

        
        //self.layer.borderWidth=0.1f;
        //self.layer.borderColor=[UIColor lightGrayColor].CGColor;
        
        
        
        
    }
    return self;
}


- (void)fetchCellActionButtonPressed:(UIButton *)button
{
    [_delegate performSelector:@selector(fetchCellActionButtonPressed:) withObject:button];
}

- (void)addToNote:(UIMenuController*)menuController
{
    NSAttributedString * str = _dataDictionary[@"fetchedData"];
    if(str)
    {
        [_delegate performSelector:@selector(addToNote:) withObject:str.string];
    }
}

- (void)fetchImageViewTapped:(UITapGestureRecognizer *)tap
{
    [_delegate performSelector:@selector(fetchImageViewTapped:) withObject:tap];
}



+(CGFloat)padding
{
    return 10.f;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setNeedsDisplay];
    _imageView.image = nil;
}

+(CGFloat)emptyCellSize
{
    return 44.f;
}

- (void)layoutSubviews
{

    
    CGFloat padding = [[self class] padding];
    CGFloat width = self.contentView.frame.size.width-(2*padding);
    BOOL imageArrived = (_dataDictionary[@"imgURL"] != nil);
    static CGFloat imgHeight  = 200.f;
    _imageView.hidden = !imageArrived;
    CGFloat maxY = padding;
    
    //----- titleButton ----//
    
    
    
    _titleButton.frame = CGRectMake(padding, padding, width, 20);
    
    CGRect frame = [_dataDictionary[@"title"] boundingRectWithSize:CGSizeMake(width, FLT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                    attributes:@{NSFontAttributeName:_titleButton.titleLabel.font}
                                       context:nil];
    frame.origin = CGPointMake(padding, padding);
    frame.size.width = width;
    _titleButton.frame = frame;
    maxY += frame.size.height;
    maxY += padding;
    
    /*
    CGRect frame  = _titleButton.frame;
    CGSize sizeFs = [_titleButton.titleLabel sizeThatFits:constraintSize];
    frame.origin = CGPointMake(padding, padding);
    frame.size = sizeFs;
    _titleButton.frame = frame;
    maxY += frame.size.height;
    maxY += padding;
    */
    //----- img -----//
    
    if(imageArrived)
    {
        self.imageView.frame = CGRectMake(0, maxY, self.contentView.frame.size.width, imgHeight);
        maxY += imgHeight + padding;
    }
    
    //----- text -------//
    
   
    /*
    _label.frame = CGRectMake(padding, maxY, width, 20);
    CGRect p = _label.frame;
    CGSize s = [_label sizeThatFits:constraintSize];
    p.size = s;
    p.origin = CGPointMake(padding, maxY);
    _label.frame = p;
    */
    
    
    //_label.frame = CGRectMake(padding, padding, width, 20);
    
    CGRect e = [[_dataDictionary[@"fetchedData"] string] boundingRectWithSize:CGSizeMake(width, FLT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                        attributes:@{NSFontAttributeName:_label.font}
                                                           context:nil];
    e.origin = CGPointMake(padding, maxY);
    e.size.width = width;
    _label.frame = e;
    
}


- (void)setDataDictionary:(NSDictionary *)dataDictionary
{
    _dataDictionary = dataDictionary;
    NSString * title = _dataDictionary[@"title"];
    if(title) title = [title stringByAppendingString:@" ⇾"];//→∞
    [_titleButton setTitle:title forState:UIControlStateNormal];
    self.label.attributedText  = _dataDictionary[@"fetchedData"];
    
}

- (void)setServiceType:(API_SERVICE_TYPE)serviceType
{
    _serviceType = serviceType;
    switch (serviceType)
    {
        case API_SERVICE_TYPE_VIMEO:
        case API_SERVICE_TYPE_YOUTUBE:
            [self removeImageOverlays:NO];
            break;
        default:
            [self removeImageOverlays:YES];
            break;
    }
    [self.titleButton setHidden:(_serviceType == API_SERVICE_TYPE_WEBIMAGE)];
}


- (void)removeImageOverlays:(BOOL)remove
{
    if(remove)
    {
        self.imageLayer.hidden = self.gradientOverlay.hidden = YES;
    }
    else
    {
        self.imageLayer.hidden = self.gradientOverlay.hidden = NO;

    }
}




- (UIColor *)mainTextColor
{
    if(_mainTextColor == nil) {
        _mainTextColor = [[[self class] appearance] mainTextColor];
    }
    
    if(_mainTextColor != nil) {
        return _mainTextColor;
    }
    
    return [UIColor darkTextColor];
}



- (void)drawRect:(CGRect)rect
{

    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.8 alpha:1.f].CGColor);
    CGContextSetLineWidth(context, 0.7f);
    
    CGContextMoveToPoint(context, 0.f, rect.size.height-1.f); //start at this point
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height-1.0f); //draw to this point
    CGContextStrokePath(context);
    
    


}

@end
