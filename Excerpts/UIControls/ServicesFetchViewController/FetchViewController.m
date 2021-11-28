//
//  FetchViewController.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 11/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "FetchViewController.h"
#import "FetchViewFlowLayout.h"
#import "FetchCell_Editor.h"
#import "NSAttributedString+V.h"
#import "TapTextView.h"
#import "FetchCell.h"

@interface FetchViewController () {
    CGFloat mainCellWidth;
    BOOL keyboardShown;

}

@end

@implementation FetchViewController
@synthesize editingIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)init{
    self = [self initWithCollectionViewLayout:[[FetchViewFlowLayout alloc] init]];
    if(self)
    {

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.collectionView.scrollsToTop = YES;
    [self.collectionView registerClass:[FetchCell  class] forCellWithReuseIdentifier:@"FetchCell"];
    [self.collectionView registerClass:[FetchCell_Editor class] forCellWithReuseIdentifier:@"EditorCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ViewCell"];
    [self.collectionView registerClass:[FetchImageCell class] forCellWithReuseIdentifier:@"imgCell"];
    


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)becomeFirstResponder
{

    if(self.isEditing)
    {
        [super becomeFirstResponder];
        
        DLog(@"%@", [editingIndexPath description]);

        FetchCell_Editor *cell = (FetchCell_Editor *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        
        if(cell) NSLog(@"CELL IS EXIST");
        [cell setEditing:self.isEditing];
        return YES;
    }
    else
    
        return YES;
    
}
-(BOOL)resignFirstResponder
{
    [super resignFirstResponder];

        FetchCell_Editor *cell = (FetchCell_Editor *)[self.collectionView cellForItemAtIndexPath:editingIndexPath];
        [cell setEditing:NO];
    return YES;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    if(section == 0)
        return 4;
    else
        return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    
    if(indexPath.section ==  0)
    {    FetchCell_Editor *cell = [cv dequeueReusableCellWithReuseIdentifier:@"EditorCell" forIndexPath:indexPath];

        cell.textView.text = @"Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.\nUse this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.";
        
        return cell;

    }else{
        FetchCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"FetchCell" forIndexPath:indexPath];
        cell.label.text = @"testing..";
        
        
        return cell;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(    NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayout];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
   // return self.collectionView.bounds.size;

    if(self.editing && indexPath.section == editingIndexPath.section && indexPath.item == editingIndexPath.item){

        NSLog(@"EDItiNG< CHNAGE");

        return CGSizeMake(self.collectionView.bounds.size.width, self.editingItemSize.height);
        
    }
    
    
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:
            {
                return CGSizeMake(self.collectionView.frame.size.width, 300);
       
                
            }
            break;
            case 1:
                return CGSizeMake(self.collectionView.frame.size.width, 100);
                break;
            default:
                return CGSizeMake(self.collectionView.frame.size.width, 100);
                break;

        }
    }
    else
        //f(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
            return CGSizeMake(self.collectionView.frame.size.width, 220);
        //else
        //return CGSizeMake(roundf(self.collectionView.bounds.size.width/2 -5), 125);
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    //[self.collectionView setContentOffset:CGPointZero animated:NO];
    if(!editingIndexPath)
    editingIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];


   // if(editing)    [self.collectionView setContentOffset:CGPointMake(0, 0)];


 
    if(editing)[self.collectionView scrollToItemAtIndexPath:editingIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    

    [super setEditing:editing animated:animated];
    

    /*
    if(editing)
        [self becomeFirstResponder];
    else
        [self resignFirstResponder];

    */
    DLog(@"isEditing=%@", @(self.isEditing));

  /*
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            0.00f * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        FetchCell_Editor *cell = (FetchCell_Editor *)[self.collectionView cellForItemAtIndexPath:editingIndexPath];
        [cell setEditing:editing];

    });
   */


    
}


- (void)keyboardWillChange:(NSNotification *)notification {
    
    
    NSDictionary* keyboardInfo = [notification userInfo];
    CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    
    
    //DLog(@" %@, %@", NSStringFromCGRect(keyboardFrame), @(keyboardShown));
    
    DLog(@"editing=%@", @(self.editing));
    
    if(self.editing)
    {

        FetchCell_Editor *cell = (FetchCell_Editor *)[self.collectionView cellForItemAtIndexPath:editingIndexPath];
        keyboardFrame = [cell convertRect:keyboardFrame fromView:nil];
        
        self.editingItemSize = CGSizeMake(self.collectionView.bounds.size.width, keyboardFrame.origin.y);
        
        //editingItemSize.height = keyboardFrame.origin.y;
        //editingItemSize.width  = self.collectionView.bounds.size.width;
        
    }

    self.collectionView.scrollEnabled = !self.editing;
    [self.collectionView performBatchUpdates:nil completion:nil];

    
    



}


@end
