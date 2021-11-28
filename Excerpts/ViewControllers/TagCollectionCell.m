//
//  TagCollectionCell.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 23/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "TagCollectionCell.h"

@interface TagCollectionCell ()

@property (nonatomic, strong) UIButton * deleteBtn;

@end
@implementation TagCollectionCell
@synthesize label, editMode = _editMode, deleteBtn = _deleteBtn;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _editMode = NO;
        self.label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.label.backgroundColor = [UIColor clearColor];
        //self.label.font = [UIFont systemFontOfSize:(isIPad)?13+iPadFactor :14];
        self.label.font = [[self class] font];
        self.label.textColor = kColor_TagText;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.contentView.layer.cornerRadius   = frame.size.height/3;
        
        self.contentView.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.3] CGColor];
        self.contentView.layer.borderWidth = 1.5f;
        [self.contentView addSubview:label];
        
        self.contentView.backgroundColor = kColor_TagBG;
        
        self.tagBgColor = [UIColor colorWithWhite:1.0 alpha:0.1];
        self.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        

    }
    return self;
}

+(UIFont *)font
{
    CGFloat fontSize = (isIPad) ? iPadFactor + 15 : 15;
    //return [UIFont systemFontOfSize:15];
    
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
}
/*
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect f = self.label.frame;
    f.origin.x = 0;
    
    if(_editMode)
    {
        if(!_deleteBtn)
        {
            self.deleteBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
            self.deleteBtn.tintColor = [UIColor lightTextColor];
            //[self.deleteBtn setFrame:CGRectMake(3, f.origin.y , self.deleteBtn.frame.size.width, self.deleteBtn.frame.size.height)];
            self.deleteBtn.frame = CGRectMake(3, f.origin.y, 20, f.size.height);
            [self.contentView addSubview:self.deleteBtn];
            [self.deleteBtn addTarget:self action:@selector(prepareDeletion:) forControlEvents:UIControlEventTouchUpInside];
            //[self.deleteBtn sizeToFit];
        }
        
        //_deleteBtn.frame =CGRectMake(3, f.origin.y, 10, f.size.height);
        
        f.origin.x = _deleteBtn.frame.size.width;
        f.size.width = self.contentView.frame.size.width - f.origin.x;
    }
    else
    {
        f = self.contentView.frame;
    }
    
    self.label.frame = f;
    _deleteBtn.hidden = !_editMode;

}
 */

- (void)prepareDeletion:(id)sender
{
    self.tagBgColor = [UIColor redColor];
    //self.label.text = @"Delete?";
    [self setSelected:YES];
    

}


-(void)setSelected:(BOOL)selected{
    
    [super setSelected:selected];
    if(selected)
    {
        self.label.textColor =  [UIColor whiteColor]; //[UIColor colorWithRed:1.00 green:0.85 blue:0.29 alpha:1.00];
        self.contentView.backgroundColor = [_tagBgColor colorWithAlphaComponent:0.2]; // [UIColor colorWithRed:1.00 green:0.85 blue:0.29 alpha:0.2];
        self.contentView.layer.borderColor = [[UIColor colorWithRed:0.20 green:0.66 blue:0.86 alpha:1.00] CGColor];


    }
    else
    {
        self.label.textColor = kColor_TagText;
        self.contentView.backgroundColor = kColor_TagBG;
        self.contentView.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.3] CGColor];
        self.contentView.layer.borderColor = [_borderColor CGColor];


    }
}

-(void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
    if(highlighted)
    {
        self.label.textColor =  [UIColor whiteColor]; //[UIColor colorWithRed:1.00 green:0.85 blue:0.29 alpha:1.00];
        self.contentView.backgroundColor = [_tagBgColor colorWithAlphaComponent:0.2]; // [UIColor colorWithRed:1.00 green:0.85 blue:0.29 alpha:0.2];
        self.contentView.layer.borderColor = [[UIColor colorWithRed:0.20 green:0.66 blue:0.86 alpha:1.00] CGColor];

        
    }
    else
    {
        self.label.textColor = kColor_TagText;
        self.contentView.backgroundColor = kColor_TagBG;
        self.contentView.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.3] CGColor];
        self.contentView.layer.borderColor = [_borderColor CGColor];

        
    }
}





@end
