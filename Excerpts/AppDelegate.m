//
//  AppDelegate.m
//   Renote
//
//  Created by M Raheel Sayeed on 22/03/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "AppDelegate.h"
#import "RWebViewController.h"
#import "RSCollectionViewController.h"
#import "MainCollectionViewLayout.h"
#import "TagViewController.h"
#import "DataManager.h"
#import <Dropbox/Dropbox.h>
#import "RSCallbackParser.h"
#import "Workflows.h"
#import "FetcherViewController.h"
#import "ExcerptViewController.h"

#import "IOAction.h"
#import "ContainerViewController.h"
#import "UIColor+LightDark.h"

#import "AFJSONRequestOperation.h"

#import "MainCell.h"
#import "MainCellSeparatorView.h"
#import "FetchCell_Editor.h"
#import "SectionHeader.h"

#import "NSString+RSParser.h"
#import "NSString+QSKit.h"
#import "RequestObject.h"

#import <ENSDK/ENSDK.h>
#import "JTSReachabilityResponder.h"

#import "AFNetworkActivityIndicatorManager.h"
#import "ContainerController.h"

#import <notify.h>
#import <TextExpander/SMTEDelegateController.h>
#import "DemoViewController.h"
#import "MRModalAlertView.h"


static int SMAppDelegateCustomKeyboardWillAppearToken = 0;




@interface AppDelegate ()< ContainerViewControllerDatasource>
{
    NSMutableArray * rsarrayM;
    NSArray *rsarray;
    NSURL * excerptsURLCallHandler;
}
@property (nonatomic, strong) UIViewController * pinkVC;
@end

@implementation AppDelegate
NSString *SMTEExpansionEnabled = @"SMTEExpansionEnabled";

