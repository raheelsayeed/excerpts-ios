//
//  MainCell.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 20/06/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "MainCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+RSParser.h"
#import "Note.h"
#import "UIColor+LightDark.h"
#import "UIFontDescriptor+Avenir.h"
#import "UIFont+EditorFontContentSize.h"
#import "MRModalAlertView.h"


@interface MainCell ()
{
    BOOL _isInitializing;
}
@property (nonatomic, strong) CAGradientLayer * gradientLayer;
@property (nonatomic, strong) UIFont * font;
@property (nonatomic, strong) UIFont * boldFont;
@end
@implementation MainCell
@synthesize  label, metaLabel, editMode = _editMode, imageView = _imageView;
@dynamic labelTextColor;
@synthesize sideLabelTextColor = _sideLabelTextColor, labelFont = _labelFont;



- (id)initWithFrame:(CGRect)frame
{
    _isInitializing = YES;

    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.editMode = NO;
        UIFontDescriptor * caption    = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];

        
        CGRect lframe = CGRectMake(5.f, 1, self.contentView.frame.size.width-8.f, self.contentView.frame.size.height-18);
        self.label = [[UILabel alloc] initWithFrame:lframe];
        self.label.textAlignment = NSTextAlignmentLeft;
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.label.textColor = [UIColor darkTextColor];
        self.label.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        //self.label.font = [UIFont systemFontOfSize:(isIPad)?14+iPadFactor:14];
        //self.label.font = self.labelFont;
        self.label.font = [UIFont fontWithDescriptor:caption size:15];
        UIFont * hLight = [UIFont fontWithName:@"HelveticaNeue" size:(isIPad)?15+iPadFactor:15];
        self.label.font = hLight;
        self.label.textColor = [UIColor colorWithWhite:0.27 alpha:1.0];
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        self.label.numberOfLines = 0;
        self.label.tag = 0;
        self.label.clipsToBounds = YES;
        
        
        //1. HelveticaNeue-Light
        //2. HelveticaNeue
        
        self.boldFont = [UIFont boldSystemFontOfSize:(isIPad) ? 14+iPadFactor : 15];
        
        UIView * selectedBG = [[UIView alloc] initWithFrame:frame];
        selectedBG.backgroundColor =
        [UIColor colorWithWhite:0.7 alpha:0.5];
        self.selectedBackgroundView = selectedBG;


        [self.contentView addSubview:self.label];
        
        self.metaLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, lframe.size.height-5 , 18, 18)];
        self.metaLabel.textColor = [UIColor colorWithRed:0.56 green:0.55 blue:0.57 alpha:1.00];
        self.metaLabel.textColor = [UIColor darkTextColor];
        self.metaLabel.font = [UIFont fontWithName:@"Lato-Light" size:12];
        self.metaLabel.adjustsFontSizeToFitWidth = YES;
        self.metaLabel.textAlignment = NSTextAlignmentCenter;
        self.metaLabel.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.4];
        self.metaLabel.layer.cornerRadius = 9;
        self.metaLabel.font = [UIFont systemFontOfSize:9];
        self.metaLabel.clipsToBounds = YES;

        [self.contentView addSubview:self.metaLabel];
        
        
        
        CGFloat edge = 18.f;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-12, self.contentView.frame.size.height-12, edge, edge)];
        
        lframe = self.metaLabel.frame;
        lframe.origin.x = CGRectGetMaxX(lframe) + 2.f;
        self.imageView.frame = lframe;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = roundf(edge/2);
        
        

        [self.contentView addSubview:self.imageView];
        self.imageView.tintColor = kColor_Orange;
        self.imageView.image = [[self class] dropboxImage];
        self.imageView.backgroundColor = self.metaLabel.backgroundColor;
        
        self.fontTypeName = [[NSUserDefaults standardUserDefaults] objectForKey:kSettings_EditorFontName];

      
    }
    _isInitializing = NO;

    return self;
}

+ (NSString *)formatDate:(NSDate *)date withCalendar:(NSCalendar *)calendar
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"d";
    });
    
    return [dateFormatter stringFromDate:date];
}

- (void)configureCell:(Note *)note sortKey:(NSString *)sortKey
{
    self.label.attributedText = [self text:note.text];
    self.metaLabel.text = [[self class] formatDate:[note valueForKey:sortKey] withCalendar:nil];
   self.imageView.hidden = ([note.type  integerValue] == EX_TYPE_LOCAL);
}




- (void)sendToArchive:(id)sender
{
    _notePointer.archived = @(YES);
    [_notePointer.managedObjectContext save:nil];
}

