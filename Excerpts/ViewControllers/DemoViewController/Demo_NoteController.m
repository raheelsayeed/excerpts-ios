//
//  Demo_NoteController.m
//  Renote
//
//  Created by M Raheel Sayeed on 29/01/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import "Demo_NoteController.h"
#import "KeyboardAccessoryBar.h"
#import "DemoViewController.h"

@interface Demo_NoteController () <UITextViewDelegate>
{
    DemoViewController * parent;
}





@end

@implementation Demo_NoteController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewCount = 0;
    
    self.msg = [[UILabel alloc] initWithFrame:CGRectMake(50, 200, self.view.bounds.size.width - 100, 100)];
    self.msg.textColor = [UIColor lightGrayColor];
    self.msg.font      = [UIFont fontWithName:@"Lato-BlackItalic" size:18];
    self.msg.lineBreakMode = NSLineBreakByWordWrapping;
    self.msg.numberOfLines = 0;
    self.msg.textAlignment = NSTextAlignmentCenter;
    self.msg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.msg.userInteractionEnabled = NO;
    
    [self.view addSubview:self.msg];
    
}

- (void)startDemo
{
    self.viewCount += 1;

    parent = (DemoViewController *)self.parentViewController;

    if((id)[self msgForVisit:self.viewCount])
    {
        [self showMsg:(id)[self msgForVisit:self.viewCount] whileEditing:NO];
    }
    
    [parent.bubble startAnimatingLeftoToRight:YES atPoint:CGPointMake(self.view.bounds.size.width * 0.1, CGRectGetMidY(self.view.bounds))];
}

- (void)leftKeyboardAccessoryBarAction:(id)sender
{
    [super performSelector:@selector(rightKeyboardAccessoryBarAction:) withObject:sender];
}

- (void)setNote:(Note *)note
{
    [super setNote:note];
    
    self.shouldTurnOnEditMode = NO;
}


- (NSString *)msgForVisit:(NSInteger)visit
{
    switch (visit) {
            case 1:
        {
            self.note = (id)@"The Note Title";
            
            return @"Tap anywhere to Edit this Note\n\nDrag from Left-To-Right to go back.";
        }
            break;

        case 2:
        {
            return @"Tap anywhere to Edit this Note\n\nDrag from Left-To-Right to go back.";
            self.note = (id)@"This Note, was open for a while";
        }
            break;
        case 3:
            
        {
            self.note = (id) @"Pythagoren thing:\n\nhttp://en.wikipedia.org/wiki/Pythagorean_theorem";
            
            return @"Some notes can have links. RENOTE can recognize URL links of Wikipedia, Youtube, Twitter-tweets, Vimeo, PubMed and Instagram are automatically fetched (if Turned on in Settings)";
        }
            break;
        default:
            return @"For everything else, See Settings > Help.";
            break;
    }
    
    
    
    return nil;
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if(!editing)
    {
        [self showMsg:@"Tap anywhere to Edit this Note\n\nDrag from Left-To-Right to go back." whileEditing:NO];
        [parent.bubble startAnimatingLeftoToRight:YES atPoint:CGPointMake(self.view.bounds.size.width * 0.2, CGRectGetMidY(self.view.bounds))];
    }
    else
    {
        
        [self showMsg:@"For Tags & Links: Drag the text Left-To-Right. Do the same guesture to come back.\n\nTap 'Save' or '⇊' to hide keyboard without Saving." whileEditing:YES];
        [parent.bubble startAnimatingLeftoToRight:YES atPoint:CGPointMake(self.view.bounds.size.width * 0.2, 40)];
    }


}
//            return @"For Tags & Links: Drag the text Left-To-Right. Do the same guesture to come back.\n\nTap 'Save' or '⇊' to hide keyboard without Saving.";

- (void)showMsg:(NSString *)msg whileEditing:(BOOL)editing
{
    _msg.text = msg;
    [_msg sizeToFit];
    CGRect frame  = _msg.frame;
    frame.origin.y = (editing) ? 100.f : (CGRectGetHeight(self.view.bounds) * 0.8) - frame.size.height;
    _msg.frame = frame;
}


-(void)doActions:(id)sender{
    
    [MRModalAlertView showMessage:@"A Share sheet will show up with options like:\bCopy all Links\nRearranging Paragraphs\nMarkdown preview" title:@"Share & Action Menu" overView:self.view];

}


@end
