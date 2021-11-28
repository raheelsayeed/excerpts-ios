//
//  ActionMethods.m
//   Renote
//
//  Created by M Raheel Sayeed on 03/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "ActionMethods.h"
#import "SVWebViewController.h"
#include "html.h"
#include "buffer.h"
#include "document.h"
#import <StoreKit/StoreKit.h>
#import <SafariServices/SafariServices.h>
#import "NSString+QSKit.h"
#import <MobileCoreServices/MobileCoreServices.h>



@implementation ActionMethods
enum renderer_type {
    RENDERER_HTML,
    RENDERER_HTML_TOC
};
struct option_data {
    char *basename;
    int done;
    
    /* time reporting */
    int show_time;
    
    /* I/O */
    size_t iunit;
    size_t ounit;
    const char *filename;
    
    /* renderer */
    enum renderer_type renderer;
    int toc_level;
    hoedown_html_flags html_flags;
    
    /* parsing */
    hoedown_extensions extensions;
    size_t max_nesting;
};
#define DEF_IUNIT 1024
#define DEF_OUNIT 64
#define DEF_MAX_NESTING 16

+ (NSString *)parseMarkdownToHTML:(NSString *)markdown
{
    
    struct option_data data;
    /* Parse options */
    data.done = 0;
    data.show_time = 0;
    data.iunit = DEF_IUNIT;
    data.ounit = DEF_OUNIT;
    data.filename = NULL;
    data.renderer = RENDERER_HTML;
    data.toc_level = 0;
    data.html_flags = 0;
    data.extensions = 0;
    data.max_nesting = DEF_MAX_NESTING;
    
    
    
    const char * bytes = [markdown UTF8String];
    hoedown_buffer *input;
    hoedown_buffer *output;
    NSUInteger length = [markdown lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    
    input = hoedown_buffer_new(length);
    hoedown_buffer_grow(input, length);
    memcpy(input->data, bytes, length);
    input->size = length;
    
    output = hoedown_buffer_new(64);
    hoedown_document *document;
    hoedown_renderer *renderer = NULL;
    renderer = hoedown_html_renderer_new(data.html_flags, data.toc_level);
    
    
    document = hoedown_document_new(renderer, data.extensions, data.max_nesting);
    
    hoedown_document_render(document, output, input->data, input->size);
    hoedown_document_free(document);
    
    
    NSString *raw = [[NSString alloc] initWithBytes:output->data length:output->size - 1 encoding:NSUTF8StringEncoding];
    
    hoedown_buffer_free(input);
    hoedown_buffer_free(output);
    
    return raw;

    
    
}

+ (UIViewController *)webControllerForMarkdownFilename:(NSString *)resourceFileName cssFileName:(NSString *)cssFileName varReplacements:(NSDictionary *)replacements
{
    NSString* path = [[NSBundle mainBundle] pathForResource:resourceFileName
                                                     ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];

    NSString * shinyNewHTML = [[self class] parseMarkdownToHTML:content];
    
    NSString * finalString;
    
    
    if(cssFileName)
    {
       NSString *csspath = [[NSBundle mainBundle] pathForResource:cssFileName ofType:@"css"];
       NSString *style = [NSString stringWithContentsOfFile:csspath encoding:NSUTF8StringEncoding error:nil];
       finalString  = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\"width=device-width; minimum-scale=1.0; maximum-scale=1.0; user-scalable=no\"><style>%@</style>%@", style, shinyNewHTML];
    }
    else
    {
        finalString  = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\"width=device-width; minimum-scale=1.0; maximum-scale=1.0; user-scalable=no\">%@", shinyNewHTML];

    }
    
    if(replacements)
    {
        for(NSString * variable in replacements.allKeys)
        {
            finalString = [finalString stringByReplacingOccurrencesOfString:variable withString:replacements[variable]];
        }
    }
    
    return [[SVWebViewController alloc] initWithHtml:finalString];
}


+ (BOOL)action_AddURLTOReadingList:(NSURL *)url
{
    SSReadingList * readList = [SSReadingList defaultReadingList];
    NSError * error;
    BOOL status =[readList addReadingListItemWithURL:url title:nil previewText:nil error:&error];
    if(!status)
    {
//        DLog(@"%@", error.description);
        return NO;
    }
    return YES;
}

+ (void)addToClipboard:(id)object
{
    NSMutableArray * mutableArray = [NSMutableArray new];

        if([object isKindOfClass:[NSString class]])
        {
            [mutableArray addObject:@{(NSString *)kUTTypeText: object}];
        }
        else if([object isKindOfClass:[UIImage class]])
        {
            [mutableArray addObject:@{(NSString *)kUTTypeImage: object}];
            
        }
        else if ([object isKindOfClass:[NSURL class]])
        {
            [mutableArray addObject:@{(NSString *)kUTTypeURL: object}];
        }
    
    [[UIPasteboard generalPasteboard] setItems:[mutableArray copy]];
}

+ (NSString *)lastObjectFromPasteboard
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if(pasteboard.string)
    {
        return pasteboard.string;
    }
    return nil;
}

+ (NSArray *)linksFromString:(NSString *)string
{
    return [string qs_links];
}

+ (NSString *)linksForString:(NSString *)string;
{
    NSArray * a = [string qs_links];
    if(a)
    {
        return [a componentsJoinedByString:@"\n"];
    }
    return nil;
}



+ (UINavigationController *)reorderParagraphsInText:(NSString *)text
{
    ReorderViewController * r = [[ReorderViewController alloc] initWithInputObject:text];
    UINavigationController * n = [[UINavigationController alloc] initWithRootViewController:r];
    
    
    return n;
}

+ (void)uploadFileAtPath:(NSString *)path data:(id)data
{
    [EXOperationQueue uploadOperationToFilePath:path writeData:data service:EX_DROPBOX];
}

@end
