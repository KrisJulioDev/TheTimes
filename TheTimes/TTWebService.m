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

static TTWebService *sharedInstance = nil;

@implementation TTWebService

static NSDateFormatter *dateFormatter;

// Singleton style method to retrieve shared instance.
+ (TTWebService*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[TTWebService alloc] init];
        
        if (dateFormatter == nil)
        {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd"];
        }
    }
    return sharedInstance;
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
