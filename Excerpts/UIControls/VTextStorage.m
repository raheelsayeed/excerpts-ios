//
//  VTextStorage.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 03/02/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "VTextStorage.h"
#import "NSString+RSParser.h"
#import "FetchCell_Editor.h"

@implementation VTextStorage
{
    NSMutableAttributedString *_imp;
}


- (id)init
{
    self = [super init];
    if (self) {
        _imp = [NSMutableAttributedString new];
    }
    return self;
}

- (NSString *)string
{
    return _imp.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_imp attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self beginEditing];

    [_imp replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range
  changeInLength:(NSInteger)str.length - (NSInteger)range.length];
    [self endEditing];

}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];

    [_imp setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];

}

static NSRegularExpression *hashtagExpression;
static NSRegularExpression *iExpression;


- (void)processEditing
{

    

    NSRange paragaphRange = [self.string paragraphRangeForRange: self.editedRange];
    [self removeAttribute:NSFontAttributeName range:paragaphRange];
    ;[self addAttribute:NSFontAttributeName value:[FetchCell_Editor font] range:paragaphRange];

    
    NSRange topLineRange = [self.string rangeOfTopLine];

    /*
    NSLog(@"\neditedRang%@==%@\n\npara%@==%@\n\ntopline%@==%@\n%@\nline%@==%@\n\n\n",NSStringFromRange(self.editedRange), [self.string substringWithRange:self.editedRange],
          NSStringFromRange(paragaphRange),
          [self.string substringWithRange:paragaphRange],
          NSStringFromRange([self.string rangeOfTopLine]),
          [self.string topLine],
          [@(paragaphRange.location == topLineRange.length+1) description], NSStringFromRange([self.string lineRangeForRange:self.editedRange]), [self.string substringWithRange:[self.string lineRangeForRange:self.editedRange]] );
    */
    
    

    
    if(paragaphRange.location == topLineRange.length+1)
    {
        if(topLineRange.location != NSNotFound)
        {
        [self removeAttribute:NSFontAttributeName range:topLineRange];
        [self addAttribute:NSFontAttributeName value:[FetchCell_Editor boldFont] range:topLineRange];
        }
    }
    else if (paragaphRange.location == topLineRange.location)
    {
        if(topLineRange.location != NSNotFound)
        {
            [self removeAttribute:NSFontAttributeName range:topLineRange];
            [self addAttribute:NSFontAttributeName value:[FetchCell_Editor boldFont] range:topLineRange];
        }

    }
    
    
    
    
    

    
   
	
    
    

    
	
    
	// Clear text color of edited range
	[self removeAttribute:NSForegroundColorAttributeName range:paragaphRange];
	
    /*
	// Find all iWords in range
    	iExpression = iExpression ?: [NSRegularExpression regularExpressionWithPattern:@"i[\\p{Alphabetic}&&\\p{Uppercase}][\\p{Alphabetic}]+" options:0 error:NULL];
	[iExpression enumerateMatchesInString:self.string options:0 range:paragaphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		// Add red highlight color
		[self addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:result.range];
	}];
     */
    
    
    hashtagExpression = hashtagExpression ? : [NSRegularExpression regularExpressionWithPattern:@"#[\\p{Alphabetic}][\\p{Alphabetic}]+" options:0 error:NULL];
    
    [hashtagExpression enumerateMatchesInString:self.string options:0 range:paragaphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		// Add red highlight color
		[self addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(result.range.location, 1)];
	}];
  
    [super processEditing];





}



@end
