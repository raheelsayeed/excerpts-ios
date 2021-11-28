//
//  FetchCell_Editor.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 11/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "FetchCell_Editor.h"
#import "TapTextView.h"
#import "VTextStorage.h"
#import "AAPullToRefresh.h"
@implementation FetchCell_Editor
@synthesize textView = _textView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        
        VTextStorage *textStorage = [VTextStorage new];
        
        NSLayoutManager *layoutManager = [NSLayoutManager new];
        [textStorage addLayoutManager: layoutManager];
        
        NSTextContainer *textContainer = [NSTextContainer new];
        [layoutManager addTextContainer: textContainer];
        
        
        _textView = [[TapTextView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height) textContainer:textContainer];
        [_textView  setTextContainerInset:UIEdgeInsetsMake(10, 10, 10, 10)];
        //_textView.directionalLockEnabled = YES;

        
       // _textView = [[TapTextView alloc] initWithFrame:CGRectMake(10, 0, self.contentView.frame.size.width-10, self.contentView.frame.size.height)];
        
        
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;


        _textView.editable = NO;
        _textView.textColor = [UIColor darkTextColor];
        _textView.userInteractionEnabled = NO;
        _textView.tag = 111;

        
        _textView.font = [[self class] font];

        [self.contentView addSubview:_textView];
        
        self.backgroundColor = _textView.backgroundColor = kVignetteViewBGColor;
   
        
       [self setuptextViewActions];
    
        
        self.contentView.backgroundColor =  _textView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];


    }
    return self;
}

- (void)setuptextViewActions
{
    AAPullToRefresh *tv = [_textView addPullToRefreshPosition:AAPullToRefreshPositionTop actionHandler:^(AAPullToRefresh *v){
        NSLog(@"fire from top");
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.0f];
    }];
    tv.imageIcon = [UIImage imageNamed:@"price_tag-32"];
    tv.borderColor = [UIColor whiteColor];
    
    __weak typeof(_textView)  weakText  = _textView;
    AAPullToRefresh * m = [_textView addPullToRefreshPosition:AAPullToRefreshPositionLeft actionHandler:^(AAPullToRefresh *v){
        NSLog(@"fire from left");
        [weakText.delegate performSelector:@selector(showTagView:) withObject:nil];
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.0f];
    }];
    m.imageIcon = [UIImage imageNamed:@"launchpad"];
    
    [_textView addPullToRefreshPosition:AAPullToRefreshPositionRight actionHandler:^(AAPullToRefresh *v){
        NSLog(@"fire from right");
        [v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.0f];
        
    }];
}

+ (UIFont *)font
{
    return [UIFont fontWithName:@"Verdana" size:(isIPad) ? 15.f+iPadFactor:15.f];
}

+ (UIFont *)boldFont
{
    return [UIFont fontWithName:@"Verdana-Bold" size:(isIPad) ? 14.f+iPadFactor:14.f];
}

-(void)endEditing
{
    [(UIViewController *)_textView.delegate setEditing:NO animated:YES];
}

-(void)setEditing:(BOOL)editing
{
    _textView.editable = editing;
    _textView.userInteractionEnabled = editing;
    if(editing) [_textView becomeFirstResponder];
    else
        [_textView resignFirstResponder];
    
}

-(BOOL)becomeFirstResponder
{
    if([_textView isFirstResponder])
        return YES;
    
    [_textView becomeFirstResponder];
    return YES;
}

@end
