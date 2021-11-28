//
//  TapTextView.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 12/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//


//https://github.com/rhgills/uitextview-tap-detection/tree/master/UITextView%20Link%20Detection

#import "TapTextView.h"
#import "NSString+QSKit.h"
@interface TapTextView  ()
{
    NSRange _range;
    NSTextAttachment * _textAttachment;
}
@end
@implementation TapTextView




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _disableContentScroll = NO;
        _imageAttachmentTouched = NO;
        //
    }
    return self;
}
/*

- (CGRect)firstRectForRange:(UITextRange *)range
{
        CGRect r1= [self caretRectForPosition:[self positionWithinRange:range farthestInDirection:UITextLayoutDirectionRight]];
        CGRect r2= [self caretRectForPosition:[self positionWithinRange:range farthestInDirection:UITextLayoutDirectionLeft]];
 
    return CGRectUnion(r1,r2);
}

- (NSUInteger)characterIndexForPoint:(CGPoint)point
{
    if (self.text.length == 0) {
        return 0;
    }
    
    CGRect r1;
    if ([[self.text substringFromIndex:self.text.length-1] isEqualToString:@"\n"]) {
        r1 = [super caretRectForPosition:[super positionFromPosition:self.endOfDocument offset:-1]];
        CGRect sr = [super caretRectForPosition:[super positionFromPosition:self.beginningOfDocument offset:0]];
        r1.origin.x = sr.origin.x;
        r1.origin.y += self.font.lineHeight;
    } else {
        r1 = [super caretRectForPosition:[super positionFromPosition:self.endOfDocument offset:0]];
    }
    
    if ((point.x > r1.origin.x && point.y >= r1.origin.y) || point.y >= r1.origin.y+r1.size.height) {
        return [super offsetFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    }
    
    CGFloat fraction;
    NSUInteger index = [self.textStorage.layoutManagers[0] characterIndexForPoint:point inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:&fraction];
    
    return index;
}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        point.y -= self.font.lineHeight/2;
        NSUInteger index = [self characterIndexForPoint:point];
        UITextPosition *pos = [self positionFromPosition:self.beginningOfDocument offset:index];
        return pos;
    }
    return [super closestPositionToPoint:point];
}

- (void)scrollRangeToVisible:(NSRange)range
{
    [super scrollRangeToVisible:range];
    
    if (self.layoutManager.extraLineFragmentTextContainer != nil && self.selectedRange.location == range.location)
    {
        CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.start];
        [self scrollRectToVisible:caretRect animated:YES];
    }
}
*/


- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    if (!self.disableContentScroll) [super scrollRectToVisible: rect animated: animated];
}


- (void)scrollToCaretInTextView:(UITextView *)textView animated:(BOOL)animated {
    CGRect rect = [textView caretRectForPosition:textView.selectedTextRange.end];
    rect.size.height += textView.textContainerInset.bottom;
    [textView scrollRectToVisible:rect animated:animated];
}


/*

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    _imageAttachmentTouched = NO;
    
    UITouch *touch = [touches anyObject];
    NSTextContainer *textContainer = self.textContainer;
    NSLayoutManager *layoutManager = self.layoutManager;
    
    CGPoint point = [touch locationInView:self];
    point.x -= self.textContainerInset.left;
    point.y -= self.textContainerInset.top;
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:point inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:nil];
    
    if (characterIndex >= self.text.length)
    {
        return;
    }
    
    _textAttachment = [self.attributedText attribute:NSAttachmentAttributeName atIndex:characterIndex effectiveRange:&_range];
    if (_textAttachment)
    {
        _imageAttachmentTouched = YES;
    }
    
    _textAttachment = nil;
    
    [super touchesBegan:touches withEvent:event];

}
*/


@end
