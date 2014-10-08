//
//  CookieService.m
//  BeerExplorer
//
//  Created by Daniel Wichett on 04/03/2011.
//  Copyright 2011 News International. All rights reserved.
//

#import "CookieService.h"

@implementation CookieService

+ (BOOL) deleteCookie:(NSString *)cookieName
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];    
    
    for (NSHTTPCookie *cookie in [storage cookies])
    {
        if ([cookie.name isEqualToString:cookieName])
        {
            [storage deleteCookie:cookie];
            return YES;
        }
    }
    
    return NO;
}

+ (void) deleteCookiesForDomain:(NSString *)domain
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [storage cookies])
    {
        if ([cookie.domain isEqualToString:domain])
        {
            [storage deleteCookie:cookie];
        }
    }
}

+ (void) setCookieWithName:(NSString *)name value:(NSString *)value site:(NSString *)site
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];    
    [storage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                site, NSHTTPCookieDomain,
                                name, NSHTTPCookieName,
                                value, NSHTTPCookieValue,
                                @"/", NSHTTPCookiePath,
                                nil];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:[NSHTTPCookie cookieWithProperties:properties]];        
}

@end
