//
//  FetchCell_Editor.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 11/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "FetchCell_Editor.h"
#import "VTextStorage.h"
#import "EXThemeLoader.h"
#import "RSPullToAction.h"
#import "NSString+RSParser.h"
#import "UIFont+EditorFontContentSize.h"

#import "NSRegularExpression+ServicesSearchRegex.h"
#import "HPTextViewTapGestureRecognizer.h"
#import "AppDelegate.h"
#import "NSString+QSKit.h"

@interface FetchCell_Editor () <UIGestureRecognizerDelegate, HPTextViewTapGestureRecognizerDelegate>
{
    BOOL _isInitialising;
}

@end


@implementation FetchCell_Editor



- (id)initWithFrame:(CGRect)frame
{
    _isInitialising = YES;
    self = [super initWithFrame:frame];
    if (self) {
        
        //self.fontTypeName = [[NSUserDefaults standardUserDefaults] objectForKey:kSettings_EditorFontName];

        //self.fontSize     = [[[NSUserDefaults standardUserDefaults] objectForKey:kSettings_EditorFontSize] floatValue];
        self.fontFamily = [[NSUserDefaults standardUserDefaults] objectForKey:kSettings_EditorFontFamily];


        VTextStorage *textStorage = [VTextStorage new];
        textStorage.delegate = self;
        NSLayoutManager *layoutManager = [NSLayoutManager new];
        [textStorage addLayoutManager: layoutManager];
        layoutManager.delegate = self;
         NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:frame.size];
        [layoutManager addTextContainer: textContainer];
        layoutManager.allowsNonContiguousLayout = NO;
        
       // self.textColor = [UIColor redColor];
        _cellBackgroundColor = [UIColor clearColor];


        
        self.textView = [[TapTextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) textContainer:textContainer];
        [_textView  setTextContainerInset:UIEdgeInsetsMake(20, 10, 15, 10)];
        _textView.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        HPTextViewTapGestureRecognizer * gest = [[HPTextViewTapGestureRecognizer alloc] init];
        gest.delegate = self;
        [_textView addGestureRecognizer:gest];

        
        _textView.tag = 111;

        //_textView.font = [[self class] font];
        [self.contentView addSubview:_textView];

       [self setuptextViewActions];
        
        
 //       self.contentView.backgroundColor = [UIColor blueColor];
//        _textView.backgroundColor = [UIColor orangeColor];
        
        

        
        _textView.directionalLockEnabled = YES;
        _textView.scrollEnabled = NO;
        _textView.decelerationRate = UIScrollViewDecelerationRateFast;
        _textView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];

        _textView.keyboardAppearance = UIKeyboardAppearanceDark;
        _textView.clipsToBounds = YES;
        _textView.textColor = [UIColor darkTextColor];
//        UIFont * font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody fontName:_fontTypeName];
        _textView.font = _textFont;
        
        
        
        _textView.editable = YES;
        _textView.selectable = YES;


        

        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        

        


    }
    _isInitialising = NO;
    
    return self;
}


-(void)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer handleTapOnURL:(NSURL*)URL inRange:(NSRange)characterRange
{
    [APP_DELEGATE showGlobalWebViewWithURL:URL];
}

-(void)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer handleTapOnTextAttachment:(NSTextAttachment*)textAttachment inRange:(NSRange)characterRange
{
    
}



/*
+ (void) initialize
{
    if (self == [FetchCell_Editor class])
    {
        FetchCell_Editor *circularProgressViewAppearance = [FetchCell_Editor appearance];
        [circularProgressViewAppearance setEditorTextColor:[UIColor redColor]];
    }
}
*/
/*
- (void)prepareForReuse
{
    [super prepareForReuse];
    _textView.textColor = _editorTextColor;
}*/



#pragma mark - UI_APPEARANCE

- (UIColor *)editorTextColor
{
    if(_editorTextColor == nil) {
        _editorTextColor = [[[self class] appearance] editorTextColor];
    }
    
    if(_editorTextColor != nil) {
        return _editorTextColor;
    }
    
    return [UIColor darkTextColor];
}





/*
- (void)setCellBackgroundColor:(UIColor *)cellBackgroundColor
{
    if (_cellBackgroundColor != cellBackgroundColor) {
        _cellBackgroundColor = cellBackgroundColor;
        if(!_isInitialising) self.contentView.backgroundColor = _cellBackgroundColor;
    }
}
- (void)setTextColor:(UIColor *)textColor
{
    if (_textColor != textColor) {
        _textColor = textColor;
        if(!_isInitialising) self.textView.textColor = _textColor;
    }
}

 */

