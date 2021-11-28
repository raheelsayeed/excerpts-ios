//
//  ExcerptViewController.h
//   Renote
//
//  Created by M Raheel Sayeed on 23/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "FetcherViewController.h"
#import "WorkflowActionActivity.h"
#import "HPTextViewTapGestureRecognizer.h"
#import  <TextExpander/SMTEDelegateController.h>

typedef void (^EditingCompletionBlock)(id  inputObject, BOOL saveTrack);

@class Note;

@interface ExcerptViewController : FetcherViewController <HPTextViewTapGestureRecognizerDelegate>

@property (nonatomic, strong) Note * note;
@property (nonatomic, copy)   EditingCompletionBlock editingCompletionBlock;
@property (nonatomic, strong) SMTEDelegateController * textExpander;
@property (nonatomic, assign) BOOL shouldTurnOnEditMode;


-(instancetype)initWithNote:(id)note;

-(void)setupEditorWithText:(id)text tags:(NSArray *)tagArray completion:(EditingCompletionBlock)completionBlock;

- (void)setTheme:(NSString *)themeName;
- (void)addSettingsObservers:(BOOL)add;

@end
