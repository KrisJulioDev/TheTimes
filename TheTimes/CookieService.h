//
//  CookieService.h
//  BeerExplorer
//
//  Created by Daniel Wichett on 04/03/2011.
//  Copyright 2011 News International. All rights reserved.
//
//  Utility to set and delete cookies for future web requests.

#import <Foundation/Foundation.h>


@interface CookieService : NSObject 
{

}

+ (void) deleteCookiesForDomain:(NSString *)domain;
+ (BOOL) deleteCookie:(NSString *)cookieName;
+ (void) setCookieWithName:(NSString *)name value:(NSString *)value site:(NSString *)site;

@end