/*
- (void)setCellBackgroundColor:(UIColor *)cellBackgroundColor
{
    _cellBackgroundColor = cellBackgroundColor;
    
    if(!_isInitialising)
    {
        self.contentView.backgroundColor = _cellBackgroundColor;
    }
    
}
- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    
     if(!_isInitialising) self.textView.textColor = _textColor;
    
}
*/

- (void)setFontFamily:(NSString *)fontFamily
{
    _fontFamily = fontFamily;
    NSNumber * n  = [[NSUserDefaults standardUserDefaults] objectForKey:kSettings_EditorFontSize];
    self.fontSize = (n) ? ((isIPad) ? iPadFactor+[n floatValue]:[n floatValue]) : 0.0;
    self.textFont = [UIFont editorFontWithFamily:_fontFamily bold:NO size:_fontSize];
    self.boldFont = [UIFont editorFontWithFamily:_fontFamily bold:YES size:_fontSize];
    _textView.font = _textFont; 
}

- (void)setFontTypeName:(NSString *)fontTypeName
{
    _fontTypeName = fontTypeName;
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
}


- (void)dealloc
{
    [_textView enableAllRSViewPullActionViews:NO];
    
}


- (void)setuptextViewActions
{
    __weak typeof(self)  weakSelf  = self;
    
    RSPullToAction * tags = [_textView addPullToActionPosition:RSPullActionPositionLeft actionHandler:^(RSPullToAction * v)
                     {
                         [(id)weakSelf.textView.delegate performSelector:@selector(showTagView)];
                     }];
    tags.text = @"Tags";
    tags.enablePullToAction = NO;
}

-(BOOL)becomeFirstResponder
{
    if([_textView isFirstResponder])
    {
        return YES;
    }
    
    return [_textView becomeFirstResponder];
}


/*

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 2.5f;
}


- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex
{
    NSRange range;
    NSURL *linkURL = [layoutManager.textStorage attribute:NSLinkAttributeName
                                                  atIndex:charIndex
                                           effectiveRange:&range];
    
    return !(linkURL && charIndex > range.location && charIndex <= NSMaxRange(range));
}

- (void)layoutManager:(NSLayoutManager *)layoutManager textContainer:(NSTextContainer *)textContainer didChangeGeometryFromSize:(CGSize)oldSize
{
    


}

- (void)layoutManagerDidInvalidateLayout:(NSLayoutManager *)sender
{
}

// This is sent whenever a container has been filled.  This method can be useful for paginating.  The textContainer might be nil if we have completed all layout and not all of it fit into the existing containers.  The atEnd flag indicates whether all layout is complete.
/*
- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag
{

}

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    
}
*/

+(UIFont *) font:(UIFont *)font bold:(BOOL)bold italic:(BOOL)italic
{
    NSUInteger traits = 0;
    if (bold)
    {
        traits |= UIFontDescriptorTraitBold;
    }
    if (italic)
    {
        traits |= UIFontDescriptorTraitItalic;
    }
    return [UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:traits] size:font.pointSize];
}



-(void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    NSRange paragaphRange = [textStorage.string paragraphRangeForRange: textStorage.editedRange];
    paragaphRange = [textStorage.string paragraphRangeForRange: textStorage.editedRange];
    
    [textStorage removeAttribute:NSFontAttributeName range:paragaphRange];
    [textStorage addAttribute:NSFontAttributeName value:_textFont range:paragaphRange];
    
    
    NSRange topLineRange = [textStorage.string rangeOfTopLine];
    
    if(paragaphRange.location == topLineRange.length+1)
    {
        if(topLineRange.location != NSNotFound)
        {
            [textStorage removeAttribute:NSFontAttributeName range:topLineRange];
            [textStorage addAttribute:NSFontAttributeName value:_boldFont range:topLineRange];

        }
    }
    else if (paragaphRange.location == topLineRange.location)
    {
        if(topLineRange.location != NSNotFound)
        {
            [textStorage removeAttribute:NSFontAttributeName range:topLineRange];
            [textStorage addAttribute:NSFontAttributeName value:_boldFont range:topLineRange];
        }
        
    }
    
    
    
    
    
    
    
    
	
    
    
    
    
	
    


    
    [[NSRegularExpression servicesRegex] enumerateMatchesInString:textStorage.string
                                        options:0
                                          range:paragaphRange
                                     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                         
        [textStorage addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.14 green:0.32 blue:0.53 alpha:1.00] range:result.range];
        [textStorage addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Menlo-Regular" size:13] range:result.range];
	}];
    
}


@end
