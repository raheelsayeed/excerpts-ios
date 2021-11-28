//
//  ReviseViewController.m
//  Renote
//
//  Created by M Raheel Sayeed on 23/02/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import "ReviseViewController.h"
#import "DataManager.h"
#import "MRModalAlertView.h"

@interface ReviseViewController ()
{
    NSDate * stage1;
    NSDate * stage2;
    NSDate * stage3;
    NSDate * stage4;
    NSTimer * timer;
    NSDate * currentDate;
}
@property (nonatomic) NSMutableArray * notes;
@property (nonatomic) UILabel * stopwatchTimeLabel;
@property int currentTimeInSeconds;


@end


@implementation ReviseViewController


- (BOOL)prefersStatusBarHidden
{
    return NO;
}
+ (UIViewController *)presentWithNavigationController
{
    ReviseViewController * r = [[ReviseViewController alloc] initWithNote:nil];
    r.title = @"Revise";
    r.shouldTurnOnEditMode = NO;
    UINavigationController * n = [[UINavigationController alloc] initWithRootViewController:r];
    r.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:r action:@selector(dismissRevision:)];
    UIBarButtonItem * next =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:r action:@selector(goNextWithSuccess:)];
    UIBarButtonItem * previous =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:r action:@selector(goBack:)];
    UIBarButtonItem * flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem * get = [[UIBarButtonItem alloc] initWithTitle:@"Hit Me" style:UIBarButtonItemStylePlain target:r action:@selector(getNotes:)];
    
    r.navigationItem.leftBarButtonItem = get;

    r.stopwatchTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    r.stopwatchTimeLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    r.stopwatchTimeLabel.text = @"00:00";
    r.stopwatchTimeLabel.textColor = [UIColor lightTextColor];
    UIBarButtonItem *prog = [[UIBarButtonItem alloc] initWithCustomView:r.stopwatchTimeLabel];
    
    
    [r setToolbarItems:@[prog,flex, previous,next]];
    
    n.navigationBar.barStyle = UIBarStyleBlack;
    n.view.backgroundColor = [UIColor blackColor];
    n.toolbar.barStyle = UIBarStyleBlack;
    n.toolbar.tintColor = kColor_WhiteButtonTint;
    n.navigationBar.tintColor = kColor_WhiteButtonTint;
    r.navigationItem.titleView = [r titleLabel];
    [n setToolbarHidden:NO];
    return n;
}

static NSString  * stage1p  = @"mentalStatus == 0 AND (lastAccessedDate <= %@ OR lastAccessedDate == nil)";
static NSString  * stage2p  = @"mentalStatus == 1 AND lastAccessedDate <= %@";
static NSString  * stage3p  = @"mentalStatus == 2 AND lastAccessedDate <= %@";
static NSString  * stage4p  = @"mentalStatus == 3 AND lastAccessedDate <= %@";
- (void)getNotes:(id)sender
{
    self.notes = nil;
    self.notes = [NSMutableArray new];
    
    
    NSManagedObjectContext * moc = [[DataManager sharedInstance] managedObjectContext];
    NSFetchRequest * fetch = [[NSFetchRequest alloc] initWithEntityName:@"Note"];
    [fetch setResultType:NSManagedObjectIDResultType];

    for(NSInteger i = 0; i<4; i++)
    {
        NSString * pString;
        NSDate * date;
        switch (i) {
            case 0:
                pString = stage1p;
                date = stage1;
                break;
            case 1:
                pString = stage2p;
                date = stage2;
                break;
            case 2:
                pString = stage3p;
                date = stage3;
                break;
            case 3:
                pString = stage4p;
                date = stage4;
                break;
            default:
                break;
        }
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:pString, date];
        [fetch setPredicate:predicate];
        NSError *error = nil;
        NSArray *noteArr = [moc executeFetchRequest:fetch error:&error];
        if (noteArr == nil) {
            
        }
        else
        {
            NSArray * randoms = [self randomObjectsFromArray:noteArr maxCount:10];
            for(NSManagedObjectID * oid in randoms)
            {
                [self.notes addObject:[moc objectWithID:oid]];
            }
        }
    }
    
    self.note = [_notes firstObject];
    [self stopTimer];
    [self reset:nil];
    [self startTimer];

}
- (void)startTimer {
    
    if (!_currentTimeInSeconds) {
        _currentTimeInSeconds = 0 ;
    }
    
    if (!timer) {
        timer = [self createTimer];
    }
    
}
- (void)stopTimer
{
        [timer invalidate];
        
}
- (void)reset:(id)sender {
    
    if (timer) {
        [timer invalidate];
        timer = [self createTimer];
    }
    _currentTimeInSeconds = 0;
    self.stopwatchTimeLabel.text = [self formattedTime:_currentTimeInSeconds];
}


- (NSTimer *)createTimer {
    return [NSTimer scheduledTimerWithTimeInterval:1.0
                                            target:self
                                          selector:@selector(timerTicked:)
                                          userInfo:nil
                                           repeats:YES];
}

