//
//  SettingsController.m
//   Renote
//
//  Created by M Raheel Sayeed on 29/07/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "SettingsController.h"
#import "StorageOpsViewController.h"
#import "DataManager.h"
#import "AboutViewController.h"
#import "CustomActionsController.h"
#import <Dropbox/Dropbox.h>
#import <ENSDK/ENSDK.h>
#import "AppDelegate.h"
#import "AppearanceView.h"
#import "ActionMethods.h"
#import "DebugDatastoreController.h"
#import "DemoViewController.h"
#import "UIImageView+AFNetworking.h"




@interface SettingsController () <FieldEditorViewControllerDelegate>
{
    BOOL currentDropboxLinkStatus;
}

@property (nonatomic) FieldSectionSpecifier * syncAndstorage;
@property (nonatomic) FieldSectionSpecifier * textExpanderSection;
@property (nonatomic) FieldSectionSpecifier * accounts;
@property (strong, nonatomic) SMTEDelegateController *textExpander;


@end

@implementation SettingsController
#define kSection_Accounts 4
#define kSection_TE 3

- (id)init
{
    FieldSectionSpecifier * appearance = [SettingsController buttonWithKey:@"appearance" title:@"Fonts (editor) & List Style" arrow:NO dV:nil];

    
    FieldSectionSpecifier * helpSection = [SettingsController buttonsWithTitles:@{@"basicNavigation":@"Basic Navigation",
                                                                                  @"autoImportHelp":@"Auto Dropbox File Import",
                                                                                  @"syncHelp":@"Sync & Backup",
                                                                                  @"howIUse":@"Tip: How I used this app",
                                                                                  @"Tag_Selection": @"Tag Selection",
                                                                                  @"Excerpts_Fetching": @"Links: Excerpt fetches"}
                                                                          arrow:YES
                                                                   sectionTitle:@"Help" sectionDesc:nil];
    FieldSpecifier * helpSubSection = [FieldSpecifier subsectionFieldWithSection:helpSection key:@"helpSection"];
    helpSubSection.shouldDisplayDisclosureIndicator = YES;
    FieldSpecifier * about = [FieldSpecifier buttonFieldWithKey:@"about" title:@"About"];
    about.shouldDisplayDisclosureIndicator = YES;
    
    FieldSectionSpecifier * helpAndAboutSection = [FieldSectionSpecifier sectionWithFields:@[about, helpSubSection] title:@"Help & About" description:nil];
    
    
    
    FieldSectionSpecifier * urlActions = [SettingsController buttonWithKey:@"urlactions" title:@"URL Actions" arrow:YES dV:nil];
    
    BOOL useTextExpander = [[NSUserDefaults standardUserDefaults] boolForKey:SMTEExpansionEnabled];
    self.textExpanderSection = [self textExpanderSectionEnabled:useTextExpander];


    //FieldSectionSpecifier * debugDatastore = [SettingsController buttonWithKey:@"debugdatastore" title:@"Debug Datastore" arrow:YES dV:nil];
    

    NSArray * sections  = @[self.syncAndstorage,
                            appearance,
                            [self settings],
                            self.textExpanderSection,
                            [self accounts],
                            urlActions,
                            helpAndAboutSection
//                            debugDatastore  //::: REMOVE DB
                            ];
    
    self = [super initWithFieldSections:sections tableStyle:UITableViewStyleGrouped title:@"Settings"];
    if(self)
    {
        self.editorIdentifier = @"main";
        self.delegate = self;
        self.doneButtonTitle = @"Done";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textExpanderSnippetsArrived:) name:@"NewSnippetsArrived" object:nil];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate]  addSettingsObserver:YES];

    
    
    /*
    __weak typeof(self) ws = self;
    [[DBAccountManager sharedManager] addObserver:self block:^(DBAccount *account) {
        __strong typeof(self) strongself = ws;
        [strongself reloadSection:0];
        [strongself reloadSection:kSection_Accounts];
    }];
    
    */


    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([self.editorIdentifier isEqualToString:@"main"])
    {
        BOOL isLinked = ([[[DBAccountManager sharedManager] linkedAccount] isLinked]) ? YES : NO;

        if(currentDropboxLinkStatus != isLinked)
        {
            [self reloadSection:kSection_Accounts];
            [self reloadSection:0];
            
        }
        
    


        
    }
    
}
- (void)dealloc
{
    //[[DBAccountManager sharedManager] removeObserver:self];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate]  addSettingsObserver:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)userDefaultsDidChange
{
   // [[self tableView] reloadData];
}
- (void)applicationDidBecomeActive:(NSNotification *)note
{
   // [[self tableView] reloadData];
}
- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

+ (FieldSectionSpecifier *)buttonsWithTitles:(NSDictionary *)dict arrow:(BOOL)arrow sectionTitle:(NSString *)sectiontitle sectionDesc:(NSString *)desc
{
    
    NSMutableArray * m = [@[] mutableCopy];
    for(NSString * key in dict.allKeys)
    {
        FieldSpecifier * btn = [FieldSpecifier buttonFieldWithKey:key title:dict[key]];
        btn.shouldDisplayDisclosureIndicator = arrow;
        [m addObject:btn];
    }
    return [FieldSectionSpecifier sectionWithFields:m.copy  title:sectiontitle  description:desc];
}
+ (FieldSectionSpecifier *)buttonWithKey:(NSString *)key title:(NSString *)title arrow:(BOOL)disclosure dV:(id)value
{
    FieldSpecifier * btn = [FieldSpecifier buttonFieldWithKey:key title:title];
    btn.defaultValue = value;
    btn.shouldDisplayDisclosureIndicator = disclosure;
    return [FieldSectionSpecifier sectionWithFields:@[btn] title:nil description:nil];
}


//######################################
//######################################
#pragma mark - Sync And Storage

- (FieldSectionSpecifier *)syncAndstorage
{
    if(!_syncAndstorage)
    {
        DBAccount * acount = [[DBAccountManager sharedManager] linkedAccount];
        FieldSpecifier * mainBtn;
        NSString * syncStatus  = [[DataManager sharedInstance] syncStatus];
        mainBtn = [FieldSpecifier buttonFieldWithKey:@"syncAndStorage" title:@"Sync & Storage"];
        mainBtn.shouldDisplayDisclosureIndicator = YES;

        if(acount)
        {
            currentDropboxLinkStatus = YES;
//            mainBtn = [FieldSpecifier buttonFieldWithKey:@"syncAndStorage" title:@"Sync & Storage"];
//            mainBtn.shouldDisplayDisclosureIndicator = YES;
            BOOL isSyncing = [[DataManager sharedInstance] isSyncEnabled];
            mainBtn.defaultValue = (isSyncing) ? @"Syncing: ON" : @"Syncing: OFF";
        }
        else
        {
            currentDropboxLinkStatus = NO;
            mainBtn.defaultValue = @"Syncing: OFF";
//            mainBtn = [FieldSpecifier buttonFieldWithKey:@"dropbox.link" title:@"Link Dropbox for Sync"];
        }
        self.syncAndstorage = [FieldSectionSpecifier sectionWithFields:@[mainBtn] title:nil description:(syncStatus)?syncStatus:@"Dropbox is required for syncing"];
    }
    
    return _syncAndstorage;
}
-(void)handleDropboxLink
{
    BOOL isLinked = ([[[DBAccountManager sharedManager] linkedAccount] isLinked]) ? YES : NO;
    if(isLinked)
    {
        UIAlertView * alert = [[UIAlertView alloc] init];
        alert.title = @"Unlink Renote + Dropbox";
        alert.message = @"Are you sure you want to unlink dropbox?";
        alert.delegate = self;
        [alert addButtonWithTitle:@"Unlink"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert show];
    }
    else
    {
        [[DBAccountManager sharedManager] linkFromController:self];
    }
}

//##############################
//##############################
#pragma mark - Evernote

#pragma mark - ACCOUNTS
- (FieldSectionSpecifier *)accounts
{
    FieldSpecifier * evernote;
    FieldSpecifier * dropbox;
    
    NSString *SANDBOX_HOST = ENSessionHostSandbox;//:::
    NSString *CONSUMER_KEY = @"raheelsayeed-0034";
    NSString *CONSUMER_SECRET = @"bbdc09ed0f63bac4";
    [ENSession setSharedSessionConsumerKey:CONSUMER_KEY
                            consumerSecret:CONSUMER_SECRET
                              optionalHost:SANDBOX_HOST];
    ENSession *session = [ENSession sharedSession];
    if(session.isAuthenticated)
    {
        FieldSectionSpecifier * unlinkSec = [SettingsController buttonWithKey:@"evernote.unlink" title:@"Unlink Evernote" arrow:NO dV:[[ENSession sharedSession] userDisplayName]];
        evernote = [FieldSpecifier subsectionFieldWithSection:unlinkSec key:@"subsection.evernote"];
        evernote.shouldDisplayDisclosureIndicator = YES;
        evernote.defaultValue = [[ENSession sharedSession] userDisplayName];
        evernote.title = @"Evernote Options";
    }
    else
    {
        evernote = [FieldSpecifier buttonFieldWithKey:@"evernote.notauthenticated" title:@"Link Evernote"];
    }
    
    if([[[DBAccountManager sharedManager] linkedAccount] isLinked])
    {
        NSString * name = [[[[DBAccountManager sharedManager] linkedAccount] info] displayName];
//        FieldSectionSpecifier * unlinkSec = [SettingsController buttonWithKey:@"dropbox.unlink" title:@"Unlink Dropbox" arrow:NO dV:name];
        FieldSectionSpecifier * autoimportSection  = [self dropbox_autoimport];
//        FieldSpecifier * ff = [FieldSpecifier fieldWithType:FieldSpecifierTypeSection key:@"dropbox.options"];
//        [ff setSubsections:@[unlinkSec, autoimportSection]];
        
        dropbox = [FieldSpecifier subsectionFieldWithSections:@[autoimportSection] key:@"dropbox.options" title:@"Dropbox Options"];
        dropbox.shouldDisplayDisclosureIndicator = YES;
        dropbox.defaultValue = name;
        dropbox.title = @"Dropbox Options";
    }
    else
    {
        dropbox = [FieldSpecifier buttonFieldWithKey:@"dropbox.link" title:@"Link Dropbox"];
    }
    
    
    return [FieldSectionSpecifier sectionWithFields:@[dropbox] title:@"Accounts & Extra Options" description:nil];
}



- (FieldSectionSpecifier *)dropbox_autoimport
{
    NSUserDefaults * defaults  = [NSUserDefaults standardUserDefaults];
    BOOL enableAI = (self.values) ? [self.values[kSettings_AutoImport] boolValue] : [[NSUserDefaults standardUserDefaults] boolForKey:kSettings_AutoImport];
    
    FieldSpecifier * autoImportHelp = [FieldSpecifier buttonFieldWithKey:@"autoImportHelp" title:@"Autoimport Help"];
    FieldSpecifier * autoImportSwitch = [FieldSpecifier switchFieldWithKey:kSettings_AutoImport title:@"Enable Automatic Import" defaultValue:enableAI];
    autoImportHelp.shouldDisplayDisclosureIndicator = YES;
    FieldSectionSpecifier * section = [FieldSectionSpecifier sectionWithFields:nil title:@"Dropbox File-Autoimport" description:@"Files with a\"tag\" in their filename will imported into the App database. However, Imported notes remain independent from the synced inbuilt notes.\nAll automatic file imports have to be pushed-to-sync.\n\nEg. ATP Receptors @renote.txt"];

    if(enableAI)
    {


        
        NSString *tag = (self.values[kSettings_AutoImportFilenameTag]) ? self.values[kSettings_AutoImportFilenameTag] : [defaults objectForKey:kSettings_AutoImportFilenameTag];
        NSString *aiPath = (self.values[kSettings_AutoImportFolderPath]) ? self.values[kSettings_AutoImportFolderPath] : [defaults objectForKey:kSettings_AutoImportFolderPath];
        
        FieldSpecifier * autoImportFolderPath = [FieldSpecifier textFieldWithKey:kSettings_AutoImportFolderPath title:@"Path" defaultValue:aiPath];
        FieldSpecifier * fileNameTag = [FieldSpecifier textFieldWithKey:kSettings_AutoImportFilenameTag title:@"Filename Tag" defaultValue:tag];
        [section setFields:@[autoImportSwitch, autoImportFolderPath, fileNameTag, autoImportHelp]];
    }
    else
    {
        [section setFields:@[autoImportSwitch, autoImportHelp]];
    }
    
    return section;
}


//##############################
//##############################
#pragma mark - TextExpander
- (FieldSectionSpecifier *)textExpanderSectionEnabled:(BOOL)enabled
{
    
    
    BOOL textExpanderIsInstalled = [SMTEDelegateController isTextExpanderTouchInstalled];
    
    FieldSectionSpecifier * section_textexpander = [[FieldSectionSpecifier alloc] init];
    section_textexpander.title = @"TextExpander Touch";
    FieldSpecifier * te_status = [FieldSpecifier buttonFieldWithKey:@"te_status" title:@"Update Snippets"];
    FieldSpecifier * TE_switch = [FieldSpecifier switchFieldWithKey:@"te_switch" title:@"Use TextExpander" defaultValue:enabled];
    
    
    
    if(textExpanderIsInstalled && enabled)
    {
        NSDate *modDate;
		NSError *loadErr;
		NSUInteger snipCount;
        BOOL haveSettings = [SMTEDelegateController expansionStatusForceLoad: NO snippetCount: &snipCount loadDate: &modDate error: &loadErr];
        if(haveSettings)
        {
            te_status.title = @"Update Snippets";
            if (loadErr != nil)
            {
                section_textexpander.description = [NSString stringWithFormat: @"Error: %@", [loadErr description]];
            }
            else if (modDate != nil)
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                [formatter setTimeStyle: NSDateFormatterShortStyle];
                NSString *lastDateStr = [formatter stringFromDate: modDate];
                if (snipCount > 0)
                {	// snippets means the snippet data has been loaded
                    section_textexpander.description = [NSString stringWithFormat: @"%ld snippets modified: %@", (long)snipCount, lastDateStr];
                }
                else
                {		// snippet data is present, but has not been loaded yet
                    section_textexpander.description = [NSString stringWithFormat: @"Modified: %@", lastDateStr];
                }
                
            }
            else
            {
                section_textexpander.description = nil;
            }
        }
        else if (loadErr != nil)
        {
            te_status.title =  @"Fetch Snippets";
            section_textexpander.description = [NSString stringWithFormat: @"Error: %@", [loadErr description]];
            
        }
        else
        {
            te_status.title = @"Fetch Snippets";
            section_textexpander.description = @"(no snippets loaded yet)";
        }
        
        [section_textexpander setFields:@[TE_switch, te_status]];
        
    }
    
    else if(textExpanderIsInstalled)
    {
        te_status.title = @"Expansion Disabled";
        [section_textexpander setFields:@[TE_switch]];
        section_textexpander.description = @"Expansion Disabled";
        
    }
    else
    {
        te_status.title = @"Get TextExpander Touch";
        [section_textexpander setFields:@[te_status]];
    }
    
    return section_textexpander;
}
- (void)textExpanderSnippetsArrived:(NSNotification *)note
{
    NSError *error = nil;
    BOOL cancel = NO;
    if(![self.textExpander handleGetSnippetsURL:note.object error:&error cancelFlag:&cancel])
    {
        NSLog(@"Failed to handle URL: user canceled: %@, error: %@", cancel ? @"yes" : @"no", error);
    }
    else
    {
        if (cancel) {
            NSLog(@"User cancelled get snippets");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SMTEExpansionEnabled];
        } else if (error != nil) {
            NSLog(@"Error updating TextExpander snippets: %@", error);
        } else {
            NSLog(@"Successfully updated TextExpander Snippets");
        }
    }
    [self reloadSection:kSection_TE];
}
- (FieldSectionSpecifier *)settings
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * kCacheLinks = kSettings_CacheLinks;
    NSString * kFetchNotes = kSettings_FetchNoteLinks;
    NSString * kWifiOnly   = KSettings_UseWifiOnly;
    
    FieldSpecifier *cacheLinks = [FieldSpecifier switchFieldWithKey:kCacheLinks title:@"Cache Links" defaultValue:[[defaults objectForKey:kCacheLinks] boolValue]];
    FieldSpecifier *cacheNoteLinks = [FieldSpecifier switchFieldWithKey:kFetchNotes title:@"Fetch links within note" defaultValue:[[defaults objectForKey:kFetchNotes] boolValue]];
    FieldSpecifier *btnClearCache = [FieldSpecifier buttonFieldWithKey:@"settings.clearcache" title:@"Clear Cache"];
    BOOL wifiONly = [[defaults objectForKey:kWifiOnly] boolValue];
    FieldSpecifier *btnWifiOnly = [FieldSpecifier switchFieldWithKey:kWifiOnly title:@"Use WiFi only for links" defaultValue:wifiONly];
    FieldSpecifier *btnOpenApp  = [FieldSpecifier buttonFieldWithKey:@"showAppSettings" title:@"iOS Permissions"];
    btnOpenApp.defaultValue = @"Settings.app";
    btnOpenApp.shouldDisplayDisclosureIndicator = YES;

    return  [FieldSectionSpecifier sectionWithFields:@[btnWifiOnly,cacheLinks,cacheNoteLinks,btnClearCache,btnOpenApp] title:@"Links & Excerpts" description:@"If \"Fetch Links from note\" is switched on, RENOTE will fetch excerpts from links that exist within the note text pointing to Wikipedia, YouTube, Vimeo, Twitter-tweets, Instagram and PubMed; If \"Cache Fetched Links\" is switched on, excerpts once fetched will be saved locally and will work offline."];
    
    
}


