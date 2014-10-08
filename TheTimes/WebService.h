//
//  WebService.h
//  News International
//
//  Created by Daniel Wichett on 12/02/2010.
//  Copyright 2010 News International. All rights reserved.
//
//  A class to control external connections and return parsed objects.

#import <Foundation/Foundation.h>
#import "XMLParser.h"
#import "Config.h"
#import <StoreKit/StoreKit.h>

@interface WebService : NSObject
{

}

+ (WebService*) sharedInstance;

- (Config *) getConfig;
- (NSMutableArray *) getEditions;
- (NSMutableDictionary *) loginWithEmail:(NSString *)email password:(NSString *)password;
- (BOOL) checkLoggedIn;

- (void) setupAuthentication;

- (BOOL) getBoolResults:(NSString *)url;
- (NSMutableArray *)getArrayResults:(NSString *)urlString;
- (NSMutableDictionary *) getMapResults:(NSString *)url;
- (XMLParser *) getResults:(NSString *)urlString;
- (NSMutableDictionary *) verifySubscription:(SKPaymentTransaction *)transaction subscriptionIds:(NSArray *)subscriptionIds;

+ (NSString *) getUrl;

@end
