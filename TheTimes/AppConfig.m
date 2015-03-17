//
//  AppConfig.m
//  The Sun
//
//  Created by Daniel on 07/05/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import "AppConfig.h"

@implementation AppConfig

static AppConfig *sharedInstance;

// Singleton so we only need to load the values from the config file once.
+ (AppConfig *) sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[AppConfig alloc] init];
    }
    
    return sharedInstance;
}

- (id) init
{
    if (self = [super init])
    {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *configFile = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CONFIG_FILE"];
        NSString *customPlistPath = [path stringByAppendingPathComponent:configFile];
        self.values = [NSDictionary dictionaryWithContentsOfFile:customPlistPath];
    }
    
    return self;
}

- (BOOL) getBoolean:(NSString *)key defaultValue:(BOOL)defaultValue
{
    if ([_values objectForKey:key] != nil)
    {
        return [[_values objectForKey:key] boolValue];
    }
    
    return defaultValue;
}

- (NSString *) getString:(NSString *)key defaultValue:(NSString *)defaultValue
{
    if ([_values objectForKey:key] != nil)
    {
        return [_values objectForKey:key];
    }
    
    return defaultValue;
}

- (NSString *) getBaseUrl
{
    return [self getString:@"BASE_URL" defaultValue:@"http://thecoapperative.com/times/config.xml"];
    
    //@"http://config.thetimes.co.uk/TNL/irishsundaytimes/IOS/prod/1.0/config.xml"];
}

- (BOOL) isTestAccount
{
    return [self getBoolean:@"PAYMENT_IS_TEST_ACCOUNT" defaultValue:NO];
}

- (BOOL) isPaymentAllowAllFree
{
    return [self getBoolean:@"PAYMENT_ALLOW_ALL_FREE" defaultValue:NO];
}

- (BOOL) isPaymentAlwaysSubscribed
{
    return [self getBoolean:@"PAYMENT_IS_ALWAYS_SUBSCRIBED" defaultValue:NO];
}

- (BOOL) isAllowUrlChanger
{
    return [self getBoolean:@"ALLOW_URL_CHANGER" defaultValue:NO];
}

- (BOOL) isTestingTracking
{
    return [self getBoolean:@"TESTING_TRACKING" defaultValue:NO];
}

- (BOOL) isTrackingUseOmnitureV4
{
    return [self getBoolean:@"TRACKING_USE_OMNITURE_V4" defaultValue:YES];
}

- (BOOL) isTrackingUseTealium
{
    return [self getBoolean:@"TRACKING_USE_TEALIUM" defaultValue:YES];
}

- (BOOL) isTrackingUseLocalytics
{
    return [self getBoolean:@"TRACKING_USE_LOCALYTICS" defaultValue:YES];
}

- (NSString *) getLocalyticsAppKey
{
    return [self getString:@"LOCALYTICS_APP_KEY" defaultValue:@"79b4bd437c70389f1f40968-f6063120-c637-11e3-1d88-004a77f8b47f"];
}

- (NSString *) getTealiumAccountName
{
    return [self getString:@"TEALIUM_ACCOUNT_NAME" defaultValue:@"newsinternational"];
}

- (NSString *) getTealiumProfileName
{
    return [self getString:@"TEALIUM_PROFILE_NAME" defaultValue:@"thetimes.ios.phone.lite"];
}

- (NSString *) getTealiumTarget
{
    return [self getString:@"TEALIUM_TARGET" defaultValue:@"prod"];
}

- (NSString *) getCrashlyticsKey
{
    return [self getString:@"CRASHLYTICS_KEY" defaultValue:@"f274dd3aa2fd1ef189f517c06db4a6ba6ab7bf33"];
}

- (NSString *) getOoyalaPlayerDomain
{
    return [self getString:@"OOYALA_PLAYER_DOMAIN" defaultValue:@"http://www.ooyala.com"];
}

- (NSString *) getOoyalaPCode
{
    return [self getString:@"OOYALA_PCODE" defaultValue:@""];
}

- (NSString *) subscriptionProductId
{
    return [self getString:@"SUBSCRIPTION_PRODUCT_ID" defaultValue:@"SP12"];
}

- (NSString *) getVerifyUrl
{
    return [self getString:@"VERIFY_URL" defaultValue:@"https://buy.itunes.apple.com/verifyReceipt"];
}

- (NSString *) getAirshipDevKey
{
    return [self getString:@"AIRSHIP_DEV_KEY" defaultValue:@"WttMRaIAQ3eSvnbmpkJoiQ"];
}

- (NSString *) getAirshipDevSecret
{
    return [self getString:@"AIRSHIP_DEV_SECRET" defaultValue:@"IXJvnDN6R6a42Vjt4eqpUA"];
}

- (NSString *) getAirshipProductionKey
{
    return [self getString:@"AIRSHIP_PRODUCTION_KEY" defaultValue:@"8qtNk2SjTVaD8D8VM9-I6g"];
}

- (NSString *) getAirshipProductionSecret
{
    return [self getString:@"AIRSHIP_PRODUCTION_SECRET" defaultValue:@"2-hSWXB1QOmmGBP-ILpa6Q"];
}

- (BOOL) isAirshipInProduction
{
    return [self getBoolean:@"AIRSHIP_IN_PRODUCTION" defaultValue:NO];
}

@end