- (void)sendToUnarchive:(id)sender
{
    _notePointer.archived = @(NO);
    [_notePointer.managedObjectContext save:nil];
}


- (void)delete:(id)sender
{
    
    MRModalAlertView * alert = [[MRModalAlertView alloc] initWithTitle:@"Delete Notes" mesage:@"Are you sure?"];
    [alert showForView:self.superview.superview
         selectorBlock:^(BOOL result){
             if(result)
             {
                 NSManagedObjectContext * moc = _notePointer.managedObjectContext;
                 [moc deleteObject:_notePointer];
                 [moc save:nil];
             }
         }];
}




-(void)blink
{
    UIColor * oldBG = self.backgroundColor;

    
    [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:
     ^{
        

        self.backgroundColor = [UIColor yellowColor];
       // self.label.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = oldBG;


  //      self.contentView.backgroundColor = c;
    }completion:^(BOOL finished){
//        NSLog(@"finished");
    }];
    
    
}




- (NSAttributedString *)text:(NSString *)text
{
    if(!text)
    {
        text = @"missing text";
        return [[NSAttributedString alloc] initWithString:text];
    }
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:[text stringByAppendingString:@"\n\n\n\n\n\n\n\n"]];
    NSRange firstLineRange  = [text rangeOfTopLine];
    if(firstLineRange.location == NSNotFound)
    {
        return [mutableAttributedString copy];
    }
    else
    {

        [mutableAttributedString addAttribute:NSFontAttributeName value:_boldFont range:firstLineRange];
        
        return [mutableAttributedString copy];
    }
}






-(UIFont *)labelFont
{
    if(_labelFont)
    {
        return _labelFont;
    }
    
    //_boldFont = [UIFont boldSystemFontOfSize:(isIPad)?15+iPadFactor:15];
    _boldFont = [UIFont systemFontOfSize:15];
    return  [UIFont fontWithName:@"Helvetica-Light" size:(isIPad)?15+iPadFactor:15];

}

- (void)setLabelFont:(UIFont *)labelFont
{
    _labelFont = labelFont;
    
    _boldFont = [UIFont boldSystemFontOfSize:(isIPad)?15+iPadFactor:15];
    _boldFont = [UIFont fontWithName:@"HelveticaNeue" size:15];

}
- (UIColor *)labelTextColor
{
    return self.label.textColor;
}

- (void)setLabelTextColor:(UIColor *)labelTextColor
{
    //[[self label] setTextColor:labelTextColor];
//    [[self label] setNeedsDisplay];
}

- (void)setSideLabelTextColor:(UIColor *)sideLabelTextColor
{
    _sideLabelTextColor = sideLabelTextColor;
    
}

- (void)setBackgroundColor:(UIColor *)color {
    [super setBackgroundColor:[UIColor clearColor]];
    // Check needed for UIAppearance to work (since UILabel uses setters in init)
    if (!_isInitializing) self.cellBackgroundColor = color;
}



static UIImage * dropboxImage = nil;


+ (UIImage *)dropboxImage
{
    if(dropboxImage) return dropboxImage;
    
    dropboxImage = [[UIImage imageNamed:@"ionicons-social-dropbox-outline-24"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return dropboxImage;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
//    CGRect bounds = self.contentView.bounds;
//    CGRect labelFrame = self.label.frame;
//    CGRect metaFrame  = self.metaLabel.frame;
    CGFloat height = self.contentView.bounds.size.height;
    CGFloat width  =self.contentView.bounds.size.width;
    
    BOOL isLandscape  = width * 0.8 > height;
    
    if(isLandscape)
    {
        CGRect frame = CGRectMake(5, 10, 18, 18);
        self.metaLabel.frame = frame;
        frame.origin.y = CGRectGetMaxY(frame) + 2;
        self.imageView.frame = frame;
        CGFloat maxX   = CGRectGetMaxX(frame);
        
        self.label.frame = CGRectMake(maxX+5.f, 0, width-(maxX+10.f), height);
    }
    else
    {
        CGRect lframe = CGRectMake(5.f, 1, self.contentView.bounds.size.width-8.f, self.contentView.bounds.size.height-18);
        self.label.frame = lframe;
        CGRect frame = CGRectMake(5, self.contentView.bounds.size.height- 22 , 18, 18);
        self.metaLabel.frame = frame;
        frame.origin.x = CGRectGetMaxX(frame) + 2.f;
        self.imageView.frame = frame;
        
        


        
    }
}



@end
