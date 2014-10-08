//
//  WebService.m
//  News Internationaal
//
//  Created by Daniel Wichett on 12/02/2010.
//  Copyright 2010 News International. All rights reserved.
//

#import "WebService.h"
#import "XMLParser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "XMLMapParser.h"
#import "CookieService.h"
#import "NSString+MD5Addition.h"
#import "ErrorObject.h"
#import "JSONKit.h"
#import "Edition.h"
#import "NSString+UAObfuscatedString.h"
#import "UserInterfaceUtils.h"
#import "AppConfig.h"
#import "EditUrlViewController.h"
#import "TheSunAppDelegate.h"
#import "SubscriptionHandler.h"

@implementation WebService

static NSDateFormatter *dateFormatter;

// Singleton style method to retrieve shared instance.
+ (WebService*) sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static WebService *_sharedObject = nil;
    
    dispatch_once(&pred, ^{
        _sharedObject = [[WebService alloc] init];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
    });
    
    return _sharedObject;
}

// Retrieve the Config object from the XML file at the base URL.
- (Config *) getConfig
{
    return [self getResults:[WebService getUrl]].config;
}

// Retrieve the editions list, from the JSON specified at the URL in the config file.
- (NSMutableArray *) getEditions
{
    NSMutableArray *editions = nil;
    TheSunAppDelegate *appDelegate = (TheSunAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.config != nil)
    {
        Feed *feed = [appDelegate.config getFeed];
        if (feed != nil)
        {
            NSDictionary *results = [self getJSONResult:feed.public_url];
            
            if (results != nil)
            {
                editions = [[NSMutableArray alloc] init];
                NSArray *editionsArray = [results objectForKey:@"availablePapers"];
                for (NSDictionary *editionDict in editionsArray)
                {
                    Edition *edition = [[Edition alloc] init];
                    edition.paperUrl = [editionDict objectForKey:@"paperUrl"];
                    edition.paperThumb = [editionDict objectForKey:@"paperThumb"];
                    
                    edition.dateString = [editionDict objectForKey:@"paperDate"];
                    
                    edition.type = [editionDict objectForKey:@"type"];
                    edition.region = [[NSUserDefaults standardUserDefaults] objectForKey:PAPER_REGION_KEY];
                    
                    edition.date = [dateFormatter dateFromString:edition.dateString];
                    [editions insertObject:edition atIndex:0];
                }
            }
        }
    }
    
    return editions;
}

// Will connect to the ACS service (when it is built).
- (NSMutableDictionary *) loginWithEmail:(NSString *)email password:(NSString *)password
{
    return nil;
}

// Verify subscriptions by retrieving them from Apple
// ignore the deprecated transactionReceipt warnings to keep iOS 6 compatibility
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (NSMutableDictionary *) verifySubscription:(SKPaymentTransaction *)transaction subscriptionIds:(NSArray *)subscriptionIds
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1 && transaction.transactionReceipt == nil)
    {
        return nil;
    }
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    NSString *key;
    if ([[AppConfig sharedInstance] isTestAccount])
    {
        //test account
        //TODO: Put a test account key here if we get one?
        key = @"";
    }
    else
    {
        //live account, this chaining obfuscates the value when compiled.
        key = @""._9._1._1.b._8.f._1._6._0._4._8._1._4._7.e._1.a._6._9.b.b.e._5.e._2.c._3._9.d.e._8._7;
    }
    
    NSData *receipt = [self appStoreReceiptForPaymentTransaction:transaction];
    NSString *receiptDataAsString = [receipt base64EncodedStringWithOptions:0];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[[AppConfig sharedInstance] getVerifyUrl]]];
    
    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:receiptDataAsString, @"receipt-data", key, @"password", nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    
    [request appendPostData: jsonData];
    [request setRequestMethod:@"POST"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error)
    {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:[request responseData]
                              options:kNilOptions
                              error:nil];
        
        NSString *receiptStatus = [json valueForKey:@"status"];
        if(receiptStatus == nil)
        {
            //invalid
        }
        else{
            
            int receiptCheck = [receiptStatus intValue];
            if( receiptCheck == 0)
            {
                NSMutableArray *subscriptions = [self getSubscriptions:json subscriptionId:subscriptionIds];
                if (subscriptions != nil)
                {
                    [results setObject:subscriptions forKey:@"subscriptions"];
                }
            }
            else
            {
                //invalid
            }
        }
    }
    else
    {
        //invalid
    }
    
    return results;
}

