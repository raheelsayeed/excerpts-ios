//
//  TapTextView.h
//  Vignettes
//
//  Created by M Raheel Sayeed on 12/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TapTextView : UITextView
@property (nonatomic, assign) BOOL imageAttachmentTouched;
@property (nonatomic, assign) BOOL disableContentScroll;

- (void)scrollToCaretInTextView:(UITextView *)textView animated:(BOOL)animated ;
@end
