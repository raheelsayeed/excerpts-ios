//
//  TapTextView.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 12/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//


//https://github.com/rhgills/uitextview-tap-detection/tree/master/UITextView%20Link%20Detection

#import "TapTextView.h"

@implementation TapTextView




-(void)setEditing:(BOOL)editing
{
    self.editable = editing;
    self.userInteractionEnabled = editing;
    self.alwaysBounceHorizontal = editing;
    self.alwaysBounceVertical = editing;
    self.showsHorizontalScrollIndicator = NO;
    self.directionalLockEnabled = YES;
    if(editing)
        [self becomeFirstResponder];
    else
        [self resignFirstResponder];
}

-(BOOL)becomeFirstResponder
{
    

    
   // self.backgroundColor = [UIColor whiteColor];
    

  //  self.directionalLockEnabled = YES;
    [super becomeFirstResponder];
    return YES;
    
}

-(BOOL)resignFirstResponder
{
    
   // self.backgroundColor = [UIColor clearColor];
   // self.directionalLockEnabled = YES;
    [super resignFirstResponder];
    return YES;
}


/*
- (CGRect)firstRectForRange:(UITextRange *)range
{
        CGRect r1= [self caretRectForPosition:[self positionWithinRange:range farthestInDirection:UITextLayoutDirectionRight]];
        CGRect r2= [self caretRectForPosition:[self positionWithinRange:range farthestInDirection:UITextLayoutDirectionLeft]];
        return CGRectUnion(r1,r2);
    return [super firstRectForRange:range];
}

- (NSUInteger)characterIndexForPoint:(CGPoint)point
{
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
        point.y -= self.font.lineHeight/2;
        NSUInteger index = [self characterIndexForPoint:point];
        UITextPosition *pos = [self positionFromPosition:self.beginningOfDocument offset:index];
        return pos;
    return [super closestPositionToPoint:point];
}

*/







/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


/*
 #import "WWPhoneticTextView.h"
 #import "WWLabel.h"
 
 #define WWPhoneticTextViewInset 5
 #define WWPhoneticTextViewDefaultColor [UIColor blackColor]
 #define WWPhoneticTextViewHighlightColor [UIColor yellowColor]
 
 #define UILabelMagicTopMargin 5
 #define UILabelMagicLeftMargin -5
 
 @implementation WWPhoneticTextView {
 WWLabel *label;
 NSMutableAttributedString *labelText;
 NSRange tappedRange;
 }
 
 // ... skipped init methods, very simple, just call through to configureView
 
 - (void)configureView
 {
 if(!label) {
 tappedRange.location = NSNotFound;
 tappedRange.length = 0;
 
 label = [[WWLabel alloc] initWithFrame:[self bounds]];
 [label setLineBreakMode:NSLineBreakByWordWrapping];
 [label setNumberOfLines:0];
 [label setBackgroundColor:[UIColor clearColor]];
 [label setTopInset:WWPhoneticTextViewInset];
 [label setLeftInset:WWPhoneticTextViewInset];
 [label setBottomInset:WWPhoneticTextViewInset];
 [label setRightInset:WWPhoneticTextViewInset];
 
 [self addSubview:label];
 }
 
 
 // Setup tap handling
 UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc]
 initWithTarget:self action:@selector(handleSingleTap:)];
 singleFingerTap.numberOfTapsRequired = 1;
 [self addGestureRecognizer:singleFingerTap];
 }
 
 - (void)setText:(NSString *)text
 {
 labelText = [[NSMutableAttributedString alloc] initWithString:text];
 [label setAttributedText:labelText];
 }
 
 - (void)handleSingleTap:(UITapGestureRecognizer *)sender
 {
 if (sender.state == UIGestureRecognizerStateEnded)
 {
 // Get the location of the tap, and normalise for the text view (no margins)
 CGPoint tapPoint = [sender locationInView:sender.view];
 tapPoint.x = tapPoint.x - WWPhoneticTextViewInset - UILabelMagicLeftMargin;
 tapPoint.y = tapPoint.y - WWPhoneticTextViewInset - UILabelMagicTopMargin;
 
 // Iterate over each word, and check if the word contains the tap point in the correct line
 __block NSString *partialString = @"";
 __block NSString *lineString = @"";
 __block int currentLineHeight = label.font.pointSize;
 [label.text enumerateSubstringsInRange:NSMakeRange(0, [label.text length]) options:NSStringEnumerationByWords usingBlock:^(NSString* word, NSRange wordRange, NSRange enclosingRange, BOOL* stop){
 
 CGSize sizeForText = CGSizeMake(label.frame.size.width-2*WWPhoneticTextViewInset, label.frame.size.height-2*WWPhoneticTextViewInset);
 partialString = [NSString stringWithFormat:@"%@ %@", partialString, word];
 
 // Find the size of the partial string, and stop if we've hit the word
 CGSize partialStringSize  = [partialString sizeWithFont:label.font constrainedToSize:sizeForText lineBreakMode:label.lineBreakMode];
 
 if (partialStringSize.height > currentLineHeight) {
 // Text wrapped to new line
 currentLineHeight = partialStringSize.height;
 lineString = @"";
 }
 lineString = [NSString stringWithFormat:@"%@ %@", lineString, word];
 
 CGSize lineStringSize  = [lineString sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
 lineStringSize.width = lineStringSize.width + WWPhoneticTextViewInset;
 
 if (tapPoint.x < lineStringSize.width && tapPoint.y > (partialStringSize.height-label.font.pointSize) && tapPoint.y < partialStringSize.height) {
 NSLog(@"Tapped word %@", word);
 if (tappedRange.location != NSNotFound) {
 [labelText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:tappedRange];
 }
 
 tappedRange = wordRange;
 [labelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:tappedRange];
 [label setAttributedText:labelText];
 *stop = YES;
 }
 }];
 }
 }
 */
@end