// Extract subscriptions from the Apple JSON data (which has quite a variable format!)
- (NSMutableArray *) getSubscriptions:(NSDictionary *)json subscriptionId:(NSArray *)subscriptionIds
{
    NSMutableArray *subscriptions = [[NSMutableArray alloc] init];
    NSDictionary *receipt = [json objectForKey:@"receipt"];
    
    id latestReceiptInfo = [json objectForKey:@"latest_receipt_info"];
    if (latestReceiptInfo != nil && [latestReceiptInfo isKindOfClass:[NSDictionary class]])
    {
        if (latestReceiptInfo != nil)
        {
            if ([subscriptionIds containsObject:[latestReceiptInfo objectForKey:@"product_id"]])
            {
                [self addSubscriptionFromDictionary:latestReceiptInfo toArray:subscriptions];
            }
        }
    }
    else if (latestReceiptInfo != nil && [latestReceiptInfo isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *latestReceipt in latestReceiptInfo)
        {
            if (latestReceipt != nil)
            {
                if ([subscriptionIds containsObject:[latestReceipt objectForKey:@"product_id"]])
                {
                    [self addSubscriptionFromDictionary:latestReceipt toArray:subscriptions];
                }
            }
        }
    }
    
    if (receipt != nil)
    {
        if ([subscriptionIds containsObject:[receipt objectForKey:@"product_id"]])
        {
            [self addSubscriptionFromDictionary:receipt toArray:subscriptions];
        }
    }
    
    return subscriptions;
}

// Add a subscription to our list, after checking the dates are valid.
- (void) addSubscriptionFromDictionary:(NSDictionary *)dictionary toArray:(NSMutableArray *)subscriptions
{
    long long expiresEpoch = [self getExpires:dictionary];
    long long purchasedEpoch = [self getPurchased:dictionary];
    if (expiresEpoch > 0 && purchasedEpoch < LONG_LONG_MAX)
    {
        if (expiresEpoch > 1000000000000)
        {
            //ms!
            expiresEpoch = expiresEpoch / 1000;
        }
        if (purchasedEpoch > 1000000000000)
        {
            //ms!
            purchasedEpoch = purchasedEpoch / 1000;
        }
        
        NSDate *expiresDate = [NSDate dateWithTimeIntervalSince1970:expiresEpoch];
        NSDate *purchasedDate = [NSDate dateWithTimeIntervalSince1970:purchasedEpoch];
        Subscription *subscription = [[Subscription alloc] init];
        subscription.startDate = purchasedDate;
        subscription.endDate = expiresDate;
        [subscriptions addObject:subscription];
    }
}

// Get expired date from Apple data (based on their various keys).
- (long long) getExpires:(NSDictionary *)dictionary
{
    if ([dictionary objectForKey:@"expires_date_ms"] != nil)
    {
        return [[dictionary objectForKey:@"expires_date_ms"] longLongValue];
    }
    
    else if ([dictionary objectForKey:@"expires_date"] != nil)
    {
        return [[dictionary objectForKey:@"expires_date"] longLongValue];
    }
    
    return -1;
}