@synthesize excerptViewController = _excerptViewController;


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    /*
    
    NSString * s = @"http://en.wikipedia.org/wiki/Coulomb's_Law";
    
    NSLog(@" \n%@\n%@ \n%@ \n%@ \n %@\n %@",
          s,
          [s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
          [s stringByAddingPercentEscapesUsingEncoding:NSUTF32StringEncoding],
          [s ro_URLEncode],
          [s ro_URLEncoding2],
          [NSURL URLWithString:s]
          );
    
    s = @"http://en.wikipedia.org/wiki/Mallory–Weiss_syndrome";
    
    
    NSLog(@"\n\n \n%@\n%@\n %@ \n %@\n %@\n",
          s,
          [s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
          [s ro_URLEncode],
          [s ro_URLEncoding2],
          [NSURL URLWithString:[s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
          );
    
    s =           [s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"\n\n\n%@\n%@\n\n%@",
          s,
          [s stringByRemovingPercentEncoding],
          [s stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    
    */
    
    
    return YES;
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    return YES;
    
    BOOL firstTime = [self isFirstTimeLaunch];
    
    
    self.containerViewController = [[ContainerController alloc] init];
    [_containerViewController setDatasource:self];
    MainCollectionViewLayout *collectionViewLayout = [[MainCollectionViewLayout alloc] init];
    self.mainViewController = [[RSCollectionViewController alloc] initWithCollectionViewLayout:collectionViewLayout];
    [self.containerViewController setInitialViewController:self.mainViewController];
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = _containerViewController;
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    if(firstTime)
    {
        DemoViewController * demo = [[DemoViewController alloc] init];
        [_containerViewController presentViewController:demo animated:NO completion:nil];
    }
    

    
    
    DBAccountManager *mgr = [[DBAccountManager alloc] initWithAppKey:@"y7tvlnfb2ubbago" secret:@"wka5u92zqkg8o9p"];
    [DBAccountManager setSharedManager:mgr];
    if ([mgr linkedAccount]) {
        [self initiateSync];
    }
    [self setupURLHandlers];
    
    BOOL textExpanderEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:SMTEExpansionEnabled];
    [SMTEDelegateController setExpansionEnabled:textExpanderEnabled];

    notify_register_dispatch("com.smileonmymac.tetouch.keyboard.viewWillAppear",
                             &SMAppDelegateCustomKeyboardWillAppearToken,
                             dispatch_get_main_queue(), ^(int t) {
                                 [SMTEDelegateController setCustomKeyboardExpansionEnabled:NO];
                             });
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    self.excerptViewController = [[ExcerptViewController alloc] initWithNote:nil];
    
    [self loadTheme:@"Default"];


    return YES;
}
- (void)testingThings
{
    
    
    
    
    NSString *idf  = @"Alveolar–arterial_gradient";
    NSString * iden = [idf stringByReplacingOccurrencesOfString:@"–" withString:@"-"];
    iden = [idf ro_URLEncode];
    iden = idf;
    
    //NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(nil,(CFStringRef)@"parameter",NULL,(CFStringRef)@"!*'();@&+$,/?%#[]~=_-.:",kCFStringEncodingUTF8 );
    
    
    //getURLString = [NSString stringWithFormat:getURLString,iden];
    NSString * getURLString = @"http://en.wikipedia.org/w/api.php?action=query&titles=%@&prop=extracts|pageimages&exintro&indexpageids&piprop=thumbnail|name&pilimit=3&pithumbsize=500&format=json";
    getURLString = [NSString stringWithFormat:getURLString, iden];
    
    //getURLString = [NSString stringWithFormat:[getURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], iden];
    
    getURLString = [getURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //Alveolar–arterial gradient
    //Alveolar-arterial gradient
    NSURL * url = [NSURL URLWithString:getURLString];
    if(!url)
    {
        DLog(@"%@=%@", url.description, getURLString);
    }
    
    
    //    idf = @"http://foobar:nicate@example.com:8080";
    
    
    

}

- (UIViewController *)containerViewController:(UIViewController *)container viewControllerBeforeViewController:(UIViewController *)vc
{
    if(vc == _mainViewController)
    {
        _tagViewController.view.tag = 9898;
        return nil;
    }
    
    if(vc == _webViewController)
    {
        return _excerptViewController;
    }
    
    return _mainViewController;
}
- (UIViewController *)containerViewController:(UIViewController *)container viewControllerAfterViewController:(UIViewController *)vc
{
    if(vc == _webViewController)
    {
        return nil;
    }
    
    if(vc == _excerptViewController)
    {
        
        return _webViewController;
    }
    
    return _excerptViewController;
    
}
- (void)containerViewController:(UIViewController *)container viewControllerWillTransitionToNewTraits:(UITraitCollection *)traitCollection coordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [_webViewController willTransitionToTraitCollection:traitCollection withTransitionCoordinator:coordinator];
    [_excerptViewController willTransitionToTraitCollection:traitCollection withTransitionCoordinator:coordinator];
    [_mainViewController willTransitionToTraitCollection:traitCollection withTransitionCoordinator:coordinator];
}

- (void)showGlobalWebViewWithURL:(NSURL *)url
{
    if(!_webViewController)
    {
        self.webViewController = [[RWebViewController alloc] initWithURL:url];
    }
    else
    {
        [_webViewController loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    [_containerViewController transitionToNext];
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
        __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
    */
    [_tagViewController saveOnTerminate];
    NSManagedObjectContext * moc  = [[DataManager sharedInstance] managedObjectContext];
    if([moc hasChanges])
    {
        NSError * error;
        [moc save:&error];
        if(error)   NSLog(@"%@", error.description);
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.renoteapp.ios.shared"];
        NSArray * a  = [defaults arrayForKey:@"shared_Notes"];
        if(a)
        {
            for(NSString * text in a)
            {
//                NSLog(@"shared: %@\n", text);
                [[DataManager sharedInstance] newNote:text tags:nil];
            }
            [defaults removeObjectForKey:@"shared_Notes"];
            [defaults synchronize];
            [[DataManager sharedInstance] save];
        }
    });
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}



- (void)xCallbackURLParser:(SBRCallbackParser *)parser shouldOpenSourceCallbackURL:(NSURL *)callbackURL{
    
    [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:callbackURL afterDelay:0.7];
}


-(BOOL)isFirstTimeLaunch
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:kSettings_CacheLinks])
    {
        [defaults setInteger:1                          forKey:@"SettingsVersion"];
        [defaults setObject:@YES                        forKey:kSettings_CacheLinks];
        [defaults setObject:@"/nvALT/"                  forKey:kSettings_AutoImportFolderPath];
        [defaults setObject:@"Default"                  forKey:kSettings_ThemeName];
        [defaults setObject:@YES                        forKey:kSettings_DatastoreSyncEnabled];
        [defaults setObject:@"Source Sans Pro"          forKey:kSettings_EditorFontFamily];
        [defaults setObject:@(0.0)                      forKey:kSettings_EditorFontSize];
        [defaults setObject:@NO                         forKey:kSettings_FirstSyncRound];
        [defaults setObject:@YES                        forKey:kSettings_FetchNoteLinks];
        [defaults setObject:@1                          forKey:kSettings_MainListStyle_Grid];
        return YES;
    }
    
    return NO;
}


