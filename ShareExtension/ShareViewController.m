//
//  ShareViewController.m
//  ShareExtension
//
//  Created by M Raheel Sayeed on 07/01/15.
//  Copyright (c) 2015 Mohammed Raheel Sayeed. All rights reserved.
//

#import "ShareViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {

    return YES;
}

- (void)appendTextToTextView:(NSString *)text
{
    if(!self.textView.text)
    {
        [self.textView setText:text];
    }
    else
        [self.textView setText:[self.textView.text stringByAppendingFormat:@"\n%@", text]];
}

- (void)presentationAnimationDidFinish
{
    self.title = @"RENOTE";
    
 
    
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSItemProvider *itemProvider = item.attachments.firstObject;
    
    if([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList])
    {
    
    [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList options:nil completionHandler:^(NSDictionary *item, NSError *error) {
        NSDictionary *results = (NSDictionary *)item;
        NSString *title = [[results objectForKey:NSExtensionJavaScriptPreprocessingResultsKey] objectForKey:@"title"];
        NSString *selection = [[results objectForKey:NSExtensionJavaScriptPreprocessingResultsKey] objectForKey:@"selection"];
        NSString *urlstr = [[results objectForKey:NSExtensionJavaScriptPreprocessingResultsKey] objectForKey:@"URL"];
        NSString *compiled = [NSString stringWithFormat:@"%@\n\n%@\n\n%@", title, urlstr, selection];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.textView setText:compiled];

        });

    }];
    }
    
    
    if([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL])
    {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
            if(error) return;

            NSError * error1 = nil;
            NSString * string;
            if(url.isFileURL)
            string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error1];
            else
                string = url.absoluteString;

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self appendTextToTextView:string];
                
            });
            
        }];
    }
    
    
    
}

- (void)shareText:(NSString *)text
{
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSUserDefaults * defaults  = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.renoteapp.ios.shared"];
    NSMutableArray * m = [[defaults arrayForKey:@"shared_Notes"] mutableCopy];
    if(!m) m  = [NSMutableArray new];
    [m addObject:text];
    [defaults setObject:[m copy] forKey:@"shared_Notes"];
    [defaults synchronize];
}

- (void)didSelectPost {
    
    [self shareText:self.contentText];
    [self.extensionContext completeRequestReturningItems:@[]
                                       completionHandler:nil];

}

- (NSArray *)configurationItems {
    
    return @[];

}
- (UIView *)loadPreviewView
{
    return nil;
}



@end