// Get purchased date from Apple data (based on their various keys).
- (long long) getPurchased:(NSDictionary *)dictionary
{
    long long result = 0;
    if ([dictionary objectForKey:@"purchase_date_ms"] != nil)
    {
        result = [[dictionary objectForKey:@"purchase_date_ms"] longLongValue];
    }
    
    else if ([dictionary objectForKey:@"purchase_date"] != nil)
    {
        result = [[dictionary objectForKey:@"purchase_date"] longLongValue];
    }
    
    return result > 0 ? result : LONG_LONG_MAX;
}

- (NSData *)appStoreReceiptForPaymentTransaction:(SKPaymentTransaction *)transaction
{
    NSData *receiptData = nil;
    
    if (transaction.transactionReceipt == nil)
    {
        NSURL *receiptFileURL = [[NSBundle mainBundle] appStoreReceiptURL];
        receiptData = [NSData dataWithContentsOfURL:receiptFileURL];
    }
    else
    {
        receiptData = transaction.transactionReceipt;
    }
    
    return receiptData;
}

- (BOOL) checkLoggedIn
{
    BOOL loggedIn = YES;
    TheSunAppDelegate *appDelegate = (TheSunAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.config != nil && appDelegate.user != nil && !appDelegate.user.isAppleAccount)
    {
        Feed *feed = [appDelegate.config getFeed];
        if (feed != nil)
        {
            [self setupAuthentication];
            
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:feed.url]];
            [request startSynchronous];
            int status = request.responseStatusCode;
            NSString *result = request.responseString;
            
            if ((status == 200 && result != nil && ![result hasPrefix:@"{\"availablePapers\""]) || status == 302)
            {
                loggedIn = NO;
            }
        }
    }
    
    return loggedIn;
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

// Set up authentication with the cookies to make calls to the authenticated service.
- (void) setupAuthentication
{
    NSString *sacs_ngn = [User getKeychainSacs];
    NSString *acs_ngn = [User getKeychainAcs];
    NSString *iam_tgt = [User getKeychainIam];
    NSString *livefyre_token = [User getKeychainLivefyre];
    
    TheSunAppDelegate *appDelegate = (TheSunAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *domain = [appDelegate.config.hostURL stringByReplacingOccurrencesOfString:@"login" withString:@""];

    if (domain != nil && appDelegate.user != nil && !appDelegate.user.isAppleAccount)
    {
        [CookieService setCookieWithName:@"sacs_ngn" value:sacs_ngn site:domain];
        [CookieService setCookieWithName:@"acs_ngn" value:acs_ngn site:domain];
        [CookieService setCookieWithName:@"iam_tgt" value:iam_tgt site:domain];
        [CookieService setCookieWithName:@"livefyre_token" value:livefyre_token site:domain];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
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

- (ErrorObject *)getArrayResultsErrorObject:(NSString *)urlString
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
        
        ErrorObject *errorObject = [[ErrorObject alloc] init];
        errorObject.object = parser.elements;
        errorObject.errorText = parser.errorText;
        return errorObject;
    }
    return nil;
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

- (NSMutableArray *)getArrayResults:(NSString *)urlString
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
        
        return parser.elements;
    }
}

- (ErrorObject *)getErrorObjectArray:(NSString *)urlString
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
        
        ErrorObject *errorObject = [[ErrorObject alloc] init];
        errorObject.object = parser.elements;
        errorObject.errorText = parser.errorText;
        return errorObject;
    }
}

- (NSMutableDictionary *) getMapResults:(NSString *)url
{
	NSError    *error = nil;
    NSString *results = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
    
    if (error != nil || results == nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowError" object:@"Connection error, please try again when you have better signal."];
        return nil;
    }
    else
    {
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[results dataUsingEncoding:NSUTF8StringEncoding]];
        
        XMLMapParser *parser = [[XMLMapParser alloc] init];
        [xmlParser setDelegate:parser];
        [xmlParser parse];
        
        return parser.dict;
    }
}

- (BOOL) getBoolResults:(NSString *)url
{
	NSError    *error = nil;
    NSString *results = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
    
    if (error != nil || results == nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowError" object:@"Connection error, please try again when you have better signal."];
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
