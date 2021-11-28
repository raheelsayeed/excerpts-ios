//
//  VTextStorage.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 03/02/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "VTextStorage.h"
#import "NSString+RSParser.h"
#import "NSString+QSKit.h"
#import "NSAttributedString+QSKit.h"

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
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)str.length - (NSInteger)range.length];
    [self endEditing];

}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];
    [_imp setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];

}





/*
- (void)processEditing
{

    
    UIFontDescriptor* fontDescriptor = [UIFontDescriptor
                                        preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor* boldFontDescriptor = [fontDescriptor
                                            fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont* boldFont =  [UIFont fontWithDescriptor:boldFontDescriptor size: 0.0];
    UIFont* normalFont =  [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    

     UIFont * font = [UIFont fontWithName:@"Verdana" size:15]; //15
     //UIFont * boldFont  = [UIFont fontWithName:@"Verdana-Bold" size:14]; //14
    
    //[self addAttribute:NSForegroundColorAttributeName value:[UIColor darkTextColor] range:self.editedRange];

    NSRange paragaphRange = [self.string paragraphRangeForRange: self.editedRange];
    [self removeAttribute:NSFontAttributeName range:paragaphRange];
    [self addAttribute:NSFontAttributeName value:font range:paragaphRange];

    
    NSRange topLineRange = [self.string rangeOfTopLine];

    if(paragaphRange.location == topLineRange.length+1)
    {
        if(topLineRange.location != NSNotFound)
        {
        [self removeAttribute:NSFontAttributeName range:topLineRange];
        [self addAttribute:NSFontAttributeName value:boldFont range:topLineRange];
        }
    }
    else if (paragaphRange.location == topLineRange.location)
    {
        if(topLineRange.location != NSNotFound)
        {
            [self removeAttribute:NSFontAttributeName range:topLineRange];
            [self addAttribute:NSFontAttributeName value:boldFont range:topLineRange];
        }

    }
    
    
    
    
    

    
   
	
    
    

    

    
    
    
    static NSDataDetector *linkDetector;
    linkDetector = linkDetector ?: [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:NULL];
    
    [self removeAttribute:NSLinkAttributeName range:paragaphRange];
    
    [linkDetector enumerateMatchesInString:self.string
                                   options:0
                                     range:paragaphRange
                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
    {
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage imageNamed:@"ionicons-social-youtube-24.png"];
        
        NSAttributedString *linkedMark = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        //NSAttributedString * linkedMark = [[NSAttributedString alloc] initWithString:@" >>>" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Menlo-Regular" size:13],NSForegroundColorAttributeName: [UIColor redColor],CCHLinkAttributeName:result.URL}];
        
        
        [self insertAttributedString:linkedMark atIndex:result.range.location+result.range.length];
        [self addAttribute:NSLinkAttributeName value:result.URL range:result.range];
    }];
    



    DLog(@"before superProcessEditing");
    DLog(@"after superProcessEditing");
    
//    [self applyUnderlinesForLinks];
    
    [super processEditing];

}


- (void)applyUnderlinesForLinks
{
    
    NSArray * links = [self.string qs_links];
    
    if(!links) return;
    
    for(NSString * link in links)
    {
        
        NSRange range = [self.string rangeOfString:link];
      
        

        [self addAttribute:NSLinkAttributeName value:link range:range];
        
    }
}
 */


@end