//######################################
//######################################

#pragma mark - Field Editor Delegate

- (void)fieldEditor:(FieldEditorViewController *)editor pressedButtonWithKey:(NSString *)key
{
    
        if(matching(key, @"dropbox.link"))
        {
            [self handleDropboxLink];
        }
        else if([key isEqualToString:@"syncAndStorage"])
        {
            StorageOpsViewController * storageView = [[StorageOpsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:storageView animated:YES];
        }
        else if (matching(key, @"appearance"))
        {
            AppearanceView * a = [[AppearanceView alloc] initWithFontNames:nil];
            [a showForView:self.navigationController.view dismissCompletionBlock:^(id alertView, int buttonIndex) {
                
                NSUserDefaults * d = [NSUserDefaults standardUserDefaults];

                if(buttonIndex == 0)
                {
                    [d setObject:alertView[kSettings_EditorFontSize] forKey:kSettings_EditorFontSize];
                    [d setObject:alertView[kSettings_EditorFontName] forKey:kSettings_EditorFontName];
                    [d setObject:alertView[kSettings_EditorFontFamily] forKey:kSettings_EditorFontFamily];

                    if(alertView[kSettings_EditorFontSize])
                    {
                    }
                }
                else if(buttonIndex == 1)
                {
                    [d setObject:@(0.0) forKey:kSettings_EditorFontSize];
                    [d setObject:@"Lato" forKey:kSettings_EditorFontFamily];
                }
                [d synchronize];

            }];
        }
        else if ([key isEqualToString:@"evernote.notauthenticated"])
        {
            
            [[ENSession sharedSession] authenticateWithViewController:self
                                                   preferRegistration:NO
                                                           completion:^(NSError *authenticateError)
             {
                 if (authenticateError)
                 {
                     [self reloadSection:kSection_Accounts];
                 }
                 else
                 {
                     [self reloadSection:kSection_Accounts];
                 }
                 
             }];
            
        }
        else if ([key isEqualToString:@"evernote.authenticated"])
        {
            [self reloadSection:kSection_Accounts];
        }
        else if([key isEqualToString:@"about"])
        {
            AboutViewController * about  = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            [self.navigationController pushViewController:about animated:YES];
        }
        
        else if(matching(key, @"urlactions"))
        {
            CustomActionsController * actions = [[CustomActionsController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:actions animated:YES];
        }
        else if (matching(key,@"te_status"))
        {
            if ([SMTEDelegateController isTextExpanderTouchInstalled])
            {
                BOOL useTextExpander = [[NSUserDefaults standardUserDefaults] boolForKey:SMTEExpansionEnabled];
                if (!useTextExpander)
                    return;
                
                if (self.textExpander == nil)
                {
                    // Lazy load of TextExpander
                    self.textExpander = [[SMTEDelegateController alloc] init];
                    self.textExpander.clientAppName = @"Renote";
                    self.textExpander.getSnippetsScheme = @"renote-get-snippets-xc";
                }
                [self.textExpander getSnippets];
                
            } else {
                // Note: This only works on the device, not in the Simulator, as the Simulator does
                // not include the App Store app
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://smilesoftware.com/cgi-bin/redirect.pl?product=tetouch&cmd=itunes"]];
            }
        }
        else if (matching(key, @"autoImportHelp"))
        {
            [self showHelp:@"Autoimport_Dropbox_help"];

        }else if(matching(key, @"syncHelp"))
        {
            [self showHelp:@"Sync_And_Backup"];

        }else if(matching(key, @"basicNavigation"))
        {
            DemoViewController * d = [[DemoViewController alloc] init];
            [self.navigationController presentViewController:d animated:YES completion:nil];
            
        }else if(matching(key, @"howIUse"))
        {
            [self showHelp:@"How I Used This App"];
        }
    else if (matching(key, @"Excerpts_Fetching"))
    {
        [self showHelp:key];
    }
    
    else if(matching(key, @"Tag_Selection"))
    {
        [self showHelp:key];
    }
    
    else if(matching(key, @"settings.clearcache"))
    {
        MRModalAlertView * alert = [[MRModalAlertView alloc] initWithTitle:@"Clear Cache" mesage:@"Clearing cache will delete all links that were downloaded and saved. Do you want to continue?"];
        [alert showForView:self.navigationController.view selectorBlock:^(BOOL result)
        {
            if(result) {
                [UIImageView clearImageCache];
                [[DataManager sharedInstance] deleteAllObjectsForEntityName:@[@"CachedLinkData"] useMainContextForSync:NO];
            }
        }];
    }
    else if(matching(key, @"showAppSettings"))
    {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    else if(matching(key, @"debugdatastore"))
    {
        DebugDatastoreController * c = [[DebugDatastoreController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:c animated:YES];
    }
}
- (void)showHelp:(NSString *)fileName
{
    SVWebViewController * web = (SVWebViewController * )[ActionMethods webControllerForMarkdownFilename:fileName cssFileName:@"markdown-whitebg" varReplacements:@{@"[[editorFontName]]": @"sans-serif"}];
    web.showHTMLActionButton = NO;
    [self.navigationController pushViewController:web animated:YES];

}

- (void)fieldEditor:(FieldEditorViewController *)editor didFinishEditingWithValues:(NSDictionary *)returnValues
{

    if(matching(editor.editorIdentifier, @"main"))
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSLog(@"editor Iden=%@", editor.editorIdentifier);
//        NSLog(@"returnValues = %@", returnValues.description);
        
        if(editor.hasChanges)
        {
            
            if(returnValues[@"te_switch"])
            {
//                BOOL newIsEnabled  = [returnValues[@"te_switch"] boolValue];
//                [SMTEDelegateController setExpansionEnabled:newIsEnabled];
//                [defaults setBool: newIsEnabled forKey: SMTEExpansionEnabled];
            }
            if(returnValues[kSettings_AutoImport])
            {
                BOOL enableAI = [returnValues[kSettings_AutoImport] boolValue];
                if(enableAI)
                {
//                    NSLog(@"enabledAI");
                    [defaults setObject:returnValues[kSettings_AutoImportFilenameTag] forKey:kSettings_AutoImportFilenameTag];
                    [defaults setObject:returnValues[kSettings_AutoImportFolderPath] forKey:kSettings_AutoImportFolderPath];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        if(![[DataManager sharedInstance] startDbxFolderSync])
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Cannot enable Autoimport" message:@"Please verify correct folder path from the dropbox root and a name tag" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [alert show];
                            });
                        }
                    });
                }
                else
                {
//                    NSLog(@"disabledAI");
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        [[DataManager sharedInstance] stopDbxFolderSync];
                    });
                }
            }
            
            [defaults setObject:returnValues[kSettings_CacheLinks] forKey:kSettings_CacheLinks];
            [defaults setObject:returnValues[KSettings_UseWifiOnly] forKey:KSettings_UseWifiOnly];
            [defaults setObject:returnValues[kSettings_FetchNoteLinks] forKey:kSettings_FetchNoteLinks];
            [defaults synchronize];

        }
        
        [self close];
    }
    else
    {
        //if(editor.hasChanges) [self reloadSection:kSection_Accounts editor:self];
    }
}

