//
//  LinkSearchCell.m
//   Renote
//
//  Created by M Raheel Sayeed on 22/05/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "LinkSearchCell.h"

@implementation LinkSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.numberOfLines = 3;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        //self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.indentationWidth = 45;

        self.detailTextLabel.textColor = [UIColor grayColor];
        self.detailTextLabel.numberOfLines = 2;

        self.selectedBackgroundView.backgroundColor = [UIColor orangeColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.imageView.contentMode = UIViewContentModeCenter;
      
        self.imageView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.4] ;
        self.imageView.layer.cornerRadius = 32/2;
        //self.imageView.layer.borderWidth = 2.f;
        //self.imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.imageView.layer.masksToBounds = YES;
        
        CGRect bounds  = self.imageView.bounds;
        bounds.size  = CGSizeMake(32, 32);
        
        self.imageView.bounds = bounds;

    }
    return self;
}
- (void)prepareForReuse
{
    [self.imageView setImage:nil];
    [super prepareForReuse];

}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect frame  = self.imageView.frame;
    frame.size  = CGSizeMake(32, 32);
    
    self.imageView.frame = frame;
    
  

}



- (void)setCellSelection:(BOOL)selection
{
    if(selection)
    {
        self.contentView.backgroundColor = self.tintColor;
        self.detailTextLabel.textColor = [UIColor whiteColor];

    }
    else
    {
        self.contentView.backgroundColor = [UIColor clearColor];

        self.detailTextLabel.textColor = [UIColor grayColor];

        
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self setCellSelection:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setCellSelection:selected];

    // Configure the view for the selected state
}

@end