- (void)timerTicked:(NSTimer *)timer {
    
    _currentTimeInSeconds++;
    self.stopwatchTimeLabel.text = [self formattedTime:_currentTimeInSeconds];

    
}
- (NSString *)formattedTime:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    //int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (NSArray *)randomObjectsFromArray:(NSArray *)array maxCount:(NSInteger)maxCount
{
    NSMutableArray* pickedNames = [[NSMutableArray alloc] init];
    
    
    if ( [array count] >= maxCount )
    {
        while (maxCount > 0)
        {
            id name = [array objectAtIndex: arc4random() % [array count]];
            
            if ( ! [pickedNames containsObject: name] )
            {
                [pickedNames addObject: name];
                maxCount --;
            }
        }
    }
    
    return pickedNames.copy;
}

- (void)goNextWithSuccess:(BOOL)success
{
    if(!self.note) return;
    
    NSInteger idx = [_notes indexOfObject:self.note];

    idx += 1;
    
    if(idx < _notes.count)
    {
        if ([currentDate timeIntervalSinceReferenceDate] == [[(Note *)_notes[idx] lastAccessedDate] timeIntervalSinceReferenceDate])
        {
            self.note = _notes[idx];
        }
        else
        {
            __weak typeof(self) weakSelf = self;
            MRModalAlertView * input = [[MRModalAlertView alloc] initWithTitle:@"Done!" mesage:@"Graduate this note for the next revision stage? If not, this note will remain in its current revision stage."];
            [input showForView:self.navigationController.view selectorBlock:^(BOOL result) {
            
                if(result)
                {
                        weakSelf.note.mentalStatus = [NSNumber numberWithInteger:(weakSelf.note.mentalStatus.integerValue+1)];
                }
            
                weakSelf.note = weakSelf.notes[idx];
            }];
        }
    }
    else
    {
        
        [MRModalAlertView showMessage:@"Tap \"Hit Me\" to start a new session" title:@"All Done" overView:self.navigationController.view];
    }
}

- (void)goBack:(id)sender
{
        if(!self.note) return;
        
        NSInteger idx = [_notes indexOfObject:self.note];
        
        idx -= 1;
        
        if(idx >= 0) self.note = _notes[idx];
        else
        {
            
        }
}

static NSDateFormatter *formatter = nil;

+ (NSDateFormatter *)formatter
{
    if(!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        [formatter setDateStyle:NSDateFormatterShortStyle];
    }
    return formatter;
}

-(BOOL)revisedToday:(Note *)n
{
    return  ([currentDate timeIntervalSinceReferenceDate] == [[n  lastAccessedDate] timeIntervalSinceReferenceDate]);
}


- (void)setNote:(Note *)note
{
    
    NSInteger revisionStatus = note.mentalStatus.integerValue;
    
    switch (revisionStatus) {
        case 0:
            
            if(!note.lastAccessedDate) self.title = @"FIRST REVISION\nTOTALLY NEW";
            else
            self.title = [NSString stringWithFormat:@"FIRST REVISION\nLAST REVIEWED ON %@", [[[self class] formatter] stringFromDate:note.lastAccessedDate]];
            break;
        case 1:
            self.title = [NSString stringWithFormat:@"SECOND REVISION\nLAST REVIEWED ON %@", [[[self class] formatter] stringFromDate:note.lastAccessedDate]];
            break;
        case 2:
            self.title = [NSString stringWithFormat:@"THIRD REVISION\nLAST REVIEWED ON %@", [[[self class] formatter] stringFromDate:note.lastAccessedDate]];
            break;
        case 3:
            self.title = [NSString stringWithFormat:@"FOURTH REVISION\nLAST REVIEWED ON %@", [[[self class] formatter] stringFromDate:note.lastAccessedDate]];
            break;
        default:
            self.title = [NSString stringWithFormat:@"MORE THAN FOUR REVISIONS\nLAST REVIEWED ON %@", [[[self class] formatter] stringFromDate:note.lastAccessedDate]];
            break;
    }
    // ::: UNDO LAST ACCESSED DATE:
    
    [super setNote:note];
    
    self.note.lastAccessedDate = currentDate;
    
 

}

- (UILabel *)titleLabel
{
    UILabel * lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    lbl.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.lineBreakMode = NSLineBreakByWordWrapping;
    lbl.numberOfLines = 2;
    lbl.textColor = [UIColor whiteColor];
    return lbl;
}
- (void)setTitle:(NSString *)title
{
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange range = [title rangeOfString:@"\n"];
    if(range.location != NSNotFound)
    {
        NSRange r = NSMakeRange(range.location+1, title.length-(range.location+1));
        [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:10] range:r ];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor lightTextColor] range:r];

    }
    [(UILabel *)self.navigationItem.titleView  setAttributedText:str.copy];
    [(UILabel *)self.navigationItem.titleView  sizeToFit];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    

    //incremented dates
    
    currentDate = [NSDate date];
    
    stage1 = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                    value:-3
                                                                   toDate:currentDate
                                                                  options:0];
    
    stage2 = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                      value:-7
                                                     toDate:currentDate
                                                    options:0];
    
    stage3 = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                      value:-20
                                                     toDate:currentDate
                                                    options:0];
    
    stage4 = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                      value:-30
                                                     toDate:currentDate
                                                    options:0];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dismissRevision:(id)sender
{
    id s = (self.navigationController) ? self.navigationController : self;
    [s dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
