//
//  TTWebService.m
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "TTWebService.h"
#import "Constants.h"
#import "Config.h"
#import "XMLParser.h"
#import "AppConfig.h"
#import "TheTimesAppDelegate.h"
#import "JSONKit.h"
#import "Feed.h"
#import "Constants.h"
#import "Edition.h"

@implementation TTWebService

TheTimesAppDelegate *appDelegate;

static NSDateFormatter *dateFormatter;

+ (instancetype) sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [[self alloc] init];
        
        if (dateFormatter == nil)
        {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd"];
        }
    });
    return sharedInstance;
}
- (id) init
{
    appDelegate = (TheTimesAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    return [super init];
}

// Retrieve the Config object from the XML file at the base URL.
- (Config *) getConfig
{
    return [self getResults:[TTWebService getUrl]].config;
}

- (XMLParser *) getResults:(NSString *)urlString
{
	NSError    *error = nil;
    NSString *results = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];
    
    if (error != nil || results == nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowError" object:@"Connection error, please try again when you have better signal."];
        return nil;
    }
    else
    {
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[results dataUsingEncoding:NSUTF8StringEncoding]];
        
        XMLParser *parser = [[XMLParser alloc] init];
        [xmlParser setDelegate:parser];
        [xmlParser parse];
        
        return parser;
    }
    
    return nil;
}

- (NSMutableArray*) getEditions
{
    NSMutableArray *editions = nil;
 
        if (_paper_editions != nil)
        {
            editions = [[NSMutableArray alloc] init];
            
            for (NSDictionary *editionDict in _paper_editions)
            {
                Edition *edition = [[Edition alloc] init];
                edition.paperUrl = [editionDict objectForKey:@"paperUrl"];
                edition.paperThumb = [editionDict objectForKey:@"paperThumb"];
                
                edition.dateString = [editionDict objectForKey:@"paperDate"];
                edition.type = [editionDict objectForKey:@"type"];
                edition.region = [[NSUserDefaults standardUserDefaults] objectForKey:PAPER_REGION_KEY];
                
                edition.date = [dateFormatter dateFromString:[editionDict objectForKey:@"paperDate"]];
                [editions insertObject:edition atIndex:0];
            }
        }
    
    return editions;
}

- (id) getJSONResult:(NSString *)urlString
{
    NSError    *error = nil;
    NSString *results = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];
    
    id resultsObject = nil;
    if (error != nil || results == nil)
    {
        return nil;
    }
    else
    {
        resultsObject = [[results dataUsingEncoding:NSUTF8StringEncoding] objectFromJSONData];
    }
    
    return resultsObject;
}

// Get the URL to use, based on the app config, but potentially overridden by the user.
+ (NSString *) getUrl
{
    NSString *overriddenUrl = [[NSUserDefaults standardUserDefaults] objectForKey:OVERRIDDEN_URL_KEY];
    if (overriddenUrl != nil)
    {
        return overriddenUrl;
    }
    
    return [[AppConfig sharedInstance] getBaseUrl];
}

@end