- (void)fieldEditor:(FieldEditorViewController *)editor switchChangedWithKey:(NSString *)key withValue:(id)value
{
    
    if([key isEqualToString:@"te_switch"])
    {
        [self reloadSection:kSection_TE];
    }
    else if([key isEqualToString:kSettings_AutoImport])
    {
        self.hasChanges = YES;
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        [self.values setObject:value forKey:key];
        [self reloadSection:0 editor:editor];
        [self reloadSection:kSection_Accounts editor:self];
    }
}

//##############################
//##############################

#pragma mark - SUPPORT FUNC
- (void)reloadSection:(NSUInteger)sectionIndex
{
    [self reloadSection:sectionIndex editor:self];
}
- (void)reloadSection:(NSUInteger)sectionIndex editor:(FieldEditorViewController *)editor
{
    NSMutableArray * m  = [editor.fieldSections mutableCopy];
    FieldSectionSpecifier * section;

    if(matching(editor.editorIdentifier, self.editorIdentifier))
    {
        switch (sectionIndex) {
            case 0:
            {
                _syncAndstorage = nil;
                section = self.syncAndstorage;
            }
                break;
            case kSection_TE:
            {
                BOOL innerChange = [self.values[@"te_switch"] boolValue];
                [SMTEDelegateController setExpansionEnabled:innerChange];
                [[NSUserDefaults standardUserDefaults] setBool:innerChange forKey:SMTEExpansionEnabled];
                section = [self textExpanderSectionEnabled:innerChange];
            }
                break;
            case kSection_Accounts:
                section = [self accounts];
                break;
            default:
                break;
            }
    }
    else
    {
        switch (sectionIndex) {
            case 0:
                section = [self dropbox_autoimport];
                break;
                
            default:
                break;
        }
    }
    
    
    if(nil == section) return;
    
    m[sectionIndex] = section;
    
    
    
    
    [editor setSections:[m copy]];
    
//    NSLog(@"%@", self.values);
//    NSLog(@"%@", editor.values);
    
//    NSLog(@"%@", self.fieldSections);
    
    
    m = nil;
    
    [editor.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}

bool matching(NSString *key, NSString *value)
{
    return [key isEqualToString:value];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        
    }
}




@end