-(void)setupURLHandlers{
    
    RSCallbackParser *urlParser = [RSCallbackParser sharedParser];
    [urlParser setURLScheme:@"renote"];
    [urlParser setDelegate:self];
    __weak AppDelegate * weakSelf = self;
    __weak RSCollectionViewController * mainController =  _mainViewController;
    
    [urlParser addHandlerForActionName:@"get"  handlerBlock:^BOOL(NSDictionary *parameters, NSString *source, SBRCallbackActionHandlerCompletionBlock completion) {
        
        
        [weakSelf.mainViewController activeSelectionModeForGetAction:YES params:parameters callback:completion];
        
        return YES;
    }];
    
    [urlParser addHandlerForActionName:@"new" requiredParameters:@[@"text"] handlerBlock:^BOOL(NSDictionary *parameters, NSString *source, SBRCallbackActionHandlerCompletionBlock completion)
     {
         if(completion)
         {
             __block SBRCallbackActionHandlerCompletionBlock blockComp = completion;
             [weakSelf showEditorViewControllerWithObject:parameters[@"text"]
                                                     from:nil
                                          completionBlock:^(id inputObject, BOOL saveTrack)
              {
                  if(saveTrack)
                  {
                      blockComp(nil, nil, NO);
                  }
                  else
                  {
                      blockComp(nil, nil, YES);
                  }
              
              }
                                             startEditing:YES];
         }
         else
         {
             [weakSelf showEditorViewControllerWithObject:parameters[@"text"]
                                                     from:nil
                                          completionBlock:nil
                                             startEditing:YES];

         }
         return YES;
         
     }];
    
}



- (void)initiateSync
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL syncEnabled = [[[NSUserDefaults standardUserDefaults] objectForKey:kSettings_DatastoreSyncEnabled] boolValue];
        BOOL autoImport = [[[NSUserDefaults standardUserDefaults] objectForKey:kSettings_AutoImport] boolValue];
        if(syncEnabled) [[DataManager sharedInstance] setSyncEnabled:syncEnabled];
        if(autoImport)  [[DataManager sharedInstance] startDbxFolderSync];
    });
}
- (void)checkFileForImport:(NSURL *)fileURL
{

    __block UIAlertController * alertC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Importing \"%@\"\nPlease wait...", [fileURL lastPathComponent]] message:nil    preferredStyle:UIAlertControllerStyleAlert];
    UIViewController * vc = self.window.rootViewController;
    while (vc.presentedViewController)
    {
        vc = vc.presentedViewController;
    }

    [vc presentViewController:alertC animated:YES completion:nil];
    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        [IOAction importOperationWithFileURL:fileURL completion:^(id exportedObject, BOOL success) {

            if(success)
            {
                
                [alertC dismissViewControllerAnimated:YES completion:^{
                    UIViewController * vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                    while (vc.presentedViewController)
                    {
                        vc = vc.presentedViewController;
                    }
                    
                    [MRModalAlertView showMessage:nil title:@"Imported Successfully" overView:vc.view];
                }];
            }
            else
            {
                [alertC dismissViewControllerAnimated:YES completion:^{
                    UIViewController * vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                    while (vc.presentedViewController)
                    {
                        vc = vc.presentedViewController;
                    }
                    [MRModalAlertView showMessage:nil title:@"Something went wrong, could not import" overView:vc.view];
                }];
            }
        }];
        
    });
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  
    if(url.isFileURL)
    {
        [self checkFileForImport:[url filePathURL]];
            return YES;
    }
    
    if ([url.scheme isEqualToString:@"w-renote"])
    {
        [[Workflows shared] handleURL:url];
        return YES;
    }
    else if ([url.scheme isEqualToString:@"renote-get-snippets-xc"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewSnippetsArrived" object:url userInfo:nil];
    }
    else if ([url.scheme isEqualToString:@"renote-fill-xc"])
    {
        id root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        if([root topViewController])
        {
            root = [root topViewController];
        }
        
        if([root respondsToSelector:@selector(textExpander)])
        {
            SMTEDelegateController * textExpander = [root performSelector:@selector(textExpander)];
            [textExpander handleFillCompletionURL:url];
        }
    }
    else if ([url.scheme isEqualToString:@"db-y7tvlnfb2ubbago"])
    {
        DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
        if (account)
        {
            [self initiateSync];
            NSLog(@"Dbx linked successfully!");
            return YES;
        }
        return YES;
    }
    else if([url.scheme isEqualToString:@"en-raheelsayeed-0034"])
    {
        BOOL didHandle = [[ENSession sharedSession] handleOpenURL:url];
        
        return didHandle;
    }
    if([url.absoluteString rangeOfString:@"?"].location != NSNotFound)
    {
        [[RSCallbackParser sharedParser] handleURL:url];
    }
    
    return YES;
}

-(void)showEditorViewControllerWithObject:(id)object from:(id)fromController  completionBlock:(EditingCompletionBlock)completion startEditing:(BOOL)startEditing
{
    if(!_excerptViewController)
    {
        self.excerptViewController  = [[ExcerptViewController alloc] initWithNote:object];
        [self.excerptViewController setEditingCompletionBlock:completion];

    }
    else
    {
        [_excerptViewController setupEditorWithText:object tags:nil completion:completion];
    }
    
    _excerptViewController.shouldTurnOnEditMode = startEditing;
   
    if(!_excerptViewController.view.window)
    {
        [_containerViewController transitionToNext];
    }

}

- (void)addSettingsObserver:(BOOL)observe
{
    
   [_excerptViewController addSettingsObservers:observe];

    [_mainViewController addSettingsObservers:observe];
    
}

/*
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([self.window.rootViewController.presentedViewController isKindOfClass: [TagViewController class]])
    {
        UIViewController * vc = self.window.rootViewController.presentedViewController;
        
        
        if (vc.isBeingPresented)
        {
            return UIInterfaceOrientationMaskPortrait;
        }
        else return UIInterfaceOrientationMaskAll;
    }
    else return UIInterfaceOrientationMaskAll;
}
*/
- (void)loadTheme:(NSString *)themeName
{
    
    
    if([themeName isEqualToString:@"Default"])
    {
        UIColor *bgColor = kColor_MainViewBG;

        self.window.tintColor = kColor_Tint_Default_Blue;
        [_mainViewController.collectionView setBackgroundColor:bgColor];
        

        
        
    }
    else if ([themeName isEqualToString:@"Dark"])
    {
        //[self SectionHeaderBG:[UIColor blackColor]];
        //[self MainCellSeparatorViewColor:[UIColor redColor]];
        UIColor *blueOnDarkContent = kColor_Dark_Content_tint;
        self.window.tintColor = blueOnDarkContent;
        [_mainViewController.collectionView setBackgroundColor:kColor_MAinView_Dark_Background];

        



        

    }
    
    [_excerptViewController  setTheme:themeName];

}


- (void)SectionHeaderBG:(UIColor*)color
{
    [[SectionHeader appearanceWhenContainedIn:[UICollectionView class], nil] setBackgroundColor:color];
}
- (void)MainCellSeparatorViewColor:(UIColor *)color
{
    [[MainCellSeparatorView appearanceWhenContainedIn:[UICollectionView class],  nil] setBackgroundColor:color];
}
- (void)MainCellBG:(UIColor *)color
{
    [[MainCell appearanceWhenContainedIn:[UICollectionView class], nil] setBackgroundColor:color];
}




- (UIViewController *)demo
{
    DemoViewController * d = [[DemoViewController alloc] init];
    return d;
}


@end
